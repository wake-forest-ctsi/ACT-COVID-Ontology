/* ------ COVID ONTOLOGY --------- */

--------------------------------------------------------
--  DDL for Table TMP_I2B2_METADATA
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "TMP_I2B2_METADATA" 
   (	
    "C_HLEVEL" NUMBER(22,0), 
	"C_FULLNAME" VARCHAR2(700 BYTE), 
	"C_NAME" VARCHAR2(2000 BYTE), 
	"C_SYNONYM_CD" CHAR(1 BYTE), 
	"C_VISUALATTRIBUTES" CHAR(3 BYTE), 
	"C_TOTALNUM" NUMBER(22,0), 
	"C_BASECODE" VARCHAR2(50 BYTE), 
	"C_METADATAXML" CLOB, 
	"C_FACTTABLECOLUMN" VARCHAR2(50 BYTE), 
	"C_TABLENAME" VARCHAR2(50 BYTE), 
	"C_COLUMNNAME" VARCHAR2(50 BYTE), 
	"C_COLUMNDATATYPE" VARCHAR2(50 BYTE), 
	"C_OPERATOR" VARCHAR2(10 BYTE), 
	"C_DIMCODE" VARCHAR2(700 BYTE), 
	"C_COMMENT" CLOB, 
	"C_TOOLTIP" VARCHAR2(900 BYTE), 
	"M_APPLIED_PATH" VARCHAR2(700 BYTE), 
	"UPDATE_DATE" DATE, 
	"DOWNLOAD_DATE" DATE, 
	"IMPORT_DATE" DATE, 
	"SOURCESYSTEM_CD" VARCHAR2(50 BYTE), 
	"VALUETYPE_CD" VARCHAR2(50 BYTE), 
	"M_EXCLUSION_CD" VARCHAR2(25 BYTE), 
	"C_PATH" VARCHAR2(700 BYTE), 
	"C_SYMBOL" VARCHAR2(50 BYTE)
   ) ON COMMIT DELETE ROWS ;
--------------------------------------------------------
--  Constraints for Table TMP_I2B2_METADATA
--------------------------------------------------------

ALTER TABLE "TMP_I2B2_METADATA" MODIFY ("UPDATE_DATE" NOT NULL ENABLE);
ALTER TABLE "TMP_I2B2_METADATA" MODIFY ("M_APPLIED_PATH" NOT NULL ENABLE);
ALTER TABLE "TMP_I2B2_METADATA" MODIFY ("C_DIMCODE" NOT NULL ENABLE);
ALTER TABLE "TMP_I2B2_METADATA" MODIFY ("C_OPERATOR" NOT NULL ENABLE);
ALTER TABLE "TMP_I2B2_METADATA" MODIFY ("C_COLUMNDATATYPE" NOT NULL ENABLE);
ALTER TABLE "TMP_I2B2_METADATA" MODIFY ("C_COLUMNNAME" NOT NULL ENABLE);
ALTER TABLE "TMP_I2B2_METADATA" MODIFY ("C_TABLENAME" NOT NULL ENABLE);
ALTER TABLE "TMP_I2B2_METADATA" MODIFY ("C_FACTTABLECOLUMN" NOT NULL ENABLE);
ALTER TABLE "TMP_I2B2_METADATA" MODIFY ("C_VISUALATTRIBUTES" NOT NULL ENABLE);
ALTER TABLE "TMP_I2B2_METADATA" MODIFY ("C_SYNONYM_CD" NOT NULL ENABLE);
ALTER TABLE "TMP_I2B2_METADATA" MODIFY ("C_NAME" NOT NULL ENABLE);
ALTER TABLE "TMP_I2B2_METADATA" MODIFY ("C_FULLNAME" NOT NULL ENABLE);
ALTER TABLE "TMP_I2B2_METADATA" MODIFY ("C_HLEVEL" NOT NULL ENABLE);

/* Change remdisivir from act local to rxnorm standard */
insert into tmp_i2b2_metadata
select * from act_covid where c_basecode = 'ACT|LOCAL:REMDESIVIR'
;

update tmp_i2b2_metadata src
set
  src.c_basecode = 'RXNORM:2284718'
where
  c_basecode = 'ACT|LOCAL:REMDESIVIR'
;

