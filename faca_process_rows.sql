-- NB! This script should be executed after loading data from CSV file

SET @lastOrgId=IFNULL( (SELECT MAX(org_id) AS last_org_id FROM orgs), 0);
SELECT @lastOrgId AS `Last Org Id`;

-- ALTER TABLE raw_faca DROP INDEX raw_faca_org_id_idx;

-- Normalize Names:
UPDATE raw_faca 
SET occupationoraffiliation=normal_name(occupationoraffiliation);

CREATE INDEX raw_faca_occupationoraffiliation_idx ON raw_faca( occupationoraffiliation);

-- Mark occupations:
UPDATE raw_faca
SET is_occupation = TRUE
WHERE
    occupationoraffiliation IN ('poet', 'actress', 'actor', 'writer', 'Consultant',
        'adjunct professor',	'assistant member',	'assistant professor of medicine',	
        'assistant professor',	'assistant research scientist',	'associate director',	
        'associate member',	'associate professor of medicine',	'associate professor of pediatrics',	
        'associate professor',	'associate scientist', 'attorney',	'banker',	'business owner',	'chair',
        'chairman',	'chief',	'community volunteer',	'consultant',	'dean',	'director of research',	
        'director',	'executive director',	'general public',	'head',	'medical director',	'member',	
        'president', 'principal scientist',	'private consultant',	'professor', 'professor & chair',	
        'professor & chairman',	'professor & director',	'professor & head',	'professor and chair',	
        'professor and chairman',	'professor and chief',	'professor and director',	'professor and head',	
        'professor and vice chair',	'professor emeritus',	'professor of biochemistry', 
        'professor of biology',	'professor of medicine',	'professor of pathology',	
        'professor of pediatrics',	'professor of pharmacology',	'professor of psychology',	
        'professor of surgery',	'project director',	'rancher',	'research assistant professor',	
        'research associate professor',	'research associate',	'research director',	'research professor',	
        'research scientist',	'scientific director',	'scientist',	'senior investigator',	
        'senior research scientist',	'senior scientist',	'senior staff scientist',	'staff scientist',	
        'subsistence user',	'teacher',	'unaffiliated',	'vice president' )
    OR LOCATE( 'prof.',occupationoraffiliation)>0
    OR LOCATE( 'prof ',occupationoraffiliation)>0
    OR LOCATE( 'professor',occupationoraffiliation)>0;


-- Match and link agencies
UPDATE raw_faca JOIN orgs_agencies AS oa
    ON oa.org_agency_abbr=raw_faca.agencyabbr
SET raw_faca.agency_id = oa.org_agency_id;

SET @lastAgencyId = IFNULL((SELECT MAX(org_agency_id) FROM orgs_agencies), 0);
SELECT @lastAgencyId AS `Last Agency Org Id`;

INSERT IGNORE INTO orgs_agencies 
    ( org_agency_code, org_agency_abbr)
SELECT DISTINCT NULL, agencyabbr 
FROM raw_faca
WHERE agency_id IS NULL;

UPDATE raw_faca JOIN orgs_agencies AS oa
    ON oa.org_agency_abbr=raw_faca.agencyabbr
SET raw_faca.agency_id = oa.org_agency_id
WHERE raw_faca.agency_id IS NULL
    AND org_agency_id>@lastAgencyId;

--
-- Committees
--

SET @lastAgencyOrgId = IFNULL((SELECT MAX(org_id) FROM orgs), 0);
SELECT @lastAgencyOrgId AS `Last Agency Org Id`;

-- Match and link committee numbers to the loaded raw data.
UPDATE raw_faca JOIN orgs AS o
    ON raw_faca.comm_id IS NULL 
    AND o.org_comm_no = raw_faca.cno 
    AND o.is_advisory_committee
SET raw_faca.comm_id = o.org_id;

SET @CurrentTS = CURRENT_TIMESTAMP();
-- Create committees if no match found
INSERT INTO orgs
    (
        org_name, 
        org_name_length, 
        org_type, 
        org_sub_types, 
        org_parent_id, 
        org_created,
        org_comm_no,
        is_advisory_committee,
        agency_id)
SELECT DISTINCT -- TODO: check if it can improve performance
    committeename,
    LENGTH(committeename), 
    'Org', 
    'Org,GovernmentEntity,AdvisoryCommittee', 
    agency_id, 
    @CurrentTS,
    cno,
    TRUE,
    org_agency_id AS agency_id
FROM raw_faca JOIN orgs_agencies
    ON orgs_agencies.org_agency_abbr = raw_faca.agencyabbr
WHERE comm_id IS NULL -- AND cno IS NOT NULL
ON DUPLICATE KEY UPDATE
    org_comm_no = cno,
    is_advisory_committee = TRUE,
    org_sub_types = 'Org,GovernmentEntity,AdvisoryCommittee',
    agency_id = org_agency_id;

