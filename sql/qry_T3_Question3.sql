-- Part III · Question 3 | Employees repeatedly associated with possible duplicates.
-- Built on the Question 2 population. Counts duplicate *occasions* — one date/vendor/amount
-- cluster is one occasion however many charges it contains — rather than counting rows,
-- so an employee with one four-charge cluster does not outrank one with three separate
-- two-charge clusters.
-- Output: employee, duplicate occasions, charges involved, total value; most occasions first.
WITH t AS (
    SELECT
        FullName, CardholderFirstInitial, CardholderLastName, Vendor, Amount,
        printf('%04d-%02d-%02d',
            CAST(substr(substr(TransactionDate, 1, instr(TransactionDate, ' ') - 1),
                        length(substr(TransactionDate, 1, instr(TransactionDate, ' ') - 1)) - 3) AS INTEGER),
            CAST(substr(TransactionDate, 1, instr(TransactionDate, '/') - 1) AS INTEGER),
            CAST(substr(substr(TransactionDate, instr(TransactionDate, '/') + 1), 1,
                        instr(substr(TransactionDate, instr(TransactionDate, '/') + 1), '/') - 1) AS INTEGER)
        ) AS TxnDate
    FROM pcards
    WHERE Year = 2014
      AND Amount > 0
),
occasions AS (
    SELECT FullName, TxnDate, Vendor, Amount,
           COUNT(*) AS MatchingCharges
    FROM t
    GROUP BY TxnDate, Vendor, CardholderFirstInitial, CardholderLastName, Amount
    HAVING COUNT(*) > 1
)
SELECT
    FullName                                    AS Name,
    COUNT(*)                                    AS DuplicateOccasions,
    SUM(MatchingCharges)                        AS ChargesInvolved,
    ROUND(SUM(Amount * MatchingCharges), 2)     AS TotalValue,
    ROUND(SUM(Amount * (MatchingCharges - 1)), 2) AS ValueAtRisk,
    COUNT(DISTINCT Vendor)                      AS DistinctVendors
FROM occasions
GROUP BY FullName
ORDER BY DuplicateOccasions DESC, ValueAtRisk DESC;
