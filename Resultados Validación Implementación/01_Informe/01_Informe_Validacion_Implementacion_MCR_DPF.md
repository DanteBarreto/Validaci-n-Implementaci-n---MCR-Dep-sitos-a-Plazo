# Informe de Validación de Implementación
## Modelo Conductual MCR – Depósitos a Plazo (DPF): módulos GAPS y Asignado

| Campo | Detalle |
|---|---|
| Tipo de validación | Validación de implementación (estándar VIRF – modelos conductuales) |
| Fecha del informe | 18/11/2026 (versión 3: incorpora el contraste con la validación metodológica) |
| Cortes evaluados | GAPS: 30/09/2026 (corrida oficial del 02/10/2026). Asignado: periodo 202610 (muestras) |
| Evidencia | Repositorio `DanteBarreto/Validaci-n-Implementaci-n---MCR-Dep-sitos-a-Plazo` (commit `ee2b261`, que incluye la carpeta *Validación metodológica*), transcripción Teams del 22/10/2026 y pruebas y réplicas del validador |
| Anexos | 02 Matriz de cumplimiento (xlsx) · 03 Scripts de réplica · 04 Reporte de conciliación · 05 Resumen de grabación · 06 Requerimientos de información (xlsx) · 07 Mapa de inputs (xlsx y diagramas PNG/SVG) · 08 Resumen de la validación metodológica · Fase 1 (inventarios) |

---

## 1. Resumen ejecutivo

| Módulo | Cumple | Cumple parcialmente | No cumple | No evaluable | No aplica | KILLER que cumplen | KILLER que no cumplen / sin evidencia | Conclusión |
|---|---|---|---|---|---|---|---|---|
| GAPS | 7 | 19 | 6 | 8 | 0 | 0 | 19 | No favorable |
| Asignado | 2 | 10 | 11 | 17 | 0 | 1 | 18 | No favorable |

**Conclusión general: NO FAVORABLE para ambos módulos.** En GAPS no cumple ninguna de las 19 actividades `KILLER`; en Asignado sólo cumple IMP-01 (pruebas de impacto en el Asignado). La documentación de la validación metodológica acredita el prerrequisito GOB-02 (nota **SATISFACTORIO**, setiembre 2025) y explica el origen de las curvas, pero no subsana ninguna brecha KILLER de documentación, accesos, respaldos ni calidad de datos. El prerrequisito GOB-03 sigue sin cumplirse: GAPS se usó en producción antes de esta validación. El detalle está en la sección 7.

- **GAPS.** La parte de cálculo está **correctamente implementada salvo una regla no documentada**. La réplica independiente en Python, construida desde el manual, reproduce la clasificación de las 95.874 operaciones, la matriz de curvas (964/964 filas) y los totales, y coincide en las bandas GER, REPRECIO y CE (diferencia < 0,04 %). La excepción es el bucket **AX7** (Anexo 7): el código asigna el desgaste del primer mes según el día de vencimiento, lo que reasigna ≈S/ 1.400 MM entre buckets de 1 a 30 días (H-03). Las brechas más relevantes están en documentación, controles, accesos, backups y gobierno. GAPS **ya está en uso**: la corrida de septiembre se cargó a la Macro ALM.
- **Asignado.** La evaluación está limitada por la información entregada: no hay grabación, sólo muestras de 99 registros, y faltan 9 funciones y las tablas de TT y prima. La réplica parcial confirma el traspaso de atributos y la fórmula de ingreso financiero (100 %), pero **no permite verificar la TT asignada**. Hay incumplimientos con evidencia: uso de esquemas **sandbox** (IMP-05), **falta de segregación de funciones** (GOB-01) y ausencia de bitácora de cambios. La tabla conductual reproduce exactamente la curva remitida por Riesgos de Mercado; su no monotonicidad proviene del modelo. Queda por confirmar el tratamiento de los DPF de Tesorería, porque el SP aplica la curva RETAIL a todos los depósitos (H-15).

## 2. Alcance y limitaciones

**Alcance.** Se evaluaron las 40 actividades del checklist de `Estandares_VIRF_conductuales.md` (DOC-01 a DOC-14, CDD-01 a CDD-14, IMP-01 a IMP-09 y GOB-01 a GOB-03), por indicación del usuario. No se consideraron actividades adicionales del `.xlsx` del estándar incluido en el repositorio. Se evaluó cada módulo por separado. Para GAPS se hizo réplica completa; para Asignado, réplica parcial.

**Limitaciones.**
1. **Asignado no tiene grabación.** No hay evidencia del ejecutor real, del ambiente, de la periodicidad efectiva ni de las validaciones de resultados del SP. Esto afecta CDD-01, CDD-02, IMP-05, GOB-01 y GOB-03, que se evaluaron sólo con el manual V.0 y el código.
2. **La grabación de GAPS está truncada** (≈65 s de 28:45). El proceso se evaluó con la transcripción de Teams; no fue posible verificar visualmente pantallas ni datos después del minuto 1:05.
3. **Hay un solo periodo por módulo**, y Asignado sólo tiene muestras. Por eso no se pueden aplicar los umbrales de 3 meses de CDD-06 y CDD-13 ni las pruebas poblacionales de Asignado.
4. **Hay insumos y código no provistos**: Base DPF original, SP de origen de GAPS, Macro ALM, funciones PL/SQL y tablas de prima y TT completas. La validación metodológica se entregó el 18/11/2026; su archivo `Reporte Final - Plazos Conductuales.xlsx` está protegido y no pudo leerse.
5. El repositorio de evidencias era **público** (H-14). Toda la información se procesó localmente y no se envió a servicios externos.

## 3. Metodología de validación

1. **Fase 1 – Inventario y entendimiento:** extracción del checklist, inventario de 25 archivos, análisis de la transcripción, diagramas de flujo y mapa de 19 inputs con 23 inconsistencias. Documento: `Fase1_Inventario_y_Entendimiento.md`.
2. **Fase 2 – Evaluación:** cada actividad se calificó como Cumple, Cumple parcialmente, No cumple, No evaluable o No aplica, con su equivalencia VIRF. *Cumple parcialmente* equivale a `NO CUMPLE` en actividades KILLER, y *No evaluable* equivale a `SIN EVIDENCIA`. La severidad se califica como Alta, Media o Baja, ya que el estándar no define escala. No se asumió cumplimiento sin evidencia. Se ejecutaron pruebas propias de calidad de datos sobre los insumos disponibles.
3. **Fase 3 – Réplica:** reimplementación independiente en Python a partir de los manuales, comparación posterior con el código original, conciliación por bucket con tolerancia de 0,1 % y análisis de causa raíz.

## 4. Mapa de inputs y linaje de datos

![Linaje de inputs](diagramas/03_Linaje_inputs.png)

Diagramas por módulo: `diagramas/01_GAPS_flujo.png` y `diagramas/02_Asignado_flujo.png` (con sus fuentes `.mmd` y `.svg`). Inventario completo en `07_Mapa_Inputs_Linaje.xlsx`.

