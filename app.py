"""OSU P-card audit assistant — Part IV of the Analytics Mindset P-card case.

Two tabs for auditors:
  1. Ask the database — a question in plain English becomes one read-only SQLite query,
     written by Gemini, checked, run, and shown with the SQL and its caveats.
  2. Prohibited purchases — keyword search over Description or Vendor for a chosen year.
     Fixed, parameterised SQL; no language model involved.

The Gemini key is read from Streamlit secrets (deployed) or a local .env file, never from
the repository.

    streamlit run app.py
"""
import gzip
import json
import os
import re
import shutil
import sqlite3
import tempfile
import time
from pathlib import Path

import pandas as pd
import streamlit as st

ROOT = Path(__file__).parent
DB_LOCAL = ROOT / "data" / "pcards.db"
DB_GZ = ROOT / "data" / "pcards.db.gz"
YEARS = [2014, 2013, 2012, 2011, 2010]
DEFAULT_MODEL = "gemini-3.5-flash-lite"
MAX_ROWS = 5000          # rows fetched for display; the full result is not silently truncated
QUERY_SECONDS = 15       # a model-written query that runs longer than this is stopped

st.set_page_config(page_title="OSU P-card audit", page_icon="🔎", layout="wide")


# --------------------------------------------------------------------------- database

@st.cache_resource
def db_path() -> str:
    """Use the local build if present, otherwise unpack the shipped .gz once."""
    if DB_LOCAL.exists():
        return str(DB_LOCAL)
    out = Path(tempfile.gettempdir()) / "osu_pcards.db"
    if not out.exists():
        with gzip.open(DB_GZ, "rb") as src, out.open("wb") as dst:
            shutil.copyfileobj(src, dst)
    return str(out)


def _regexp(pattern: str, value) -> bool:
    return value is not None and re.search(pattern, value, re.IGNORECASE) is not None


# Anything other than reading the pcards table is refused by SQLite itself, so a bad or
# malicious model output cannot write, attach another file or read the schema tables.
_ALLOWED = {sqlite3.SQLITE_SELECT, sqlite3.SQLITE_FUNCTION, getattr(sqlite3, "SQLITE_RECURSIVE", 33)}


def _authorizer(action, arg1, arg2, dbname, source):
    if action == sqlite3.SQLITE_READ:
        return sqlite3.SQLITE_OK if arg1 == "pcards" else sqlite3.SQLITE_DENY
    return sqlite3.SQLITE_OK if action in _ALLOWED else sqlite3.SQLITE_DENY


def run_query(sql: str, params: tuple = ()) -> tuple[pd.DataFrame, bool]:
    """Run one read-only query. Returns (rows, truncated)."""
    con = sqlite3.connect(f"file:{db_path()}?mode=ro", uri=True, check_same_thread=False)
    try:
        con.create_function("REGEXP", 2, _regexp, deterministic=True)
        con.set_authorizer(_authorizer)
        deadline = time.monotonic() + QUERY_SECONDS
        con.set_progress_handler(lambda: time.monotonic() > deadline, 10_000)
        cur = con.execute(sql, params)
        rows = cur.fetchmany(MAX_ROWS + 1)
        cols = [d[0] for d in cur.description]
    finally:
        con.close()
    return pd.DataFrame(rows[:MAX_ROWS], columns=cols), len(rows) > MAX_ROWS


# --------------------------------------------------------------------------- language model

def secret(name: str) -> str | None:
    try:
        if name in st.secrets:
            return st.secrets[name]
    except Exception:  # no secrets file at all when running locally
        pass
    return os.getenv(name)


try:
    from dotenv import load_dotenv
    load_dotenv(ROOT / ".env")
except ImportError:
    pass

