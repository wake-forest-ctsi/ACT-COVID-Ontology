--sqlldr user/password@//localhost:1521/orcl bad='bad_file.txt' control='ACT_COVID_V3.ctl' data='ACT_COVID_V3.dsv' log='log.txt' direct='true'   
OPTIONS (DIRECT=TRUE)
load data 
infile 'ACT_COVID_V3.dsv' "str '\n'"
append
into table ACT_COVID
fields terminated by '|'
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( C_HLEVEL,
             C_FULLNAME CHAR(700),
             C_NAME CHAR(2000),
             C_SYNONYM_CD CHAR(1),
             C_VISUALATTRIBUTES CHAR(3),
             C_TOTALNUM,
             C_BASECODE CHAR(50),
             C_METADATAXML CHAR(4000),
             C_FACTTABLECOLUMN CHAR(50),
             C_TABLENAME CHAR(50),
             C_COLUMNNAME CHAR(50),
             C_COLUMNDATATYPE CHAR(50),
             C_OPERATOR CHAR(10),
             C_DIMCODE CHAR(700),
             C_COMMENT CHAR(4000),
             C_TOOLTIP CHAR(900),
             M_APPLIED_PATH CHAR(700),
             UPDATE_DATE DATE "RRRR-MM-DD",
             DOWNLOAD_DATE DATE "RRRR-MM-DD",
             IMPORT_DATE DATE "RRRR-MM-DD",
             SOURCESYSTEM_CD CHAR(50),
             VALUETYPE_CD CHAR(50),
             M_EXCLUSION_CD CHAR(25),
             C_PATH CHAR(700),
             C_SYMBOL CHAR(50)
           )
