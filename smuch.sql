/*
truncate table cdrg.org_aliases;
truncate table cdrg.orgs;
*/


INSERT INTO orgs_meta
    (org_meta_org_id, org_meta_employees, org_meta_employees_year,org_meta_revenue, org_meta_revenue_year)
SELECT
    org_id, numberofemployees, fiscal_year, annualrevenue, fiscal_year
FROM raw_row
WHERE org_id IS NOT NULL
ON DUPLICATE KEY UPDATE
    org_meta_employees = numberofemployees,
    org_meta_employees_year = fiscal_year,
    org_meta_revenue = annualrevenue,
    org_meta_revenue_year = fiscal_year;
    

INSERT IGNORE INTO orgs_contact (
    org_contact_org_id, org_contact_address1, org_contact_address2,
    org_contact_address3,org_contact_city,org_contact_state,org_contact_zip,
    org_contact_country,org_contact_cd, org_contact_phone, org_contact_fax
)
SELECT
    org_id, streetaddress, streetaddress2, 
    streetaddress3,city,state,zipcode,
    vendorcountrycode,vendor_cd, phoneno, faxno
FROM raw_row
WHERE org_id IS NOT NULL;

truncate table orgs_ext;

CREATE INDEX raw_row_org_id_idx ON raw_row (org_id);

INSERT IGNORE INTO orgs_ext
(org_ext_local_id, org_ext_local_type, org_ext_remote_src)
SELECT
    org_id, 'org', 'usaspending'
FROM raw_row
WHERE org_id IS NOT NULL;

truncate table org_ref_duns;
-- UPDATE raw_row SET dunsnumber=TRIM(dunsnumber), parentdunsnumber=TRIM(parentdunsnumber) WHERE org_id IS NOT NULL;
INSERT IGNORE org_ref_duns ( org_id, duns)
SELECT org_id, dunsnumber FROM raw_row 
WHERE org_id IS NOT NULL AND dunsnumber IS NOT NULL AND dunsnumber!=''
UNION
SELECT org_id, parentdunsnumber FROM raw_row 
WHERE org_id IS NOT NULL AND parentdunsnumber IS NOT NULL AND parentdunsnumber!='';

SELECT org_id, dunsnumber FROM raw_row limit 100;

select maj_agency_cat from raw_row;
SELECT TRIM(SUBSTRING_INDEX('70: Department of Homeland Security',':',-1));

-- Match and link agencies
UPDATE raw_row JOIN orgs_agencies AS oa 
    ON oa.org_agency_code=raw_row.maj_agency_cat
SET raw_row.agency_org_id = oa.org_agency_o_id;
-- Create agnency trgs if no match found
SET @lastOrgId = (SELECT MAX(org_id) FROM orgs);
INSERT IGNORE INTO orgs
    ( org_name, org_name_length, org_type, org_sub_types, org_aliases, org_created )
SELECT a.org_name, NULL, 'Org', 'Org, GovernmentEntity,Federal,Agency', NULL, CURRENT_TIMESTAMP()
FROM
( SELECT DISTINCT
    maj_agency_cat AS org_name
FROM raw_row
WHERE agency_org_id IS NULL ) AS a;
INSERT IGNORE INTO orgs_agencies ( org_agency_code, org_agency_o_id)
SELECT org_name, org_id
FROM orgs
WHERE org_id>@lastOrgId;
INSERT IGNORE INTO orgs_meta ( org_meta_org_id, org_meta_is_govt, org_meta_is_fed)
SELECT org_id, 1, 1
FROM orgs
WHERE org_id>@lastOrgId;
INSERT IGNORE INTO orgs_ext
    ( org_ext_local_type, org_ext_local_id, org_ext_remote_src)
SELECT 'org', org_id, 'usaspending'
FROM orgs
WHERE org_id>@lastOrgId;
UPDATE orgs
SET org_name = CONCAT('U.S. ', TRIM(SUBSTRING_INDEX( org_name,':',-1)) )
WHERE org_id>@lastOrgId AND LOCATE( ':', org_name) > 0;
UPDATE orgs SET org_name_length = LENGTH( org_name)
WHERE org_id>@lastOrgId;
-- Match and link missing agencies:
UPDATE raw_row JOIN orgs_agencies AS oa 
    ON oa.org_agency_code=raw_row.maj_agency_cat AND raw_row.agency_org_id IS NULL
SET raw_row.agency_org_id = oa.org_agency_o_id;

DELETE FROM orgs;
DELETE FROM org_ref_duns;
DELETE FROM orgs_contact;
DELETE FROM orgs_meta;
DELETE FROM orgs_agencies;
select * from orgs_agencies;
DELETE FROM orgs_ext;

SELECT
    MAX(LENGTH( AgencyAbbr)),
    MAX(LENGTH( CommitteeName)),
    MAX(LENGTH( CNo)),
    MAX(LENGTH( FY)),
    MAX(LENGTH( Prefix)),
    MAX(LENGTH( FirstName)),
    MAX(LENGTH( MiddleName)),
    MAX(LENGTH( LastName)),
    MAX(LENGTH( Suffix)),
    MAX(LENGTH( MemberDesignation)),
    MAX(LENGTH( RepresentedGroup)),
    MAX(LENGTH( Chairperson)),
    MAX(LENGTH( OccupationOrAffiliation)),
    MAX(LENGTH( StartDate)),
    MAX(LENGTH( EndDate)),
    MAX(LENGTH( AppointmentType)),
    MAX(LENGTH( AppointmentTerm)),
    MAX(LENGTH( PayPlan)),
    MAX(LENGTH( PaySource))
FROM raw_faca;


SELECT DISTINCT OccupationOrAffiliation,
-- CNo
-- FY,
-- MemberDesignation,
-- RepresentedGroup,
-- StartDate,
-- EndDate,
-- AppointmentType,
-- AppointmentTerm,
-- PayPlan,
-- PaySource
'x'
FROM raw_faca;

SELECT STR_TO_DATE('10/1/1996 0:00:00','%m/%d/%Y');

select occupationoraffiliation, MATCH (occupationoraffiliation) AGAINST ('prof.')
from raw_faca
where MATCH (occupationoraffiliation) AGAINST ('prof.') > 0
limit 100;