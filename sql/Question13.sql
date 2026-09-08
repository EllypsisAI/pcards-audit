-- Part II · Control 13 (student-defined) | Recurring payments above $5,000 a year need a PO.
-- Part I: "Regular Monthly Payments > $5,000 per Fiscal Year - Maintenance, lease/rental,
-- and service agreements ... should be processed on a requisition and a PO issued if the
-- total for the fiscal year is greater than $5,000."
-- Each individual charge can sit well under the single-transaction limit and still breach
-- this rule, so the test looks at the cardholder-vendor relationship over the whole year.
-- Test: cardholder-vendor pairs charged in six or more distinct months of 2014 (evidence of
-- a standing arrangement rather than ad-hoc buying) whose annual total exceeds $5,000.
-- Output: cardholder, vendor, months charged, annual total; largest total first.
SELECT
    FullName                    AS Name,
    Vendor,
    COUNT(DISTINCT Month)       AS MonthsCharged,
    COUNT(*)                    AS Transactions,
    ROUND(SUM(Amount), 2)       AS AnnualTotal,
    ROUND(AVG(Amount), 2)       AS AverageCharge,
    ROUND(MAX(Amount), 2)       AS LargestCharge
FROM pcards
WHERE Year = 2014
GROUP BY FullName, Vendor
HAVING COUNT(DISTINCT Month) >= 6
   AND SUM(Amount) > 5000
ORDER BY AnnualTotal DESC;
