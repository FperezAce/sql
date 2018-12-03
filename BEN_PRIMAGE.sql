--------------------------------------------------------
--  File created - Thursday-November-24-2016   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table BEN_PRIMAGE
--------------------------------------------------------

  CREATE TABLE "BEN"."BEN_PRIMAGE" 
   (	"PRI_RUT" VARCHAR2(10 BYTE), 
	"PRI_COMPANIA" VARCHAR2(50 BYTE), 
	"PRI_PRIMA_DIRECTA" VARCHAR2(20 BYTE), 
	"PRI_ANIO" NUMBER(4,0), 
	"PRI_MES" NUMBER(2,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "BEN_DAT" ;
--------------------------------------------------------
--  Constraints for Table BEN_PRIMAGE
--------------------------------------------------------

  ALTER TABLE "BEN"."BEN_PRIMAGE" MODIFY ("PRI_MES" NOT NULL ENABLE);
  ALTER TABLE "BEN"."BEN_PRIMAGE" MODIFY ("PRI_ANIO" NOT NULL ENABLE);
  ALTER TABLE "BEN"."BEN_PRIMAGE" MODIFY ("PRI_PRIMA_DIRECTA" NOT NULL ENABLE);
  ALTER TABLE "BEN"."BEN_PRIMAGE" MODIFY ("PRI_COMPANIA" NOT NULL ENABLE);
  ALTER TABLE "BEN"."BEN_PRIMAGE" MODIFY ("PRI_RUT" NOT NULL ENABLE);
