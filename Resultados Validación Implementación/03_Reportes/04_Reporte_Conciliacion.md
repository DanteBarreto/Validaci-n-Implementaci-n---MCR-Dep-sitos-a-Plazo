# Reporte de conciliación – Réplica vs output oficial

**Tolerancia aplicada:** 0,1 % de diferencia relativa por bucket (aprobada por el usuario). Se considera dentro de tolerancia un bucket con diferencia absoluta < 0,01. Como referencia también se aplican los umbrales VIRF de CDD-06 / CDD-13 (coincidencia ≥ 99 %).
**Scripts:** `scripts/replica_gaps.py`, `scripts/conciliacion_gaps.py`, `scripts/replica_asignado.py`. **Resultados detallados:** `replica_resultados/`.

## 1. Módulo GAPS (corte 30/09/2026) – réplica completa

| Componente | Comparación | Resultado |
|---|---|---|
| Clasificación MARCAORIGEN_C, MARCA_CONTA, FLAG, CURVA | 95.874 operaciones | 100 % de coincidencia en las 4 variables |
| Matriz CURVAS (2 monedas × 2 curvas × 241 plazos) | CURVAS.xlsx oficial, celda a celda | 964 de 964 filas idénticas (diferencia máx. 0) |
| Universo y monto total | Output_R01 | 95.874 operaciones; S/ 8.774.087.917,41 en ambos |
| Detalle por operación y banda (particiones 94-96) | Resultados_*.csv | 14.663 de 14.663 filas coincidentes; capital dif. máx. S/ 0,03; interés dif. máx. S/ 0,04 (redondeo); bucket AX7 coincidente en 89,9 % de las filas |
| Agregado por clave completa de Output_R01 | 401 claves oficiales | 85 claves fuera de tolerancia en monto, todas explicadas por la regla AX7 (ver §1.3) |

### 1.1 Totales por moneda
| MONEDA | Monto oficial | Monto réplica | Dif. abs. | Dif. rel. | Dif. interés vto. | Dentro de tolerancia |
|---|---|---|---|---|---|---|
| 1 | 8,693,473,809.58 | 8,693,473,809.58 | 0.00 | 0.0000 % | -1.90 | Sí |
| 2 | 80,614,107.83 | 80,614,107.83 | 0.00 | 0.0000 % | -0.11 | Sí |

