DROP PROCEDURE match_organizations;

DELIMITER $$

CREATE PROCEDURE match_organizations()
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE org_id INT;
  DECLARE org_name VARCHAR(1000);
  DECLARE org_cr CURSOR FOR
    SELECT org_id, org_name
    FROM orgs
    WHERE NOT(is_advisory_committee)
    ORDER BY org_name_length DESC, org_name;
  DECLARE alias_cr CURSOR FOR
    SELECT
        org_alias_org_id AS org_id,
        org_alias
    FROM org_aliases
    ORDER BY LENGTH( org_alias) DESC;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  OPEN org_cr;
  read_loop: LOOP
    FETCH org_cr INTO org_id, org_name;
    IF done THEN
      LEAVE read_loop;
    END IF;

    UPDATE raw_faca JOIN (SELECT raw_faca_id FROM affs_fragment WHERE fragment LIKE CONCAT( org_name, '%') ) AS f
    ON
        NOT(is_occupation) 
        AND raw_faca.org_id IS NULL 
        AND f.raw_faca_id = raw_faca.raw_faca_id
        -- AND f.fragment LIKE CONCAT( org_name, '%')
        -- AND LOCATE( o.org_name, raw_faca.occupationoraffiliation) > 0
    SET raw_faca.org_id = org_id;
    
  END LOOP;
  CLOSE org_cr;

  -- Aliases:
  SET done=0;
  OPEN alias_cr;
  read_loop: LOOP
    FETCH alias_cr INTO org_id, org_name;
    IF done THEN
      LEAVE read_loop;
    END IF;

    UPDATE raw_faca JOIN (SELECT raw_faca_id FROM affs_fragment WHERE fragment LIKE CONCAT( org_name, '%') ) AS f
    ON
        NOT(is_occupation) 
        AND raw_faca.org_id IS NULL 
        AND f.raw_faca_id = raw_faca.raw_faca_id
        AND raw_faca.org_id IS NULL
        -- AND f.fragment LIKE CONCAT( org_name, '%')
            -- AND LOCATE( o.org_name, raw_faca.occupationoraffiliation) > 0
    SET raw_faca.org_id = org_id;
    
  END LOOP;
  CLOSE alias_cr;

END$$

DELIMITER ;