| ID | Nombre | Fuente | Responsable | GAPS | Asig. | Tipo | Controles |
|---|---|---|---|---|---|---|---|
| G-IN-01 | Base DPF DD.MM.xlsx (p. ej. 'Base DPF 30.09.xlsx') | Store procedure ejecutado por job diario; carpeta \\domibco.com.pe\fs\PRI_RIESGOS\9_GS_RIE_TESORERIA\RUTA\14 - Bases diarias\DD.MM\ | [Por confirmar] (dueño del SP/job) | Sí | No | Automático (job) + carga manual por botón | Ninguno en código (sin conteo ni cuadre a la importación) |
| G-IN-02 | Hoja Data / Base_DPF_20260930.csv | Generado por la macro a partir de G-IN-01 + reglas de Calculadora/Aux | Ejecutor GAPS (W. F. Gastelu) | Sí | No | Automático (macro) disparado manualmente | Cuadre SUM(DPF_Modelo!H) − SUM(Data!I) en Parámetros H20:H22 (sin umbral ni registro) |
| G-IN-03 | Hoja 'Curvas GAP Modelo' (curvas finales de desgaste para Gaps) | COE de Riesgo de Mercado (manual GAPS Paso 5); en grabación 'Brandon' / corporativo BCP | Remitente: COE Riesgo de Mercado [Por confirmar nombre]; carga: ejecutor GAPS | Sí | No (ver A-IN-01) | Manual (digitación/pegado) | Ninguno identificado (sin control de versión ni evidencia de remisión) |
| G-IN-04 | CURVAS.xlsx | Generado por la macro desde G-IN-03 | Ejecutor GAPS | Sí | No | Automático (macro) | Ninguno identificado |
| G-IN-05 | Data_Parametros.csv / hoja Data_Parametros | Hoja Parámetros (fecha de cierre) | Ejecutor GAPS | Sí | No | Automático, a partir de fecha digitada | Ninguno |
| G-IN-06 | Hoja Parámetros (fecha de cierre y rutas) | Digitación del ejecutor | Ejecutor GAPS | Sí | No | Manual | Tabla de estado por tarea (F8:J13) con horas; sin validación de la fecha |
| G-IN-07 | Hoja Aux (equivalencias TIPO PASIVO, listas Cooperativas/Otros) | Parametrización interna del área | [Por confirmar] | Sí | No | Manual | Ninguno identificado |
| G-IN-08 | Hoja Calculadora (reglas FLAG/CURVA y plazo máximo) | Parametrización interna | [Por confirmar] | Sí | No | Manual (parámetros) / automático (cálculo) | Ninguno identificado |
| G-IN-09 | Script '01. Simulación Modelo DPF.R' (copia desde repositorio) | \\domibco.com.pe\fs\PRI_RIESGOS\9_GS_RIE_TESORERIA\RUTA\26. Respaldo de Archivos\01. ALM\Modelo DPF\ | Riesgos de Tesorería (desarrollo propio, grabación 23:28) | Sí | No | Manual (ejecución en RStudio) | Copia desde ruta de respaldo 'para evitar cambios' (control declarado); log con etiqueta de versión |
| A-IN-01 | modelo_conductual (plazo contractual → plazo conductual) | Riesgo de Tesorería (manual Asignado §3.1); DOC-02 exige Riesgos de Mercado BCP | Riesgo de Tesorería [Por confirmar persona] | No (ver G-IN-03) | Sí | Manual (carga de tabla) [Por confirmar] | Ninguno en código |
| A-IN-02 | fin_tt_pasivo_dist_total (curvas de TT) | Gestión de Información Financiera (correo diario) | Gestión de Información Financiera | No | Sí | Automático [Por confirmar] | Ninguno en código |
| A-IN-03 | fin_prima_liquidez / fin_prima_liquidez_final | Gestión de Información Financiera | Gestión de Información Financiera | No | Sí | [Por confirmar] | Ninguno en código |
| A-IN-04 | bds.f_fin_saldos_pasivos_d@dblink_dwh_fin_pla (y f_fin_saldos_pasivos para periodos < 202301) | DWH (dblink dwh_fin_pla) | Finanzas / Gestión de Información Financiera | No | Sí | Automático | Ninguno en código; manual declara 'conteo de registros y cuadre de saldos' |
| A-IN-05 | saldos (core) | Core bancario | [Por confirmar] | No | Sí | Automático | Ninguno |
| A-IN-06 | hd_broad_contable | Contabilidad (broad) | [Por confirmar] | No | Sí | Automático | Conteo de carga (v_carga_broad) para decidir fuente de intereses |
| A-IN-07 | input_pre_duration / tbl_pre_duration | Riesgo de Tesorería (pesos metodológicos) | Riesgo de Tesorería | No | Sí (no DPF) | [Por confirmar] | Ninguno |
| A-IN-08 | Dimensiones y enriquecimiento: fin_calendario, hm_egd, lkh_s.hm_funcionario_ctr, md_clientes, fin_dim_productos_pasivos, fin_segmentacion_comercial, FIN_MODELO_ATENCION, cl_clientpersona, fin_detalle_empleado_hm | DWH / tablas internas | [Por confirmar] | No | Sí | Automático | Ninguno |
| A-IN-09 | Tablas sandbox: sdbx_inco.dim_puestoscanal, sdbx_pas.pp_pasivos_diarios, sdbx_pas.mp_pas_aperturas_mens, sdbx_pas.pp_dinero_fresco_comp, ew_segm.mbco_segmento_rie_gestion@dblink_dbsanbox0…, sdbx_pla.* | Esquemas sandbox (sdbx_*) | [Por confirmar] | No | Sí | Automático | Ninguno |
| A-IN-10 | Funciones PL/SQL: f_tipo_documento, f_asigna_flujo_pasivo, f_familia_producto_pas, f_asigna_rango_monto_pasivo, f_asigna_rango_plazo_pasivo, f_grupo_producto, f_familia_producto_2, f_tt_pasiva_geb, f_pasivo_if_0_nuevo | Base de datos (código no provisto) | [Por confirmar] | No | Sí | Automático | — |

**Dependencias.** No hay dependencias físicas entre los módulos: ningún output de uno es input del otro, y pueden ejecutarse en cualquier orden. La dependencia es **conceptual**: ambos deberían basarse en la misma curva conductual corporativa, pero GAPS la usa como curvas de desgaste y Asignado como tabla de equivalencia de plazos, y no hay evidencia de que sean consistentes (H-07, H-08).

**Inconsistencias y su vínculo con los hallazgos**

