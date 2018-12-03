CREATE OR REPLACE PACKAGE BEN_PRIMAGE_PKG AS 
TYPE v_cursor IS REF CURSOR;
TYPE CURSOR_TYPE IS REF CURSOR;
PROCEDURE BEN_VERIFICA_RUT_PRIMAGE (RUT VARCHAR2, resultado out varchar2);
FUNCTION BEN_LISTAR_PRIMAGE(ANIO in NUMBER,MES in NUMBER) RETURN sys_refcursor; 
PROCEDURE BEN_GUARDA_PRIMAGE(
        PRI_RUT IN VARCHAR2,
      PRI_COMPANIA IN VARCHAR2,
      PRI_PRIMA_DIRECTA IN VARCHAR2 , 
      PRI_ANIO IN VARCHAR2, 
      PRI_MES IN VARCHAR2);

END BEN_PRIMAGE_PKG;
/


CREATE OR REPLACE PACKAGE BODY BEN_PRIMAGE_PKG 
AS 
 
PROCEDURE BEN_VERIFICA_RUT_PRIMAGE (RUT VARCHAR2, resultado out varchar2) 
 AS 
  CONTADOR         NUMBER;
   BEGIN
      select count(*) INTO CONTADOR from pu_entes
      where pu_tipo_ent_web = 'CSGEN'
      and pu_situacion = 'VI'
        and pu_rut_ent = RUT;
 
      IF CONTADOR > 0 THEN
         resultado:= 'OK';                                            
      ELSE
         resultado:= 'NOK';                                             
      END IF;
       
   END BEN_VERIFICA_RUT_PRIMAGE;
   
  --INGRESO DE PRIMAGE
PROCEDURE BEN_GUARDA_PRIMAGE(
      PRI_RUT IN VARCHAR2,
      PRI_COMPANIA IN VARCHAR2,
      PRI_PRIMA_DIRECTA IN VARCHAR2,
      PRI_ANIO IN VARCHAR2,  
      PRI_MES IN VARCHAR2) AS 
    BEGIN
       INSERT INTO BEN_PRIMAGE(
            PRI_RUT,
            PRI_COMPANIA,
            PRI_PRIMA_DIRECTA,
            PRI_ANIO,
            PRI_MES)
      VALUES(
          PRI_RUT,
          PRI_COMPANIA,
          PRI_PRIMA_DIRECTA,
          PRI_ANIO,
          PRI_MES);
      COMMIT;
    END BEN_GUARDA_PRIMAGE; 
    
  FUNCTION BEN_LISTAR_PRIMAGE(ANIO in NUMBER,MES in NUMBER)
     return sys_refcursor
  as
    v_cursor CURSOR_TYPE;  
    begin
       open v_cursor for SELECT PRI_RUT,PRI_COMPANIA,PRI_PRIMA_DIRECTA FROM BEN_PRIMAGE 
       WHERE PRI_ANIO = ANIO AND PRI_MES = MES;      
        return v_cursor;
      close v_cursor;   
   END BEN_LISTAR_PRIMAGE;
   
   
END BEN_PRIMAGE_PKG;
/
