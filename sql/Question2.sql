-- Part II · Control 2 | User shall not spend more than $10,000 per month without approval.
-- Cardholder-months in 2014 with net spend over $10,000.
-- Sorted by month (January first), then by amount with the largest first.
SELECT
    FullName                AS Name,
    Month                   AS Month,
    ROUND(SUM(Amount), 2)   AS MonthlyTotal,
    COUNT(*)                AS Transactions
FROM pcards
WHERE Year = 2014
GROUP BY FullName, Month
HAVING SUM(Amount) > 10000
ORDER BY Month ASC, SUM(Amount) DESC;
