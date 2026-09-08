-- Part II · Control 1 | User shall not spend more than $50,000 per year.
-- Employees whose 2014 net spend exceeded $50,000, largest first.
-- Note: Year matches the calendar year of TransactionDate in 100% of rows
-- (489,178/489,178 verified), so Year = 2014 is an exact calendar-year filter.
-- Amount is summed net of credits/returns (negative amounts) — that is the
-- amount the cardholder actually cost the University over the year.
SELECT
    FullName                AS Name,
    ROUND(SUM(Amount), 2)   AS TotalSpent2014,
    COUNT(*)                AS Transactions
FROM pcards
WHERE Year = 2014
GROUP BY FullName
HAVING SUM(Amount) > 50000
ORDER BY SUM(Amount) DESC;
