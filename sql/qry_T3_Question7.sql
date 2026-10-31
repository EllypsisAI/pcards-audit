-- Part III · Question 7 (student-defined) | Untraceable refunds — credits from vendors the
-- cardholder never paid.
-- Risk: Part III covers "fraud or processing errors", and this is mainly the second.
-- Part I requires the cardholder to check that returns are credited properly. That check
-- only works if every credit traces back to a purchase; a credit with no purchase behind it
-- can be a merchant reversing a transaction the University never recorded, a returned item
-- whose original purchase sits on somebody else's card, or a refund for goods bought with
-- other funds being routed onto a University card.
-- Known limit: the case restricts testing to 2014, so a credit in early 2014 for a purchase
-- made in late 2013 also appears here. Those are false positives the test cannot remove.
--
-- The first version of this test matched credits against charges of the same amount and
-- returned 2,351 of the 3,791 credits — a population too large to be a finding, because
-- partial refunds, restocking deductions and price adjustments legitimately fail an exact
-- amount match. Requiring instead that the cardholder made *no* purchase at that vendor
-- all year narrows it to 298, and a $100 materiality floor to 115. That version also runs
-- as a join rather than a correlated subquery: 92 seconds down to under a second.
--
-- Output: credit amount, cardholder, vendor and detail; largest credit first.
WITH charges AS (
    SELECT FullName, Vendor,
           COUNT(*)         AS ChargeCount,
           SUM(Amount)      AS ChargeValue
    FROM pcards
    WHERE Year = 2014
      AND Amount > 0
    GROUP BY FullName, Vendor
)
SELECT
    ROUND(c.Amount, 2)  AS CreditAmount,
    c.FullName          AS Name,
    c.Vendor,
    c.Description,
    c.TransactionDate,
    c.PostedDate,
    c.MCC
FROM pcards c
LEFT JOIN charges ch
       ON ch.FullName = c.FullName
      AND ch.Vendor   = c.Vendor
WHERE c.Year = 2014
  AND c.Amount <= -100
  AND ch.FullName IS NULL
ORDER BY c.Amount ASC;