### 1.2 Por banda GAP_GER (liquidez de gestión)
| MONEDA | GAP_GER | Monto oficial | Monto réplica | Dif. abs. | Dif. rel. | Dif. interés vto. | Dentro de tolerancia |
|---|---|---|---|---|---|---|---|
| 1 | 01_1M | 2,111,018,559.91 | 2,111,018,558.32 | -1.59 | -0.0000 % | -4.78 | Sí |
| 1 | 02_2M | 1,074,291,701.76 | 1,074,291,705.56 | 3.80 | 0.0000 % | -0.10 | Sí |
| 1 | 03_3M | 1,046,933,688.06 | 1,046,933,674.89 | -13.17 | -0.0000 % | 1.88 | Sí |
| 1 | 04_4M | 1,000,766,418.38 | 1,000,766,433.58 | 15.20 | 0.0000 % | -0.69 | Sí |
| 1 | 05_5M | 733,901,374.57 | 733,901,371.77 | -2.80 | -0.0000 % | -0.32 | Sí |
| 1 | 06_6M | 584,995,698.20 | 584,995,698.84 | 0.64 | 0.0000 % | 0.83 | Sí |
| 1 | 07_7M | 281,203,899.24 | 281,203,899.84 | 0.60 | 0.0000 % | 0.49 | Sí |
| 1 | 08_8M | 336,492,381.62 | 336,492,382.56 | 0.94 | 0.0000 % | 0.72 | Sí |
| 1 | 09_9M | 249,419,947.37 | 249,419,946.63 | -0.74 | -0.0000 % | 0.09 | Sí |
| 1 | 10_10M | 321,560,026.13 | 321,560,026.21 | 0.08 | 0.0000 % | 0.36 | Sí |
| 1 | 11_11M | 346,984,792.25 | 346,984,791.71 | -0.54 | -0.0000 % | -0.04 | Sí |
| 1 | 12_12M | 279,940,949.02 | 279,940,947.53 | -1.49 | -0.0000 % | -0.02 | Sí |
| 1 | 13_2A | 304,125,518.46 | 304,125,517.62 | -0.84 | -0.0000 % | -0.14 | Sí |
| 1 | 14_3A | 14,036,385.46 | 14,036,385.53 | 0.07 | 0.0000 % | -0.01 | Sí |
| 1 | 15_4A | 4,365,655.98 | 4,365,655.93 | -0.05 | -0.0000 % | -0.04 | Sí |
| 1 | 16_5A | 1,419,851.19 | 1,419,851.22 | 0.03 | 0.0000 % | -0.01 | Sí |
| 1 | 17_6A | 1,188,100.79 | 1,188,100.82 | 0.03 | 0.0000 % | -0.00 | Sí |
| 1 | 18_7A | 736,429.49 | 736,429.37 | -0.12 | -0.0000 % | -0.11 | Sí |
| 1 | 19_8A | 46,387.21 | 46,387.28 | 0.07 | 0.0001 % | 0.02 | Sí |
| 1 | 20_9A | 11,965.18 | 11,965.16 | -0.02 | -0.0001 % | -0.02 | Sí |
| 1 | 21_10A | 5,820.55 | 5,820.54 | -0.01 | -0.0001 % | 0.00 | Sí |
| 1 | 22_11A | 10,315.33 | 10,315.31 | -0.02 | -0.0002 % | -0.01 | Sí |
| 1 | 23_12A | 7,565.28 | 7,565.28 | 0.00 | 0.0000 % | 0.03 | Sí |
| 1 | 24_13A | 1,929.23 | 1,929.18 | -0.05 | -0.0027 % | -0.01 | Sí |
| 1 | 25_14A | 1,443.01 | 1,443.03 | 0.02 | 0.0011 % | 0.00 | Sí |
| 1 | 26_15A | 3,993.56 | 3,993.54 | -0.02 | -0.0004 % | 0.00 | Sí |
| 1 | 27_16A | 514.51 | 514.49 | -0.02 | -0.0040 % | 0.00 | Sí |
| 1 | 28_17A | 2,497.84 | 2,497.84 | 0.00 | 0.0000 % | -0.01 | Sí |
| 2 | 01_1M | 20,772,976.88 | 20,772,976.69 | -0.19 | -0.0000 % | 0.07 | Sí |
| 2 | 02_2M | 17,731,002.21 | 17,731,002.31 | 0.10 | 0.0000 % | -0.02 | Sí |
| 2 | 03_3M | 13,598,680.08 | 13,598,680.13 | 0.05 | 0.0000 % | 0.02 | Sí |
| 2 | 04_4M | 8,855,983.09 | 8,855,983.17 | 0.08 | 0.0000 % | -0.06 | Sí |
| 2 | 05_5M | 9,101,705.84 | 9,101,705.78 | -0.06 | -0.0000 % | 0.03 | Sí |
| 2 | 06_6M | 7,635,033.24 | 7,635,033.28 | 0.04 | 0.0000 % | -0.05 | Sí |
| 2 | 07_7M | 353,484.06 | 353,484.10 | 0.04 | 0.0000 % | -0.03 | Sí |
| 2 | 08_8M | 383,673.38 | 383,673.35 | -0.03 | -0.0000 % | -0.01 | Sí |
| 2 | 09_9M | 762,627.84 | 762,627.79 | -0.05 | -0.0000 % | 0.01 | Sí |
| 2 | 10_10M | 381,276.52 | 381,276.45 | -0.07 | -0.0000 % | -0.04 | Sí |
| 2 | 11_11M | 401,503.04 | 401,503.04 | -0.00 | -0.0000 % | -0.01 | Sí |
| 2 | 12_12M | 482,900.70 | 482,900.80 | 0.10 | 0.0000 % | -0.01 | Sí |
| 2 | 13_2A | 90,204.86 | 90,204.88 | 0.02 | 0.0000 % | 0.01 | Sí |
| 2 | 14_3A | 59,733.47 | 59,733.43 | -0.04 | -0.0001 % | -0.02 | Sí |
| 2 | 15_4A | 1,506.25 | 1,506.27 | 0.02 | 0.0011 % | -0.00 | Sí |
| 2 | 16_5A | 310.25 | 310.22 | -0.03 | -0.0081 % | 0.00 | Sí |
| 2 | 17_6A | 257.25 | 257.24 | -0.01 | -0.0038 % | 0.00 | Sí |
| 2 | 18_7A | 213.28 | 213.30 | 0.02 | 0.0117 % | 0.00 | Sí |
| 2 | 19_8A | 220.70 | 220.70 | -0.00 | -0.0012 % | -0.00 | Sí |
| 2 | 20_9A | 565.58 | 565.59 | 0.01 | 0.0026 % | -0.00 | Sí |
| 2 | 21_10A | 42.57 | 42.58 | 0.01 | 0.0217 % | 0.00 | Sí |
| 2 | 22_11A | 35.32 | 35.31 | -0.01 | -0.0370 % | 0.00 | Sí |
| 2 | 23_12A | 29.27 | 29.28 | 0.01 | 0.0229 % | 0.00 | Sí |
| 2 | 24_13A | 142.15 | 142.14 | -0.01 | -0.0084 % | -0.00 | Sí |

