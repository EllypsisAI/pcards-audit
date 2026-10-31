-- Considered and rejected · Mail and postage
-- Rejected: small; left to the Part IV vendor search.
SELECT COUNT(*) AS Transactions, ROUND(SUM(Amount), 2) AS Total, COUNT(DISTINCT FullName) AS Cardholders
FROM pcards WHERE Year = 2014 AND Amount > 0
  AND (UPPER(MCC) LIKE '%POSTAL%' OR UPPER(Vendor) LIKE '%USPS%' OR UPPER(Vendor) LIKE '%POST OFFICE%');