/* changes need to be reflected in act_covid for later steps */
merge into act_covid tgt
  using tmp_i2b2_metadata src
    on (tgt.c_fullname = src.c_fullname)
when matched then
  update set
    tgt.C_HLEVEL=src.C_HLEVEL,tgt.C_NAME=src.C_NAME,tgt.C_SYNONYM_CD=src.C_SYNONYM_CD,tgt.C_VISUALATTRIBUTES=src.C_VISUALATTRIBUTES,tgt.C_TOTALNUM=src.C_TOTALNUM,tgt.C_BASECODE=src.C_BASECODE,tgt.C_METADATAXML=src.C_METADATAXML,tgt.C_FACTTABLECOLUMN=src.C_FACTTABLECOLUMN,tgt.C_TABLENAME=src.C_TABLENAME,tgt.C_COLUMNNAME=src.C_COLUMNNAME,tgt.C_COLUMNDATATYPE=src.C_COLUMNDATATYPE,tgt.C_OPERATOR=src.C_OPERATOR,tgt.C_DIMCODE=src.C_DIMCODE,tgt.C_COMMENT=src.C_COMMENT,tgt.C_TOOLTIP=src.C_TOOLTIP,tgt.M_APPLIED_PATH=src.M_APPLIED_PATH,tgt.UPDATE_DATE=src.UPDATE_DATE,tgt.DOWNLOAD_DATE=src.DOWNLOAD_DATE,tgt.IMPORT_DATE=src.IMPORT_DATE,tgt.SOURCESYSTEM_CD=src.SOURCESYSTEM_CD,tgt.VALUETYPE_CD=src.VALUETYPE_CD,tgt.M_EXCLUSION_CD=src.M_EXCLUSION_CD,tgt.C_PATH=src.C_PATH,tgt.C_SYMBOL=src.C_SYMBOL
when not matched then
  insert 
    values (src.C_HLEVEL,src.C_FULLNAME,src.C_NAME,src.C_SYNONYM_CD,src.C_VISUALATTRIBUTES,src.C_TOTALNUM,src.C_BASECODE,src.C_METADATAXML,src.C_FACTTABLECOLUMN,src.C_TABLENAME,src.C_COLUMNNAME,src.C_COLUMNDATATYPE,src.C_OPERATOR,src.C_DIMCODE,src.C_COMMENT,src.C_TOOLTIP,src.M_APPLIED_PATH,src.UPDATE_DATE,src.DOWNLOAD_DATE,src.IMPORT_DATE,src.SOURCESYSTEM_CD,src.VALUETYPE_CD,src.M_EXCLUSION_CD,src.C_PATH,src.C_SYMBOL)
;

/* Diagnoses ICD-10 */
insert into tmp_i2b2_metadata
select * from act_covid where c_basecode like 'ICD10CM%'
;

update tmp_i2b2_metadata
SET 
    c_basecode = replace(c_basecode,'ICD10CM:','ICD10:') 
    ,update_date = sysdate
where 
    c_basecode is not null and c_basecode like 'ICD10CM%'
;


/* Labs */
insert into tmp_i2b2_metadata
select * from act_covid where c_basecode is not null and c_basecode like 'LOINC:%'
;

update tmp_i2b2_metadata
set c_basecode = replace(c_basecode,'LOINC:','LOI|')
    ,update_date = sysdate
WHERE
    c_basecode is not null and c_basecode like 'LOINC:%'
;

/* Medications RXNORM */
Insert into tmp_i2b2_metadata (C_HLEVEL,C_FULLNAME,C_NAME,C_SYNONYM_CD,C_VISUALATTRIBUTES,C_TOTALNUM,C_BASECODE,C_METADATAXML,C_FACTTABLECOLUMN,C_TABLENAME,C_COLUMNNAME,C_COLUMNDATATYPE,C_OPERATOR,C_DIMCODE,C_COMMENT,C_TOOLTIP,M_APPLIED_PATH,UPDATE_DATE,DOWNLOAD_DATE,IMPORT_DATE,SOURCESYSTEM_CD,VALUETYPE_CD,M_EXCLUSION_CD,C_PATH,C_SYMBOL)
SELECT C_HLEVEL+1, C_FULLNAME || mapped.medication_id || '\',C_NAME,C_SYNONYM_CD,REPLACE(C_VISUALATTRIBUTES,'A','H'),C_TOTALNUM,'MEDID:' || mapped.medication_id,C_METADATAXML,C_FACTTABLECOLUMN,C_TABLENAME,C_COLUMNNAME,C_COLUMNDATATYPE,C_OPERATOR,C_DIMCODE || mapped.medication_id || '\',C_COMMENT,C_TOOLTIP,M_APPLIED_PATH,UPDATE_DATE,DOWNLOAD_DATE,IMPORT_DATE,'wakehealth',VALUETYPE_CD,M_EXCLUSION_CD,C_PATH,C_SYMBOL 
FROM act_covid ont
    JOIN (select distinct mcode, msystem, medication_id FROM i2b2stage.map_medid) mapped ON mapped.mcode = SUBSTR(ont.c_basecode,8) AND mapped.msystem like 'RXNORM%'