| ID | Descripción | Módulo | Criterios | Hallazgo vinculado |
|---|---|---|---|---|
| INC-01 | La fuente original 'Base DPF DD.MM.xlsx' (49 columnas, ruta '14 - Bases diarias') y el store procedure/job que la genera no están en el repositorio; sólo existe el CSV derivado. | GAPS | DOC-05, CDD-04, CDD-13, IMP-05 | H-11 |
| INC-02 | Data_Macro_ALM_DPF_20260930.xlsx es output del módulo (Paso 9) pero está en '3.1 Inputs'. | GAPS | DOC-07 | H-13 |
| INC-03 | Sólo se entregan las particiones 94-96 (inputs y resultados); el log registra 96 particiones. | GAPS | CDD-06, CDD-13 | H-11 |
| INC-04 | El ejecutor elimina manualmente las filas posteriores a la última fila de la hoja Data para evitar un error; no figura en el manual. | GAPS | DOC-06, CDD-01 | H-09 |
| INC-05 | GAPS atribuye las curvas al 'COE de Riesgo de Mercado' / corporativo; Asignado atribuye las 'curvas conductuales' a 'Riesgo de Tesorería'; el estándar exige la curva de 'Riesgos de Mercado BCP'. No hay evidencia de remisión en ninguno de los dos. | Ambos | DOC-02 | H-08 |
| INC-06 | GAPS usa curvas de desgaste mensual por plazo agrupado; Asignado usa una tabla de equivalencia plazo contractual→conductual. No se documenta la relación entre ambas ni si provienen del mismo modelo corporativo. [Actualización 18/11/2026: ambas representaciones provienen de la misma entrega de RdM (correo del 07/08/2025): curvas GAP por plazo agrupado y plazos conductuales diarios interpolados.] | Ambos | DOC-02, DOC-06 | H-07 |
| INC-07 | La captura del manual Asignado muestra registros 'ACTUAL'; la muestra entregada sólo contiene 'NUEVA'. El SP usa 'NUEVA' desde 202601. | Asignado | DOC-03, DOC-06 | H-07 |
| INC-08 | La muestra entregada es 'f_fin_saldos_pasivos' (mensual); para periodos ≥ 202301 el SP consume 'f_fin_saldos_pasivos_d' (diaria). | Asignado | DOC-05, CDD-13 | H-10 |
| INC-09 | El SP lee y escribe en esquemas sdbx_* y el manual indica ejecución en sandbox; el manual no lo trata como excepción ni incluye plan de regularización. | Asignado | IMP-05 | H-05 |
| INC-10 | 9 funciones PL/SQL que determinan TT_PASIVA_GEB e ING_FIN_TOTAL no están en el repositorio; tampoco fin_prima_liquidez_final ni el proceso que carga fin_tt_pasivo_dist_total. | Asignado | DOC-06, réplica | H-10 |
| INC-11 | Manual: IF = (1+TT)^(días/360) − 1 * saldo promedio (precedencia de operadores ambigua). Código: saldo_promedio × ((1 + f_pasivo_if_0_nuevo(...))^(días/360) − 1), donde la tasa proviene de una función no provista. | Asignado | DOC-06 | H-10 |
| INC-12 | v_ultimo_dia se calcula desde SYSDATE (día de ejecución) y no desde el parámetro v_periodo; la ejecución depende de la fecha en que se corre. Existe una línea comentada con fecha fija 20261031. | Asignado | DOC-06, reproducibilidad | H-10 |
| INC-13 | Para periodos > 202008, v_fecha_prima se obtiene de input_pre_duration y no de fin_prima_liquidez. | Asignado | DOC-06 [Por confirmar con desarrollador] | H-10 |
| INC-14 | GAPS evidencia el corte 30/09/2026; Asignado evidencia el periodo 202610 (31/10/2026). No hay un mismo corte para ambos módulos. | Ambos | CDD-06, CDD-13 | H-11 |
| INC-15 | El MP4 está truncado (≈65 s de 28:45). Sólo la transcripción cubre la reunión completa; no es posible verificar visualmente pantallas, controles ni datos mostrados. | GAPS | Limitación de alcance | RQ-08 |
| INC-16 | Exportar_Resultados selecciona la hoja 'Prepago_Creditos', inexistente en el libro; el error queda oculto por 'On Error Resume Next'. La grabación (≈14:43) menciona que la macro proviene de la estructura de prepago. | GAPS | DOC-14 | H-09 |
| INC-17 | Data_Parametros.csv incluye Fecha_Cierre, pero el script R no la lee; la fecha de proceso se toma de la columna FECHA_PROCESO de la data. | GAPS | DOC-06 | H-13 |
| INC-18 | En 'Curvas GAP Modelo' los plazos 1.500 (RETAIL) y 570 (TESORERIA NO IFIS) tienen 'Meses' por fórmula y porcentajes no redondos (p. ej. 0,11990000000000002), a diferencia del resto. No se documenta su origen. [Actualización 18/11/2026: los nodos 1.500 y 570 corresponden a las filas '>1110' y '>540' de las curvas de RdM; el 570 se cierra en el mes 19 en la macro.] | GAPS | DOC-02, DOC-06 | H-08 |
| INC-19 | El manual describe el relleno hacia nodos superiores con 'nodos de las curvas inferiores'; el código, cuando el nodo previo vale 1, toma el valor del nodo anterior (c−1). La grabación sólo describe el uso del nodo posterior. | GAPS | DOC-06 | H-03 |
| INC-20 | Asignado: las mismas dos personas figuran como Implementador/Modificador y como Usuario. GAPS: el manual asigna al 'Subgerente/Especialista/Analista Senior de Riesgos' sin nombre; control de cambios: actualiza F. Gastelú, revisa A. Arrieta (también solicitante del Asignado). | Ambos | GOB-01 | H-06 |
| INC-21 | Base DPF (SP/job), hojas Aux y Calculadora, tablas sandbox y dimensiones del SP no tienen responsable identificado. | Ambos | DOC-05, CDD-02 | H-01 |
| INC-22 | El .xlsx del estándar del repositorio contiene una hoja adicional ('Modelos TIR I, II y III') con actividades que no están en el .md. Por indicación del usuario (17/11/2026), la evaluación se limita a las 40 actividades del .md y esa hoja no se considera. | General | Alcance | Alcance definido: 40 actividades del .md |
| INC-23 | El repositorio de GitHub es público y contiene datos a nivel de operación (95.874 DPF con código de cliente, número de cuenta y número de documento en la muestra de Asignado). | General | No es criterio VIRF; riesgo de información | H-14 |

## 5. Resultados del checklist

Los detalles por actividad (evidencia, hallazgo y recomendación) están en `02_Matriz_Cumplimiento_Checklist.xlsx`.

