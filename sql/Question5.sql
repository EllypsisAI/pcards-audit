-- Part II · Control 5 | A purchase must not be split between two or more cardholders.
-- Vendor-days where the combined total exceeded $5,000 and exactly two different
-- cardholders bought from that vendor. Requiring exactly two transactions as well as
-- exactly two cardholders is what "excludes people who may have made double payments":
-- it removes vendor-days where one person swiped more than once (that is Control 4's
-- population, not a two-person split).
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
two_person_days AS (
    SELECT Vendor, TxnDate,
           ROUND(SUM(Amount), 2) AS DayTotal
    FROM t
    GROUP BY Vendor, TxnDate
    HAVING SUM(Amount) > 5000
       AND COUNT(DISTINCT FullName) = 2
       AND COUNT(*) = 2
)
SELECT
    t.TxnDate           AS TransactionDate,
    t.Vendor,
    t.FullName          AS Name,
    ROUND(t.Amount, 2)  AS Amount,
    d.DayTotal,
    t.Description,
    t.MCC,
    t.PostedDate
FROM t
JOIN two_person_days d
  ON t.Vendor = d.Vendor AND t.TxnDate = d.TxnDate
ORDER BY t.TxnDate ASC, t.Vendor, t.Amount DESC;
