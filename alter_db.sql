-- USE cdrg_alpha;

DROP TABLE IF EXISTS raw_faca;

CREATE TABLE raw_faca (
	raw_faca_id INT AUTO_INCREMENT PRIMARY KEY, 
	agencyabbr varchar(15),
	committeename varchar(450),
	cno INT,
	fy YEAR,
	prefix VARCHAR(15),
	firstname VARCHAR(150),
	middlename VARCHAR(150),
	lastname VARCHAR(150),
	suffix VARCHAR(150),
	memberdesignation VARCHAR(45),
	representedgroup VARCHAR(450),
	chairperson VARCHAR(3),
	-- occupationoraffiliation TEXT,
  occupationoraffiliation VARCHAR(1600),
	startdate DATE,
	enddate DATE,
	appointmenttype VARCHAR(25),
	appointmentterm VARCHAR(25),
	payplan VARCHAR(150),
	paysource VARCHAR(150),	
    
  org_id BIGINT NULL,
  agency_id BIGINT NULL,
  comm_id BIGINT NULL,
  indiv_id BIGINT NULL,
  fullname VARCHAR(450) NULL,
  -- `occupationoraffiliation` contains an occupation
  is_occupation BOOL DEFAULT FALSE 
)
ENGINE=MyISAM DEFAULT CHARSET=utf8;


ALTER TABLE orgs ADD is_advisory_committee BOOL DEFAULT FALSE; 
UPDATE orgs SET is_advisory_committee=(org_sub_types LIKE '%AdvisoryCommittee%');

DROP INDEX orgs_agencies_org_agency_abbr_idx ON orgs_agencies;
CREATE INDEX orgs_agencies_org_agency_abbr_idx ON orgs_agencies(org_agency_abbr);

DROP INDEX indivs_indiv_full_name_idx ON indivs;
CREATE INDEX indivs_indiv_full_name_idx ON indivs( indiv_full_name);

DROP INDEX indivs_name_idx ON indivs;
CREATE INDEX indivs_name_idx ON indivs( indiv_last(50), indiv_first(50), indiv_middle(50));

DROP INDEX affs_comm_indiv_idx ON affs;
ALTER IGNORE TABLE affs ADD UNIQUE INDEX affs_comm_indiv_idx ( aff_e1_id, aff_e2_id);

DELETE FROM orgs
WHERE org_name IN (
    'poet', 'actress', 'actor', 'writer', 'consultant',
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
OR LOCATE( 'prof.',org_name)>0
OR LOCATE( 'professor',org_name)>0;

DELETE FROM org_aliases
WHERE org_alias IN (
    'poet', 'actress', 'actor', 'writer', 'consultant',
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
OR LOCATE( 'prof.', org_alias)>0
OR LOCATE( 'professor', org_alias)>0;


-- many committees belongs to one agency NOT many agencies related to one commitee!!!
ALTER TABLE orgs_agencies DROP COLUMN org_agency_o_id;
ALTER TABLE orgs_agencies DROP INDEX org_agency_o_id;

ALTER IGNORE TABLE orgs_agencies ADD COLUMN agency_id INT NOT NULL AFTER is_advisory_committee;

DROP INDEX orgs_agencies_org_agency_abbr_idx ON orgs_agencies;
ALTER IGNORE TABLE orgs_agencies ADD UNIQUE INDEX orgs_agencies_org_agency_abbr_idx ( org_agency_abbr);


DROP TABLE IF EXISTS affs_fragment;

CREATE TABLE affs_fragment (
	raw_faca_id INT, 
  fragment VARCHAR(1600)
)
ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Fix data:
UPDATE orgs SET org_name = normal_name(org_name);
UPDATE orgs SET org_name_length = LENGTH( org_name);

DROP FUNCTION IF EXISTS normal_name;

DELIMITER $$
CREATE FUNCTION normal_name (v TEXT)
RETURNS TEXT
    COMMENT 'Normalize a string stripping delimiters and excluding delimiter repeats'
    LANGUAGE SQL
    DETERMINISTIC
    CONTAINS SQL
BEGIN
SET v = TRIM(
REPLACE(REPLACE(REPLACE(REPLACE( REPLACE(v,'\t',' '), '  ', ' '), '  ', ' '), '  ', ' '), '  ', ' ')
);
IF v='' THEN SET v=NULL; END IF;
RETURN v;
END$$

DELIMITER ;

-- TEST:
/*
SELECT LENGTH( v)=13, v FROM (
SELECT normal_name( '    a   a  \t  a     a     a  \t     a             a  \t   ') AS v) AS t;
SELECT normal_name(' \t  ');

*/

ALTER IGNORE TABLE orgs ADD agency_id INT NULL;

