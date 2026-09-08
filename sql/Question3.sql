-- Part II · Control 3 | User shall not spend more than $5,000 per transaction.
-- Every single 2014 transaction above the $5,000 single-transaction limit.
-- Sorted by transaction amount, largest first (highest-exposure items lead the
-- follow-up list; the brief does not state a direction for this test).
SELECT
    ROUND(Amount, 2)    AS Amount,
    FullName            AS Name,
    Description,
    Vendor,
    TransactionDate,
    PostedDate,
    MCC
FROM pcards
WHERE Year = 2014
  AND Amount > 5000
ORDER BY Amount DESC;
