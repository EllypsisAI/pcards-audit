-- Considered and rejected · Apple products outside the Bookstore
-- Rejected: small, and the data cannot show which campus a cardholder works on (rule is Stillwater-only).
SELECT COUNT(*) AS Transactions, ROUND(SUM(Amount), 2) AS Total, COUNT(DISTINCT FullName) AS Cardholders
FROM pcards WHERE Year = 2014 AND Amount > 0
  AND (UPPER(Vendor) LIKE 'APPLE STORE%' OR UPPER(Vendor) LIKE 'APL*%'
    OR UPPER(Vendor) LIKE 'APPLE ONLINE%' OR UPPER(Vendor) LIKE 'APPLE.COM%');
