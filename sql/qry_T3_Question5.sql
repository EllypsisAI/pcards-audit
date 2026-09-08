-- Part III · Question 5 (student-defined) | Weekend purchasing at retail merchants.
-- Fraud risk: a P-card used for personal shopping is most likely to be used when the
-- cardholder is not at work. University buying happens in office hours; a card that is
-- consistently active on Saturdays and Sundays at consumer-retail merchants is behaving
-- like a personal card. Isolated weekend activity is expected (conference travel, event
-- setup, facilities call-outs), so the test targets repetition, not single occurrences.
-- Merchant types that are legitimately weekend-heavy for a university — lodging, airlines,
-- restaurants, fuel and freight, all of which appear on travel and event weekends — are
-- excluded so that the population is consumer retail rather than travel.
-- Output: cardholder, weekend charges, value, distinct vendors, weekend share of their
-- own transaction count; most weekend charges first. Fewer than three excluded as noise.
WITH t AS (
    SELECT
        FullName, Vendor, Amount, MCC,
        printf('%04d-%02d-%02d',
            CAST(substr(substr(TransactionDate, 1, instr(TransactionDate, ' ') - 1),
                        length(substr(TransactionDate, 1, instr(TransactionDate, ' ') - 1)) - 3) AS INTEGER),
            CAST(substr(TransactionDate, 1, instr(TransactionDate, '/') - 1) AS INTEGER),
            CAST(substr(substr(TransactionDate, instr(TransactionDate, '/') + 1), 1,
                        instr(substr(TransactionDate, instr(TransactionDate, '/') + 1), '/') - 1) AS INTEGER)
        ) AS TxnDate
    FROM pcards
    WHERE Year = 2014
      AND Amount > 0
),
classified AS (
    SELECT *,
        CAST(strftime('%w', TxnDate) AS INTEGER) AS DayOfWeek,
        CASE WHEN UPPER(MCC) LIKE '%HOTEL%'   OR UPPER(MCC) LIKE '%MOTEL%'
               OR UPPER(MCC) LIKE '%INN%'     OR UPPER(MCC) LIKE '%RESORT%'
               OR UPPER(MCC) LIKE '%LODGING%' OR UPPER(MCC) LIKE '%AIRLINE%'
               OR UPPER(MCC) LIKE '%AIR CARRIER%' OR UPPER(MCC) LIKE '%RESTAURANT%'
               OR UPPER(MCC) LIKE '%FOOD%'    OR UPPER(MCC) LIKE '%SERVICE STATION%'
               OR UPPER(MCC) LIKE '%FUEL%'    OR UPPER(MCC) LIKE '%COURIER%'
               OR UPPER(MCC) LIKE '%CAR RENTAL%' OR UPPER(MCC) LIKE '%TRANSPORTATION%'
             THEN 1 ELSE 0 END AS IsTravelType
    FROM t
)
SELECT
    FullName                                                                AS Name,
    SUM(CASE WHEN DayOfWeek IN (0, 6) AND IsTravelType = 0 THEN 1 ELSE 0 END)           AS WeekendRetailCharges,
    ROUND(SUM(CASE WHEN DayOfWeek IN (0, 6) AND IsTravelType = 0 THEN Amount ELSE 0 END), 2) AS WeekendRetailValue,
    COUNT(*)                                                                AS AllCharges2014,
    ROUND(100.0 * SUM(CASE WHEN DayOfWeek IN (0, 6) AND IsTravelType = 0 THEN 1 ELSE 0 END)
          / COUNT(*), 1)                                                    AS WeekendRetailPercent
FROM classified
GROUP BY FullName
HAVING WeekendRetailCharges >= 3
ORDER BY WeekendRetailCharges DESC, WeekendRetailValue DESC;
