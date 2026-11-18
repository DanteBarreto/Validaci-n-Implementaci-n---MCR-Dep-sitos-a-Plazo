# Resumen de la validación metodológica
## Modelo Conductual MCR – Depósitos a Plazo (DPF) MiBanco Perú

| Campo | Detalle |
|---|---|
| Fecha del resumen | 18/11/2026 |
| Fuente | Carpeta `Validación metodológica` del repositorio de evidencias (commit `ee2b261`), con 43 archivos |
| Uso en esta validación | Sólo como referencia, para verificar si subsana observaciones de la validación de implementación (ver informe, sección 7) |
| Evidencia reproducible | `scripts/contraste_validacion_metodologica.py` → `replica_resultados/contraste_validacion_metodologica.xlsx` |

---

## 1. Identificación

| Campo | Detalle | Evidencia |
|---|---|---|
| Validador | CoE Model Risk Management, Gerencia de Administración de Riesgo de Modelo (BCP) | `Informe MCR DPF MIBPE 2025.pdf` p. 1 |
| Tier | Tier I | `Resultados Finales MCR DPF MIBPE 2025 v2 - Comite.pptx` lám. 1 |
| Fecha | Setiembre 2025 | Mismo archivo |
| ID de inventario | MOD-MIB-0001755 | Carátula de los manuales metodológico y operativo |
| Modelador | B. Calsi, COE de Riesgo de Mercado Estructural, Negociación y Liquidez (BCP). Revisión y aprobación del manual: D. Cardoso (20/05/2025) | `MiBanco DPF - Documento Metodológico.docx` |
| Nota | **SATISFACTORIO** ("Satisfactorio/Aceptable: se recomienda su uso") | `Informe … .pdf` p. 2 |

## 2. Modelo validado

- **Objetivo:** estimar el plazo conductual de los DPF de MiBanco para asignar tasas de transferencia (Asignado) y para los GAP de reprecio y de liquidez.
- **Población:** DPF vigentes entre marzo 2015 y marzo 2025. Al corte del ejercicio, el saldo activo es de S/ 9.026 MM: Retail S/ 4.936 MM, Tesorería IFIS S/ 4.024 MM y Tesorería no IFIS S/ 67 MM.
- **Metodología:** estimador de Kaplan-Meier con plazo conductual medido como RMST, ponderado por capital, por segmento (Retail, Tesorería IFIS y Tesorería no IFIS) y por plazo agrupado. Para los plazos y monedas no modelados se usa el plazo contractual.
- **Productos entregados al implementador:**
  - Para GAPS, curvas de desgaste mensual por plazo agrupado. El tratamiento de plazos intermedios es la curva superior directa, y para más de 1.110 días se usa el promedio por maduración.
  - Para el Asignado, plazos conductuales diarios de 1 a 9.000 días, con interpolación lineal y extrapolación para más de 1.110 días.
  - Fuente: correo "RE: Resultados - Depósitos a Plazo MB" del 07/08/2025, ratificado el 13/08/2025.

## 3. Resultados de la validación

**Fortalezas principales:**
- Criterio estadístico para elegir la ventana de modelamiento.
- Replicabilidad de la métrica y scripts explicados.
- Entendimiento de las casuísticas de calidad de datos.
- Comunicación entre el área usuaria, modelamiento y validación.

**Controles exitosos:**
- Documentación que permite replicar el proceso.
- Scripts comentados y automatizados.
- Réplica exitosa de los resultados.
- Cálculo de impactos en el Asignado y el GAP.

**Réplica del validador:**

| Segmento | Diferencia en RMST (RdM frente al validador) |
|---|---|
| Retail | Entre 0 y 2 días (por ejemplo, 360 → 275 frente a 273) |
| Tesorería no IFIS | Entre 1 y 2 días |

La réplica del impacto en el Asignado (cálculo proxy, 202503) difiere en 1,01 %.

**Benchmark (modelo de Cox):**

| Modelo | RMSE ponderado |
|---|---|
| Cox (benchmark) | 71,25 |
| Kaplan-Meier (modelo propuesto) | 64,06 |

La metodología propuesta ajusta mejor.

**Observaciones del informe final:**

