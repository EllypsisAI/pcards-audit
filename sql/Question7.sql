-- Part II · Control 7 | P-cards must not be used for food or mileage while in travel
-- status (per diem is claimed on a travel voucher instead).
-- Days on which a cardholder charged lodging (MCC containing hotel, motel, resort or
-- inn) AND also charged an MCC containing food or restaurant on the same day.
WITH t AS (
    SELECT
        FullName, Vendor, Amount, Description, MCC, TransactionDate, PostedDate,
        printf('%04d-%02d-%02d',
            CAST(substr(substr(TransactionDate, 1, instr(TransactionDate, ' ') - 1),
                        length(substr(TransactionDate, 1, instr(TransactionDate, ' ') - 1)) - 3) AS INTEGER),
            CAST(substr(TransactionDate, 1, instr(TransactionDate, '/') - 1) AS INTEGER),
            CAST(substr(substr(TransactionDate, instr(TransactionDate, '/') + 1), 1,
                        instr(substr(TransactionDate, instr(TransactionDate, '/') + 1), '/') - 1) AS INTEGER)
        ) AS TxnDate
    FROM pcards
    WHERE Year = 2014
),
lodging_days AS (
    SELECT DISTINCT FullName, TxnDate
    FROM t
    WHERE UPPER(MCC) LIKE '%HOTEL%'
       OR UPPER(MCC) LIKE '%MOTEL%'
       OR UPPER(MCC) LIKE '%RESORT%'
       OR UPPER(MCC) LIKE '%INN%'
)
SELECT
    t.FullName          AS Name,
    ROUND(t.Amount, 2)  AS Amount,
    t.Description,
    t.Vendor,
    t.TxnDate           AS TransactionDate,
    t.PostedDate,
    t.MCC
FROM t
JOIN lodging_days l
  ON t.FullName = l.FullName AND t.TxnDate = l.TxnDate
WHERE UPPER(t.MCC) LIKE '%FOOD%'
   OR UPPER(t.MCC) LIKE '%RESTAURANT%'
ORDER BY t.FullName ASC, t.Amount ASC;
