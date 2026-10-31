-- Considered and rejected · Gifts, flowers, candy (original Control 9)
-- Rejected: mostly nursery stock and event supplies; MCC cannot separate them from gifts.
SELECT COUNT(*) AS Transactions, ROUND(SUM(Amount), 2) AS Total, COUNT(DISTINCT FullName) AS Cardholders
FROM pcards WHERE Year = 2014
  AND (UPPER(MCC) LIKE '%GIFT%' OR UPPER(MCC) LIKE '%FLORIST%' OR UPPER(MCC) LIKE '%CANDY%');
