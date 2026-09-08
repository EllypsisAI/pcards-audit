-- Part II · Control 6 | A purchase must not be split between two or more vendors.
-- Cardholder-days where the combined total exceeded $5,000 and the spend fell across
-- exactly two different vendors. Requiring exactly two transactions as well as exactly
-- two vendors excludes cardholders who simply paid the same vendor twice in a day.
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
two_vendor_days AS (
    SELECT FullName, TxnDate,
           ROUND(SUM(Amount), 2) AS DayTotal
    FROM t
    GROUP BY FullName, TxnDate
    HAVING SUM(Amount) > 5000
       AND COUNT(DISTINCT Vendor) = 2
       AND COUNT(*) = 2
)
SELECT
    t.TxnDate           AS TransactionDate,
    t.FullName          AS Name,
    t.Vendor,
    ROUND(t.Amount, 2)  AS Amount,
    d.DayTotal,
    t.Description,
    t.MCC,
    t.PostedDate
FROM t
JOIN two_vendor_days d
  ON t.FullName = d.FullName AND t.TxnDate = d.TxnDate
ORDER BY t.TxnDate ASC, t.FullName, t.Amount DESC;
