-- Considered and rejected · Personal memberships and dues
-- Rejected: institutional memberships are allowed and the data cannot tell them from personal ones.
SELECT MCC, COUNT(*) AS Transactions, ROUND(SUM(Amount), 2) AS Total
FROM pcards WHERE Year = 2014 AND Amount > 0
  AND (UPPER(MCC) LIKE '%MEMBERSHIP%' OR UPPER(MCC) LIKE '%CLUBS%')
GROUP BY MCC ORDER BY Total DESC;
