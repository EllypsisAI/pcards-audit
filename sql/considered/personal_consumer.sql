-- Considered and rejected · Personal / consumer merchants
-- Rejected: too noisy; athletics, theatre and uniform buying share these merchant types.
SELECT COUNT(*) AS Transactions, ROUND(SUM(Amount), 2) AS Total, COUNT(DISTINCT FullName) AS Cardholders
FROM pcards WHERE Year = 2014 AND Amount > 0
  AND (UPPER(Vendor) LIKE '%NETFLIX%' OR UPPER(Vendor) LIKE '%SPOTIFY%' OR UPPER(Vendor) LIKE '%ITUNES%'
    OR UPPER(Vendor) LIKE '%HULU%' OR UPPER(MCC) LIKE '%CLOTHING%' OR UPPER(MCC) LIKE '%SHOE%'
    OR UPPER(MCC) LIKE '%JEWELRY%' OR UPPER(MCC) LIKE '%COSMETIC%');