### 1.3 Por banda GAP_AX7: diferencia material
| MONEDA | GAP_AX7 | Monto oficial | Monto réplica | Dif. abs. | Dif. rel. | Dif. interés vto. | Dentro de tolerancia |
|---|---|---|---|---|---|---|---|
| 1 | 01_1-7d | 861,798,614.09 | 42,569,870.28 | -819,228,743.81 | -95.0603 % | -4,766,338.05 | **No** |
| 1 | 02_8-15d | 580,963,155.40 | 0.00 | -580,963,155.40 | -100.0000 % | -11,304,730.91 | **No** |
| 1 | 03_16d-1M | 665,590,495.30 | 2,068,448,688.04 | 1,402,858,192.74 | 210.7690 % | 16,071,064.18 | **No** |
| 1 | 04_2M | 1,076,957,996.88 | 1,074,291,705.56 | -2,666,291.32 | -0.2476 % | -0.10 | **No** |
| 1 | 05_3M | 1,046,933,688.06 | 1,046,933,674.89 | -13.17 | -0.0000 % | 1.88 | Sí |
| 1 | 06_4-6M | 2,319,663,491.15 | 2,319,663,504.19 | 13.04 | 0.0000 % | -0.17 | Sí |
| 1 | 07_7M-1A | 1,815,601,995.63 | 1,815,601,994.48 | -1.15 | -0.0000 % | 1.59 | Sí |
| 1 | 08_2A | 304,125,518.46 | 304,125,517.62 | -0.84 | -0.0000 % | -0.14 | Sí |
| 1 | 09_3A | 14,036,385.46 | 14,036,385.53 | 0.07 | 0.0000 % | -0.01 | Sí |
| 1 | 10_4A | 4,365,655.98 | 4,365,655.93 | -0.05 | -0.0000 % | -0.04 | Sí |
| 1 | 11_5A | 1,419,851.19 | 1,419,851.22 | 0.03 | 0.0000 % | -0.01 | Sí |
| 1 | 12_6-10A | 1,988,703.22 | 1,988,703.17 | -0.05 | -0.0000 % | -0.11 | Sí |
| 1 | 13_11-20A | 28,258.76 | 28,258.67 | -0.09 | -0.0003 % | -0.01 | Sí |
| 2 | 01_1-7d | 4,095,588.62 | 0.00 | -4,095,588.62 | -100.0000 % | -36,580.05 | **No** |
| 2 | 02_8-15d | 6,708,855.96 | 0.00 | -6,708,855.96 | -100.0000 % | -67,416.11 | **No** |
| 2 | 03_16d-1M | 9,938,441.87 | 20,772,976.69 | 10,834,534.82 | 109.0164 % | 103,996.23 | **No** |
| 2 | 04_2M | 17,761,092.64 | 17,731,002.31 | -30,090.33 | -0.1694 % | -0.02 | **No** |
| 2 | 05_3M | 13,598,680.08 | 13,598,680.13 | 0.05 | 0.0000 % | 0.02 | Sí |
| 2 | 06_4-6M | 25,592,722.17 | 25,592,722.23 | 0.06 | 0.0000 % | -0.08 | Sí |
| 2 | 07_7M-1A | 2,765,465.54 | 2,765,465.53 | -0.01 | -0.0000 % | -0.09 | Sí |
| 2 | 08_2A | 90,204.86 | 90,204.88 | 0.02 | 0.0000 % | 0.01 | Sí |
| 2 | 09_3A | 59,733.47 | 59,733.43 | -0.04 | -0.0001 % | -0.02 | Sí |
| 2 | 10_4A | 1,506.25 | 1,506.27 | 0.02 | 0.0011 % | -0.00 | Sí |
| 2 | 11_5A | 310.25 | 310.22 | -0.03 | -0.0081 % | 0.00 | Sí |
| 2 | 12_6-10A | 1,299.38 | 1,299.42 | 0.04 | 0.0028 % | -0.00 | Sí |
| 2 | 13_11-20A | 206.74 | 206.72 | -0.02 | -0.0089 % | -0.00 | Sí |