SCHEMA = """Table pcards — one row per purchasing-card transaction at Oklahoma State University (OSU), 2010-2014.
  Year                    INTEGER  calendar year of the transaction. 2010 holds far fewer rows than other years.
  Month                   INTEGER  1-12
  FullName                TEXT     pseudonymised cardholder, e.g. 'Employee 51914657'
  ID                      INTEGER  transaction id
  AgencyNumber            INTEGER  always 1000 (OSU)
  AgencyName              TEXT     always 'OKLAHOMA STATE UNIVERSITY'
  CardholderLastName      TEXT
  CardholderFirstInitial  TEXT
  Description             TEXT     free text; about two thirds of rows say only 'GENERAL PURCHASE'
  Amount                  REAL     US dollars; negative amounts are credits and returns
  Vendor                  TEXT     merchant name as printed by the bank; one merchant can appear under several spellings
  TransactionDate         TEXT     'M/D/YYYY 0:00:00' — never sort or compare this column
  PostedDate              TEXT     'M/D/YYYY 0:00:00' — never sort or compare this column
  TxnDate                 TEXT     transaction date as 'YYYY-MM-DD' — use for every date order, range or grouping
  PostDate                TEXT     posting date as 'YYYY-MM-DD'
  MCC                     TEXT     merchant category description, e.g. 'BOOK STORES'. Describes the merchant, not the purchase.
The data has no department, card limit, approver, receipt or real-name information."""

PROMPT = """You translate an internal auditor's question into exactly one SQLite query.

{schema}

Rules:
- Return one SELECT statement (a WITH clause is allowed). Only the table pcards exists.
- No semicolons, comments, PRAGMA, ATTACH or any statement that changes data.
- Unless the question names other years, filter on Year = {year}.
- Match text case-insensitively with UPPER(column) LIKE '%WORD%'.
- Round money to 2 decimals and give columns readable aliases.
- When listing individual transactions include ID, TxnDate, FullName, Vendor, Description, Amount and MCC,
  and add LIMIT 500 unless the question asks for everything.
- If the question needs data this table does not hold, write the closest useful query and say what is missing.

Return JSON with exactly these keys:
  "sql": the query,
  "explanation": two or three plain-English sentences on the period, filters, grouping and sorting,
  "caveats": a list of short strings — assumptions you made and limits of the data that affect the answer.

Auditor question: {question}"""


def ask_gemini(question: str, year: int) -> dict:
    from google import genai
    from google.genai import errors, types

    client = genai.Client(api_key=secret("GEMINI_API_KEY"))
    model = secret("GEMINI_MODEL") or DEFAULT_MODEL
    prompt = PROMPT.format(schema=SCHEMA, year=year, question=question)
    config = types.GenerateContentConfig(
        response_mime_type="application/json", temperature=0, max_output_tokens=2048)

    # Free-tier models are sometimes overloaded or rate limited; retry briefly before failing.
    for attempt in range(3):
        try:
            start = time.perf_counter()
            resp = client.models.generate_content(model=model, contents=prompt, config=config)
            break
        except errors.APIError as e:
            if e.code in (429, 500, 503) and attempt < 2:
                time.sleep(2 ** attempt * 2)
                continue
            raise
    out = json.loads(resp.text)
    usage = resp.usage_metadata
    out["model"] = model
    out["seconds"] = time.perf_counter() - start
    out["tokens"] = getattr(usage, "total_token_count", None)
    return out


def check_sql(sql: str) -> str:
    """Light shape check with a readable message; the authorizer is the real guard."""
    sql = sql.strip().rstrip(";").strip()
    if ";" in sql:
        raise ValueError("The model returned more than one statement.")
    if not re.match(r"(?is)^\s*(select|with)\b", sql):
        raise ValueError("The model did not return a SELECT query.")
    if re.search(r"--|/\*", sql):
        raise ValueError("The query contains comments, which are not allowed.")
    return sql


# --------------------------------------------------------------------------- page

st.title("OSU P-card audit assistant")
st.caption("Oklahoma State University purchasing-card transactions, 2010–2014 · "
           "cardholder names are pseudonymised")

with st.sidebar:
    st.header("Read this first")
    st.markdown(
        "Everything this tool returns is a **risk indicator, not a finding**. A flagged "
        "transaction can have a legitimate explanation; confirming a violation needs the "
        "receipt, the business purpose and the approver's sign-off, none of which are in "
        "this data.\n\n"
        "**What the data cannot tell you**\n"
        "- departments, card limits or approvers\n"
        "- real names (cardholders are pseudonymised)\n"
        "- what was bought — about two thirds of descriptions say only *GENERAL PURCHASE*\n\n"
        "**Merchant category describes the merchant, not the purchase.** A florist code "
        "covers bouquets and grounds nursery stock alike.")

ask_tab, dash_tab = st.tabs(["💬 Ask the database", "🚫 Prohibited purchases"])

# --------------------------------------------------------------------------- tab 1

EXAMPLES = [
    "Which 10 cardholders spent the most?",
    "Total spend by month",
    "All transactions over $5,000",
    "Which vendors issued the most refunds?",
]

