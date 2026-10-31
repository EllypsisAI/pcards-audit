-- Considered and rejected · Charitable-organisation MCC as a donations test
-- Rejected: the merchant type is dominated by professional bodies (standards, journals, conferences). Replaced by the narrower Control 9.
SELECT Vendor, COUNT(*) AS Transactions, ROUND(SUM(Amount), 2) AS Total
FROM pcards WHERE Year = 2014 AND Amount > 0 AND UPPER(MCC) LIKE '%CHARITABLE%'
GROUP BY Vendor ORDER BY Total DESC;