### 5.1 GAPS
| ID | Etiq. | Resultado | VIRF | Hallazgo | Sev. | Evidencia |
|---|---|---|---|---|---|---|
| DOC-01 | — | Cumple parcialmente | NO CUMPLE (parcial) | El manual metodológico identifica el objetivo del FTP y el código del modelo (MOD-MIB-0001755). El manual operativo de GAPS no lo referencia ni identifica la versión productiva. | Media | Manual GAPS v2 (completo); Transcripción Teams 24:43–25:31; [VM] MiBanco DPF - Documento Metodológico.docx (MOD-MIB-0001755, v1, 20/05/2025) §1 |
| DOC-02 | — | Cumple | CUMPLE | Riesgos de Mercado BCP (B. Calsi, COE Riesgo de Mercado Estructural, Negociación y Liquidez) remitió las curvas GAP al ejecutor y definió el tratamiento de plazos intermedios (curva superior directa) y > 1.110 días (promedio por maduración). Las curvas de la macro coinciden con las de RdM redondeadas a 4 decimales (dif. máx. 0,00005) en ambas monedas; los nodos 1.500 y 570 corresponden a las filas '>1110' y '>540' de RdM. Observación residual: el nodo 570 se cierra en el mes 19, mientras que RdM mantiene una proporción estable de 1,65 % hasta el mes 50 (sin exposición al corte: 0 operaciones TESORERIA NO IFIS > 540 días). El archivo 'Reporte Final - Plazos Conductuales.xlsx' está protegido y no pudo leerse; el contraste se hizo con 'Ejemplo DPF_MiBanco.xlsx'. | Baja | Macro, hoja 'Curvas GAP Modelo'; manual GAPS Paso 5 y §4; transcripción 23:39–23:58; [VM] correo 'RE: Resultados - Depósitos a Plazo MB' (23/06, 14/07, 07/08 y 13/08/2025); Ejemplo DPF_MiBanco.xlsx hoja 'Curvas GAP'; contraste_validacion_metodologica.xlsx (C1) |
| DOC-03 | KILLER | Cumple parcialmente | NO CUMPLE | Existe bitácora con versión, fecha, responsable, revisor y descripción (v01 y v02), pero no tiene el campo 'aprobado por'. Tampoco cubre el script R ni la macro, cuya única etiqueta es 'Setiembre_2025 Versión 1.0'. | Alta | Manual GAPS §5; R l.241; log Output_R02 |
| DOC-04 | KILLER | Cumple parcialmente | NO CUMPLE | El modelo tiene ID de inventario MOD-MIB-0001755 (manuales metodológico y operativo de RdM), pero la documentación de implementación del módulo no lo consigna. | Media | Manual GAPS; transcripción 24:43; [VM] MiBanco DPF - Documento Metodológico.docx (MOD-MIB-0001755, v1, 20/05/2025), carátula |
| DOC-05 | KILLER | Cumple parcialmente | NO CUMPLE | El universo se describe de forma genérica. No se documentan el SP de origen, los filtros ni el mapeo de 26 de las 49 columnas (sólo existe en el VBA). Se incluyen 7 DPF ABANDONADO ya vencidos y 2 de tipo AJUSTE sin un criterio documentado. | Alta | Manual GAPS §3; VBA Importar_Data l.318-346; base (TIPO_DPF) |
| DOC-06 | KILLER | Cumple parcialmente | NO CUMPLE | Los cálculos principales están documentados y la réplica los reproduce. No están documentados: (i) la regla AX7 de la banda 1 basada en el día de vencimiento, que reasigna S/ 1.400 MM entre buckets; (ii) el redondeo por banda; (iii) el borrado manual de filas (INC-04); (iv) la regla de relleno de nodos superiores cuando el nodo previo vale 1 (INC-19). | Alta | Manual GAPS Paso 5 y §4; R l.340-431; VBA l.100-216; réplica |
| DOC-07 | KILLER | Cumple parcialmente | NO CUMPLE | Están documentadas las rutas de bases diarias y del repositorio R. Faltan la ruta de la carpeta de trabajo mensual (…\01 - Reportes y Monitoreo\…) y la de la Macro ALM. | Alta | Manual GAPS §3, Paso 3 y Paso 9; macro hoja Parámetros |
| DOC-08 | KILLER | Cumple parcialmente | NO CUMPLE | Hay una única captura de la carpeta del script, que no muestra la arquitectura de directorios ni el esquema de versionamiento. | Alta | Manual GAPS Paso 3 (imagen) |
| DOC-09 | KILLER, SOX | No cumple | NO CUMPLE | No hay evidencia visual de usuarios, grupos ni roles con acceso a los directorios. Por ser SOX, se requiere evidencia trazable. | Alta | Manual GAPS |
| DOC-10 | KILLER, SOX | No cumple | NO CUMPLE | No hay evidencia de accesos al origen de los inputs: el schema o tablas del SP, ni la carpeta '14 - Bases diarias'. | Alta | Manual GAPS |
| DOC-11 | KILLER, SOX | Cumple parcialmente | NO CUMPLE | La única ruta de respaldo ('26. Respaldo de Archivos') es a la vez el repositorio de origen. No hay evidencia de custodia ni de respaldo independiente. | Alta | Manual GAPS Paso 3 (imagen) y nota 1; hoja Parámetros F3 |
| DOC-12 | KILLER, SOX | No cumple | NO CUMPLE | No hay evidencia de mecanismos de respaldo del origen de los inputs. | Alta | Manual GAPS |
| DOC-13 | — | No cumple | NO CUMPLE | La condición aplica, porque no hay bitácora del script ni herramienta de versiones. El script R y el VBA no tienen cabecera de control de cambios. | Media | R l.1-15; VBA Módulo1 |
| DOC-14 | — | Cumple parcialmente | NO CUMPLE (parcial) | El script R está comentado. El VBA tiene comentarios mínimos y usa 'On Error Resume Next', que oculta errores (INC-16). | Baja | R (comentarios por bloque); VBA Módulo1 |
| CDD-01 | KILLER, SOX | No cumple | NO CUMPLE | No existe monitoreo de calidad de datos mínimos (duplicados, nulos, comparación con el mes anterior ni semáforo). El único control es un cuadre de monto total sin umbral ni registro. | Alta | Manual GAPS; transcripción (pasos R-01 a R-13); macro hoja Parámetros H20:H22 |
| CDD-02 | KILLER, SOX | No evaluable | SIN EVIDENCIA | No hay evidencia de comunicación de resultados de calidad de datos. | Alta | — |
| CDD-03 | KILLER, SOX | No evaluable | SIN EVIDENCIA | No hay documento formal de seguimiento. La validación metodológica dejó abierta la observación 'No se cuenta con el seguimiento a la metodología' (Squad de Seguimiento, 31/08/2026); no hay evidencia de su atención. | Alta | —; [VM] Validación metodológica/2. Resultados/Presentaciones/Informe MCR DPF MIBPE 2025.pdf p. 3 |
| CDD-04 | — | Cumple | CUMPLE | 0 duplicados por NUMERO_DESEMBOLSO (95.874 registros) y 0 filas duplicadas. La llave del modelo no está documentada [Por confirmar]. | Baja | Prueba del validador sobre Base_DPF_20260930.csv |
| CDD-05 | — | Cumple parcialmente | NO CUMPLE (parcial) | La base no tiene fecha de cancelación. Hay 535 combinaciones repetidas de (cliente, moneda, TEA, apertura, vencimiento, monto) con distinto número de desembolso, que pueden ser operaciones legítimas. | Media | Prueba del validador |
| CDD-06 | — | Cumple parcialmente | NO CUMPLE (parcial) | Coincidencia del 100 % en clasificación (4 variables), CURVAS (964 filas), capital y bandas GER, REPRECIO y CE (máx. 0,037 %). La banda AX7 coincide en 89,9 % de las filas (< 99 %); la causa raíz está identificada (DOC-06). Sólo hay 1 periodo disponible (se exigen 3). | Alta | Réplica GAPS (conciliacion_gaps.xlsx) |
| CDD-07 | — | Cumple | CUMPLE | 0 valores negativos en monto, intereses, pago y saldo. | Baja | Prueba del validador |
| CDD-08 | — | No evaluable | SIN EVIDENCIA | Sólo se entregó el corte 30/09/2026. | Media | Repositorio (1 periodo) |
| CDD-09 | — | Cumple | CUMPLE | 0 nulos en las tablas agregadas. | Baja | Output_R01 y Data_Macro_ALM |
| CDD-10 | — | Cumple parcialmente | NO CUMPLE (parcial) | 0 nulos en todas las columnas, pero la base no contiene codproducto, tipbanca ni codsubsegmento. | Baja | Base_DPF_20260930.csv |
| CDD-11 | — | Cumple | CUMPLE | 0 operaciones con apertura posterior a la fecha de proceso. | Baja | Prueba del validador |
| CDD-12 | — | Cumple | CUMPLE | 0 operaciones con apertura posterior al vencimiento. Hay 7 DPF ABANDONADO con vencimiento anterior al corte (S/ 39.538), que se asignan en la banda 1. | Baja | Prueba del validador |
| CDD-13 | — | Cumple parcialmente | NO CUMPLE (parcial) | El universo es consistente entre la hoja Data, el CSV, el log y la réplica (95.874 registros; monto total igual). No se pudo comparar con la fuente original (Base DPF xlsx no provista). Sólo hay 1 periodo. | Media | Hoja Data, CSV, log (96 particiones), cuadre H20:H22, réplica |
| CDD-14 | — | No evaluable | SIN EVIDENCIA | No hay evidencia de ejecución del motor ARM y el validador no tiene acceso a él. | Media | — |
| IMP-01 | KILLER | Cumple parcialmente | NO CUMPLE | El equipo modelador presentó impactos en GER, VEN y GaP de liquidez acumulado (junio 2025) y la validación metodológica confirma que 'se tienen cálculos de los impactos en el Asignado y GAP'. Son impactos del modelo propuesto calculados antes de la implementación; no hay pruebas con la herramienta productiva (macro + R) ni papeles de trabajo. | Alta | [VM] MiBanco DPF - Presentación.pdf (agosto 2025, adjunto al correo de socialización) pp. 13-16 ('Impactos complementarios': GER, VEN y GaP de liquidez); Resultados Finales MCR DPF MIBPE 2025 v2 - Comite.pptx lám. 2 |
| IMP-02 | KILLER | Cumple parcialmente | NO CUMPLE | El implementador comunicó al modelador los casos detectados al aplicar la curva (21.600–21.704 operaciones con plazos fuera de los nodos y 493 con plazo > 1.110 días) y se acordó el tratamiento. No hay evidencia de comunicación de esos hallazgos al negocio ni de un plan de acción formal. | Alta | [VM] correo 'RE: Resultados - Depósitos a Plazo MB' (23/06, 14/07, 07/08 y 13/08/2025) (consultas del 30/07/2025 y respuesta del 07/08/2025) |
| IMP-03 | KILLER | Cumple parcialmente | NO CUMPLE | Los resultados e impactos se socializaron el 02/09/2025 con 17 participantes de MiBanco y BCP (Riesgos de Tesorería, implementadores del Asignado y otros). Corresponden al modelo propuesto, no a pruebas de inicio de la implementación productiva, y no se identifica qué participantes representan al negocio. | Alta | [VM] correo 'RE: Modelo Conductual de DPF - Socialización de impactos' (reunión 02/09/2025; envío 03/09/2025); MiBanco DPF - Presentación.pdf (agosto 2025, adjunto al correo de socialización) pp. 13-16 |
| IMP-04 | KILLER | Cumple parcialmente | NO CUMPLE | Hay conformidad de D. Cardoso (revisor y aprobador del manual metodológico) sobre los manuales y cálculos del modelo. No es una conformidad del PO ni del negocio sobre la implementación del módulo. | Alta | [VM] correo 'RE: Aprobación: Modelo Conductual de Prepago - MiBanco DPF' (D. Cardoso, 'Conforme', 04/09/2025) |
| IMP-05 | — | No evaluable | SIN EVIDENCIA | Los inputs provienen de archivos generados por un SP cuyas tablas fuente no se conocen. | Media | Manual GAPS §3 |
| IMP-06 | — | No evaluable | SIN EVIDENCIA | No hay definición de usuarios, grupos ni roles de los directorios. | Media | — |
| IMP-07 | — | No evaluable | SIN EVIDENCIA | No hay definición de accesos al schema fuente. | Media | — |
| IMP-08 | KILLER | Cumple parcialmente | NO CUMPLE | La ruta '26. Respaldo de Archivos' existe y se usa como origen del script. No hay evidencia de que esté habilitada como respaldo con custodia ni de sus permisos. | Alta | Hoja Parámetros F3; manual Paso 3 y nota 1; transcripción 0:06–8:46 |
| IMP-09 | KILLER | No evaluable | SIN EVIDENCIA | No hay evidencia de respaldos del origen de los inputs. | Alta | — |
| GOB-01 | — | Cumple parcialmente | NO CUMPLE (parcial) | La bitácora tiene actualizador y revisor distintos (F. Gastelú y A. Arrieta). La macro y el R los desarrolló el mismo equipo que los ejecuta, y no hay conformidad de implementación de un tercero. | Media | Manual GAPS §5; transcripción 23:28 |
| GOB-02 | Prerrequisito | Cumple | CUMPLE | Existe validación metodológica del CoE Model Risk Management (Tier I, setiembre 2025) con nota SATISFACTORIO ('se recomienda su uso'), anterior a esta validación. Queda abierta una observación de Gobierno (riesgo nulo): seguimiento de la metodología, con fecha 31/08/2026, sin evidencia de atención. | Baja | [VM] Validación metodológica/2. Resultados/Presentaciones/Informe MCR DPF MIBPE 2025.pdf pp. 2-3; Resultados Finales MCR DPF MIBPE 2025 v2 - Comite.pptx lám. 1-3 |
| GOB-03 | Prerrequisito | No cumple | NO CUMPLE | El modelo está en uso: la corrida oficial de septiembre 2026 se cargó en la Macro ALM antes y durante la validación. | Alta | Log Output_R02 (02/10/2026); Data_Macro_ALM_DPF exportado; transcripción 10:09–17:58 |

