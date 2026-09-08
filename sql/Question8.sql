-- Part II · Control 8 (student-defined) | Alcohol is a prohibited P-card purchase.
-- Part I, Prohibited Purchases: "Alcohol". Purchases of alcohol are prohibited outright,
-- so any transaction at a liquor store or drinking establishment is a deviation.
-- Test: 2014 transactions whose MCC identifies an alcohol merchant.
-- Output: full transaction detail, largest amount first (largest exposure investigated first).
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
  AND (UPPER(MCC) LIKE '%LIQUOR%'
    OR UPPER(MCC) LIKE '%DRINKING PLACES%'
    OR UPPER(MCC) LIKE '%BEER%'
    OR UPPER(MCC) LIKE '%WINE%')
ORDER BY Amount DESC;