**Causa raíz.** El script R (l.372-376) trata distinto la **banda mensual 1** de los DPF con curva conductual: en lugar de usar el plazo de la banda (30 días), asigna el bucket AX7 con el **día del mes de la fecha de vencimiento**. Así, un DPF que vence el 04/01/2027 reporta el desgaste esperado de octubre 2026 en el bucket *1-7 días*, y uno que vence un día 31 lo reporta en *2M*. La regla no está en el manual. La réplica independiente, que asigna la banda 1 por 30 días según el manual §4 ("bandas en múltiplos de 30 días"), lleva todo ese monto a *16d-1M*. **Prueba de sensibilidad:** al aplicar la regla del código, la réplica coincide en las 397 claves (máx. dif. S/ 14,72 en monto y S/ 2,95 en interés; todo dentro de tolerancia). Se confirma que la causa es una única regla y que el resto de la implementación es consistente.

### 1.4 Por banda GAP_REPRECIO
| MONEDA | GAP_REPRECIO | Monto oficial | Monto réplica | Dif. abs. | Dif. rel. | Dif. interés vto. | Dentro de tolerancia |
|---|---|---|---|---|---|---|---|
| 1 | 01_1M | 2,111,018,559.91 | 2,111,018,558.32 | -1.59 | -0.0000 % | -4.78 | Sí |
| 1 | 02_2M | 1,074,291,701.76 | 1,074,291,705.56 | 3.80 | 0.0000 % | -0.10 | Sí |
| 1 | 03_3M | 1,046,933,688.06 | 1,046,933,674.89 | -13.17 | -0.0000 % | 1.88 | Sí |
| 1 | 04_4-6M | 2,319,663,491.15 | 2,319,663,504.19 | 13.04 | 0.0000 % | -0.17 | Sí |
| 1 | 05_7M-1A | 1,815,601,995.63 | 1,815,601,994.48 | -1.15 | -0.0000 % | 1.59 | Sí |
| 1 | 06_2A | 304,125,518.46 | 304,125,517.62 | -0.84 | -0.0000 % | -0.14 | Sí |
| 1 | 07_3A | 14,036,385.46 | 14,036,385.53 | 0.07 | 0.0000 % | -0.01 | Sí |
| 1 | 08_4A | 4,365,655.98 | 4,365,655.93 | -0.05 | -0.0000 % | -0.04 | Sí |
| 1 | 09_5A | 1,419,851.19 | 1,419,851.22 | 0.03 | 0.0000 % | -0.01 | Sí |
| 1 | 10_6-10A | 1,988,703.22 | 1,988,703.17 | -0.05 | -0.0000 % | -0.11 | Sí |
| 1 | 11_11-20A | 28,258.76 | 28,258.67 | -0.09 | -0.0003 % | -0.01 | Sí |
| 2 | 01_1M | 20,772,976.88 | 20,772,976.69 | -0.19 | -0.0000 % | 0.07 | Sí |
| 2 | 02_2M | 17,731,002.21 | 17,731,002.31 | 0.10 | 0.0000 % | -0.02 | Sí |
| 2 | 03_3M | 13,598,680.08 | 13,598,680.13 | 0.05 | 0.0000 % | 0.02 | Sí |
| 2 | 04_4-6M | 25,592,722.17 | 25,592,722.23 | 0.06 | 0.0000 % | -0.08 | Sí |
| 2 | 05_7M-1A | 2,765,465.54 | 2,765,465.53 | -0.01 | -0.0000 % | -0.09 | Sí |
| 2 | 06_2A | 90,204.86 | 90,204.88 | 0.02 | 0.0000 % | 0.01 | Sí |
| 2 | 07_3A | 59,733.47 | 59,733.43 | -0.04 | -0.0001 % | -0.02 | Sí |
| 2 | 08_4A | 1,506.25 | 1,506.27 | 0.02 | 0.0011 % | -0.00 | Sí |
| 2 | 09_5A | 310.25 | 310.22 | -0.03 | -0.0081 % | 0.00 | Sí |
| 2 | 10_6-10A | 1,299.38 | 1,299.42 | 0.04 | 0.0028 % | -0.00 | Sí |
| 2 | 11_11-20A | 206.74 | 206.72 | -0.02 | -0.0089 % | -0.00 | Sí |

