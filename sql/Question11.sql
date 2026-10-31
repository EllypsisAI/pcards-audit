-- Part II · Control 11 (student-defined) | Purchases from University departments and
-- auxiliaries.
-- Part I: "University Departments and/or Auxiliaries - The campus vendor invoice (CVI)
-- system is to be used for the purchase of goods or services from University sources."
-- A P-card charge to an OSU unit moves money from one University account to another
-- through an external bank, paying card fees on an internal transfer and bypassing the
-- internal billing record.
--
-- Test: positive 2014 charges where the vendor is an OSU unit. "OSU" must stand as its
-- own word (padding with spaces) or open the vendor name, so names merely containing the
-- letters do not match. Branch campuses (OSU-Oklahoma City, OSU-Tulsa) and the OSU
-- Medical Center are reported but are separate institutions in the OSU system that may
-- sit outside Stillwater's CVI system — the conclusion treats them separately.
--
-- Output: transaction detail, sorted by vendor then amount, largest first.
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
  AND (' ' || UPPER(Vendor) || ' ' LIKE '% OSU %'
    OR UPPER(Vendor) LIKE 'OSU%'
    OR UPPER(Vendor) LIKE '%OKLAHOMA STATE UNIV%')
ORDER BY Vendor, Amount DESC;
