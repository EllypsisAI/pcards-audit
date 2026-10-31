-- Considered and rejected · Insurance (original Control 11)
-- Rejected: valid but immaterial; mostly travel and event-ticket cover bought at booking.
SELECT COUNT(*) AS Transactions, ROUND(SUM(Amount), 2) AS Total, COUNT(DISTINCT FullName) AS Cardholders
FROM pcards WHERE Year = 2014 AND UPPER(MCC) LIKE '%INSURANCE%';