### 5.2 Asignado
| ID | Etiq. | Resultado | VIRF | Hallazgo | Sev. | Evidencia |
|---|---|---|---|---|---|---|
| DOC-01 | — | Cumple parcialmente | NO CUMPLE (parcial) | El objetivo existe ('cálculo del asignado para pasivos retail'), pero falta el nombre y código del modelo y la versión productiva. | Media | Manual Asignado V.0 §1 |
| DOC-02 | — | Cumple parcialmente | NO CUMPLE (parcial) | RdM BCP remitió los plazos conductuales diarios (1 a 9.000) con interpolación lineal y extrapolación > 1.110 días. La tabla modelo_conductual coincide al 100 % (9.000/9.000) con la curva propuesta RETAIL (PEN y USD). La no monotonicidad (73 tramos, 271–1.110 días) proviene de los nodos RMST del modelo (p. ej. 270 → 227,6 y 300 → 184,8 días), no de la implementación. Pendiente: el manual atribuye la curva a 'Riesgo de Tesorería' sin citar remisión ni versión, y la tabla sólo contiene la curva RETAIL, aunque la entrega de RdM incluye curvas para TESORERIA IFIS y NO IFIS (H-15). | Media | Manual Asignado V.0 §3.1 y §3.2 Paso 1; muestra modelo_conductual; [VM] correo 'RE: Resultados - Depósitos a Plazo MB' (23/06, 14/07, 07/08 y 13/08/2025); Supuesto_Conductual_DPF_Propuesta.csv; Tabla_Resultados_Finales.xlsx hoja 'KM_RdM'; contraste_validacion_metodologica.xlsx (C2, C3) |
| DOC-03 | KILLER | No cumple | NO CUMPLE | No hay bitácora de cambios: sólo existe una política descriptiva. | Alta | Manual Asignado V.0 (V.0) |
| DOC-04 | KILLER | Cumple parcialmente | NO CUMPLE | El modelo tiene ID de inventario MOD-MIB-0001755 (manuales metodológico y operativo de RdM), pero la documentación de implementación del módulo no lo consigna. | Media | Manual Asignado V.0; [VM] MiBanco DPF - Documento Metodológico.docx (MOD-MIB-0001755, v1, 20/05/2025), carátula |
| DOC-05 | KILLER | No cumple | NO CUMPLE | El manual no define el universo. Los filtros (co_cliente≠0, tz_lock=0, c9314∈{2,3,4}, cuentas 4111/4121, corte 202104) sólo están en el código. | Alta | Manual Asignado V.0; SP l.130-160, 199, 256 |
| DOC-06 | KILLER | Cumple parcialmente | NO CUMPLE | Se describen los pasos 1 a 4. No se documentan el piso de fecha 01/06/2015, el corte 202104, las funciones de TT GEB e IF, ni la precedencia de la fórmula IF (INC-11). | Alta | Manual Asignado V.0 §3.2; SP l.401-408, 565-567 |
| DOC-07 | KILLER | No cumple | NO CUMPLE | No se documentan rutas, repositorios, schemas ni dblinks. | Alta | Manual Asignado V.0 |
| DOC-08 | KILLER | No cumple | NO CUMPLE | No hay evidencia visual de directorios. | Alta | Manual Asignado V.0 |
| DOC-09 | KILLER, SOX | No cumple | NO CUMPLE | Hay una tabla de roles, pero no evidencia visual de privilegios (SOX). | Alta | Manual Asignado V.0 §3.1 (tabla de roles) |
| DOC-10 | KILLER, SOX | No cumple | NO CUMPLE | No hay evidencia de accesos a los schemas de input (incluidos los sdbx_*). | Alta | Manual Asignado V.0 |
| DOC-11 | KILLER, SOX | No cumple | NO CUMPLE | No hay evidencia de un repositorio de respaldo de scripts. | Alta | Manual Asignado V.0 |
| DOC-12 | KILLER, SOX | No cumple | NO CUMPLE | No hay evidencia de respaldo de los schemas de input. | Alta | Manual Asignado V.0 |
| DOC-13 | — | No cumple | NO CUMPLE | No tiene cabecera ni versión; sólo comentarios fechados sueltos. | Media | SP l.1-15 |
| DOC-14 | — | Cumple parcialmente | NO CUMPLE (parcial) | Tiene comentarios puntuales; las funciones invocadas no están documentadas. | Baja | SP |
| CDD-01 | KILLER, SOX | No evaluable | SIN EVIDENCIA | Los controles son declarativos; no hay evidencia de su ejecución ni semáforo. | Alta | Manual Asignado V.0 §3.1 'Controles mínimos' |
| CDD-02 | KILLER, SOX | No evaluable | SIN EVIDENCIA | No hay evidencia. | Alta | — |
| CDD-03 | KILLER, SOX | No evaluable | SIN EVIDENCIA | No hay evidencia. La validación metodológica dejó abierta la observación 'No se cuenta con el seguimiento a la metodología' (Squad de Seguimiento, 31/08/2026); no hay evidencia de su atención. | Alta | —; [VM] Validación metodológica/2. Resultados/Presentaciones/Informe MCR DPF MIBPE 2025.pdf p. 3 |
| CDD-04 | — | No evaluable | SIN EVIDENCIA | En la muestra no hay duplicados por (cuenta, ordinal), pero no se entregó la población. | Media | Muestras (99 registros) |
| CDD-05 | — | No evaluable | SIN EVIDENCIA | Sólo hay muestra. | Media | Muestras |
| CDD-06 | — | Cumple parcialmente | NO CUMPLE (parcial) | Traspaso de 8 variables: 100 %. Ingreso financiero dada la TT: 100 % (máx. dif. rel. 5,6e-14). La TT y la prima no se pudieron replicar (sólo hay muestra de TT en plazos 1.693–1.742). Hay 1 periodo. | Media | Réplica Asignado (replica_asignado.xlsx) |
| CDD-07 | — | No evaluable | SIN EVIDENCIA | Población no provista. En la muestra hay 3 GAST_FIN_TOTAL negativos sin justificación. | Media | Muestra output |
| CDD-08 | — | No evaluable | SIN EVIDENCIA | Sólo hay un periodo. | Media | — |
| CDD-09 | — | No evaluable | SIN EVIDENCIA | No se entregó tabla agregada. | Baja | — |
| CDD-10 | — | No evaluable | SIN EVIDENCIA | En la muestra: CO_SEGM_RIES con 5 nulos y NU_DOCUMENTO con 5 nulos en el output; producto, moneda, apertura y saldo completos. | Media | Muestras |
| CDD-11 | — | No evaluable | SIN EVIDENCIA | Muestra: 0 casos. | Baja | Muestra |
| CDD-12 | — | No evaluable | SIN EVIDENCIA | Muestra: 0 casos. | Baja | Muestra |
| CDD-13 | — | No evaluable | SIN EVIDENCIA | Población no provista. | Media | — |
| CDD-14 | — | No evaluable | SIN EVIDENCIA | No hay evidencia de ejecución del motor ARM. | Media | — |
| IMP-01 | KILLER | Cumple | CUMPLE | Hay pruebas que sustentan los impactos en el Asignado: impacto en ingreso financiero y TT de 202501 a 202506 (MiBanco) y estimación del COE Riesgo de Mercado por moneda y segmento. La validación metodológica replicó el impacto con una diferencia de 1,01 % (cálculo proxy). | Baja | [VM] MiBanco DPF - Presentación.pdf (agosto 2025, adjunto al correo de socialización) pp. 13-16 pp. 13-14; Analisis Impactos Curva DPF - MIB.xlsx (M. Bendezú, 18/08/2025); Resultados Finales MCR DPF MIBPE 2025 v2 - Comite.pptx lám. 2 |
| IMP-02 | KILLER | Cumple parcialmente | NO CUMPLE | El implementador comunicó al modelador los casos detectados al aplicar la curva (21.600–21.704 operaciones con plazos fuera de los nodos y 493 con plazo > 1.110 días) y se acordó el tratamiento. No hay evidencia de comunicación de esos hallazgos al negocio ni de un plan de acción formal. | Alta | [VM] correo 'RE: Resultados - Depósitos a Plazo MB' (23/06, 14/07, 07/08 y 13/08/2025) (consultas del 30/07/2025 y respuesta del 07/08/2025) |
| IMP-03 | KILLER | Cumple parcialmente | NO CUMPLE | Los resultados e impactos se socializaron el 02/09/2025 con 17 participantes de MiBanco y BCP (Riesgos de Tesorería, implementadores del Asignado y otros). Corresponden al modelo propuesto, no a pruebas de inicio de la implementación productiva, y no se identifica qué participantes representan al negocio. | Alta | [VM] correo 'RE: Modelo Conductual de DPF - Socialización de impactos' (reunión 02/09/2025; envío 03/09/2025); MiBanco DPF - Presentación.pdf (agosto 2025, adjunto al correo de socialización) pp. 13-16 |
| IMP-04 | KILLER | Cumple parcialmente | NO CUMPLE | Hay conformidad de D. Cardoso (revisor y aprobador del manual metodológico) sobre los manuales y cálculos del modelo. No es una conformidad del PO ni del negocio sobre la implementación del módulo. | Alta | [VM] correo 'RE: Aprobación: Modelo Conductual de Prepago - MiBanco DPF' (D. Cardoso, 'Conforme', 04/09/2025) |
| IMP-05 | — | No cumple | NO CUMPLE | Consume y escribe en esquemas sandbox (sdbx_*) y el manual indica que se ejecuta en el sandbox. No hay análisis de calidad de campos ni plan de regularización. | Alta | SP l.207, 264, 350, 418, 422, 425, 471, 647-656; manual §3.5 |
| IMP-06 | — | Cumple parcialmente | NO CUMPLE (parcial) | Hay roles de herramienta para 2 personas, sin definición de grupos ni directorios. | Media | Manual Asignado V.0 §3.1 |
| IMP-07 | — | No evaluable | SIN EVIDENCIA | No hay evidencia. | Media | — |
| IMP-08 | KILLER | No evaluable | SIN EVIDENCIA | No hay evidencia. | Alta | — |
| IMP-09 | KILLER | No evaluable | SIN EVIDENCIA | No hay evidencia. | Alta | — |
| GOB-01 | — | No cumple | NO CUMPLE | M. Bendezú y P. López son a la vez Implementador/Modificador y Usuario. No hay conformidad de un tercero. | Alta | Manual Asignado V.0 §3.1 |
| GOB-02 | Prerrequisito | Cumple | CUMPLE | Existe validación metodológica del CoE Model Risk Management (Tier I, setiembre 2025) con nota SATISFACTORIO ('se recomienda su uso'), anterior a esta validación. Queda abierta una observación de Gobierno (riesgo nulo): seguimiento de la metodología, con fecha 31/08/2026, sin evidencia de atención. | Baja | [VM] Validación metodológica/2. Resultados/Presentaciones/Informe MCR DPF MIBPE 2025.pdf pp. 2-3; Resultados Finales MCR DPF MIBPE 2025 v2 - Comite.pptx lám. 1-3 |
| GOB-03 | Prerrequisito | No evaluable | SIN EVIDENCIA | Hay indicios de uso (tabla generada para oct-2026 y usuarios consumidores descritos), sin confirmación formal. | Alta | Manual Asignado V.0 §3.1 'Usos y usuarios'; output 202610 |

