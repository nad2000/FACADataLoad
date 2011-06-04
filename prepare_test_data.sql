SET @orgId=IFNULL( (SELECT MAX(org_id) FROM orgs), 0);
SET @indivId=IFNULL( (SELECT MAX(indiv_id) FROM indivs), 0);
SET @agencyId=IFNULL( (SELECT MAX(org_agency_id) FROM orgs_agencies), 0);

-- Delete 2/3 of data 
DELETE FROM indivs WHERE indiv_id > 2*@indivId/3;
DELETE FROM indivs_ext WHERE indiv_ext_ext_id > 2*@indivId/3;
DELETE FROM indivs_meta WHERE indiv_meta_indiv_id > 2*@indivId/3;

DELETE FROM orgs WHERE org_id > 2*@orgId/3;
DELETE FROM orgs_agencies WHERE org_agency_id > 2*@agencyId/3;