with ask_tab:
    st.subheader("Ask a question in plain English")
    st.markdown(
        "A language model (Google Gemini) turns your question into a SQL query; the query "
        "runs against the database and you see **the answer, the exact SQL and the "
        "assumptions behind it**. Read the SQL — the model can misunderstand a question, "
        "and the query is what actually produced the numbers.")

    c1, c2 = st.columns([1, 4])
    year = c1.selectbox("Year", YEARS, key="ask_year")
    c2.caption("Try an example")
    cols = c2.columns(2)
    for i, ex in enumerate(EXAMPLES):
        if cols[i % 2].button(ex, use_container_width=True):
            st.session_state["question"] = ex

    with st.form("ask"):
        question = st.text_area("Your question", key="question", height=80,
                                placeholder="e.g. Which vendors received more than $100,000 in 2014?")
        asked = st.form_submit_button("Ask", type="primary")

    if asked and question.strip():
        if not secret("GEMINI_API_KEY"):
            st.error("No Gemini API key is configured, so natural-language questions are "
                     "unavailable. The Prohibited purchases tab works without one.")
        else:
            with st.spinner("Writing and running the query…"):
                try:
                    answer = ask_gemini(question.strip(), year)
                    sql = check_sql(answer.get("sql", ""))
                    df, truncated = run_query(sql)
                    st.session_state["answer"] = {**answer, "sql": sql, "df": df,
                                                  "truncated": truncated, "question": question}
                except sqlite3.DatabaseError as e:
                    st.session_state.pop("answer", None)
                    st.error(f"The generated query could not run: {e}. Try rephrasing the question.")
                except Exception as e:
                    st.session_state.pop("answer", None)
                    st.error(f"Could not answer: {e}")

    a = st.session_state.get("answer")
    if a:
        st.markdown(f"**{a['question']}**")
        st.write(a.get("explanation", ""))
        for c in a.get("caveats") or []:
            st.warning(c, icon="⚠️")
        df = a["df"]
        if df.empty:
            st.info("The query ran and returned no rows.")
        else:
            st.dataframe(df, use_container_width=True, hide_index=True)
            if a["truncated"]:
                st.caption(f"Showing the first {MAX_ROWS:,} rows — narrow the question for the rest.")
            st.download_button("Download CSV", df.to_csv(index=False), "pcard_query.csv", "text/csv")
        with st.expander("SQL that produced this answer", expanded=False):
            st.code(a["sql"], language="sql")
        st.caption(f"{a['model']} · {a['seconds']:.1f}s · "
                   f"{a['tokens'] if a['tokens'] is not None else '?'} tokens")

# --------------------------------------------------------------------------- tab 2

PROHIBITED = pd.DataFrame([
    ("Alcohol", "liquor, wine, beer", "liquor, bottle, wine, brew"),
    ("Cash, cash advances, ATM", "cash, ATM", "ATM, cash advance, western union"),
    ("Decorations", "decoration, balloon", "party, decor"),
    ("Donations and sponsorships", "donation, sponsor", "foundation, red cross, united way"),
    ("Gasoline", "fuel, gas", "shell, conoco, phillips 66, quiktrip"),
    ("Gifts, gift cards, gift certificates", "gift", "gift"),
    ("Insurance", "insurance", "insurance"),
    ("Late fees", "late fee", "—"),
    ("Mail and postage", "postage, stamps", "USPS, post office"),
    ("Moving expenses", "moving", "u-haul, mayflower, movers"),
    ("Personal purchases", "personal", "netflix, spotify, itunes"),
    ("Personal memberships and dues", "membership, dues", "membership"),
    ("Salaries, wages and benefits", "salary, payroll", "payroll"),
    ("Service and incentive awards", "award, plaque, trophy", "trophy, awards"),
], columns=["Prohibited category", "Try in Description", "Try in Vendor"])

FIELDS = {"Description": "Description", "Vendor": "Vendor"}   # whitelist: never user-supplied

SEARCH_SQL = """
SELECT ID, TxnDate AS Date, ROUND(Amount, 2) AS Amount, FullName AS Cardholder,
       Vendor, Description, MCC, PostDate AS Posted
FROM pcards
WHERE Year = ?
  AND {field} LIKE ?
  AND {field} REGEXP ?
ORDER BY Amount DESC, ID
"""


