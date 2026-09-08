-- Part II · Control 9 (student-defined) | Gifts, gift cards, flowers and candy.
-- Part I prohibits "Gifts, Gift Cards, Gift Certificates - The purchase of gifts is a
-- violation of State statutes" and "Items that do not Serve a Business Purpose - includes,
-- but is not limited to, flowers, candy, meals, greeting cards..."
-- Test: 2014 transactions at gift, florist and confectionery merchants.
-- Output: transaction detail grouped by merchant type, largest amount first.
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
  AND (UPPER(MCC) LIKE '%GIFT%'
    OR UPPER(MCC) LIKE '%FLORIST%'
    OR UPPER(MCC) LIKE '%CANDY%')
ORDER BY Amount DESC;
