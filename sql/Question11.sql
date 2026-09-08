-- Part II · Control 11 (student-defined) | Insurance must go through Risk Management.
-- Part I: "Insurance - Insurance must be processed on a requisition through Risk and
-- Property Management." A P-card charge to an insurance merchant bypasses that route.
-- Test: 2014 transactions at insurance merchants.
-- Output: full transaction detail, largest amount first.
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
  AND UPPER(MCC) LIKE '%INSURANCE%'
ORDER BY Amount DESC;