| Ámbito | Observación | Riesgo | Estado |
|---|---|---|---|
| Gobierno | No se cuenta con el seguimiento de la metodología implementada | Nulo | Abierta (Squad de Seguimiento, 31/08/2026). No hay evidencia de su atención. |
| Calidad de datos | Falta respaldo de la información de modelamiento y evidencia de accesos limitados | Bajo | Subsanada |
| Implementación | Faltan correos con resultados al implementador, respaldo de manuales y scripts, y accesos al drive | Potencial | Subsanada |
| Gobierno | Falta comunicación de supuestos al área usuaria y visto bueno del PO y del Chapter Leader | Potencial | Subsanada |
| Usos | Faltan los impactos oficiales en el Asignado y el GAP, y la comunicación a stakeholders | Moderado | Subsanada |
| Documentación | Falta criterio para plazos y monedas no modelados, y manual operativo de implementación en el GAP | Bajo / Moderado | Subsanada |

Fuente: `Resultados Finales MCR DPF MIBPE 2025 v2.pptx`, láminas 17 y 18.

**Oportunidades de mejora:**
1. Agregar a la data un flag de renovación y el motivo de retiro (responsable: MiBanco).
2. Explorar el modelo de Cox con covariables (responsable: Squad ALM & Liquidez).
3. Alinear la base del impacto en el Asignado con la práctica corporativa, porque hoy considera todo el stock activo (responsable: MiBanco).

## 4. Hallazgos del validador de implementación sobre esta documentación

1. **Curvas GAP.** Las curvas de la macro coinciden con las de Riesgos de Mercado, redondeadas a 4 decimales (diferencia máxima 0,00005 en ambas monedas).
   - Los nodos 1.500 y 570 de la macro corresponden a las filas `>1110` y `>540` de RdM.
   - La macro cierra el nodo 570 en el mes 19, mientras que RdM mantiene una proporción estable de 1,65 % hasta el mes 50.
   - Al 30/09/2026 no hay operaciones Tesorería no IFIS con plazo mayor a 540 días, así que esta diferencia no tiene exposición.
   - Evidencia: C1 y C4.
2. **Tabla conductual del Asignado.** `modelo_conductual` coincide al 100 % con la curva propuesta RETAIL (9.000 de 9.000 plazos, PEN y USD).
   - Con las curvas de Tesorería IFIS y no IFIS sólo coincide en 0,2 % de los plazos.
   - El SP une la tabla sólo por plazo (l.420), así que todo DPF del cubo recibe la curva RETAIL.
   - El cuaderno de impactos del validador metodológico excluye Tesorería ("no puede cobrarse a sí mismo"), pero la muestra de output incluye un producto "MI RENTA - TESORERIA". [Por confirmar] Ver H-15.
   - Evidencia: C2.
3. **No monotonicidad.** Los nodos RMST del modelo decrecen en 300, 390, 750 y 1.110 días (por ejemplo, 270 → 227,6 y 300 → 184,8).
   - Por eso la tabla tiene 73 tramos decrecientes.
   - Es una característica del modelo, no un error de implementación. La validación metodológica no se pronuncia sobre ella.
   - Evidencia: C3.
4. **Archivo protegido.** `Reporte Final - Plazos Conductuales.xlsx` está protegido (cifrado) y no pudo leerse; el contraste de curvas se hizo con `Ejemplo DPF_MiBanco.xlsx`. [Por confirmar] que ambos archivos coincidan.
5. **Alcance de la validación metodológica.** No reemplaza la validación de implementación. No cubre la bitácora de cambios, los accesos y respaldos SOX, el monitoreo de calidad de datos productivo, las pruebas de inicio con la herramienta productiva ni la conformidad del negocio sobre la implementación.

## 5. Efecto en la validación de implementación

| Elemento | Antes | Después |
|---|---|---|
| GOB-02, prerrequisito (ambos módulos) | No evaluable | **Cumple** |
| DOC-02 GAPS | Cumple parcialmente | **Cumple** |
| DOC-02 Asignado | Cumple parcialmente | Cumple parcialmente (se acredita la remisión; queda H-15) |
| DOC-01 GAPS | No evaluable | Cumple parcialmente |
| DOC-04 (ambos) | No cumple | Cumple parcialmente (sigue siendo NO CUMPLE en VIRF por ser KILLER) |
| IMP-01 Asignado | No evaluable | **Cumple** |
| IMP-01 GAPS | No evaluable | Cumple parcialmente |
| IMP-02 a IMP-04 (ambos) | No evaluable | Cumple parcialmente |
| H-02 | GOB-02 y GOB-03 | Sólo GOB-03 |
| H-07 | — | Se reformula: la no monotonicidad es metodológica |
| H-08 | Media | Baja (subsanado en lo principal) |
| Nuevo | — | H-15 (Tesorería en el Asignado) y RQ-18, RQ-19 |
| **Conclusión** | No favorable en ambos módulos | **No favorable en ambos módulos.** Las brechas KILLER de documentación de implementación, SOX y calidad de datos no se subsanan, y GOB-03 sigue incumplido. |
