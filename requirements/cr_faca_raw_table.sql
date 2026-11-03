-- USE cdrg_alpha;

DROP TABLE IF EXISTS raw_faca;

CREATE TABLE raw_faca (
	-- raw_faca_id  BIGINT AUTO_INCREMENT /*PRIMARY KEY*/, 
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
  -- PRIMARY KEY (raw_faca_id),
  is_occupation BOOL DEFAULT FALSE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;