### 1.5 Supuestos de la réplica GAPS

| ID | Supuesto | Fuente o motivo |
|---|---|---|
| SUPUESTO-01 | Tesorería IFIs = RUBRO que inicia con 2313 o 2323 | El manual sólo dice "Tesorería IFIs"; la regla figura en la hoja Calculadora |
| SUPUESTO-02 | En el relleno hacia nodos superiores, la posición m−1 toma el desgaste del nodo previo de la curva inferior | El manual no especifica ese valor |
| SUPUESTO-03 | Bandas regulatorias (GER, AX7, REPRECIO, CE) según las definiciones de reporte; banda k = 30·k días | Las bandas no están en el manual |
| SUPUESTO-04 | Curva según los meses de apertura y posición = meses transcurridos + banda | El manual dice "según la curva de desgaste que le corresponde", sin detallar la posición |
| SUPUESTO-05 | Sin redondeo intermedio | El manual no lo menciona; el código redondea por banda (explica diferencias ≤ S/ 0,04) |
| SUPUESTO-06 | Los DPF CONTRACTUAL (IFIs) mantienen las bandas y los montos de la base | Manual §4 |

## 2. Módulo Asignado (periodo 202610) – réplica parcial

**Factibilidad: Parcialmente.** Sólo se entregaron muestras de 99 registros. Faltan las funciones que calculan TT_PASIVA_GEB e ING_FIN_TOTAL, la tabla de prima de liquidez y la tabla de TT en los plazos requeridos (la muestra cubre sólo los plazos 1.693–1.742 del 30/10/2026; se requieren 27–496).

### 2.1 Traspaso de atributos input → output
| Campo output | Campo input | Registros | Coincidentes | % coincidencia |
|---|---|---|---|---|
| SALDO_PROMEDIO | MO_CAPI_PROM_MN | 99 | 99 | 100 |
| SALDO_CIERRE | MO_SALD_CAPI_MN | 99 | 99 | 100 |
| TASA_TEA | VL_TEA | 99 | 99 | 100 |
| PLAZO_DIAS | NU_PLAZ_DIAS | 99 | 99 | 100 |
| MONTO_APERTURA | MO_APERTURA | 99 | 99 | 100 |
| FECHA_APERTURA | FE_APERTURA | 99 | 99 | 100 |
| FECHA_VENCIMIENTO | FE_VENCIMIENTO | 99 | 99 | 100 |
| CO_MONEDA_OUT | CO_MONEDA_IN | 99 | 99 | 100 |

