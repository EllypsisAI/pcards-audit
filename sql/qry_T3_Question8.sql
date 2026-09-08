-- Part III · Question 8 (student-defined) | Fiscal year-end spending surge.
-- Fraud and misstatement risk: Oklahoma's fiscal year ends 30 June, and Part I refers to
-- fiscal-year thresholds. Budget holders who expect an unspent balance to lapse have an
-- incentive to spend it before the year closes — buying goods that are not yet needed,
-- prepaying (which Part I prohibits outright as a State statute violation), or stockpiling.
-- The signature is a June concentration that the rest of the cardholder's year does not
-- explain, so the test compares each cardholder's June against their own eleven-month
-- average rather than against other people.
-- Threshold: June spend of at least $5,000 and at least three times the cardholder's
-- average month, so that low-volume cards do not dominate on a ratio alone.
-- Output: cardholder, June spend, average other month, ratio, June charges; largest ratio first.
WITH monthly AS (
    SELECT FullName, Month, SUM(Amount) AS MonthTotal, COUNT(*) AS Charges
    FROM pcards
    WHERE Year = 2014
      AND Amount > 0
    GROUP BY FullName, Month
),
profile AS (
    SELECT
        FullName,
        SUM(CASE WHEN Month = 6 THEN MonthTotal ELSE 0 END)         AS JuneSpend,
        SUM(CASE WHEN Month = 6 THEN Charges ELSE 0 END)            AS JuneCharges,
        SUM(CASE WHEN Month <> 6 THEN MonthTotal ELSE 0 END) / 11.0 AS AvgOtherMonth
    FROM monthly
    GROUP BY FullName
)
SELECT
    FullName                                            AS Name,
    ROUND(JuneSpend, 2)                                 AS JuneSpend,
    JuneCharges,
    ROUND(AvgOtherMonth, 2)                             AS AvgOtherMonth,
    ROUND(JuneSpend / NULLIF(AvgOtherMonth, 0), 1)      AS JuneMultiple
FROM profile
WHERE JuneSpend >= 5000
  AND JuneSpend > 3 * AvgOtherMonth
ORDER BY JuneMultiple DESC, JuneSpend DESC;
