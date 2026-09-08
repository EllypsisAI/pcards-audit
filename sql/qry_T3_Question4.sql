-- Part III · Question 4 | Four-digit round-number transactions.
-- Positive OSU 2014 charges whose whole-dollar amount is four digits and ends in 000 —
-- $1,000, $2,000 ... $9,000 — ignoring cents. Naturally occurring prices rarely land on a
-- round thousand; amounts that do were usually negotiated, estimated or invented, so this
-- population is worth reading transaction by transaction.
-- Output: Amount, Vendor, Description, FullName; ascending by vendor then name.
SELECT
    ROUND(Amount, 2)    AS Amount,
    Vendor,
    Description,
    FullName,
    TransactionDate,
    MCC
FROM pcards
WHERE Year = 2014
  AND Amount > 0
  AND CAST(Amount AS INTEGER) BETWEEN 1000 AND 9999
  AND CAST(Amount AS INTEGER) % 1000 = 0
ORDER BY Vendor ASC, FullName ASC;