## 6. Réplica

**Factibilidad.** GAPS: **Sí**. Se replicó por completo con los insumos del repositorio; sólo faltan la fuente original (Base DPF xlsx) y periodos adicionales. Asignado: **Parcialmente**. Faltan las funciones de TT e IF, las tablas de prima y TT completas, y las poblaciones.

**Resultados.** En GAPS, totales, curvas, clasificación y bandas GER, REPRECIO y CE coinciden dentro de tolerancia. Los buckets AX7 difieren por una regla no documentada; al aplicar esa regla, la réplica coincide al 100 % (detalle en `04_Reporte_Conciliacion.md`). En Asignado, el traspaso de atributos y el ingreso financiero dada la TT coinciden al 100 %; la TT, la prima y el plazo conductual no son verificables con la información entregada.

| MONEDA | Monto oficial | Monto réplica | Dif. abs. | Dif. rel. | Dif. interés vto. | Dentro de tolerancia |
|---|---|---|---|---|---|---|
| 1 | 8,693,473,809.58 | 8,693,473,809.58 | 0.00 | 0.0000 % | -1.90 | Sí |
| 2 | 80,614,107.83 | 80,614,107.83 | 0.00 | 0.0000 % | -0.11 | Sí |

## 7. Contraste con la validación metodológica

Se revisó la carpeta *Validación metodológica* como referencia (resumen completo en `08_Resumen_Validacion_Metodologica.md`). La validación del CoE Model Risk Management (Tier I, setiembre 2025) tiene nota **SATISFACTORIO**. Se verificó si su documentación subsana observaciones de esta validación:

