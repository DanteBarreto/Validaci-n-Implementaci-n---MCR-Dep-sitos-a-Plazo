# Validación de implementación – MCR Depósitos a Plazo (GAPS y Asignado)

Índice de los resultados de la validación. Última actualización: 18/11/2026 (versión 3, que incorpora el contraste con la validación metodológica, y presentación de resultados).

## Estructura

| Carpeta | Contenido |
|---|---|
| `01_Informe/` | Informe de validación de implementación (versión Word `.docx` y Markdown `.md`). Documento principal con la conclusión. La sección 7 contrasta los resultados con la validación metodológica. |
| `02_Matrices_y_Anexos/` | `02_Matriz_Cumplimiento_Checklist.xlsx` (cumplimiento de las 40 actividades del estándar VIRF; la pestaña `Cambios_Val_Metodologica` lista los resultados modificados), `06_Requerimientos_Informacion.xlsx` (información solicitada al área) y `07_Mapa_Inputs_Linaje.xlsx` (linaje de inputs). |
| `03_Reportes/` | `04_Reporte_Conciliacion.md` (conciliación de la réplica contra los outputs oficiales), `05_Resumen_Grabacion_GAPS.md` (resumen de la sesión grabada de GAPS) y `08_Resumen_Validacion_Metodologica` (`.md` y `.docx`, resumen de la validación metodológica y su efecto en esta validación). |
| `04_Fase1/` | Entregables de la Fase 1: inventario y entendimiento del proceso (`.md`) y Excel de inventarios y mapa de inputs. |
| `05_Diagramas/` | Flujos de GAPS, Asignado y linaje de inputs en `.png` (para ver), `.svg` (vectorial) y `.mmd` (fuente Mermaid). |
| `06_Scripts/` | Scripts Python de réplica independiente (`replica_gaps.py`, `conciliacion_gaps.py`, `replica_asignado.py`), el script de contraste con la validación metodológica (`contraste_validacion_metodologica.py`) y el instructivo `03_Scripts_Replica_README.md`. |
| `07_Resultados_Replica/` | Salidas de los scripts: conciliación GAPS (`conciliacion_gaps.xlsx`), réplica Asignado (`replica_asignado.xlsx`), contraste con la validación metodológica (`contraste_validacion_metodologica.xlsx`) y CSV de la réplica GAPS. En el repositorio, los dos CSV de detalle (unos 65 MB cada uno) se suben comprimidos en `.zip` (unos 10 MB cada uno) por el límite de tamaño de GitHub. |
| `08_Presentacion/` | `09_Presentacion_Resultados_Validacion_MCR_DPF.pptx`: presentación de resultados en la plantilla de Resultados Preliminares (14 láminas): antecedentes y alcance, flujos GAPS y Asignado, calificación (Deficiente / No favorable), hallazgos y controles, observaciones por ámbito, oportunidades de mejora y requerimientos. |

## Orden de lectura sugerido
1. `08_Presentacion/09_Presentacion_Resultados_Validacion_MCR_DPF.pptx` (visión ejecutiva)
2. `01_Informe/01_Informe_Validacion_Implementacion_MCR_DPF.docx`
3. `02_Matrices_y_Anexos/02_Matriz_Cumplimiento_Checklist.xlsx`
4. `03_Reportes/08_Resumen_Validacion_Metodologica.docx`
5. `03_Reportes/04_Reporte_Conciliacion.md`
6. El resto como soporte.

## Reejecutar la réplica
Los scripts necesitan un clon local del repositorio de evidencias (actualmente privado), que incluya la carpeta `Validación metodológica`:

```
git clone https://github.com/DanteBarreto/Validaci-n-Implementaci-n---MCR-Dep-sitos-a-Plazo
```

Después hay que ajustar la variable `REPO` del instructivo `06_Scripts/03_Scripts_Replica_README.md` con la ruta del clon, por ejemplo `REPO="D:/Validación implementación MCR DPF/repo"`. Requisitos: Python 3.10 o superior con `pandas`, `numpy` y `openpyxl`.
