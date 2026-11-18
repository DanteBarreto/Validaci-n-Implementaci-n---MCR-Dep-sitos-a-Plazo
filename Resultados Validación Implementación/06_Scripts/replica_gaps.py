# -*- coding: utf-8 -*-
"""
Réplica independiente – Módulo GAPS (MCR Depósitos a Plazo)
===========================================================
Validación de Implementación – Fase 3.

Reimplementa en Python, a partir del *Manual de Herramienta de Modelo DPF - Gaps - v2*
(Paso 5 y §4 "Supuestos - Criterios"), los tres componentes del módulo:

  1. Clasificación de cada operación (MARCAORIGEN_C, MARCA_CONTA, FLAG, CURVA).
  2. Construcción de la matriz CURVAS (nodos mensuales) desde la hoja "Curvas GAP Modelo".
  3. Distribución conductual de flujos por bandas y agregación al formato Output_R01.

No reejecuta el código del modelo (R/VBA). Cada supuesto que el manual no define queda
marcado como SUPUESTO-xx y está documentado en el informe (sección Réplica).

Uso:
    python3 replica_gaps.py <ruta_repositorio> <carpeta_salida>

Requisitos: Python ≥ 3.10, pandas, numpy, openpyxl.
Todos los datos se procesan localmente.
"""
import math
import os
import sys

import numpy as np
import openpyxl
import pandas as pd

REPO = sys.argv[1]
OUT = sys.argv[2]
os.makedirs(OUT, exist_ok=True)
G = os.path.join(REPO, "Modelo DPF - GAPS")
XLSM = os.path.join(G, "2. Script", "Macro Modelo Conductual DPF en Gaps 30.09.xlsm")
BASE = os.path.join(G, "3. Inputs y Outputs", "3.1 Inputs", "Base_DPF_20260930.csv")
CURVAS_OF = os.path.join(G, "3. Inputs y Outputs", "3.1 Inputs", "CURVAS.xlsx")
R01_OF = os.path.join(G, "3. Inputs y Outputs", "3.2 Outputs", "Output_R01_Reporte_Base_DPF_20260930.csv")
FECHA_CIERRE = pd.Timestamp("2026-09-30")   # Hoja Parámetros C2 / Data_Parametros.csv

# ---------------------------------------------------------------------------
# 0. Lectura de parámetros de la macro (hojas de entrada, no código)
# ---------------------------------------------------------------------------
wb = openpyxl.load_workbook(XLSM, read_only=True, data_only=True)
aux = wb["Aux"]
equiv, coop, otros = {}, [], {}
for r in aux.iter_rows(min_row=2, values_only=True):
    if r[0] is not None:
        equiv[r[0]] = r[1]                      # TIPO PASIVO -> MARCA_CONTA (EQUIVALENCIA)
    if r[4] is not None:
        coop.append(r[4])                        # Cooperativas -> AGENCIA / FINANCIERO (manual Paso 5)
    if r[8] is not None:
        otros[r[8]] = (r[9], r[10])              # Otros: ENTIDAD -> (MARCAORIGEN, MARCA_CONTA)
cgm = [list(r) for r in wb["Curvas GAP Modelo"].iter_rows(min_row=2, values_only=True) if r[0] is not None]

# ---------------------------------------------------------------------------
# 1. Clasificación (manual Paso 5, columnas AA–AD)
# ---------------------------------------------------------------------------
b = pd.read_csv(BASE, encoding="latin1")
for col in ["FECHA_PROCESO", "FECHA_APT", "FECHA_VTO"]:
    b[col] = pd.to_datetime(b[col], format="%d/%m/%Y")

def clasificar(row):
    ent = row.ENTIDAD
    if ent in coop:
        mo, mc = "AGENCIA", "FINANCIERO"
    elif ent in otros:
        mo, mc = otros[ent]
    else:
        mo, mc = row.MARCAORIGEN, equiv.get(row.TIPO_PASIVO, "---")
    rub = str(row.RUBRO)[:4]
    # Manual §4: Tesorería IFIs -> distribución contractual; Retail y Tesorería No IFIs -> curvas modeladas.
    if rub in ("2313", "2323"):           # SUPUESTO-01: identificación de IFIs por rubro contable (sólo en hoja Calculadora)
        flag = "TESORERIA IFIS"
    elif mo == "TESORERIA":
        flag = "TESORERIA NO IFIS"
    else:
        flag = "RETAIL"
    curva = {"TESORERIA IFIS": "CONTRACTUAL"}.get(flag, flag)
    return pd.Series([mo, mc, flag, curva])

