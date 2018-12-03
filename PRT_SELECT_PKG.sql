CREATE OR REPLACE PACKAGE     PRT_SELECT_PKG AS 
 
  FUNCTION PRT_VERIFICA_RAMO_EF(RAMO NUMBER) RETURN VARCHAR;
  FUNCTION PRT_VERIFICA_ESTADO_FINAN(SRAMO NUMBER, SGRUPO NUMBER) RETURN VARCHAR ;
  FUNCTION PRT_POL_OBTENER_ESTADO(NUMERO_DOCTO NUMBER, FECHA_INGRESO_ENVIO DATE) RETURN VARCHAR;
  FUNCTION PRT_OBTENER_CONSTITUCION(GRUPO_E in NUMBER) RETURN sys_refcursor;
  FUNCTION PRT_VERIFICA_RAMO_LN_GRUPO(RAMO NUMBER, LINEA_NEG NUMBER, GRUPO NUMBER) RETURN VARCHAR;
  FUNCTION PRT_VERIFICA_POLIZA_POL(POLIZA VARCHAR2) RETURN VARCHAR;
  FUNCTION PRT_VERIFICA_POLIZA_DPC(POLIZA VARCHAR2) RETURN VARCHAR;TYPE CURSOR_TYPE IS REF CURSOR;
