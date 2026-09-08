-- Part III · Question 1 | Benford's Law, first digit of transaction amounts.
-- OSU, calendar year 2014, amounts of $1.00 and above (amounts below $1.00 have no
-- meaningful first digit and negatives are returns, both excluded by the same filter).
-- Benford's Law expects the leading digit of naturally occurring financial amounts to be
-- 1 about 30.1% of the time, falling to 4.6% for 9. Large departures from that curve —
-- particularly a deficit of 1s or a surplus of 5s, 6s and 9s — indicate amounts that were
-- chosen by a person rather than set by a transaction.
-- Single query, percentages rounded to three decimal places, digits 1 through 9.
SELECT
    CAST(substr(CAST(CAST(Amount AS INTEGER) AS TEXT), 1, 1) AS INTEGER)    AS FirstDigit,
    COUNT(*)                                                                AS Transactions,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM pcards
                              WHERE Year = 2014 AND Amount >= 1.00), 3)     AS PercentActual,
    CASE CAST(substr(CAST(CAST(Amount AS INTEGER) AS TEXT), 1, 1) AS INTEGER)
        WHEN 1 THEN 30.103 WHEN 2 THEN 17.609 WHEN 3 THEN 12.494
        WHEN 4 THEN 9.691  WHEN 5 THEN 7.918  WHEN 6 THEN 6.695
        WHEN 7 THEN 5.799  WHEN 8 THEN 5.115  WHEN 9 THEN 4.576
    END                                                                     AS PercentExpected,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM pcards
                              WHERE Year = 2014 AND Amount >= 1.00)
          - CASE CAST(substr(CAST(CAST(Amount AS INTEGER) AS TEXT), 1, 1) AS INTEGER)
                WHEN 1 THEN 30.103 WHEN 2 THEN 17.609 WHEN 3 THEN 12.494
                WHEN 4 THEN 9.691  WHEN 5 THEN 7.918  WHEN 6 THEN 6.695
                WHEN 7 THEN 5.799  WHEN 8 THEN 5.115  WHEN 9 THEN 4.576
            END, 3)                                                         AS Deviation
FROM pcards
WHERE Year = 2014
  AND Amount >= 1.00
GROUP BY FirstDigit
ORDER BY FirstDigit;
