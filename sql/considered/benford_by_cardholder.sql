-- Considered and rejected · Part III — Benford's first-digit test per cardholder
-- Idea: Question 1 tests the whole file, where one person's invented amounts would vanish.
-- Testing each high-volume card (300+ charges of $1.00 or more) on its own should expose
-- a person rather than a population.
-- Rejected: half of these cards fail Benford, and every one at the top fails because of a
-- fixed price billed over and over (a $30 data plan, an $83 room rate, an $8 e-fee).
-- Benford assumes amounts vary freely; fixed prices break that assumption, so per-card
-- Benford finds billing arrangements, not fraud.
-- MAD = mean absolute deviation of the nine digit shares; above 0.015 is nonconformity
-- on Nigrini's first-digit scale.
WITH t AS (
    SELECT FullName, Amount,
           CAST(SUBSTR(CAST(CAST(Amount AS INTEGER) AS TEXT), 1, 1) AS INTEGER) AS d
    FROM pcards WHERE Year = 2014 AND Amount >= 1
),
cards AS (SELECT FullName, COUNT(*) AS n FROM t GROUP BY FullName HAVING COUNT(*) >= 300),
benford(d, p) AS (VALUES (1, 0.30103), (2, 0.17609), (3, 0.12494), (4, 0.09691), (5, 0.07918),
                         (6, 0.06695), (7, 0.05799), (8, 0.05115), (9, 0.04576)),
obs AS (SELECT FullName, d, COUNT(*) AS k FROM t
        WHERE FullName IN (SELECT FullName FROM cards) GROUP BY FullName, d)
SELECT c.FullName,
       c.n AS Transactions,
       ROUND(AVG(ABS(COALESCE(o.k, 0) * 1.0 / c.n - b.p)), 4) AS MAD,
       (SELECT ROUND(Amount, 2) FROM t WHERE t.FullName = c.FullName
        GROUP BY ROUND(Amount, 2) ORDER BY COUNT(*) DESC LIMIT 1) AS MostRepeatedAmount,
       (SELECT COUNT(*) FROM t WHERE t.FullName = c.FullName
        GROUP BY ROUND(Amount, 2) ORDER BY COUNT(*) DESC LIMIT 1) AS TimesRepeated
FROM cards c
CROSS JOIN benford b
LEFT JOIN obs o ON o.FullName = c.FullName AND o.d = b.d
GROUP BY c.FullName, c.n
ORDER BY MAD DESC;