WHERE ont.c_basecode is not null and ont.c_basecode like 'RXNORM%';

/* Medicationss NDC */
Insert into tmp_i2b2_metadata (C_HLEVEL,C_FULLNAME,C_NAME,C_SYNONYM_CD,C_VISUALATTRIBUTES,C_TOTALNUM,C_BASECODE,C_METADATAXML,C_FACTTABLECOLUMN,C_TABLENAME,C_COLUMNNAME,C_COLUMNDATATYPE,C_OPERATOR,C_DIMCODE,C_COMMENT,C_TOOLTIP,M_APPLIED_PATH,UPDATE_DATE,DOWNLOAD_DATE,IMPORT_DATE,SOURCESYSTEM_CD,VALUETYPE_CD,M_EXCLUSION_CD,C_PATH,C_SYMBOL)
SELECT C_HLEVEL+1, C_FULLNAME || mapped.medication_id || '\',C_NAME,C_SYNONYM_CD,REPLACE(C_VISUALATTRIBUTES,'A','H'),C_TOTALNUM,'MEDID:' || mapped.medication_id,C_METADATAXML,C_FACTTABLECOLUMN,C_TABLENAME,C_COLUMNNAME,C_COLUMNDATATYPE,C_OPERATOR,C_DIMCODE || mapped.medication_id || '\',C_COMMENT,C_TOOLTIP,M_APPLIED_PATH,UPDATE_DATE,DOWNLOAD_DATE,IMPORT_DATE,'wakehealth',VALUETYPE_CD,M_EXCLUSION_CD,C_PATH,C_SYMBOL 
FROM act_covid ont
    JOIN (select distinct mcode, msystem, medication_id FROM i2b2stage.map_medid) mapped ON mapped.mcode = substr(ont.c_basecode,instr(ont.c_basecode,':')+1) AND mapped.msystem like 'NDC11%'
WHERE ont.c_basecode is not null and ont.c_basecode like 'NDC%';

/* Procedures ICD10PCS */
Insert into tmp_i2b2_metadata (C_HLEVEL,C_FULLNAME,C_NAME,C_SYNONYM_CD,C_VISUALATTRIBUTES,C_TOTALNUM,C_BASECODE,C_METADATAXML,C_FACTTABLECOLUMN,C_TABLENAME,C_COLUMNNAME,C_COLUMNDATATYPE,C_OPERATOR,C_DIMCODE,C_COMMENT,C_TOOLTIP,M_APPLIED_PATH,UPDATE_DATE,DOWNLOAD_DATE,IMPORT_DATE,SOURCESYSTEM_CD,VALUETYPE_CD,M_EXCLUSION_CD,C_PATH,C_SYMBOL)
SELECT C_HLEVEL+1, C_FULLNAME || mapped.source_code || '\',C_NAME,C_SYNONYM_CD,REPLACE(C_VISUALATTRIBUTES,'A','H'),C_TOTALNUM,'PXID:' || mapped.source_code,C_METADATAXML,C_FACTTABLECOLUMN,C_TABLENAME,C_COLUMNNAME,C_COLUMNDATATYPE,C_OPERATOR,C_DIMCODE || mapped.source_code || '\',C_COMMENT,C_TOOLTIP,M_APPLIED_PATH,UPDATE_DATE,DOWNLOAD_DATE,IMPORT_DATE,'wakehealth',VALUETYPE_CD,M_EXCLUSION_CD,C_PATH,C_SYMBOL 
FROM act_covid ont
    JOIN (select distinct mcode, msystem, source_code, source_system FROM i2b2stage.map_procedures) mapped ON mapped.mcode = substr(ont.c_basecode,instr(ont.c_basecode,':')+1) AND mapped.msystem like 'ICD-10-PCS%' AND mapped.source_system = 'PXID'
