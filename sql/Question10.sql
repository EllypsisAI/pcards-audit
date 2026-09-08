-- Part II · Control 10 (student-defined) | Gasoline must not be bought on a P-card.
-- Part I: "Gasoline - Gasoline should be purchased from Transportation Services or with
-- the gasoline credit card provided with each University vehicle."
--
-- Refinement made after a first run: MCC alone does not separate fuelling a vehicle at a
-- pump from a bulk fuel delivery to a facility. Both carry service-station MCCs (the
-- largest single "service station" charge in 2014 is $4,075, which is not a car). Fuel
-- dealer MCCs (fuel oil, wood, coal, propane) are heating fuel and are excluded entirely.
-- The test therefore reports pump-sized charges (<= $150, a plausible tank fill) separately
-- from larger charges, so the auditor can target the population the policy is aimed at.
--
-- Output: cardholder, pump-sized fuel charges and their value, larger charges and their
-- value, distinct stations; most pump-sized charges first.
SELECT
    FullName                                                            AS Name,
    SUM(CASE WHEN Amount <= 150 THEN 1 ELSE 0 END)                      AS PumpSizedCharges,
    ROUND(SUM(CASE WHEN Amount <= 150 THEN Amount ELSE 0 END), 2)       AS PumpSizedValue,
    SUM(CASE WHEN Amount > 150 THEN 1 ELSE 0 END)                       AS LargerCharges,
    ROUND(SUM(CASE WHEN Amount > 150 THEN Amount ELSE 0 END), 2)        AS LargerValue,
    COUNT(DISTINCT Vendor)                                              AS DistinctStations,
    ROUND(SUM(Amount), 2)                                               AS TotalFuelSpend
FROM pcards
WHERE Year = 2014
  AND (UPPER(MCC) LIKE '%SERVICE STATION%'
    OR UPPER(MCC) LIKE '%FUEL DISPENSER%')
GROUP BY FullName
ORDER BY PumpSizedCharges DESC, TotalFuelSpend DESC;
