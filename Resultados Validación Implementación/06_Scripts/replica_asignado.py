# -*- coding: utf-8 -*-
"""
Réplica parcial independiente – Módulo Asignado (TT asignada DPF)
================================================================
Validación de Implementación – Fase 3.

Con la información disponible (muestras de 99 cuentas, periodo 202610) se replican de forma
independiente, a partir del *Manual Operativo Tasas de Transferencia Asignada - Pasivos* (§3.2):

  C1. Traspaso de atributos del input al output (saldo promedio, saldo de cierre, TEA, plazo, monto).
  C2. Ingreso financiero: IF = saldo promedio × ((1 + TT)^(días del mes / 360) − 1)    [manual §3.2 Paso 4]
      usando la TT final publicada (TT_PASIVA_GEB), porque las funciones que la calculan no fueron provistas.
  C3. Prima de liquidez implícita (TT_PASIVA_GEB − TT_PONDERADA) por moneda y periodo de apertura [Paso 3].
  C4. Asignación de plazo conductual (modelo_conductual) y búsqueda de TT [Pasos 1-2]: se evalúa
      la factibilidad con la muestra de fin_tt_pasivo_dist_total.
  C5. Pruebas de calidad sobre la tabla modelo_conductual (unicidad, monotonicidad, cota conductual ≤ contractual).

Uso:  python3 replica_asignado.py <ruta_repositorio> <carpeta_salida>
Requisitos: Python ≥ 3.10, pandas, numpy, openpyxl. Procesamiento local.
"""
import os, sys
import numpy as np
import pandas as pd

REPO, OUT = sys.argv[1], sys.argv[2]
os.makedirs(OUT, exist_ok=True)
A = os.path.join(REPO, "Modelo DPF - Asignado", "3. Inputs y Outputs")
inp = pd.read_excel(os.path.join(A, "3.1 Inputs", "Muestra Tablas Inputs -DPF.xlsx"), sheet_name=None)
out = pd.read_excel(os.path.join(A, "3.2 Outputs", "Muestra Output DPF.xlsx"))
f, mc, tt = inp["f_fin_saldos_pasivos"], inp["modelo_conductual"], inp["fin_tt_pasivo_dist_total"]
TOL = 0.001
DIAS_MES = 31  # octubre 2026 (periodo 202610)

res = {}
# C1 – traspaso de atributos
j = out.merge(f, on=["NU_CUENTA", "NU_ORDINAL"], how="left", suffixes=("_OUT", "_IN"))
pares = [("SALDO_PROMEDIO", "MO_CAPI_PROM_MN"), ("SALDO_CIERRE", "MO_SALD_CAPI_MN"), ("TASA_TEA", "VL_TEA"),
         ("PLAZO_DIAS", "NU_PLAZ_DIAS"), ("MONTO_APERTURA", "MO_APERTURA"), ("FECHA_APERTURA", "FE_APERTURA"),
         ("FECHA_VENCIMIENTO", "FE_VENCIMIENTO"), ("CO_MONEDA_OUT", "CO_MONEDA_IN")]
c1 = []
for o_, i_ in pares:
    a, b = j[o_], j[i_]
    eq = (a == b) if a.dtype.kind in "OM" else pd.Series(np.isclose(a.astype(float), b.astype(float)))
    c1.append((o_, i_, len(j), int(eq.sum()), round(eq.mean() * 100, 2)))
res["C1_traspaso"] = pd.DataFrame(c1, columns=["Campo output", "Campo input", "Registros", "Coincidentes", "% coincidencia"])

# C2 – ingreso financiero
o = out.copy()
o["IF_REPLICA"] = o.SALDO_PROMEDIO * ((1 + o.TT_PASIVA_GEB) ** (DIAS_MES / 360) - 1)
o["DIF_ABS"] = o.IF_REPLICA - o.ING_FIN_TOTAL
o["DIF_REL"] = np.where(o.ING_FIN_TOTAL != 0, o.DIF_ABS / o.ING_FIN_TOTAL, 0)
o["DENTRO_TOL"] = o.DIF_REL.abs() <= TOL
res["C2_ingreso_financiero"] = o[["NU_CUENTA", "NU_ORDINAL", "CO_MONEDA", "PLAZO_DIAS", "SALDO_PROMEDIO", "TT_PASIVA_GEB", "ING_FIN_TOTAL", "IF_REPLICA", "DIF_ABS", "DIF_REL", "DENTRO_TOL"]]
# Lectura alternativa literal de la fórmula del manual: (1+TT)^(d/360) − (1 × saldo)
o["IF_LITERAL_MANUAL"] = (1 + o.TT_PASIVA_GEB) ** (DIAS_MES / 360) - 1 * o.SALDO_PROMEDIO