WHERE ont.c_basecode is not null and ont.c_basecode like 'ICD10PCS%'
;

/* Procedures HCPCS */
Insert into tmp_i2b2_metadata (C_HLEVEL,C_FULLNAME,C_NAME,C_SYNONYM_CD,C_VISUALATTRIBUTES,C_TOTALNUM,C_BASECODE,C_METADATAXML,C_FACTTABLECOLUMN,C_TABLENAME,C_COLUMNNAME,C_COLUMNDATATYPE,C_OPERATOR,C_DIMCODE,C_COMMENT,C_TOOLTIP,M_APPLIED_PATH,UPDATE_DATE,DOWNLOAD_DATE,IMPORT_DATE,SOURCESYSTEM_CD,VALUETYPE_CD,M_EXCLUSION_CD,C_PATH,C_SYMBOL)
SELECT C_HLEVEL+1, C_FULLNAME || mapped.source_code || '\',C_NAME,C_SYNONYM_CD,REPLACE(C_VISUALATTRIBUTES,'A','H'),C_TOTALNUM,'PROCID:' || mapped.source_code,C_METADATAXML,C_FACTTABLECOLUMN,C_TABLENAME,C_COLUMNNAME,C_COLUMNDATATYPE,C_OPERATOR,C_DIMCODE || mapped.source_code || '\',C_COMMENT,C_TOOLTIP,M_APPLIED_PATH,UPDATE_DATE,DOWNLOAD_DATE,IMPORT_DATE,'wakehealth',VALUETYPE_CD,M_EXCLUSION_CD,C_PATH,C_SYMBOL 
FROM act_covid ont
    JOIN (select distinct mcode, msystem, source_code, source_system FROM i2b2stage.map_procedures) mapped ON mapped.mcode = substr(ont.c_basecode,instr(ont.c_basecode,':')+1) AND mapped.msystem like 'HCPCS.2%' AND mapped.source_system = 'PROCID'
WHERE ont.c_basecode is not null and ont.c_basecode like 'HCPCS%'
;

/* Procedures CPT-4 */
Insert into tmp_i2b2_metadata (C_HLEVEL,C_FULLNAME,C_NAME,C_SYNONYM_CD,C_VISUALATTRIBUTES,C_TOTALNUM,C_BASECODE,C_METADATAXML,C_FACTTABLECOLUMN,C_TABLENAME,C_COLUMNNAME,C_COLUMNDATATYPE,C_OPERATOR,C_DIMCODE,C_COMMENT,C_TOOLTIP,M_APPLIED_PATH,UPDATE_DATE,DOWNLOAD_DATE,IMPORT_DATE,SOURCESYSTEM_CD,VALUETYPE_CD,M_EXCLUSION_CD,C_PATH,C_SYMBOL)
SELECT C_HLEVEL+1, C_FULLNAME || mapped.source_code || '\',C_NAME,C_SYNONYM_CD,REPLACE(C_VISUALATTRIBUTES,'A','H'),C_TOTALNUM,'PROCID:' || mapped.source_code,C_METADATAXML,C_FACTTABLECOLUMN,C_TABLENAME,C_COLUMNNAME,C_COLUMNDATATYPE,C_OPERATOR,C_DIMCODE || mapped.source_code || '\',C_COMMENT,C_TOOLTIP,M_APPLIED_PATH,UPDATE_DATE,DOWNLOAD_DATE,IMPORT_DATE,'wakehealth',VALUETYPE_CD,M_EXCLUSION_CD,C_PATH,C_SYMBOL 
FROM act_covid ont
    JOIN (select distinct mcode, msystem, source_code, source_system FROM i2b2stage.map_procedures) mapped ON mapped.mcode = substr(ont.c_basecode,instr(ont.c_basecode,':')+1) AND mapped.msystem like 'CPT-4%' AND mapped.source_system = 'PROCID'
