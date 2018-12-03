CREATE OR REPLACE PACKAGE     PRT_IUD_PKG AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */
    PROCEDURE PRT_INSERT_EXCEPCIONES(
        PRT_PERIODO IN NUMBER,
      PRT_RUT_CIA IN NUMBER,
      PRT_GRUPO IN NUMBER, 
      PRT_CODIGO IN VARCHAR2, 
      PRT_MOTIVO IN VARCHAR2, 
      PRT_USUARIO IN VARCHAR2, 
      PRT_FECHA IN DATE);
  PROCEDURE PRT_INSERT_SOL_REENVIO(
      RUT_CIA IN NUMBER,     
      PERIODO IN NUMBER,       
      TIPO IN VARCHAR2, 
      FECHA_RECEPCION IN DATE,              
      FECHA_REENVIO IN DATE,             
      NOM_ARC_ENV IN VARCHAR2, 
      COD_USUARIO IN VARCHAR2,
      MOTIVO IN CLOB,
      APLICACION IN VARCHAR2);
  PROCEDURE PRT_CONFIRM_REENVIO(
      RUT_CIA IN NUMBER,
      PERIODO IN NUMBER,
      CONFIRMACION IN VARCHAR2,
      TIPO IN VARCHAR2,
      FECHA_RECEPCION IN DATE,
      FECHA_SOLICITA IN DATE,
      USUARIO_AUTORIZA IN VARCHAR2);

END PRT_IUD_PKG;
/


CREATE OR REPLACE PACKAGE BODY     PRT_IUD_PKG AS
  --INGRESO DE EXCEPCIONES  
    PROCEDURE PRT_INSERT_EXCEPCIONES( 
      PRT_PERIODO IN NUMBER,
      PRT_RUT_CIA IN NUMBER,
      PRT_GRUPO IN NUMBER, 
      PRT_CODIGO IN VARCHAR2, 
      PRT_MOTIVO IN VARCHAR2, 
      PRT_USUARIO IN VARCHAR2, 
      PRT_FECHA IN DATE) AS 
    BEGIN
       INSERT INTO  PRT_EXCEPCIONES_CARGA(
            PRT_PERIODO,
            PRT_RUT_CIA,
            PRT_GRUPO,
            PRT_CODIGO,
            PRT_MOTIVO,
            PRT_USUARIO,
            PRT_FECHA )
      VALUES(
      PRT_PERIODO,
      PRT_RUT_CIA,
      PRT_GRUPO,
      PRT_CODIGO,
      PRT_MOTIVO,
      PRT_USUARIO,
      PRT_FECHA);
      COMMIT;
    END PRT_INSERT_EXCEPCIONES;
    
  --ingreso de solicitudes de reenvio
    PROCEDURE PRT_INSERT_SOL_REENVIO(
      RUT_CIA IN NUMBER,
      PERIODO IN NUMBER,
      TIPO IN VARCHAR2,
      FECHA_RECEPCION IN DATE,
      FECHA_REENVIO IN DATE,
      NOM_ARC_ENV IN VARCHAR2,
      COD_USUARIO IN VARCHAR2,
      MOTIVO IN CLOB,  
      APLICACION IN VARCHAR2) as
    BEGIN
      INSERT INTO  DOC.DOC_CONTROL_REENVIO(
            DOC_RUT_CIA,
            DOC_PERIODO,
            DOC_TIPO,
            DOC_FECHA_RECEPCION,
            DOC_FECHA_REENVIO,
            DOC_NOM_ARC_ENV,
            DOC_COD_USUARIO,
            DOC_MOTIVO,
            DOC_SECUENCIA,
            DOC_APLICACION)
      VALUES(
      RUT_CIA,
      PERIODO,
      'prt',
      FECHA_RECEPCION,
      SYSDATE,
      '',
      COD_USUARIO,
      MOTIVO,
      PRT.DOC_CONTROL_REENVIO_SEQ.nextval,
      APLICACION); 
      
      UPDATE DOC.doc_control_seil SET doc_autoriza_reenvio = 'S', doc_motivo_reenvio = MOTIVO WHERE doc_rut_entidad = RUT_CIA AND doc_usuario_seil = COD_USUARIO AND doc_periodo = PERIODO;
      COMMIT;
    END PRT_INSERT_SOL_REENVIO;
    
--CONFIRMACION DE LAS SOLICITUES DE REENVIO
    PROCEDURE PRT_CONFIRM_REENVIO(
      RUT_CIA IN NUMBER,
      PERIODO IN NUMBER,
      CONFIRMACION IN VARCHAR2,
      TIPO IN VARCHAR2,
      FECHA_RECEPCION IN DATE,
      FECHA_SOLICITA IN DATE,
      USUARIO_AUTORIZA IN VARCHAR2) AS
    BEGIN
          IF CONFIRMACION = 'A' THEN
            UPDATE DOC.doc_control_seil 
            SET doc_autoriza_reenvio = 'S', doc_usuario_autoriza = USUARIO_AUTORIZA, doc_fecha_autoriza = SYSDATE
            WHERE doc_rut_entidad = RUT_CIA AND doc_periodo = PERIODO AND doc_tipo = TIPO AND doc_fecha_envio LIKE to_date(FECHA_RECEPCION,'dd/mm/yy');
            --
            UPDATE DOC.doc_control_reenvio
            SET doc_autoriza_reenvio = 'A', doc_usuario_autoriza = USUARIO_AUTORIZA, doc_fecha_autoriza = SYSDATE
            WHERE doc_rut_cia = RUT_CIA AND doc_periodo = PERIODO AND doc_tipo = TIPO AND doc_fecha_recepcion LIKE to_date(FECHA_RECEPCION,'dd/mm/yy') AND doc_fecha_reenvio LIKE to_date(FECHA_SOLICITA,'dd/mm/yy');
            --
            COMMIT;
          ELSIF CONFIRMACION = 'R' THEN
            UPDATE DOC.doc_control_seil 
            SET doc_autoriza_reenvio = 'N', doc_usuario_autoriza = USUARIO_AUTORIZA, doc_fecha_autoriza = SYSDATE
            WHERE doc_rut_entidad = RUT_CIA AND doc_periodo = PERIODO AND doc_tipo = TIPO AND doc_fecha_envio LIKE to_date(FECHA_RECEPCION,'dd/mm/yy');
            --
            UPDATE DOC.doc_control_reenvio
            SET doc_autoriza_reenvio = 'R', doc_usuario_autoriza = USUARIO_AUTORIZA, doc_fecha_autoriza = SYSDATE
            WHERE doc_rut_cia = RUT_CIA AND doc_periodo = PERIODO AND doc_tipo = TIPO AND doc_fecha_recepcion LIKE to_date(FECHA_RECEPCION,'dd/mm/yy') AND doc_fecha_reenvio LIKE to_date(FECHA_SOLICITA,'dd/mm/yy');
            --
            COMMIT;
          END IF;
    END PRT_CONFIRM_REENVIO;
END PRT_IUD_PKG;
/