def search(field: str, keyword: str, year: int, whole_word: bool):
    col = FIELDS[field]
    pattern = re.escape(keyword)
    if whole_word:
        pattern = rf"\b{pattern}\b"
    # LIKE narrows the rows cheaply; REGEXP then applies the word boundary
    return run_query(SEARCH_SQL.format(field=col), (year, f"%{keyword}%", pattern))


def show_results(field: str, keyword: str, year: int, df: pd.DataFrame, truncated: bool):
    st.markdown(f"#### {field} search · “{keyword}” · {year}")
    if df.empty:
        st.info("No matching transactions. Try a shorter keyword, untick whole-word "
                "matching, or search the other field.")
        return
    m = st.columns(4)
    m[0].metric("Transactions", f"{len(df):,}{'+' if truncated else ''}")
    m[1].metric("Total", f"${df['Amount'].sum():,.2f}")
    m[2].metric("Cardholders", f"{df['Cardholder'].nunique():,}")
    m[3].metric("Vendors", f"{df['Vendor'].nunique():,}")
    if truncated:
        st.caption(f"Showing the {MAX_ROWS:,} largest — refine the keyword for the rest.")
    st.dataframe(df, use_container_width=True, hide_index=True)
    st.download_button("Download CSV", df.to_csv(index=False),
                       f"{field.lower()}_{keyword}_{year}.csv", "text/csv",
                       key=f"dl_{field}")
    top = (df.groupby("Cardholder")["Amount"].agg(["count", "sum"])
             .sort_values("sum", ascending=False).head(10).reset_index())
    top.columns = ["Cardholder", "Transactions", "Total"]
    with st.expander("Who to follow up first — cardholders in these results by value"):
        st.dataframe(top, use_container_width=True, hide_index=True)


with dash_tab:
    st.subheader("Search for prohibited purchases")
    st.markdown(
        "**How to use this dashboard**\n"
        "1. Pick the **year** to examine.\n"
        "2. Use **Description search** to look inside what the cardholder wrote about the "
        "purchase (e.g. *wine*), or **Vendor search** to look for a type of merchant (e.g. "
        "*post office*). The two are separate on purpose: they find different things.\n"
        "3. Keep **whole word** ticked so *ATM* does not match *treATMent*; untick it to "
        "catch word fragments such as *liquor* inside *liquors*.\n"
        "4. Results are sorted largest first. Each row has the transaction ID, dates, "
        "cardholder, vendor, description and merchant category needed to request the "
        "receipt — download them as CSV for follow-up.\n\n"
        "Not sure what to search for? The policy's prohibited categories and starting "
        "keywords are listed below.")

    year2 = st.selectbox("Year", YEARS, key="dash_year")
    general = run_query("SELECT ROUND(AVG(Description = 'GENERAL PURCHASE') * 100) FROM pcards "
                        "WHERE Year = ?", (year2,))[0].iat[0, 0]

    with st.expander("Prohibited categories and suggested keywords"):
        st.dataframe(PROHIBITED, use_container_width=True, hide_index=True)

    left, right = st.columns(2)
    with left, st.form("desc"):
        st.markdown("##### 📝 Description search")
        st.caption(f"Searches what the cardholder entered. In {year2}, {general:.0f}% of "
                   "descriptions say only *GENERAL PURCHASE*, so this misses most purchases — "
                   "run a vendor search too.")
        kw_d = st.text_input("Keyword in description", placeholder="e.g. wine")
        ww_d = st.checkbox("Whole word only", value=True, key="ww_d")
        go_d = st.form_submit_button("Search descriptions", type="primary")
    with right, st.form("vend"):
        st.markdown("##### 🏪 Vendor search")
        st.caption("Searches the merchant name as printed by the bank. One merchant can "
                   "appear under several spellings.")
        kw_v = st.text_input("Keyword in vendor name", placeholder="e.g. post office")
        ww_v = st.checkbox("Whole word only", value=True, key="ww_v")
        go_v = st.form_submit_button("Search vendors", type="primary")

    for go, field, kw, ww in ((go_d, "Description", kw_d, ww_d), (go_v, "Vendor", kw_v, ww_v)):
        if go:
            if kw.strip():
                df, truncated = search(field, kw.strip(), year2, ww)
                st.session_state["search"] = (field, kw.strip(), year2, df, truncated)
            else:
                st.warning(f"Enter a keyword for the {field.lower()} search.")

    if "search" in st.session_state:
        show_results(*st.session_state["search"])