WHERE ont.c_basecode is not null and ont.c_basecode like 'CPT4%'
;

/* Vital */
insert into tmp_i2b2_metadata
select * from act_covid where C_BASECODE = 'DEM|VITAL STATUS:D' AND C_VISUALATTRIBUTES LIKE '%L%'
;

Update tmp_i2b2_metadata SET C_FACTTABLECOLUMN = 'patient_num', C_TABLENAME = 'patient_dimension', C_COLUMNNAME = 'vital_status_cd', C_OPERATOR = 'IN', C_DIMCODE = '''Y'',''D''' WHERE C_BASECODE = 'DEM|VITAL STATUS:D' AND C_VISUALATTRIBUTES LIKE '%L%';

/* Visit */
insert into tmp_i2b2_metadata
select * from act_covid where lower(c_columnname) = 'inout_cd' AND C_BASECODE in ('I','O')
;
Update tmp_i2b2_metadata SET C_OPERATOR = 'IN', C_DIMCODE = '''I'',''IP''' WHERE lower(c_columnname) = 'inout_cd' AND C_BASECODE = 'I';
Update tmp_i2b2_metadata SET C_OPERATOR = 'IN', C_DIMCODE = '''O'',''OP''' WHERE lower(c_columnname) = 'inout_cd' AND C_BASECODE = 'O';

merge into act_covid tgt
  using tmp_i2b2_metadata src
    on (tgt.c_fullname = src.c_fullname)
when matched then
  update set
    tgt.C_HLEVEL=src.C_HLEVEL,tgt.C_NAME=src.C_NAME,tgt.C_SYNONYM_CD=src.C_SYNONYM_CD,tgt.C_VISUALATTRIBUTES=src.C_VISUALATTRIBUTES,tgt.C_TOTALNUM=src.C_TOTALNUM,tgt.C_BASECODE=src.C_BASECODE,tgt.C_METADATAXML=src.C_METADATAXML,tgt.C_FACTTABLECOLUMN=src.C_FACTTABLECOLUMN,tgt.C_TABLENAME=src.C_TABLENAME,tgt.C_COLUMNNAME=src.C_COLUMNNAME,tgt.C_COLUMNDATATYPE=src.C_COLUMNDATATYPE,tgt.C_OPERATOR=src.C_OPERATOR,tgt.C_DIMCODE=src.C_DIMCODE,tgt.C_COMMENT=src.C_COMMENT,tgt.C_TOOLTIP=src.C_TOOLTIP,tgt.M_APPLIED_PATH=src.M_APPLIED_PATH,tgt.UPDATE_DATE=src.UPDATE_DATE,tgt.DOWNLOAD_DATE=src.DOWNLOAD_DATE,tgt.IMPORT_DATE=src.IMPORT_DATE,tgt.SOURCESYSTEM_CD=src.SOURCESYSTEM_CD,tgt.VALUETYPE_CD=src.VALUETYPE_CD,tgt.M_EXCLUSION_CD=src.M_EXCLUSION_CD,tgt.C_PATH=src.C_PATH,tgt.C_SYMBOL=src.C_SYMBOL
when not matched then
  insert 
    values (src.C_HLEVEL,src.C_FULLNAME,src.C_NAME,src.C_SYNONYM_CD,src.C_VISUALATTRIBUTES,src.C_TOTALNUM,src.C_BASECODE,src.C_METADATAXML,src.C_FACTTABLECOLUMN,src.C_TABLENAME,src.C_COLUMNNAME,src.C_COLUMNDATATYPE,src.C_OPERATOR,src.C_DIMCODE,src.C_COMMENT,src.C_TOOLTIP,src.M_APPLIED_PATH,src.UPDATE_DATE,src.DOWNLOAD_DATE,src.IMPORT_DATE,src.SOURCESYSTEM_CD,src.VALUETYPE_CD,src.M_EXCLUSION_CD,src.C_PATH,src.C_SYMBOL)
;

/* Performance issues with underscores */
update act_covid
set
  c_dimcode = case
        when trim(lower(c_tablename)) = 'concept_dimension' then replace(c_dimcode,'_','')
        else c_dimcode
        end
where 
    c_fullname like '%_%'
;

drop table tmp_i2b2_metadata;
/* You must merge these changes into the crc concept dimension tables after making updates */