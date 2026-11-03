TRUNCATE TABLE raw_faca;

DROP INDEX raw_faca_affs_idx ON raw_faca;
DROP INDEX raw_faca_org_id_idx ON raw_faca;
DROP INDEX raw_faca_occupationoraffiliation_idx ON raw_faca;


-- 1) on Mac you should INFILE replace the path;
-- 2) If your DB is remote, uncomment LOCAL and it WILL take longer becuase of the network speel limit
LOAD DATA CONCURRENT /* LOCAL */
    INFILE 'E:\\projects\\FACADataLoad\\data\\FACAMemberList1997.csv'
    IGNORE /* REPLACE */
    INTO TABLE raw_faca
    FIELDS TERMINATED BY ',' 
    OPTIONALLY ENCLOSED BY '\"'
    -- LINES TERMINATED BY '\n'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES
    (
        AgencyAbbr,
        CommitteeName,
        CNo,
        FY,
        Prefix,
        FirstName,
        MiddleName,
        LastName,
        Suffix,
        MemberDesignation,
        RepresentedGroup,
        Chairperson,
        OccupationOrAffiliation,
        @StartDate,
        @EndDate,
        @dummy, -- CreatedAt,
        @dummy, -- CreatedBy,
        @dummy, -- ChangedAt,
        @dummy, -- ChangedBy,
        @dummy, -- IncludeinAnnualReport,
        AppointmentType,
        AppointmentTerm,
        PayPlan,
        PaySource,
        @dummy -- LastLogonDate
    )
    SET
        StartDate = STR_TO_DATE( @StartDate,'%m/%d/%Y'),
        EndDate = STR_TO_DATE( @EndDate,'%m/%d/%Y');
    -- SET OccupationOrAffiliation = normal_name( @OccupationOrAffiliation);
    
-- CREATE FULLTEXT INDEX raw_faca_affs_idx ON raw_faca (OccupationOrAffiliation);


    
    