# Scripts de réplica – Instrucciones

Los scripts están en `scripts/`. Son independientes del código del modelo, están escritos en Python y se basan en los manuales. Todo el procesamiento es local.

## Requisitos
- Python ≥ 3.10 con `pandas`, `numpy`, `openpyxl` (`pip install pandas numpy openpyxl`).
- Un clon local del repositorio de evidencias (sin modificar).

## Ejecución
```bash
REPO=/ruta/al/clon/Validaci-n-Implementaci-n---MCR-Dep-sitos-a-Plazo
OUT=./replica_resultados
python3 scripts/replica_gaps.py       "$REPO" "$OUT"   # ≈30 s; réplica GAPS completa
python3 scripts/conciliacion_gaps.py  "$REPO" "$OUT"   # conciliación vs Output_R01 y Resultados 94-96
python3 scripts/replica_asignado.py   "$REPO" "$OUT"   # réplica parcial Asignado (muestras)
python3 scripts/contraste_validacion_metodologica.py "$REPO" "$OUT"   # contraste con la carpeta Validación metodológica
```

## Salidas
| Archivo | Contenido |
|---|---|
| `replica_gaps_detalle.csv` | Flujos replicados por operación y banda (486.482 filas) |
| `replica_gaps_R01.csv` | Agregado replicado con la estructura de Output_R01 |
| `replica_gaps_curvas_comparacion.csv` | Diferencia máxima por fila entre la matriz CURVAS replicada y la oficial |
| `replica_gaps_clasificacion.csv` | Porcentaje de coincidencia de MARCAORIGEN_C, MARCA_CONTA, FLAG y CURVA |
| `replica_gaps_detalle_sensibilidad_AX7.csv` | Detalle replicado aplicando la regla AX7 del código (prueba de causa raíz) |
| `conciliacion_gaps.xlsx` | Diferencias absolutas y relativas por moneda, GER, AX7, REPRECIO, CE, CAT_PLANCON, clave R01 y detalle 94-96 |
| `contraste_validacion_metodologica.xlsx` | C1 curvas GAP macro vs RdM, C2 modelo_conductual vs curva propuesta, C3 nodos RMST no monótonos, C4 exposición a nodos extrapolados |
| `replica_asignado.xlsx` | C1 traspaso de atributos, C2 ingreso financiero, C3 prima implícita, C4 factibilidad de TT, C5 calidad de modelo_conductual |

## Supuestos
Los supuestos están documentados en el encabezado y los comentarios de cada script (SUPUESTO-01 a 06) y en `04_Reporte_Conciliacion.md` §1.5 y §2.6.
