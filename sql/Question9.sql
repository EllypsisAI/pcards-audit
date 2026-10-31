-- Part II · Control 9 (student-defined) | Donations and sponsorships.
-- Part I prohibits "Donations / Sponsorships" outright, and the Part IV brief lists them
-- among the prohibited purchases an auditor must be able to find.
--
-- Why the test is narrower than the merchant category: the obvious population, MCC
-- 'CHARITABLE AND SOCIAL SERVICE ORGANIZATIONS', holds 1,053 transactions worth $489,316
-- in 2014, but reading its largest vendors shows professional bodies, not charities —
-- NFPA fire-code standards, PLOS journal publication fees, ACUI and AACRAO conference
-- registrations. Those are legitimate business purchases from non-profits. A donation is
-- defined by the recipient being a cause, so the test takes non-profit-type merchants and
-- keeps only those whose name identifies a charitable cause, plus every payment to a
-- religious or political organisation and any line that calls itself a donation.
--
-- Output: transaction detail, largest amount first.
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
  AND Amount > 0
  AND (
        UPPER(MCC) IN ('RELIGIOUS ORGANIZATIONS', 'POLITICAL ORGANIZATIONS')
     OR ((UPPER(MCC) LIKE '%CHARITABLE%' OR UPPER(MCC) LIKE '%CIVIC,SOCIAL%')
         AND (UPPER(Vendor) LIKE '%FOUNDATION%'
           OR UPPER(Vendor) LIKE '%DONAT%'
           OR UPPER(Vendor) LIKE '%CHARIT%'
           OR UPPER(Vendor) LIKE '%SPONSOR%'
           OR UPPER(Vendor) LIKE '%RED CROSS%'
           OR UPPER(Vendor) LIKE '%UNITED WAY%'
           OR UPPER(Vendor) LIKE '%FOOD BANK%'
           OR UPPER(Vendor) LIKE '%MARCH OF DIMES%'
           OR UPPER(Vendor) LIKE '%HOSPICE%'
           OR UPPER(Vendor) LIKE '%MINISTR%'))
     OR UPPER(Description) LIKE '%DONATION%'
     OR UPPER(Description) LIKE '%SPONSORSHIP%'
  )
  -- a book titled "The Donation of Constantine" is not a donation
  AND UPPER(MCC) NOT LIKE '%BOOK%'
ORDER BY Amount DESC;
