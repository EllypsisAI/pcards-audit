-- Part II · Control 14 (student-defined) | Structuring against the $5,000 single-transaction limit.
-- Part I defines split purchasing as "dividing or failing to consolidate a known quantity of
-- goods or services for the purpose of evading the P-card single transaction limit of $5,000".
-- Controls 4-6 catch splits that happen on one day. This test looks for the behavioural
-- signature that precedes them: charges parked immediately below the limit. If purchasing is
-- driven by genuine need, amounts should not pile up in the last band before the ceiling.
-- Test: 2014 charges of $4,500.00-$4,999.99, plus charges of exactly $5,000.00, per cardholder.
-- Output: cardholder, count of near-limit charges, count at exactly the limit, total value;
-- most near-limit charges first. Cardholders with a single occurrence are excluded as noise.
SELECT
    FullName                                                    AS Name,
    COUNT(*)                                                    AS NearLimitCharges,
    SUM(CASE WHEN Amount = 5000.00 THEN 1 ELSE 0 END)           AS ChargesAtExactly5000,
    ROUND(SUM(Amount), 2)                                       AS TotalValue,
    ROUND(MIN(Amount), 2)                                       AS Smallest,
    ROUND(MAX(Amount), 2)                                       AS Largest,
    COUNT(DISTINCT Vendor)                                      AS DistinctVendors
FROM pcards
WHERE Year = 2014
  AND Amount >= 4500.00
  AND Amount <= 5000.00
GROUP BY FullName
HAVING COUNT(*) > 1
ORDER BY NearLimitCharges DESC, TotalValue DESC;
