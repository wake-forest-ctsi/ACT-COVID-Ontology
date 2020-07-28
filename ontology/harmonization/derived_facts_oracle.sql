DROP TABLE "TMP_I2B2_METADATA";
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


insert into tmp_i2b2_metadata
select * from act_covid where c_fullname LIKE '\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0022885\%' and (upper(c_name) like '%POSITIVE%' or upper(c_name) like '%EQUIVOCAL%' or upper(c_name) like '%NEGATIVE%' or upper(c_name) like '%PENDING%')  order by 1,2
;

update tmp_i2b2_metadata src
set
    src.c_facttablecolumn = 'encounter_num'
    ,src.c_tablename = 'observation_fact'
    ,src.c_columnname = 'tval_char'
    ,src.c_columndatatype = 'N'
    ,src.c_operator = 'IN'
    ,src.c_dimcode = case 
        when lower(src.c_name) like '%positive%' then '''Positive'',''Detected'''
        when lower(src.c_name) like '%equivocal%' then '''Invalid'',''Comment'''
        when lower(src.c_name) like '%negative%' then '''Negative'',''Not Detected'''
        when lower(src.c_name) like '%pending%' then '''Pending'''
        end
;

update tmp_i2b2_metadata src
set
    src.c_dimcode = case
        when src.c_visualattributes like 'L%' then src.c_dimcode || ') and concept_cd in (''' || substr(src.c_basecode,0,instr(src.c_basecode,' ')-1) || ''''
        when src.c_visualattributes like 'M%' then src.c_dimcode || ') and concept_cd in (' || (select LISTAGG(substr(c_basecode,0,instr(c_basecode,' ')-1) || '''',',') WITHIN group(order by c_basecode) from tmp_i2b2_metadata where c_fullname like (src.c_fullname || '%') and tmp_i2b2_metadata.c_visualattributes like 'L%')
        end
;

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

drop table tmp_i2b2_metadata;