-- NB! This script should be executed after loading data from CSV file

SET @lastOrgId=(SELECT MAX(org_id) AS last_org_id FROM orgs);

-- ALTER TABLE raw_faca DROP INDEX raw_faca_org_id_idx;

-- Normalize Names:
UPDATE raw_faca
SET occupationoraffiliation=normal_name(occupationoraffiliation);

-- Match and link organizations to the loaded raw data.
UPDATE raw_faca JOIN orgs AS o
    ON raw_faca.org_id IS NULL AND raw_faca.occupationoraffiliation LIKE CONCAT('%',o.org_name,'%')
SET raw_faca.org_id = o.org_id;
UPDATE raw_faca JOIN org_aliases AS a
    ON raw_faca.org_id IS NULL AND raw_faca.occupationoraffiliation LIKE CONCAT('%',a.name,'%')
SET raw_faca.org_id = a.org_id;

-- Match and link agencies
UPDATE raw_faca JOIN orgs_agencies AS oa
    ON oa.org_agency_abbr=raw_faca.agencyabbr
SET raw_faca.agency_id = oa.org_agency_o_id;

SET @lastAgencyOrgId = (SELECT MAX(org_id) FROM orgs);

-- Match and link committee numbers to the loaded raw data.
UPDATE raw_faca JOIN orgs AS o
    ON raw_faca.comm_id IS NULL AND o.org_comm_no = raw_faca.cno AND o.org_sub_types LIKE '%AdvisoryCommittee%'
SET raw_faca.comm_id = o.org_id;

-- Create committees if no match found
INSERT IGNORE INTO orgs
    ( org_name, org_name_length, org_type, org_sub_types, org_parent_id, org_created )
SELECT -- DISTINCT -- TODO: check if it can improve performance
    committeename, LENGTH(committeename), 'Org', 'Org,GovernmentEntity,AdvisoryCommittee', agency_id, CURRENT_TIMESTAMP()
FROM raw_faca
WHERE agency_id IS NULL;

-- Match and link committee numbers again
UPDATE raw_faca JOIN orgs AS o
    ON raw_faca.comm_id IS NULL AND o.org_comm_no = raw_faca.cno AND o.org_sub_types LIKE '%AdvisoryCommittee%'
SET raw_faca.comm_id = o.org_id;

CREATE INDEX raw_faca_org_id_idx ON raw_faca (org_id);

-- Process Indivs
UPDATE raw_faca JOIN indivs as i
	ON raw_faca.indiv_id IS NULL AND i.indiv_full_name = raw_faca.fullname
SET raw_faca.indiv_id = i.indiv_id;

-- Insert new indivs
INSERT IGNORE INTO indivs
	( indiv_name, indiv_last, indiv_first, indiv_middle, indiv_title, indiv_suffix, indiv_full_name)
SELECT CONCAT(prefix,' ',firstname,' ',middlename,' ',lastname,', ',suffix),lastname,firstname,middlename,prefix,suffix,fullname
FROM raw_faca
WHERE indiv_id IS NULL;

-- Process Indivs again 
UPDATE raw_faca JOIN indivs as i
	ON raw_faca.indiv_id IS NULL AND i.indiv_full_name = raw_faca.fullname
SET raw_faca.indiv_id = i.indiv_id;

-- Process Affiliations:
SET @lastAffId=(SELECT MAX(aff_id) FROM affs);

-- Process Advisory Affiliations:
INSERT IGNORE INTO affs
    ( aff_subtype, aff_e1_id, aff_e1_type, aff_e2_id, aff_e2_type, 
    aff_start, aff_end, aff_created, aff_member_designation, aff_rep_group, aff_app_type, aff_app_term, aff_pay_plan, aff_pay_source, aff_chair)
SELECT 
    'advisory', comm_id, 'org', indiv_id, 'indiv', 
    STR_TO_DATE(startdate, '%m/%e/%y'), STR_TO_DATE(enddate, '%m/%e/%y'), CURRENT_TIMESTAMP(), memberdesignation, representedgroup , appointmenttype , appointmentterm, payplan, paysource, chairperson
FROM raw_faca AS r LEFT JOIN affs AS a
  ON aff_e1_id=comm_id AND aff_e2_id=indiv_id 
WHERE comm_id  IS NOT NULL AND org_id IS NOT NULL AND aff_id IS NULL;

-- Process Employment Affiliations:
INSERT IGNORE INTO affs
    ( aff_subtype, aff_e1_id, aff_e1_type, aff_e2_id, aff_e2_type, 
    aff_start, aff_created)
SELECT 
    'employment', org_id, 'org', indiv_id, 'indiv', fy, CURRENT_TIMESTAMP()
FROM raw_faca AS r LEFT JOIN affs AS a
  ON aff_e1_id=org_id AND aff_e2_id=indiv_id 
WHERE comm_id  IS NOT NULL AND org_id IS NOT NULL AND aff_id IS NULL;