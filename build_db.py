#!/usr/bin/env python3
"""Build the database the Part IV website ships with.

Reads the course-provided pcards.db and writes data/pcards.db.gz:

- the same pcards table, plus TxnDate and PostDate as ISO 'YYYY-MM-DD' text. The original
  TransactionDate / PostedDate are 'M/D/YYYY 0:00:00' strings that do not sort, which would
  silently break any date ordering or range the language model writes;
- indexes on the columns the dashboard and typical questions filter by;
- gzip-compressed, so the file stays well under GitHub's 100 MB limit. The app unpacks it
  once at startup.

    python3 build_db.py
"""
import gzip
import shutil
import sqlite3
from pathlib import Path

ROOT = Path(__file__).parent
SRC = ROOT.parent / "pcards" / "pcards.db"
OUT_DIR = ROOT / "data"
DB = OUT_DIR / "pcards.db"
GZ = OUT_DIR / "pcards.db.gz"

ISO = """printf('%04d-%02d-%02d',
    CAST(SUBSTR({c}, INSTR({c}, '/') + INSTR(SUBSTR({c}, INSTR({c}, '/') + 1), '/') + 1, 4) AS INTEGER),
    CAST(SUBSTR({c}, 1, INSTR({c}, '/') - 1) AS INTEGER),
    CAST(SUBSTR({c}, INSTR({c}, '/') + 1, INSTR(SUBSTR({c}, INSTR({c}, '/') + 1), '/') - 1) AS INTEGER))"""


def main() -> None:
    OUT_DIR.mkdir(exist_ok=True)
    DB.unlink(missing_ok=True)
    con = sqlite3.connect(DB)
    con.execute("ATTACH ? AS src", (f"file:{SRC}?mode=ro",))
    con.execute(f"""
        CREATE TABLE pcards AS
        SELECT Year, Month, FullName, ID, AgencyNumber, AgencyName,
               CardholderLastName, CardholderFirstInitial, Description, Amount, Vendor,
               TransactionDate, PostedDate, MCC,
               {ISO.format(c='TransactionDate')} AS TxnDate,
               {ISO.format(c='PostedDate')} AS PostDate
        FROM src.pcards
    """)
    con.commit()
    con.execute("DETACH src")
    for col in ("Year", "TxnDate", "FullName", "Vendor", "MCC"):
        con.execute(f"CREATE INDEX idx_{col} ON pcards({col})")

    # the ISO conversion must agree with the Year column on every row
    bad = con.execute("SELECT COUNT(*) FROM pcards WHERE CAST(SUBSTR(TxnDate, 1, 4) AS INTEGER) <> Year").fetchone()[0]
    assert bad == 0, f"{bad} rows where TxnDate disagrees with Year"
    n = con.execute("SELECT COUNT(*) FROM pcards").fetchone()[0]
    con.commit()
    con.execute("VACUUM")
    con.close()

    with DB.open("rb") as src, gzip.open(GZ, "wb", compresslevel=9) as dst:
        shutil.copyfileobj(src, dst)
    print(f"{n:,} rows · {DB.stat().st_size / 1e6:.1f} MB raw · {GZ.stat().st_size / 1e6:.1f} MB gzipped")


if __name__ == "__main__":
    main()
