-- Part III · Question 6 (student-defined) | Sole-user vendors carrying material spend.
-- Fraud risk: Part I prohibits purchases from a company owned by a University employee,
-- from family, and from any business in which the cardholder has a financial interest.
-- A fictitious or related-party vendor has a signature — exactly one cardholder ever uses
-- it, repeatedly, for material amounts. A genuine supplier of that size is normally used by
-- more than one buyer somewhere in a 2,021-cardholder institution.
-- Threshold: one cardholder, three or more charges, more than $5,000 for the year.
-- Output: vendor, cardholder, charges, total, average, months active; largest total first.
SELECT
    Vendor,
    MIN(FullName)                   AS SoleCardholder,
    COUNT(*)                        AS Charges,
    ROUND(SUM(Amount), 2)           AS AnnualTotal,
    ROUND(AVG(Amount), 2)           AS AverageCharge,
    COUNT(DISTINCT Month)           AS MonthsActive,
    MIN(MCC)                        AS MCC
FROM pcards
WHERE Year = 2014
  AND Amount > 0
GROUP BY Vendor
HAVING COUNT(DISTINCT FullName) = 1
   AND COUNT(*) >= 3
   AND SUM(Amount) > 5000
ORDER BY AnnualTotal DESC;