b[["R_MARCAORIGEN_C", "R_MARCA_CONTA", "R_FLAG", "R_CURVA"]] = b.apply(clasificar, axis=1)
clasif = {c: float((b[c] == b["R_" + c]).mean()) for c in ["MARCAORIGEN_C", "MARCA_CONTA", "FLAG", "CURVA"]}

# ---------------------------------------------------------------------------
# 2. Matriz CURVAS (manual Paso 5)
# ---------------------------------------------------------------------------
max_dias = int((b.FECHA_VTO - b.FECHA_APT).dt.days.max())
N = math.ceil(max_dias / 30)                     # último nodo = operación de mayor plazo de apertura
curvas = {}
for mon in sorted({r[0] for r in cgm}):
    for cur in dict.fromkeys(r[1] for r in cgm):
        base_nodes = {}
        for r in cgm:
            if r[0] == mon and r[1] == cur:
                m = int(round(r[2] / 30))
                v = [x for x in r[4:4 + m]]
                v[m - 1] = 1.0                    # el nodo de su apertura vale 1
                base_nodes[m] = [float(x) for x in v]
        rows = {m: base_nodes.get(m) for m in range(1, N + 1)}
        # Primer proceso: nodos inferiores toman la curva superior existente, acotada a su apertura (valor 1).
        for m in range(N - 1, 0, -1):
            if rows[m] is None and rows[m + 1] is not None:
                rows[m] = rows[m + 1][: m - 1] + [1.0]
        # Segundo proceso: nodos superiores toman la curva inferior existente, con 1 en su apertura.
        # SUPUESTO-02: para la posición m-1 (donde la curva inferior vale 1) el manual no indica el valor;
        # se usa el desgaste del nodo previo de la curva inferior (lectura de "completar con los nodos existentes").
        for m in range(2, N + 1):
            if rows[m] is None and rows[m - 1] is not None:
                prev = rows[m - 1]
                new = prev[: m - 2] + [prev[m - 3] if m >= 3 else prev[0]] + [1.0]
                rows[m] = new
        curvas[(mon, cur)] = rows

# Comparación con CURVAS.xlsx oficial
cof = pd.read_excel(CURVAS_OF)
cmp_rows = []
for _, r in cof.iterrows():
    mine = curvas[(r.Moneda, r.Curva)][int(r.Meses)]
    off = [r.iloc[4 + i] for i in range(int(r.Meses))]
    d = max(abs(a - (0 if pd.isna(o) else o)) for a, o in zip(mine, off))
    cmp_rows.append((r.Moneda, r.Curva, int(r.Meses), d))
curv_cmp = pd.DataFrame(cmp_rows, columns=["Moneda", "Curva", "Meses", "MaxDifAbs"])

# ---------------------------------------------------------------------------
# 3. Distribución de flujos (manual §4)
# ---------------------------------------------------------------------------
def gap_ger(d):
    lim = [30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330, 360] + [360 * k for k in range(2, 21)]
    lab = [f"{i+1:02d}_{i+1}M" for i in range(12)] + [f"{i+13:02d}_{i+2}A" for i in range(19)]
    for l, s in zip(lim, lab):
        if d <= l:
            return s
    return "32_>20A"
def gap_ax7(d):
    for l, s in [(7, "01_1-7d"), (15, "02_8-15d"), (30, "03_16d-1M"), (60, "04_2M"), (90, "05_3M"), (180, "06_4-6M"),
                 (360, "07_7M-1A"), (720, "08_2A"), (1080, "09_3A"), (1440, "10_4A"), (1800, "11_5A"), (3600, "12_6-10A"), (7200, "13_11-20A")]:
        if d <= l:
            return s
    return "14_+20A"
def gap_rep(d):
    for l, s in [(30, "01_1M"), (60, "02_2M"), (90, "03_3M"), (180, "04_4-6M"), (360, "05_7M-1A"), (720, "06_2A"), (1080, "07_3A"),
                 (1440, "08_4A"), (1800, "09_5A"), (3600, "10_6-10A"), (7200, "11_11-20A")]:
        if d <= l:
            return s
    return "12_+20A"