# C3 – prima implícita
o["PRIMA_IMPLICITA"] = (o.TT_PASIVA_GEB - o.TT_PONDERADA).round(6)
res["C3_prima_implicita"] = o.groupby(["CO_MONEDA", "PERIODO_APERTURA"]).PRIMA_IMPLICITA.agg(["min", "max", "count"]).reset_index()

# C4 – plazo conductual y TT
m = dict(zip(mc.PLAZO_CONTRACTUAL, mc.PLAZO_CONDUCTUAL))
o["PLAZO_CONDUCTUAL_REPLICA"] = np.where(o.FECHA_APERTURA >= "2021-04-01", o.PLAZO_DIAS.map(m), o.PLAZO_DIAS)
o["MONEDA_TXT"] = o.CO_MONEDA.map({1: "PEN", 2: "USD"})
k = o.merge(tt, left_on=["MONEDA_TXT", "PLAZO_CONDUCTUAL_REPLICA", "FECHA_APERTURA"], right_on=["MONEDA", "PLAZO", "FECHA"], how="left")
res["C4_tt_factibilidad"] = pd.DataFrame([{
    "registros": len(o), "con plazo conductual asignado": int(o.PLAZO_CONDUCTUAL_REPLICA.notna().sum()),
    "TT encontrada en la muestra": int(k.TT.notna().sum()),
    "rango de plazos en muestra TT": f"{tt.PLAZO.min()}–{tt.PLAZO.max()}", "fechas en muestra TT": ", ".join(sorted(tt.FECHA.astype(str).unique())),
    "plazos conductuales requeridos": f"{int(o.PLAZO_CONDUCTUAL_REPLICA.min())}–{int(o.PLAZO_CONDUCTUAL_REPLICA.max())}",
    "DURATION del output = plazo contractual (%)": round((o.DURATION == o.PLAZO_DIAS).mean() * 100, 1)}]).T.reset_index()
res["C4_tt_factibilidad"].columns = ["Concepto", "Valor"]
res["C4_detalle"] = o[["NU_CUENTA", "FECHA_APERTURA", "PLAZO_DIAS", "PLAZO_CONDUCTUAL_REPLICA", "DURATION", "TT_PONDERADA"]]

# C5 – calidad de modelo_conductual
s = mc.sort_values("PLAZO_CONTRACTUAL")
dec = s[s.PLAZO_CONDUCTUAL.diff() < 0]
res["C5_modelo_conductual"] = pd.DataFrame([
    ("Registros", len(mc)), ("Metodologías presentes", ", ".join(mc.TIPO_METODOLOGIA.unique())),
    ("Duplicados (plazo, metodología)", int(mc.duplicated(["PLAZO_CONTRACTUAL", "TIPO_METODOLOGIA"]).sum())),
    ("Plazo conductual > contractual", int((mc.PLAZO_CONDUCTUAL > mc.PLAZO_CONTRACTUAL).sum())),
    ("Decrementos del plazo conductual al aumentar el contractual", len(dec)),
    ("Rangos con decrementos (contractual)", ", ".join(f"{a}" for a in dec.PLAZO_CONTRACTUAL.head(15)) + (" …" if len(dec) > 15 else "")),
], columns=["Prueba", "Resultado"])
res["C5_decrementos"] = dec

with pd.ExcelWriter(os.path.join(OUT, "replica_asignado.xlsx")) as w:
    for name, df in res.items():
        df.to_excel(w, sheet_name=name[:31], index=False)
for name in ["C1_traspaso", "C3_prima_implicita", "C4_tt_factibilidad", "C5_modelo_conductual"]:
    print(name); print(res[name].to_string(index=False))
print("C2: dentro de tolerancia", int(o.DENTRO_TOL.sum()), "/", len(o), "; máx |dif rel|", float(o.DIF_REL.abs().max()))
