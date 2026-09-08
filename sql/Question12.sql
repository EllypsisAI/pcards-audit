-- Part II · Control 12 (student-defined) | Cash, cash advances and ATM transactions.
-- Part I prohibits "Cash, Cash Advances, Automated Teller Machine (ATM) Transactions".
-- This is a preventive control: the Purchasing Department blocks the relevant MCC groups
-- at the point of sale, so the expected result is nil. The test evidences that the block
-- operated for the whole of 2014 — a control test that passes is still an audit result.
--
-- Refinement made after a first run: matching the vendor field on '%ATM%' returned six
-- transactions, none of them cash withdrawals. 'ATM' is a substring of ordinary words —
-- it matched the vendors "THE ROYAL TREATMENT @ HEA" (treATMent) and "PAYPAL LPLATMAN".
-- Padding the vendor with spaces and matching '% ATM %' requires ATM to stand as its own
-- word, which removes both false positives without weakening the test.
--
-- Output: full transaction detail; an empty result set evidences an effective control.
SELECT
    ROUND(Amount, 2)    AS Amount,
    FullName            AS Name,
    Description,
    Vendor,
    TransactionDate,
    PostedDate,
    MCC
FROM pcards
WHERE Year = 2014
  AND (UPPER(MCC) LIKE '%CASH%'
    OR UPPER(MCC) LIKE '%MONEY TRANSFER%'
    OR UPPER(MCC) LIKE '%QUASI%'
    OR UPPER(MCC) LIKE '%FINANCIAL INSTITUTION%'
    OR ' ' || UPPER(MCC)    || ' ' LIKE '% ATM %'
    OR ' ' || UPPER(Vendor) || ' ' LIKE '% ATM %'
    OR UPPER(Vendor) LIKE '%CASH ADVANCE%'
    OR UPPER(Vendor) LIKE '%WESTERN UNION%'
    OR UPPER(Vendor) LIKE '%MONEYGRAM%')
ORDER BY Amount DESC;