1. **Curvas GAP (GAPS).** Coinciden con las remitidas por Riesgos de Mercado BCP, redondeadas a 4 decimales (diferencia máxima 0,00005, ambas monedas). Los nodos 1.500 y 570 días son las filas `>1110` y `>540` de Riesgos de Mercado. Sólo difiere el nodo 570, que la macro cierra en el mes 19; no tiene exposición al corte.
2. **Tabla conductual (Asignado).** `modelo_conductual` coincide al 100 % con la curva propuesta RETAIL (9.000 plazos, PEN y USD). La no monotonicidad viene de los nodos RMST del modelo (p. ej. 270 días → 227,6 y 300 días → 184,8).
3. **Gobierno y pruebas.** Hay remisión formal de la curva (correos de junio a agosto 2025), impactos en Asignado y GAP, socialización con stakeholders (02/09/2025), conformidad sobre el modelo (04/09/2025) e ID de inventario MOD-MIB-0001755. Son evidencias del modelo, no de la implementación productiva, por lo que IMP-02 a IMP-04 y DOC-04 pasan sólo a *Cumple parcialmente*.
4. **Nueva observación.** El modelo define curvas distintas para Tesorería IFIS y no IFIS, pero el SP del Asignado une la tabla sólo por plazo (H-15).

Resultados modificados (detalle en la pestaña `Cambios_Val_Metodologica` de la matriz; evidencia en `replica_resultados/contraste_validacion_metodologica.xlsx`):

| ID | Módulo | Resultado anterior | Resultado actual | Motivo |
|---|---|---|---|---|
| DOC-01 | GAPS | No evaluable | Cumple parcialmente | Se entregó el manual metodológico con objetivo y código del modelo. |
| DOC-02 | GAPS | Cumple parcialmente | Cumple | Se evidencia la remisión de RdM y la coincidencia de curvas. |
| DOC-02 | Asignado | Cumple parcialmente | Cumple parcialmente | Sin cambio de resultado: se acredita la remisión de RdM y la coincidencia exacta de la tabla, pero queda pendiente el tratamiento de Tesorería (H-15) y la atribución en el manual. |
| DOC-04 | GAPS | No cumple | Cumple parcialmente | Se acredita la existencia del ID de inventario. |
| DOC-04 | Asignado | No cumple | Cumple parcialmente | Se acredita la existencia del ID de inventario. |
| IMP-01 | GAPS | No evaluable | Cumple parcialmente | Hay impactos del modelador en métricas de GAP. |
| IMP-01 | Asignado | No evaluable | Cumple | Hay pruebas de impacto en el Asignado del modelador y del área usuaria. |
| IMP-02 | GAPS | No evaluable | Cumple parcialmente | Hay comunicación de hallazgos implementador–modelador. |
| IMP-03 | GAPS | No evaluable | Cumple parcialmente | Hay socialización de impactos a stakeholders. |
| IMP-04 | GAPS | No evaluable | Cumple parcialmente | Hay conformidad sobre el modelo, no sobre la implementación. |
| IMP-02 | Asignado | No evaluable | Cumple parcialmente | Hay comunicación de hallazgos implementador–modelador. |
| IMP-03 | Asignado | No evaluable | Cumple parcialmente | Hay socialización de impactos a stakeholders. |
| IMP-04 | Asignado | No evaluable | Cumple parcialmente | Hay conformidad sobre el modelo, no sobre la implementación. |
| GOB-02 | GAPS | No evaluable | Cumple | Se entregó la validación metodológica con nota Satisfactorio. |
| GOB-02 | Asignado | No evaluable | Cumple | Se entregó la validación metodológica con nota Satisfactorio. |

## 8. Hallazgos y recomendaciones priorizados

| ID | Prioridad | Módulo | Hallazgo | Criterios | Recomendación |
|---|---|---|---|---|---|
| H-01 | Alta | Ambos | En GAPS no cumple ninguna de las 19 actividades KILLER y en Asignado sólo cumple IMP-01. Faltan bitácora completa con aprobación, ID de inventario en la documentación de implementación, definición del universo, rutas, evidencia visual de directorios, accesos y backups (SOX), monitoreo de calidad de datos, y pruebas de inicio de la implementación productiva con conformidades del PO y del negocio. Por la regla de §0 del estándar, la validación no puede concluir favorablemente. | DOC-03 a DOC-12, CDD-01 a CDD-03, IMP-01 a IMP-04, IMP-08, IMP-09 | Preparar un manual de implementación (no operativo) que cubra DOC-03 a DOC-12 con evidencia SOX, y entregar la evidencia de pruebas de inicio y conformidades. |
| H-02 | Alta | Ambos | GAPS ya se usa en producción: la corrida oficial de septiembre 2026 se cargó a la Macro ALM antes y durante esta validación (GOB-03). Asignado muestra indicios de uso. El prerrequisito de validación metodológica (GOB-02) quedó acreditado con la nota SATISFACTORIO de setiembre 2025. | GOB-03 | Regularizar con Gestión de Riesgo de Modelo el uso previo a la validación de implementación. |
| H-03 | Alta | GAPS | Regla no documentada en el bucket AX7. En la banda mensual 1 de los DPF con curva conductual, el R asigna el bucket AX7 según el día del mes de la fecha de vencimiento (R l.372-376) y no según el plazo de la banda (30 días). Esto reasigna ≈S/ 1.400 MM y ≈US$ 10,8 MM de desgaste del primer mes entre los buckets 1-7d, 8-15d, 16d-1M y 2M. La réplica independiente difiere hasta 210 % en esos buckets; al aplicar la regla del código, la réplica coincide al 100 %. | DOC-06, CDD-06 | Que la metodología defina la asignación intra-mes del desgaste; documentar o corregir la regla y cuantificar su impacto en el Anexo 7. |
| H-04 | Alta | Ambos | No hay monitoreo de calidad de datos de primera línea. En GAPS sólo existe un cuadre de monto total sin umbral ni registro. En Asignado los controles son declarativos y no hay evidencia de su ejecución. | CDD-01 a CDD-03 | Implementar la solución táctica de calidad de datos (duplicados, nulos, variación mensual, semáforo) con plazo de remediación hacia el dashboard oficial. |
| H-05 | Alta | Asignado | El SP consume y escribe en esquemas sandbox (sdbx_*) y el manual declara que se ejecuta en el sandbox, contra la norma 4110.781.01.05. No hay plan de regularización. | IMP-05 | Migrar el proceso y sus insumos a un ambiente productivo o formalizar un plan de regularización con fechas. |
| H-06 | Alta | Asignado | No hay segregación de funciones: las mismas dos personas son Implementador/Modificador y Usuario, y no existe conformidad de un tercero. | GOB-01 | Segregar roles y obtener la conformidad de un rol independiente. |
| H-07 | Alta | Asignado | La TT asignada no es verificable contra el supuesto conductual. El output no expone el plazo conductual (DURATION = plazo contractual) y la muestra de TT no cubre los plazos usados. La tabla modelo_conductual sí reproduce al 100 % la curva entregada por RdM; su no monotonicidad (73 tramos, 271–1.110 días) proviene de los nodos RMST del modelo y corresponde a la validación metodológica, no a la implementación. | DOC-02, DOC-06 | Exponer el plazo conductual en FIN_CUBO_RENTA_PAS y entregar las TT completas. Trasladar a Riesgo de Modelo la consulta sobre la no monotonicidad del modelo. |
| H-08 | Baja | Ambos | Subsanado en lo principal: RdM BCP remitió las curvas (correos de junio a agosto 2025) y las curvas de GAPS y la tabla del Asignado coinciden con lo remitido. Queda pendiente que los manuales citen la remisión y la versión (el de Asignado la atribuye a 'Riesgo de Tesorería'), que el nodo 570 de GAPS se cierre en el mes 19 sin sustento (sin exposición actual) y que el 'Reporte Final' se entregue sin protección. | DOC-02 | Citar en los manuales la remisión del 13/08/2025 y la versión de la curva; documentar el nodo 570. |
| H-09 | Media | GAPS | Hay pasos manuales y errores silenciados. El ejecutor borra filas manualmente en la hoja Data; el VBA usa 'On Error Resume Next' y referencia la hoja inexistente 'Prepago_Creditos'; el script R se ejecuta manualmente en RStudio y depende de rstudioapi. | DOC-06, DOC-14 | Corregir el manejo de errores, eliminar el borrado manual y documentar el procedimiento. |
| H-10 | Media | Asignado | Problemas de reproducibilidad del SP. La fecha de proceso se deriva de SYSDATE y no del parámetro de periodo. La prima se lee de input_pre_duration para periodos > 202008. Faltan 9 funciones que determinan TT_PASIVA_GEB e ING_FIN_TOTAL. | DOC-06 | Parametrizar la fecha, revisar la línea 63 y entregar y documentar las funciones. |
| H-11 | Media | Ambos | Información insuficiente para cumplir los umbrales de CDD-06 y CDD-13 (3 periodos). En GAPS hay un solo periodo y la fuente original no fue provista. En Asignado sólo hay muestras de 99 registros. | CDD-06, CDD-08, CDD-13 | Entregar 3 cortes completos de inputs y outputs. |
| H-12 | Media | GAPS | No se documentan versiones de R ni de las librerías; se cargan librerías no usadas (TTR, RODBC, dplyr). | Observación fuera del checklist (reproducibilidad) | Documentar versiones (sessionInfo) y depurar librerías. |
| H-13 | Baja | Ambos | La documentación no coincide con la ejecución real. La ejecución de GAPS fue el 02/10/2026, pero el manual indica el último día calendario. El nombre del procedimiento Asignado difiere del documentado. Hay un parámetro (Fecha_Cierre) que no se usa. | Observación fuera del checklist | Alinear documentación y código. |
| H-14 | — | General | Riesgo de información fuera del estándar: el repositorio de evidencias era público y contenía datos por operación. El usuario indicó que pasará a privado. | — | Verificar el cambio a privado y revisar si hubo accesos. |
| H-15 | Media | Asignado | La tabla modelo_conductual sólo tiene la curva RETAIL y el SP la une sólo por plazo (l.420), sin segmento. El modelo define curvas distintas para TESORERIA IFIS (≈ plazo contractual) y TESORERIA NO IFIS, y la muestra de output incluye un DPF de Tesorería ('MI RENTA - TESORERIA', FLAG_BASE_RENTA = 1). No está documentado si los depósitos de Tesorería deben recibir plazo conductual en el Asignado; el cuaderno de impactos de la validación metodológica los excluye ('Tesorería no puede cobrarse a sí mismo'). [Por confirmar] | DOC-05, DOC-06 | Definir y documentar el tratamiento de los DPF de Tesorería en el Asignado (exclusión o curva por segmento) y ajustar el SP si corresponde. |