### 2.2 Ingreso financiero (manual §3.2 Paso 4, dada la TT publicada)
Las 99 de 99 cuentas están dentro de tolerancia (dif. relativa máx. 5,6 × 10⁻¹⁴). La réplica usa IF = saldo promedio × ((1 + TT_PASIVA_GEB)^(31/360) − 1). La lectura literal de la fórmula del manual, "(1+TT)^(d/360) − 1 * saldo", no reproduce el output porque la precedencia de operadores está mal escrita (INC-11).

### 2.3 Prima de liquidez implícita (TT_PASIVA_GEB − TT_PONDERADA)
| CO_MONEDA | PERIODO_APERTURA | min | max | count |
|---|---|---|---|---|
| 1.0 | 202504.0 | 0.0038 | 0.0038 | 1.0 |
| 1.0 | 202510.0 | 0.0038 | 0.0038 | 3.0 |
| 1.0 | 202511.0 | 0.0038 | 0.0038 | 1.0 |
| 1.0 | 202512.0 | 0.0038 | 0.0038 | 1.0 |
| 1.0 | 202601.0 | 0.0043 | 0.0043 | 8.0 |
| 1.0 | 202602.0 | 0.0043 | 0.0043 | 4.0 |
| 1.0 | 202603.0 | 0.0043 | 0.0043 | 2.0 |
| 1.0 | 202604.0 | 0.0036 | 0.0036 | 2.0 |
| 1.0 | 202605.0 | 0.0036 | 0.0036 | 9.0 |
| 1.0 | 202606.0 | 0.0036 | 0.0036 | 6.0 |
| 1.0 | 202607.0 | 0.0036 | 0.0036 | 9.0 |
| 1.0 | 202608.0 | 0.0038 | 0.0038 | 13.0 |
| 1.0 | 202609.0 | 0.0038 | 0.0038 | 19.0 |
| 1.0 | 202610.0 | 0.0038 | 0.0038 | 19.0 |
| 2.0 | 202607.0 | 0.0001 | 0.0001 | 1.0 |
| 2.0 | 202610.0 | 0.0021 | 0.0021 | 1.0 |

La prima es constante por moneda y periodo de apertura para aperturas desde 202601, y para aperturas anteriores es igual a la del periodo de portafolio (0,0038), lo que es consistente con el manual §3.2 Paso 3. Los valores no pueden contrastarse contra la tabla de primas, que no fue entregada.

### 2.4 Plazo conductual y TT
| Concepto | Valor |
|---|---|
| registros | 99 |
| con plazo conductual asignado | 99 |
| TT encontrada en la muestra | 0 |
| rango de plazos en muestra TT | 1693–1742 |
| fechas en muestra TT | 2026-10-30 |
| plazos conductuales requeridos | 27–496 |
| DURATION del output = plazo contractual (%) | 100 |

### 2.5 Calidad de la tabla modelo_conductual
| Prueba | Resultado |
|---|---|
| Registros | 9000 |
| Metodologías presentes | NUEVA |
| Duplicados (plazo, metodología) | 0 |
| Plazo conductual > contractual | 0 |
| Decrementos del plazo conductual al aumentar el contractual | 73 |
| Rangos con decrementos (contractual) | 271, 273, 274, 276, 278, 280, 281, 283, 285, 287, 288, 290, 292, 294, 295 … |

**Actualización 18/11/2026.** La tabla coincide al 100 % (9.000/9.000 plazos) con la curva propuesta RETAIL de la validación metodológica (`Supuesto_Conductual_DPF_Propuesta.csv`), en PEN y USD. Los 73 tramos decrecientes provienen de los nodos RMST del modelo (300, 390, 750 y 1.110 días), por lo que corresponden a la metodología y no a la implementación. Detalle en `replica_resultados/contraste_validacion_metodologica.xlsx` (C2 y C3).

### 2.6 Supuestos de la réplica Asignado
- Se usa un mes de 31 días (octubre 2026) para el exponente del ingreso financiero.
- El plazo conductual se asigna sólo a aperturas desde el 01/04/2021 (SP l.401), y se usa la metodología `NUEVA`, que es la única entregada.
- La TT final se toma del output, porque la función que la calcula no fue provista.