-- Match and link committee numbers again
UPDATE raw_faca JOIN orgs AS o
    ON raw_faca.comm_id IS NULL 
    AND o.org_comm_no = raw_faca.cno 
    AND o.is_advisory_committee -- AND o.org_sub_types LIKE '%AdvisoryCommittee%'
    AND o.org_id > @lastAgencyOrgId
SET raw_faca.comm_id = o.org_id;


--
-- Individuals:
-- 

-- Process Indivs
UPDATE raw_faca JOIN indivs as i
	ON raw_faca.indiv_id IS NULL
    AND i.indiv_last = raw_faca.lastname
    AND i.indiv_first = raw_faca.firstname
    AND i.indiv_middle = raw_faca.middlename
SET raw_faca.indiv_id = i.indiv_id;

-- Insert new indivs
INSERT IGNORE INTO indivs
	( indiv_name, indiv_last, indiv_first, indiv_middle, indiv_title, indiv_suffix, indiv_full_name)
SELECT DISTINCT
    CONCAT(prefix,' ',firstname,' ',middlename,' ',lastname,', ',suffix) AS indiv_name,
    lastname,
    firstname,
    middlename,
    prefix,
    suffix,
    CONCAT( firstname,' ',middlename,' ',lastname ) AS fullname
FROM raw_faca
WHERE indiv_id IS NULL;

-- Process Indivs again:
UPDATE raw_faca JOIN indivs as i
	ON raw_faca.indiv_id IS NULL
    AND i.indiv_last = raw_faca.lastname
    AND i.indiv_first = raw_faca.firstname
    AND i.indiv_middle = raw_faca.middlename
SET raw_faca.indiv_id = i.indiv_id;


-- Match and link organizations to the loaded raw data.

/*
UPDATE raw_faca JOIN orgs AS o
    ON
        NOT(is_occupation)
        AND raw_faca.org_id IS NULL
        -- AND f.fragment LIKE CONCAT( o.org_name, '%')
        AND LOCATE( o.org_name, raw_faca.occupationoraffiliation) > 0
SET raw_faca.org_id = o.org_id;

-- TODO: optimize
UPDATE raw_faca JOIN affs_fragment AS f
    ON NOT(is_occupation) AND raw_faca.org_id IS NULL AND f.raw_faca_id = raw_faca.raw_faca_id
JOIN orgs AS o
    ON
        NOT(is_occupation)
        AND raw_faca.org_id IS NULL
        AND f.fragment LIKE CONCAT( o.org_name, '%')
        -- AND LOCATE( o.org_name, raw_faca.occupationoraffiliation) > 0
SET raw_faca.org_id = o.org_id;

*/

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

SELECT COUNT(*) AS `Rows to match:` FROM raw_faca WHERE NOT(is_occupation) AND raw_faca.org_id IS NULL;
CALL match_organizations();
SELECT COUNT(*) AS `Rows not matched:` FROM raw_faca WHERE NOT(is_occupation) AND raw_faca.org_id IS NULL;
--
-- Affiliations:
-- 

-- Process Affiliations:
SET @lastAffId=IFNULL( (SELECT MAX(aff_id) FROM affs), 0);
SELECT @lastAffId AS `Last Affiliation Id`;

SET @CurrentTS = CURRENT_TIMESTAMP();

-- Process Advisory Affiliations:
INSERT IGNORE INTO affs
    ( aff_subtype, aff_e1_id, aff_e1_type, aff_e2_id, aff_e2_type, 
    aff_start, aff_end, aff_created, aff_member_designation, 
    aff_rep_group, aff_app_type, aff_app_term, aff_pay_plan, aff_pay_source, aff_chair)
SELECT 
    'advisory', comm_id, 'org', indiv_id, 'indiv', 
    startdate, enddate, @CurrentTS, memberdesignation, 
    representedgroup , appointmenttype , appointmentterm, payplan, paysource, chairperson
FROM raw_faca AS r JOIN orgs AS o 
    ON o.org_id = r.comm_id --r.org_id
    AND o.is_advisory_committee
LEFT JOIN affs AS a
  ON aff_e1_id=comm_id AND aff_e2_id=indiv_id 
WHERE a.aff_id IS NULL;

-- Process Employment Affiliations:
INSERT IGNORE INTO affs
    ( aff_subtype, aff_e1_id, aff_e1_type, aff_e2_id, aff_e2_type, 
    aff_start, aff_created)
SELECT 
    'employment', r.org_id, 'org', indiv_id, 'indiv', fy, CURRENT_TIMESTAMP()
FROM raw_faca AS r JOIN orgs AS o 
    ON o.org_id = r.org_id AND NOT( is_advisory_committee)
LEFT JOIN affs AS a
    ON aff_e1_id=r.org_id AND aff_e2_id=r.indiv_id 
WHERE a.aff_id IS NULL;