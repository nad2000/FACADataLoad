--
-- Create name fragments:
-- 
TRUNCATE TABLE affs_fragment;

DROP INDEX affs_fragment_fragment_idx ON affs_fragment;
DROP INDEX affs_fragment_raw_faca_id_idx ON affs_fragment;

INSERT INTO affs_fragment
    ( raw_faca_id, fragment )
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -35)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -35) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -35)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -35) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -34)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -34) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -33)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -33) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -32)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -32) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -31)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -31) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -30)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -30) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -29)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -29) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -28)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -28) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -27)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -27) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -26)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -26) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -25)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -25) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -24)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -24) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -23)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -23) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -22)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -22) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -21)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -21) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -20)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -20) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -19)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -19) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -18)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -18) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -17)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -17) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -16)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -16) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -15)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -15) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -14)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -14) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -13)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -13) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -12)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -12) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -11)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -11) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -10)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -10) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -9)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -9) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -8)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -8) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -7)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -7) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -6)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -6) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -5)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -5) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -4)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -4) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -3)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -3) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -2)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -2) != occupationoraffiliation
UNION ALL
SELECT raw_faca_id, SUBSTRING_INDEX( occupationoraffiliation, ' ', -1)
FROM raw_faca
WHERE NOT(is_occupation) AND SUBSTRING_INDEX( occupationoraffiliation, ' ', -1) != occupationoraffiliation;

DELETE FROM affs_fragment WHERE LENGTH( fragment) < 6;

DELETE FROM affs_fragment 
WHERE 
    LEFT( fragment, 1) NOT BETWEEN 'A' AND 'Z' 
    AND LEFT( fragment, 1) NOT BETWEEN 'a' AND 'z';

CREATE INDEX affs_fragment_fragment_idx ON affs_fragment (fragment /*, frabment_len DESC*/);
CREATE INDEX affs_fragment_raw_faca_id_idx ON affs_fragment (raw_faca_id);

SELECT DISTINCT fragment, LENGTH(fragment) FROM affs_fragment ORDER BY 2 DESC,1;

SELECT DISTINCT LEFT( fragment, 1) FROM affs_fragment ORDER BY 1;

-- SELECT * FROM affs_fragment WHERE fragment LIKE 'Community%';




select version();