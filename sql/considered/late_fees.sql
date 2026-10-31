-- Considered and rejected · Late fees
-- Rejected: nil — the phrase does not occur in vendor or description.
SELECT COUNT(*) AS Transactions, ROUND(COALESCE(SUM(Amount), 0), 2) AS Total
FROM pcards WHERE Year = 2014 AND Amount > 0
  AND (UPPER(Description) LIKE '%LATE FEE%' OR UPPER(Vendor) LIKE '%LATE FEE%' OR UPPER(Description) LIKE '%LATE CHARGE%');