def gap_ce(d):
    for i, l in enumerate([30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330, 360]):
        if d <= l:
            return f"{i+1}M"
    for k in range(2, 21):
        if d <= 360 * k:
            return f"{k}A"
    for l, s in [(9000, "21-25A"), (10800, "26-30A"), (12600, "31-35A"), (14400, "36-40A"), (18000, "41-50A")]:
        if d <= l:
            return s
    return ">50A"
# Nota: las tablas de bandas regulatorias (GER, AX7, REPRECIO, CE) no están en el manual; se toman de la
# definición de bandas del reporte (SUPUESTO-03). La banda AX7 de la banda mensual 1 se asigna por 30 días.

out = []
for r in b.itertuples(index=False):
    keys = dict(CAT_PLANCON=r.CAT_PLANCON, TIPO_PASIVO=r.TIPO_PASIVO, MONEDA=r.MONEDA,
                MARCAORIGEN=r.R_MARCAORIGEN_C, MARCA_CONTA=r.R_MARCA_CONTA, NUMERO_DESEMBOLSO=r.NUMERO_DESEMBOLSO)
    if r.R_CURVA == "CONTRACTUAL":
        out.append({**keys, "BANDA": 1, "GAP_AX7": r.GAP_AX7, "GAP_REPRECIO": r.GAP_REPRECIO, "GAP_CE": r.GAP_CE, "GAP_GER": r.GAP_GER,
                    "MONTO": r.MONTO, "INTERES_DEVENGADO": r.INTERES_DEVENGADO, "INTERES_VENCIMIENTO": r.INTERES_VENCIMIENTO,
                    "PAGO_TOTAL": r.PAGO_TOTAL, "INTERES_ANUAL": r.INTERES_ANUAL})
        continue
    m_ap = math.ceil((r.FECHA_VTO - r.FECHA_APT).days / 30)                    # meses de apertura
    m_rem = max(min(math.ceil((r.FECHA_VTO - FECHA_CIERRE).days / 30), m_ap), 1)  # plazo residual (manual §4)
    m_tr = m_ap - m_rem                                                         # SUPUESTO-04: posición en la curva = meses transcurridos + banda
    curva = curvas[(r.MONEDA, r.R_CURVA)][m_ap]
    remanente = r.MONTO
    for k in range(1, m_rem + 1):
        d = curva[m_tr + k - 1]
        cap = d * remanente                                                     # desgaste sobre saldo remanente (manual §4)
        remanente -= cap
        ultimo = k == m_rem
        inte = cap * ((1 + r.TEA) ** (r.PLAZO / 360) - 1) if ultimo else 0.0   # interés compuesto sólo al vencimiento (manual §4)
        dias = 30 * k
        out.append({**keys, "BANDA": k, "GAP_AX7": gap_ax7(dias), "GAP_REPRECIO": gap_rep(dias), "GAP_CE": gap_ce(dias), "GAP_GER": gap_ger(dias),
                    "MONTO": cap, "INTERES_DEVENGADO": r.INTERES_DEVENGADO if ultimo else 0.0, "INTERES_VENCIMIENTO": inte,
                    "PAGO_TOTAL": cap + inte, "INTERES_ANUAL": r.INTERES_ANUAL if ultimo else 0.0})
det = pd.DataFrame(out)
det.to_csv(os.path.join(OUT, "replica_gaps_detalle.csv"), index=False, encoding="utf-8")

K = ["CAT_PLANCON", "TIPO_PASIVO", "MONEDA", "GAP_AX7", "GAP_REPRECIO", "GAP_CE", "GAP_GER", "MARCAORIGEN", "MARCA_CONTA"]
V = ["MONTO", "INTERES_DEVENGADO", "INTERES_VENCIMIENTO", "PAGO_TOTAL", "INTERES_ANUAL"]
agg = det.groupby(K, dropna=False)[V].sum().reset_index()
agg.to_csv(os.path.join(OUT, "replica_gaps_R01.csv"), index=False, encoding="utf-8")
curv_cmp.to_csv(os.path.join(OUT, "replica_gaps_curvas_comparacion.csv"), index=False)
pd.Series(clasif).to_csv(os.path.join(OUT, "replica_gaps_clasificacion.csv"), header=["coincidencia"])
print("Clasificación:", clasif)
print("Curvas: filas", len(curv_cmp), "con diferencia > 1e-9:", int((curv_cmp.MaxDifAbs > 1e-9).sum()))
print("Detalle:", len(det), "filas; MONTO total", round(det.MONTO.sum(), 2))