## 9. Información a solicitar

Detalle en `06_Requerimientos_Informacion.xlsx`.

| ID | Información requerida | Módulo | Criterios VIRF / uso | Responsable sugerido | Prioridad |
|---|---|---|---|---|---|
| RQ-01 | Confirmación del estado de uso de cada módulo y tratamiento del uso previo a la validación (GOB-03). La validación metodológica ya fue entregada. | Ambos | GOB-03 | Gestión de Riesgo de Modelo | Alta |
| RQ-02 | Confirmar si MOD-MIB-0001755 es el único ID aplicable o si GAPS y Asignado tienen ID propio, e incorporarlo a los manuales de implementación | Ambos | DOC-04, DOC-01 | Gestión de Riesgo de Modelo | Alta |
| RQ-03 | Manual de implementación o RUS con bitácora de cambios con aprobación, rutas, arquitectura de directorios y capturas de accesos y backups | Ambos | DOC-03, DOC-07 a DOC-12, IMP-06 a IMP-09 | Riesgos de Tesorería (GAPS); M. Bendezú / P. López (Asignado) | Alta |
| RQ-04 | Pruebas de inicio con la herramienta productiva, comunicación de sus resultados al negocio, plan de acción y conformidades del PO y del negocio sobre la implementación (los impactos del modelo ya se entregaron) | Ambos | IMP-01 a IMP-04 | Riesgos de Tesorería / Control Financiero | Alta |
| RQ-05 | Evidencia del monitoreo de calidad de datos (mes actual vs anterior, semáforo), su comunicación y el informe de seguimiento | Ambos | CDD-01 a CDD-03 | Primera línea / Gobierno de Datos | Alta |
| RQ-06 | Versión sin protección de 'Reporte Final - Plazos Conductuales.xlsx' (remitido el 13/08/2025) y sustento del cierre del nodo 570 de TESORERIA NO IFIS en el mes 19 | Ambos | DOC-02 | COE Riesgo de Mercado / Riesgos de Tesorería | Media |
| RQ-07 | Sustento metodológico de la regla AX7 de la banda 1 (asignación por día de vencimiento) | GAPS | DOC-06, CDD-06 | Riesgos de Tesorería | Alta |
| RQ-08 | Grabación MP4 completa (≈100 MB) por un canal interno | GAPS | Evidencia del proceso | W. F. Gastelu | Media |
| RQ-09 | Base DPF DD.MM.xlsx original y código del SP o job que la genera, para 3 cortes (jul-sep 2026), con sus corridas completas (96 particiones) | GAPS | DOC-05, CDD-06, CDD-13, IMP-05 | W. F. Gastelu / dueño del SP | Alta |
| RQ-10 | Macro ALM del mes (hoja DPF y fórmulas hacia los GAPS) | GAPS | DOC-07 (uso del output) | Riesgos de Tesorería | Media |
| RQ-11 | Versiones de R y librerías en producción (sessionInfo) | GAPS | H-12 (observación fuera del checklist) | W. F. Gastelu | Media |
| RQ-12 | Código de las funciones f_tt_pasiva_geb, f_pasivo_if_0_nuevo, f_familia_producto_2, f_grupo_producto, f_tipo_documento, f_asigna_flujo_pasivo, f_familia_producto_pas, f_asigna_rango_monto_pasivo y f_asigna_rango_plazo_pasivo, y origen de fin_prima_liquidez_final | Asignado | DOC-06, CDD-06 | M. Bendezú / P. López | Alta |
| RQ-13 | Tablas completas para 3 periodos: f_fin_saldos_pasivos_d, modelo_conductual (ACTUAL y NUEVA), fin_tt_pasivo_dist_total, fin_prima_liquidez(_final) y FIN_CUBO_RENTA_PAS | Asignado | CDD-04 a CDD-13, réplica | M. Bendezú / P. López | Alta |
| RQ-14 | Log de ejecución real del SP (ambiente, usuario, fecha) y reporte de validación de resultados | Asignado | IMP-05, DOC-06 | M. Bendezú / P. López | Media |
| RQ-15 | Pronunciamiento de Riesgo de Modelo sobre la no monotonicidad de los nodos RMST (300, 390, 750 y 1.110 días), que se traslada a la tabla modelo_conductual | Asignado | DOC-02, DOC-06 | Gestión de Riesgo de Modelo / COE Riesgo de Mercado | Media |
| RQ-16 | Justificación de los GAST_FIN_TOTAL negativos y plan de migración fuera del sandbox | Asignado | CDD-07, IMP-05 | Control Financiero | Media |
| RQ-17 | Salidas del motor ARM para 2 periodos consecutivos | Ambos | CDD-14 | Gobierno de Datos | Media |
| RQ-18 | Definición del tratamiento de los DPF de Tesorería (IFIS y no IFIS) en el Asignado y evidencia de su aplicación en el SP | Asignado | DOC-05, DOC-06 (H-15) | Control Financiero / COE Riesgo de Mercado | Media |
| RQ-19 | Evidencia del seguimiento de la metodología comprometido para el 31/08/2026 y de la atención de la oportunidad de mejora 3 (base del impacto en el Asignado) | Ambos | CDD-03 | Squad de Seguimiento / MiBanco | Media |

## 10. Instrucciones de reproducción

Ver `03_Scripts_Replica_README.md`. Los scripts reciben la ruta del clon local del repositorio, procesan los datos localmente y escriben en `replica_resultados/`.
