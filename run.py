#!/usr/bin/env python3
"""Run every query in sql/ against the provided P-card database.

Writes full results to results/<name>.csv and a short preview to stdout, so the
numbers quoted in the write-up are always reproducible from the repo.

    python3 run.py                # run all
    python3 run.py Question4      # run one
"""
import csv
import sqlite3
import sys
import time
from pathlib import Path

ROOT = Path(__file__).parent
DB = ROOT.parent / "pcards" / "pcards.db"
SQL_DIR = ROOT / "sql"
OUT_DIR = ROOT / "results"


def run(path: Path, con: sqlite3.Connection, preview: int = 8) -> int:
    sql = path.read_text()
    start = time.perf_counter()
    cur = con.execute(sql)
    rows = cur.fetchall()
    elapsed = time.perf_counter() - start
    cols = [d[0] for d in cur.description]

    OUT_DIR.mkdir(exist_ok=True)
    with (OUT_DIR / f"{path.stem}.csv").open("w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(cols)
        w.writerows(rows)

    print(f"\n=== {path.stem} — {len(rows)} rows in {elapsed:.2f}s ===")
    widths = [max(len(str(c)), *(len(str(r[i])) for r in rows[:preview])) if rows else len(str(c))
              for i, c in enumerate(cols)]
    print("  ".join(str(c).ljust(w) for c, w in zip(cols, widths)))
    for r in rows[:preview]:
        print("  ".join(str(v).ljust(w) for v, w in zip(r, widths)))
    if len(rows) > preview:
        print(f"... {len(rows) - preview} more rows")
    return len(rows)


def main() -> None:
    if not DB.exists():
        sys.exit(f"database not found: {DB}")
    con = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    wanted = sys.argv[1:]
    files = sorted(SQL_DIR.glob("*.sql"), key=lambda p: (p.stem.startswith("qry"), len(p.stem), p.stem))
    if wanted:
        files = [f for f in files if f.stem in wanted]
    counts = {f.stem: run(f, con) for f in files}
    print("\n--- row counts ---")
    for name, n in counts.items():
        print(f"{name}: {n}")


if __name__ == "__main__":
    main()