TYPE v_cursor IS REF CURSOR;
  FUNCTION PRT_VERIFICA_CIA_FC(RUT_CIA VARCHAR2) RETURN VARCHAR;
  FUNCTION PRT_VERIFICA_EXCEPCIONES(RUT_CIA VARCHAR2) RETURN VARCHAR;
  FUNCTION PRT_VERIFICA_CLAUSULA_POL(CLAUSULA VARCHAR2) RETURN VARCHAR;
  FUNCTION PRT_VERIFICA_CLAUSULA_DPC(CLAUSULA VARCHAR2) RETURN VARCHAR;
  FUNCTION PRT_VERIFICA_POL_CLA(POLIZA VARCHAR2 , CLAUSULA VARCHAR2) RETURN VARCHAR;
 FUNCTION PRT_VERIFICA_REGISTRO(REGISTRO NUMBER,RUT_CIA VARCHAR2,PERIODO IN NUMBER, GRUPO NUMBER) RETURN VARCHAR;
  FUNCTION PRT_VERIFICA_GRUPO_CIA(RUT_CIA VARCHAR2, GRUPO NUMBER) RETURN VARCHAR;
  PROCEDURE PRT_LISTA_RESUMEN_C383_PRC (STRRUT IN VARCHAR2,PERIODO IN NUMBER,GRUPO in number, oResultSet OUT CURSOR_TYPE);
  PROCEDURE PRT_LISTA_C383_PRC (STRRUT in VARCHAR2, LINEA_NEGOCIO IN VARCHAR2, PERIODO IN NUMBER,GRUPO in number, oResultSet OUT CURSOR_TYPE);
  PROCEDURE PRT_INFO_C383_PRC (STRRUT in VARCHAR2,GRUPO in number, oResultSet OUT CURSOR_TYPE);
  PROCEDURE PRT_LISTA_SOL_REENVIO_PKG (RUT_CIA IN VARCHAR2, APLICACION IN VARCHAR2, AGNO IN VARCHAR2,  oResultSet OUT CURSOR_TYPE);
  PROCEDURE PRT_LISTA_REENVIO_PRC (AGNO IN VARCHAR2,APLIC IN VARCHAR2, ORESULTSET OUT CURSOR_TYPE);
  FUNCTION PRT_VERIFICA_REENVIO_FN (RUT_CIA IN VARCHAR2, AGNO IN VARCHAR2) return number; 
  
  FUNCTION PRT_OBTENER_NOMBRE(IRUT IN VARCHAR2)RETURN VARCHAR2;
  PROCEDURE PRT_ULTIMO_PERIODO_PRC (RUTCIA IN VARCHAR2, GRUPO IN NUMBER, oResultSet OUT CURSOR_TYPE);
  FUNCTION rowconcat(q IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION PRT_VERIFICA_FORMA_RESERVA(FORMA VARCHAR2) RETURN VARCHAR;
  FUNCTION PRT_VERIFICA_TABLA_MOR(FORMA VARCHAR2) RETURN VARCHAR;
END PRT_SELECT_PKG;
/


CREATE OR REPLACE PACKAGE BODY     PRT_SELECT_PKG
AS
   --VALIDACION RUT CORRECTO
   FUNCTION PRT_VERIFICA_CIA_FC (RUT_CIA VARCHAR2)
      RETURN VARCHAR
   IS
      CONTADOR   NUMBER;
   BEGIN  
      SELECT COUNT (RUT_CIA)
        INTO CONTADOR
        FROM PU_ENTES
       WHERE PU_RUT_ENT = RUT_CIA;

      IF CONTADOR > 0
      THEN
         RETURN 'OK';
      ELSE
         RETURN 'NOK';
      END IF;
   END PRT_VERIFICA_CIA_FC;


   --verifica que exista alguna excepcion en la base de datos
  FUNCTION PRT_VERIFICA_EXCEPCIONES(RUT_CIA VARCHAR2) 
    RETURN VARCHAR 
    IS
        CONTADOR   NUMBER;
    BEGIN
      SELECT COUNT (PRT_RUT_CIA) INTO CONTADOR FROM PRT_EXCEPCIONES_CARGA
      WHERE PRT_RUT_CIA = RUT_CIA AND PRT_ESTADO = '1';
      IF CONTADOR > 0
      THEN 
         UPDATE PRT_EXCEPCIONES_CARGA SET PRT_ESTADO = 0 WHERE PRT_RUT_CIA = RUT_CIA AND PRT_ESTADO = 1;
         COMMIT;
         RETURN 'OK';
      ELSE
         RETURN 'NOK';
      END IF;
   END PRT_VERIFICA_EXCEPCIONES;
   
   --validacion ramo estado financiero
   FUNCTION PRT_VERIFICA_RAMO_EF (RAMO NUMBER)
      RETURN VARCHAR
   IS
      CONTADOR   NUMBER;
   BEGIN
      SELECT COUNT (seg_ramo)
        INTO CONTADOR
        FROM IFI.IFI_SEG_RAMOS
       WHERE SEG_RAMO = RAMO;

      IF CONTADOR > 0
      THEN
         RETURN 'OK';
      ELSE
         RETURN 'NOK';
      END IF;
   END PRT_VERIFICA_RAMO_EF;

   --validacion consistencia ramo ef, grupo, linea de negocio
   FUNCTION PRT_VERIFICA_RAMO_LN_GRUPO (RAMO         NUMBER,
                                        LINEA_NEG    NUMBER,
                                        GRUPO        NUMBER)
      RETURN VARCHAR
   IS
      CONTADOR   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO CONTADOR
        FROM IFI.IFI_SEG_RAMOS
       WHERE     SEG_RAMO = RAMO
             AND SEG_CLASIFICACION = LINEA_NEG
             AND SEG_GRUPO = GRUPO;

      IF CONTADOR > 0
      THEN
         RETURN 'OK';
      ELSE
         RETURN 'NOK';
      END IF;
   END PRT_VERIFICA_RAMO_LN_GRUPO;

   --valida que la poliza exista en pol
   FUNCTION PRT_VERIFICA_POLIZA_POL (POLIZA VARCHAR2)
      RETURN VARCHAR
   IS
      CONTADOR   NUMBER;
   BEGIN
      IF POLIZA IN ('CAD000000', 'POL000000')
      THEN
         RETURN 'OK';
      ELSE
         SELECT COUNT (POL_COD_POLIZA)
           INTO CONTADOR
           FROM POL.POL_POLIZAS
          WHERE POL_COD_POLIZA = POLIZA;

         IF CONTADOR > 0
         THEN
            RETURN 'OK';
         ELSE
            RETURN 'NOK';
         END IF;
      END IF;
   END PRT_VERIFICA_POLIZA_POL;

   --valida que la poliza exista en dpc
   FUNCTION PRT_VERIFICA_POLIZA_DPC (POLIZA VARCHAR2)
      RETURN VARCHAR
   IS
      CONTADOR   NUMBER;
   BEGIN
      IF POLIZA IN ('CAD000000000', 'POL000000000')
      THEN
         RETURN 'OK';
      ELSE
         SELECT COUNT (POL_COD_POLIZA)
           INTO CONTADOR
           FROM POL.DPC_POLIZAS
          WHERE POL_COD_POLIZA = POLIZA;

         IF CONTADOR > 0
         THEN
            RETURN 'OK';
         ELSE
            RETURN 'NOK';
         END IF;
      END IF;
   END PRT_VERIFICA_POLIZA_DPC;

   --valida que la clausula exista
   FUNCTION PRT_VERIFICA_CLAUSULA_POL (CLAUSULA VARCHAR2)
      RETURN VARCHAR
   IS
      CONTADOR   NUMBER;
   BEGIN
      IF CLAUSULA IN ('CAD000000', 'POL000000')
      THEN
         contador := 1;
      ELSE
         SELECT COUNT (POL_COD_POLIZA)
           INTO CONTADOR
           FROM POL.POL_POLIZAS
          WHERE POL_COD_POLIZA = CLAUSULA;
      END IF;

      IF CONTADOR > 0
      THEN
         RETURN 'OK';
      ELSE
         RETURN 'NOK';
      END IF;
   END PRT_VERIFICA_CLAUSULA_POL;

   --valida que la clausula exista
   FUNCTION PRT_VERIFICA_CLAUSULA_DPC (CLAUSULA VARCHAR2)
      RETURN VARCHAR
   IS
      CONTADOR   NUMBER;
   BEGIN
      IF CLAUSULA IN ('CAD000000000', 'POL000000000')
      THEN
         --   CAD120140001
         contador := 1;  -- Despues dejar como advertencia. Delia. 29/09/2014.
      ELSE
         SELECT COUNT (POL_COD_POLIZA)
           INTO CONTADOR
           FROM POL.DPC_POLIZAS
          WHERE POL_COD_POLIZA = CLAUSULA;
      END IF;

      IF CONTADOR > 0
      THEN
         RETURN 'OK';
      ELSE
         RETURN 'NOK';
      END IF;
   END PRT_VERIFICA_CLAUSULA_DPC;

   /*
      FUNCTION PRT_VERIFICA_CLAUSULA_DPC(CLAUSULA VARCHAR2) RETURN VARCHAR IS
       CONTADOR NUMBER;
       BEGIN
         SELECT COUNT(POL_COD_POLIZA) INTO CONTADOR
         FROM POL.DPC_POLIZAS WHERE POL_COD_POLIZA = CLAUSULA;

         IF CONTADOR > 0 THEN
           RETURN 'OK';
         ELSE
           RETURN 'NOK';
         END IF;

       END PRT_VERIFICA_CLAUSULA_DPC;
     */
   --valida poliza y clausula relacionada
   FUNCTION PRT_VERIFICA_POL_CLA (POLIZA VARCHAR2, CLAUSULA VARCHAR2)
      RETURN VARCHAR
   IS
      CONTADOR   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO CONTADOR
        FROM POL.DPC_REL_POL_CLA
       WHERE poliza IN (POL_COD_POLIZA, POL_COD_POLIZA2);

      IF CLAUSULA IN ('CAD000000000', 'POL000000000')
      THEN                    --en deposito, poliza no tiene clausula asociada
         RETURN 'OK';
      ELSE
         SELECT COUNT (POL_COD_POLIZA)
           INTO CONTADOR
           FROM POL.DPC_REL_POL_CLA
          WHERE     POL_COD_POLIZA IN (POLIZA, CLAUSULA)
                AND POL_COD_POLIZA2 IN (POLIZA, CLAUSULA);

         IF CONTADOR > 0
         THEN
            RETURN 'OK';
         ELSE
            RETURN 'NOK';
         END IF;
      END IF;
   END PRT_VERIFICA_POL_CLA;

   /*
   FUNCTION PRT_VERIFICA_POL_CLA(POLIZA VARCHAR2 , CLAUSULA VARCHAR2) RETURN VARCHAR IS
         CONTADOR NUMBER;
   BEGIN
       SELECT COUNT(POL_COD_POLIZA) INTO CONTADOR
       FROM POL.DPC_REL_POL_CLA
       WHERE POL_COD_POLIZA IN(POLIZA,CLAUSULA)
       AND POL_COD_POLIZA2 IN(POLIZA,CLAUSULA);

       IF CONTADOR > 0 THEN
         RETURN 'OK';
       ELSE
         RETURN 'NOK';
       END IF;

   END PRT_VERIFICA_POL_CLA;
 */
   --valida que numero de registro no se repita
   FUNCTION PRT_VERIFICA_REGISTRO (REGISTRO      NUMBER,
                                   RUT_CIA       VARCHAR2,
                                   PERIODO    IN NUMBER,
                                   GRUPO         NUMBER)
      RETURN VARCHAR
   IS
      CONTADOR   NUMBER;
   BEGIN
      SELECT COUNT (PRT_ID)
        INTO CONTADOR
        FROM PRT_PROD_COMERCIALIZA
       WHERE     PRT_ID = REGISTRO
             AND PRT_RUT_CIA = RUT_CIA
             AND PRT_PERIODO = PERIODO
             AND PRT_GRUPO = GRUPO;

      IF CONTADOR > 0
      THEN
         RETURN 'NOK';
      ELSE
         RETURN 'OK';
      END IF;
   END PRT_VERIFICA_REGISTRO;

  -- OBTIENE POL PROHIBIDA
  FUNCTION PRT_POL_OBTENER_ESTADO(NUMERO_DOCTO NUMBER, FECHA_INGRESO_ENVIO DATE) RETURN VARCHAR 
     IS  
      v_numero NUMBER;
  BEGIN
       SELECT num_doc AS NUMERO_DOCTO
                  INTO v_numero
                  FROM DOC.DOC_DOCUMENTOS dd
                 WHERE     DD.num_doc = NUMERO_DOCTO 
                       AND TRUNC (fecha_ingreso_envio) =
                              TRUNC (TO_DATE (FECHA_INGRESO_ENVIO, 'dd/mm/yyyy'))
                       AND NOT EXISTS
                                  (SELECT 1
                                     FROM doc_documentos d1, cg_ref_codes c
                                    WHERE     d1.TI_TIPO_DOCUMENTO = 'RESOL'
                                          AND c.RV_DOMAIN = 'SANCION_PUBLICAR'
                                          AND d1.CLASIF_1 = c.RV_LOW_VALUE
                                          AND PUBLIC_SITIO_WEB = 'S'
                                          AND d1.NUMERO_DOCTO = dd.NUMERO_DOCTO);

       IF v_numero > 0 THEN
         RETURN 'OK';
       ELSE
         RETURN 'NOK';
       END IF;
  END PRT_POL_OBTENER_ESTADO;
  
  --Valida estado financiero
  FUNCTION PRT_VERIFICA_ESTADO_FINAN(SRAMO NUMBER, SGRUPO NUMBER) RETURN VARCHAR 
     IS 
      CONTADOR NUMBER; 
  BEGIN
      select COUNT (*) INTO CONTADOR from ifi_seg_cod_ramos WHERE SEG_GRUPO = SGRUPO 
      AND SEG_RAMO = SRAMO; 
      
       IF CONTADOR > 0 THEN
         RETURN 'OK';
       ELSE
         RETURN 'NOK';
       END IF;
  END PRT_VERIFICA_ESTADO_FINAN;
  
   
  --OBTENGO CONSTITUCION PARA GRUPO ESPECIFICO.
  FUNCTION PRT_OBTENER_CONSTITUCION(GRUPO_E in NUMBER)
     return sys_refcursor
  as
    v_cursor CURSOR_TYPE;  
    begin
       open v_cursor for SELECT CODIGO FROM PRT_FORMA_CONSTITUCION_RESERVA 
      WHERE VIGENCIA = EXTRACT(YEAR FROM sysdate) AND GRUPO = GRUPO_E;     
        return v_cursor;
      close v_cursor;   
   END PRT_OBTENER_CONSTITUCION;  

   --valida que grupo corresponda a cia
   FUNCTION PRT_VERIFICA_GRUPO_CIA (RUT_CIA VARCHAR2, GRUPO NUMBER)
      RETURN VARCHAR
   IS
      CONTADOR   NUMBER;
      tipo_ent   VARCHAR2 (2);
   BEGIN
      IF GRUPO = 1
      THEN
         tipo_ent := 'SG';
      ELSIF GRUPO = 2
      THEN
         tipo_ent := 'SV';
      END IF;

      SELECT COUNT (*)
        INTO CONTADOR
        FROM pu_entes
       WHERE pu_rut_ent = RUT_CIA AND pu_tip_ent = tipo_ent;

      IF CONTADOR > 0
      THEN
         RETURN 'OK';
      ELSE
         RETURN 'NOK';
      END IF;
   END PRT_VERIFICA_GRUPO_CIA;

   --resumen de circulares 383PRT_INFO_C383_PRC
   PROCEDURE PRT_LISTA_RESUMEN_C383_PRC (STRRUT       IN     VARCHAR2,
                                         PERIODO      IN     NUMBER,
                                         GRUPO        IN     NUMBER,
                                         oResultSet      OUT CURSOR_TYPE)
   AS
   BEGIN
      IF (STRRUT IS NOT NULL AND GRUPO IS NOT NULL)
      THEN
         OPEN oResultSet FOR
              SELECT (SELECT PRT_DETALLE_LN
                        FROM PRT_LINEAS_NEGOCIO
                       WHERE PRT_CODIGO_LN = NVL (PRT_LINEAS_NEGOCIO, ''))
                        AS "Lineas de Negocio",
                     TO_CHAR (SUM (NVL (PRT_PRIMA_DIRECTA, 0)),
                              'L999G999G999G999',
                              'nls_numeric_characters = '',.'''),
                        'Ver Detalle @@?pagina=paginas.listado.detallec383&rut='
                     || PRT_RUT_CIA
                     || '&periodo='
                     || PRT_PERIODO
                     || '&linea_negocio='
                     || PRT_LINEAS_NEGOCIO
                     || '&grupo='
                     || PRT_GRUPO
                     || '&fechaPeriodo='
                     || PRT_PERIODO
                     || '0101'
                        AS "ENLACE"
                FROM PRT_PROD_COMERCIALIZA
               WHERE     PRT_RUT_CIA = STRRUT
                     AND PRT_PERIODO =
                            TO_CHAR (TO_DATE (PERIODO, 'yyyymmdd'), 'yyyy')
                     AND PRT_GRUPO = GRUPO
            GROUP BY PRT_LINEAS_NEGOCIO,
                        'Ver Detalle @@?pagina=paginas.listado.detallec383&rut='
                     || PRT_RUT_CIA
                     || '&periodo='
                     || PRT_PERIODO
                     || '&linea_negocio='
                     || PRT_LINEAS_NEGOCIO
                     || '&grupo='
                     || PRT_GRUPO
                     || '&fechaPeriodo='
                     || PRT_PERIODO
                     || '0101'
            UNION
            SELECT 'TOTAL: ' AS "Total",
                   TO_CHAR (SUM (NVL (PRT_PRIMA_DIRECTA, '0')),
                            'L999G999G999G999',
                            'nls_numeric_characters = '',.'''),
                   ' '
              FROM PRT_PROD_COMERCIALIZA
             WHERE     PRT_RUT_CIA = STRRUT
                   AND PRT_PERIODO =
                          TO_CHAR (TO_DATE (PERIODO, 'yyyymmdd'), 'yyyy')
                   AND PRT_GRUPO = GRUPO;
      ELSE
         OPEN oResultSet FOR
              SELECT (SELECT pu_nom_ent
                        FROM pu_entes
                       WHERE pu_rut_ent = prt_rut_cia AND ROWNUM = 1)
                        AS "Nombre Compañía",
                     (SELECT PRT_DETALLE_LN
                        FROM PRT_LINEAS_NEGOCIO
                       WHERE PRT_CODIGO_LN = NVL (PRT_LINEAS_NEGOCIO, ''))
                        AS "Lineas de Negocio",
                     TO_CHAR (SUM (NVL (PRT_PRIMA_DIRECTA, 0)),
                              'L999G999G999G999',
                              'nls_numeric_characters = '',.'''),
                        'Ver Detalle @@?pagina=paginas.listado.detallec383&rut='
                     || PRT_RUT_CIA
                     || '&periodo='
                     || PRT_PERIODO
                     || '&linea_negocio='
                     || PRT_LINEAS_NEGOCIO
                     || '&grupo='
                     || PRT_GRUPO
                     || '&fechaPeriodo='
                     || PRT_PERIODO
                     || '0101'
                        AS "ENLACE"
                FROM PRT_PROD_COMERCIALIZA
               WHERE PRT_PERIODO =
                        TO_CHAR (TO_DATE (PERIODO, 'yyyymmdd'), 'yyyy')
            GROUP BY prt_rut_cia,
                     PRT_LINEAS_NEGOCIO,
                        'Ver Detalle @@?pagina=paginas.listado.detallec383&rut='
                     || PRT_RUT_CIA
                     || '&periodo='
                     || PRT_PERIODO
                     || '&linea_negocio='
                     || PRT_LINEAS_NEGOCIO
                     || '&grupo='
                     || PRT_GRUPO
                     || '&fechaPeriodo='
                     || PRT_PERIODO
                     || '0101'
            UNION
            SELECT 'TOTAL: ' AS "Total",
                   ' ',
                   TO_CHAR (SUM (NVL (PRT_PRIMA_DIRECTA, '0')),
                            'L999G999G999G999',
                            'nls_numeric_characters = '',.'''),
                   ' '
              FROM PRT_PROD_COMERCIALIZA
             WHERE PRT_PERIODO =
                      TO_CHAR (TO_DATE (PERIODO, 'yyyymmdd'), 'yyyy');
      END IF;
   END PRT_LISTA_RESUMEN_C383_PRC;


   --listado de circulares 383PRT_INFO_C383_PRC
   PROCEDURE PRT_LISTA_C383_PRC (STRRUT          IN     VARCHAR2,
                                 LINEA_NEGOCIO   IN     VARCHAR2,
                                 PERIODO         IN     NUMBER,
                                 GRUPO           IN     NUMBER,
                                 oResultSet         OUT CURSOR_TYPE)
   AS
   BEGIN
      OPEN oResultSet FOR
           SELECT NVL (PRT_PERIODO, '') AS "Periodo",
                  NVL (PRT_LINEAS_NEGOCIO, '') AS "Lineas de Negocio",
                  NVL (PRT_RAMO_ESTADO_FINAN, '') AS "Ramo Est. Financ.",
                  NVL (PRT_RAMO_CIA, '') AS "Ramo Cia.",
                  NVL (PRT_NOMBRE_PRODUCTO, '') AS "Producto",
                  NVL (PRT_POLIZA, '') AS "Poliza",
                  (SELECT NVL (
                             rowconcat (
                                   'SELECT PRT_CLAUSULA FROM PRT_REF_CLAUSULAS WHERE PRT_ID_REGISTRO = '
                                || PRT_ID
                                || ' AND PRT_RUT_CIA = '
                                || PRT_RUT_CIA
                                || ' AND PRT_GRUPO_CIA = '
                                || PRT_GRUPO
                                || ' AND PRT_PERIODO = '
                                || PRT_PERIODO),
                             '-')
                     FROM DUAL)
                     AS "Clausulas",
                  TO_CHAR (NVL (PRT_PRIMA_DIRECTA, ''),
                           'L999G999G999G999',
                           'nls_numeric_characters = '',.''')
                     AS "Prima Directa",
                  NVL (PRT_FORMA_CONSTITUCION_RESERVA, '')
                     AS "Forma Const. de Reserva",
                  NVL (PRT_RESERVA_TECNICA_BRUTA, '')
                     AS "Reserva Tecnica Bruta",
                  NVL (PRT_RESERVA_TECNICA_NETA, '') AS "Reserva Tecnica Neta",
                  NVL (PRT_PLAZO_SEGURO, '') AS "Plazo Seguro",
                  NVL (PRT_TABLA_MORTALIDAD, '') AS "Tabla Mort/Morb"
             FROM PRT_PROD_COMERCIALIZA
            WHERE     PRT_RUT_CIA = STRRUT
                  AND PRT_LINEAS_NEGOCIO = LINEA_NEGOCIO
                  AND PRT_PERIODO = PERIODO
                  AND PRT_GRUPO = GRUPO
         --AND PRT_PERIODO = to_char(to_date(PERIODO,'yyyymmdd'),'yyyy')
         ORDER BY PRT_PERIODO DESC;
   END PRT_LISTA_C383_PRC;

   --informacion encabezado lista circulares 383
   PROCEDURE PRT_INFO_C383_PRC (STRRUT       IN     VARCHAR2,
                                GRUPO        IN     NUMBER,
                                oResultSet      OUT CURSOR_TYPE)
   AS
      tipo_ent   VARCHAR2 (2);
   BEGIN
      IF GRUPO = 1
      THEN
         tipo_ent := 'SG';
      ELSIF GRUPO = 2
      THEN
         tipo_ent := 'SV';
      END IF;

      OPEN oResultSet FOR
         SELECT pu_rut_ent || '-' || pu_ver_ent AS "RUT",
                REPLACE (pu_nom_ent, '#', 'Ñ') AS "Raz&oacute;n Social",
                pu_tip_ent || ' (' || GRUPO || ')' AS "Grupo Cia.",
                TO_CHAR (SYSDATE) AS "Fecha de Consulta"
           FROM pu_entes
          WHERE pu_rut_ent = STRRUT AND pu_tip_ent = tipo_ent;
   END PRT_INFO_C383_PRC;

   --lista los periodos con datos vigentes
   PROCEDURE PRT_LISTA_SOL_REENVIO_PKG (RUT_CIA      IN     VARCHAR2,
                                        APLICACION   IN     VARCHAR2,
                                        AGNO         IN     VARCHAR2,
                                        oResultSet      OUT CURSOR_TYPE)
   AS
      validadato   NUMBER DEFAULT 0;
   BEGIN
      SELECT COUNT (DOC_PERIODO)
        INTO validadato
        FROM DOC.DOC_CONTROL_SEIL
       WHERE     DOC_RUT_ENTIDAD = RUT_CIA
             AND NVL (DOC_AUTORIZA_REENVIO, 'N') NOT IN ('S')
             AND NVL (DOC_APLICACION, '') = UPPER (APLICACION)
             AND DOC_PERIODO = AGNO;

      --and to_char(to_date(DOC_PERIODO, 'yyyy'), 'yyyy') = AGNO;

      IF (validadato > 0)
      THEN
         OPEN oResultSet FOR
              SELECT NVL (DOC_PERIODO, 0) AS "cod_periodo",
                     NVL (DOC_FECHA_ENVIO, '') AS "fecha_envio",
                     NVL (DOC_TIPO, '') AS "tipo_archivo"
                FROM DOC.DOC_CONTROL_SEIL
               WHERE     DOC_RUT_ENTIDAD = RUT_CIA
                     AND NVL (DOC_AUTORIZA_REENVIO, 'N') NOT IN ('S')
                     AND NVL (DOC_APLICACION, '') = UPPER (APLICACION)
                     AND DOC_PERIODO = AGNO
            ORDER BY NVL (DOC_PERIODO, 0) DESC;
      ELSE
         OPEN oResultSet FOR
            SELECT '<td colspan="3">No existe informaci&oacute;n para este a&ntilde;o</td>'
              FROM DUAL;
      END IF;
   END PRT_LISTA_SOL_REENVIO_PKG;

   --lista solicitudes de reenvio
   PROCEDURE PRT_LISTA_REENVIO_PRC (AGNO         IN     VARCHAR2,
                                    APLIC        IN     VARCHAR2,
                                    ORESULTSET      OUT CURSOR_TYPE)
   AS
      VALIDADATO   NUMBER DEFAULT 0;
   BEGIN
      SELECT COUNT (*)
        INTO VALIDADATO
        FROM DOC.DOC_CONTROL_REENVIO
       WHERE     DOC_PERIODO = TO_NUMBER (AGNO)
             --AND nvl(DOC_AUTORIZA_REENVIO,'AR') IN ('AR')
             AND DOC_AUTORIZA_REENVIO IS NULL
             AND NVL (DOC_APLICACION, '') = APLIC;

      IF (VALIDADATO > 0)
      THEN
         OPEN ORESULTSET FOR
            SELECT DOC_PERIODO AS "Periodo",
                   DOC_RUT_CIA AS "Rut Cia",
                   PRT_OBTENER_NOMBRE (DOC_RUT_CIA) AS "Nombre Cia",
                   DOC_TIPO AS "Tipo",
                   DOC_FECHA_RECEPCION AS "Fecha Recepcion",
                   DOC_COD_USUARIO AS "Usuario solicita",
                   DOC_FECHA_REENVIO AS "Fecha Solicitud Reenvio",
                   DOC_MOTIVO AS "Motivo"
              FROM DOC.DOC_CONTROL_REENVIO
             WHERE     DOC_PERIODO = TO_NUMBER (AGNO)
                   AND DOC_AUTORIZA_REENVIO IS NULL
                   AND NVL (DOC_APLICACION, '') = APLIC;
      ELSE
         OPEN ORESULTSET FOR
            SELECT '<td colspan="7">No existe informaci&oacute;n para este a&ntilde;o</td>'
              FROM DUAL;
      END IF;
   END PRT_LISTA_REENVIO_PRC;

   FUNCTION PRT_VERIFICA_REENVIO_FN (RUT_CIA IN VARCHAR2, AGNO IN VARCHAR2)
      RETURN NUMBER
   AS
      validadato   NUMBER DEFAULT 0;
   BEGIN
      SELECT COUNT (DOC_PERIODO)
        INTO validadato
        FROM DOC.DOC_CONTROL_SEIL
       WHERE     DOC_RUT_ENTIDAD = RUT_CIA
             AND NVL (DOC_AUTORIZA_REENVIO, 'N') IN ('S')
             AND DOC_PERIODO = AGNO;

      RETURN validadato;
   END PRT_VERIFICA_REENVIO_FN;


   --FUNCION DE SOPORTE PARA OBTENER NOMBRE DE CIA
   FUNCTION PRT_OBTENER_NOMBRE (IRUT IN VARCHAR2)
      RETURN VARCHAR2
   IS
      NOMBRE   VARCHAR (20);
   BEGIN
      SELECT sg_nomcor nombre_corto
        INTO NOMBRE
        FROM SG_IDENT
       WHERE SG_SITUACION < 15    -- situacion menor que 15, las cias vigentes
                               --AND SG_GRUPO  = 2   --- grupo = 2 son seguros de vida
             AND SG_1010411 = IRUT;

      RETURN NOMBRE;
   END;

   --FUNCION DE SOPORTE PARA OBTENER ULTIMO PERIODO
   PROCEDURE PRT_ULTIMO_PERIODO_PRC (RUTCIA       IN     VARCHAR2,
                                     GRUPO        IN     NUMBER,
                                     oResultSet      OUT CURSOR_TYPE)
   AS
   BEGIN
      IF (rutcia IS NOT NULL AND grupo IS NOT NULL)
      THEN
         OPEN oResultSet FOR
            SELECT NVL (MAX (PRT_PERIODO), TO_CHAR (SYSDATE, 'yyyy'))
                      AS periodo
              FROM PRT_PROD_COMERCIALIZA
             WHERE PRT_RUT_CIA = RUTCIA AND PRT_GRUPO = GRUPO;
      ELSE
         OPEN oResultSet FOR
            SELECT NVL (MAX (PRT_PERIODO), TO_CHAR (SYSDATE, 'yyyy'))
                      AS periodo
              FROM PRT_PROD_COMERCIALIZA;
      END IF;
   END;

   --FUNCION DE SOPORTE PARA CONCATENAR RESULTADOS
   FUNCTION rowconcat (q IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret    VARCHAR2 (4000);
      hold   VARCHAR2 (4000);
      cur    SYS_REFCURSOR;
   BEGIN
      OPEN cur FOR q;

      LOOP
         FETCH cur INTO hold;

         EXIT WHEN cur%NOTFOUND;

         IF ret IS NULL
         THEN
            ret := hold;
         ELSE
            ret := ret || '  <br />' || hold;
         END IF;
      END LOOP;

      RETURN ret;
   END;
 
   FUNCTION PRT_VERIFICA_FORMA_RESERVA (FORMA VARCHAR2)
      RETURN VARCHAR
   IS
      CONTADOR   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO CONTADOR
        FROM PRT_FORMA_RESERVA
       WHERE PRT_COD_FORMA = FORMA;

      IF CONTADOR > 0
      THEN
         RETURN 'OK';                                           --EXISTE FORMA
      ELSE
         RETURN 'NOK';                                                 --ERROR
      END IF;
   END PRT_VERIFICA_FORMA_RESERVA;


   FUNCTION PRT_VERIFICA_TABLA_MOR (FORMA VARCHAR2)
      RETURN VARCHAR
   IS
      SOLICITA   VARCHAR2 (1);
   BEGIN
      BEGIN
         SELECT PRT_SOLICITAR_INF
           INTO SOLICITA
           FROM PRT.PRT_FORMA_RESERVA
          WHERE PRT_COD_FORMA = FORMA;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 'OK';                                           --NO EXIGIR
      END;


      IF SOLICITA = 'S'
      THEN
         RETURN 'OK';                               --EXIGIR INFO DE TABLA MOR
      ELSE
         RETURN 'NOK';                                             --NO EXIGIR
      END IF;
   END PRT_VERIFICA_TABLA_MOR;
END PRT_SELECT_PKG;
/
