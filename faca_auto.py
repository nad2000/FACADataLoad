#-------------------------------------------------------------------------------
# Name:        faca_auto
# Purpose:     FACA Data load and processing
#
# Author:      Radomirs Cirskis
#
# Created:     05/06/2011
#-------------------------------------------------------------------------------
#!/usr/bin/env python

import sys
import os
import os.path
import argparse
import datetime
import glob
import time
import tempfile

def getArgs():
    """
    Command argument parser

    Returns structure:
        args.server
        args.port
        args.db
        args.user
        args.password
        args.input

    """
    parser = argparse.ArgumentParser(description='FACA Data Import')
    parser.add_argument( '-s', '--server', help='Server', default='localhost')
    parser.add_argument( '-P', '--port', help='Server communication port', default=3306)
    parser.add_argument( '-d', '--db', help='Database, e.g., cdrg_alpha', default='cdrg_alpha')
    parser.add_argument( '-u', '--user', help='DB User', default='root')
    parser.add_argument( '-p', '--password', help='User password', default='')
    parser.add_argument( 'input', help='CSV file or directory containing CSV files')

    args = parser.parse_args()
    return args

def getScriptAbsPath( scriptName ):
    return os.path.join( os.path.dirname( __file__ ), scriptName );

def setMySqlCommand( args):
    """
    Create mysql command with parameters for executing a script file
    """
    global sqlCmd
    sqlCmd = "mysql -u%(user)s -h%(host)s -P%(port)s -D%(db)s -v -v -v -f " % {
        'host': args.server,
        'user': args.user,
        'db'  : args.db,
        'port': args.port
    }
    if args.password!= None and args.password!='':
        sqlCmd += " -p%s " % args.password
    return sqlCmd

def getMySqlCommand():
    """
    a gloal variable wrapper
    """
    global sqlCmd
    return sqlCmd

def showMsg( message):
    """
    Displays a message printing it to the standart streem STDERR
    """
    sys.stderr.write( message+'\n' )

def loadRawData( fileName):
    """
    Loads all rows, skipping the header row, from CSV file.
    """

    tempScript = tempfile.mktemp('.sql')
    f = open( tempScript, 'w' )
    f.write(
    """
TRUNCATE TABLE raw_faca;
ALTER TABLE raw_faca DISABLE KEYS;

DROP INDEX raw_faca_affs_idx ON raw_faca;
DROP INDEX raw_faca_org_id_idx ON raw_faca;
DROP INDEX raw_faca_occupationoraffiliation_idx ON raw_faca;


-- 1) on Mac you should INFILE replace the path;
-- 2) If your DB is remote, uncomment LOCAL and it WILL take longer becuase of the network speel limit
LOAD DATA CONCURRENT /* LOCAL */
    INFILE '%s'
    IGNORE /* REPLACE */
    INTO TABLE raw_faca
    FIELDS TERMINATED BY ',' 
    OPTIONALLY ENCLOSED BY '\\"'
    -- LINES TERMINATED BY '\\n'
    LINES TERMINATED BY '\\r\\n'
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
        StartDate = STR_TO_DATE( @StartDate,'%%m/%%d/%%Y'),
        EndDate = STR_TO_DATE( @EndDate,'%%m/%%d/%%Y');		

ALTER TABLE raw_faca ENABLE KEYS;
""" % fileName.replace('\\','\\\\') )
    f.close()
    cmd = getMySqlCommand()+"<\""+tempScript+"\""
    os.system( cmd  )

def processRows():
    """
    Invokes process_rows.sql to process loaded rows from the CSV file
    """
    cmd = getMySqlCommand()+"<\""+ getScriptAbsPath('faca_process_rows.sql') +"\""
    os.system( cmd  )

def main():
    """
    1. parse parameters;
    2. loops through the file list (one file or all in the directory);
    3. loads file and prcesses it;
    """
    time_start = time.time()
    args = getArgs()
    setMySqlCommand( args)
    if not os.path.exists( args.input ):
        raise Exception("File or directory %s doesn't exist!" % args.input)

    # data source:
    source = os.path.abspath( args.input)
    # List of CSV files:
    source = [source] if os.path.isfile( source) else glob.glob( os.path.join( source, '*.csv') )

    totalRowCount = 0
    for f in source:
        loadRawData(f)
        processRows()

    showMsg( "\n\n### Data processing completed in %.5f sec. ###\n\n"
        % (time.time()-time_start))

if __name__ == '__main__':
    main()
