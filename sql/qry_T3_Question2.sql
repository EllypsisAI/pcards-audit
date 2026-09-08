-- Part III · Question 2 | Possible duplicate payments.
-- Positive OSU 2014 charges sharing transaction date, vendor, cardholder first initial,
-- cardholder last name and amount. Returns (negative amounts) are excluded. Where more
-- than two charges match, all of them are returned.
-- Output: TransactionDate, Vendor, FullName, Amount; ascending by date then vendor.
WITH t AS (
    SELECT
        FullName, CardholderFirstInitial, CardholderLastName, Vendor, Amount,
        Description, MCC, PostedDate,
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
)
SELECT
    t.TxnDate           AS TransactionDate,
    t.Vendor,
    t.FullName,
    ROUND(t.Amount, 2)  AS Amount,
    d.MatchingCharges,
    t.Description,
    t.MCC
FROM t
JOIN (
    SELECT TxnDate, Vendor, CardholderFirstInitial, CardholderLastName, Amount,
           COUNT(*) AS MatchingCharges
    FROM t
    GROUP BY TxnDate, Vendor, CardholderFirstInitial, CardholderLastName, Amount
    HAVING COUNT(*) > 1
) d
  ON  t.TxnDate                 = d.TxnDate
  AND t.Vendor                  = d.Vendor
  AND t.CardholderFirstInitial  = d.CardholderFirstInitial
  AND t.CardholderLastName      = d.CardholderLastName
  AND t.Amount                  = d.Amount
ORDER BY t.TxnDate ASC, t.Vendor ASC;
