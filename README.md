# OSU P-card audit — Analytics Mindset case

Internal-control and forensic testing of Oklahoma State University purchasing-card
transactions for calendar year 2014, plus an auditor-facing website.

Course: AI in Accounting and Business (B150316101), SDU, autumn 2026.

## Status

| Part | Scope | Status |
|---|---|---|
| II | 14 internal-control tests (7 specified + 7 student-defined) | Queries written and run, results written up |
| III | 8 forensic/fraud tests (4 specified + 4 student-defined) | Not started |
| IV | Website: natural-language query tab + prohibited-purchase dashboard | Not started |

## Layout

| Path | Contents |
|---|---|
| `sql/QuestionN.sql` | Part II control tests, one file per control |
| `results/QuestionN.csv` | Full result set for each query |
| `docs/part2-results.md` | Results and conclusions for Parts II |
| `run.py` | Runs every query against the database, writes the CSVs |

## Running

The database is course-provided and is **not** in this repository. Place `pcards.db`
in a sibling `pcards/` folder, then:

```
python3 run.py            # run every query
python3 run.py Question4  # run one
```

## The data

489,178 transactions, all Oklahoma State University (agency 1000), 2010–2014.
116,031 of them fall in 2014: $33.5m across 2,021 cardholders, 17,513 vendors, 350 MCCs.

Three things about this data shape every query:

- `Year` matches the calendar year of `TransactionDate` in all 489,178 rows, so
  `WHERE Year = 2014` is an exact calendar-year filter.
- `TransactionDate` is text in `M/D/YYYY 0:00:00` form and **does not sort chronologically**.
  Anything grouping or ordering by date parses it to `YYYY-MM-DD` first.
- Cardholder names are pseudonymised (`Employee 51914657`); they identify people
  consistently but cannot be traced to a department without the mapping file.
