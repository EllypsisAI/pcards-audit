-- Part II · Control 4 | An amount over $5,000 must not be split across two or more
-- swipes of the same card (same cardholder, same vendor, same day).
-- TransactionDate is stored as text 'M/D/YYYY 0:00:00', which does not sort
-- chronologically, so it is parsed to an ISO date for grouping and sorting.
WITH t AS (
    SELECT
        FullName, Vendor, Amount, Description, MCC, TransactionDate, PostedDate,
        printf('%04d-%02d-%02d',
            CAST(substr(substr(TransactionDate, 1, instr(TransactionDate, ' ') - 1),
                        length(substr(TransactionDate, 1, instr(TransactionDate, ' ') - 1)) - 3) AS INTEGER),
            CAST(substr(TransactionDate, 1, instr(TransactionDate, '/') - 1) AS INTEGER),
            CAST(substr(substr(TransactionDate, instr(TransactionDate, '/') + 1), 1,
                        instr(substr(TransactionDate, instr(TransactionDate, '/') + 1), '/') - 1) AS INTEGER)
        ) AS TxnDate
    FROM pcards
    WHERE Year = 2014
),
split_days AS (
    SELECT FullName, Vendor, TxnDate,
           ROUND(SUM(Amount), 2) AS DayTotal,
           COUNT(*)              AS SwipesThatDay
    FROM t
    GROUP BY FullName, Vendor, TxnDate
    HAVING COUNT(*) > 1
       AND SUM(Amount) > 5000
)
SELECT
    t.TxnDate           AS TransactionDate,
    t.FullName          AS Name,
    t.Vendor,
    ROUND(t.Amount, 2)  AS Amount,
    s.DayTotal,
    s.SwipesThatDay,
    t.Description,
    t.MCC,
    t.PostedDate
FROM t
JOIN split_days s
  ON t.FullName = s.FullName AND t.Vendor = s.Vendor AND t.TxnDate = s.TxnDate
ORDER BY t.TxnDate ASC, t.FullName, t.Vendor, t.Amount DESC;
