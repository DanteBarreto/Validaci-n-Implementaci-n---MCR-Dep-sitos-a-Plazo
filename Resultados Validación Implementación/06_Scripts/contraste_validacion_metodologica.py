# -*- coding: utf-8 -*-
"""
Contraste entre la entrega de la validación metodológica y lo implementado.
Uso: python3 contraste_validacion_metodologica.py <ruta_repositorio> <carpeta_salida>

C1  Curvas GAP de la macro ('Curvas GAP Modelo') vs curvas de Riesgos de Mercado BCP
    ('Validación metodológica/1. Documentos recibidos/Ejemplo DPF_MiBanco.xlsx', hoja 'Curvas GAP').
    Las filas '>1110' (RETAIL) y '>540' (TESORERIA NO IFIS) de RdM se comparan con los nodos 1.500 y 570 de la macro.
C2  Tabla modelo_conductual (muestra Asignado) vs 'Supuesto_Conductual_DPF_Propuesta.csv' por moneda y segmento.
C3  Monotonicidad de los nodos RMST de RdM ('Tabla_Resultados_Finales.xlsx', hoja 'KM_RdM').
C4  Exposición de la base GAPS a los nodos extrapolados (TESORERIA NO IFIS > 540 días y RETAIL > 1.110 días).
Todo el procesamiento es local; no modifica el repositorio.
"""
import os, sys, glob
import numpy as np
import pandas as pd
import openpyxl

REPO, OUT = sys.argv[1], sys.argv[2]
os.makedirs(OUT, exist_ok=True)
VM = os.path.join(REPO, "Validación metodológica")
res = {}

# C1 -----------------------------------------------------------------------
ws = openpyxl.load_workbook(os.path.join(REPO, "Modelo DPF - GAPS", "2. Script", "Macro Modelo Conductual DPF en Gaps 30.09.xlsm"),
                            read_only=True, data_only=True)["Curvas GAP Modelo"]
mac = [r for r in ws.iter_rows(values_only=True) if any(v is not None for v in r)][1:]
ws = openpyxl.load_workbook(os.path.join(VM, "1. Documentos recibidos", "Ejemplo DPF_MiBanco.xlsx"), read_only=True, data_only=True)["Curvas GAP"]
rdm = [r for r in ws.iter_rows(values_only=True) if any(v is not None for v in r)][1:]
R = {(r[0], {">1110": 1500, ">540": 570}.get(r[1], r[1])): r[3:] for r in rdm}
rows = []
for r in mac:
    mon, curva, plazo, vals = r[0], r[1], r[2], r[4:]
    ref = R.get((curva, plazo))
    for i, a in enumerate(vals):
        b = ref[i] if ref is not None and i < len(ref) else None
        if a is None and b is None:
            continue
        rows.append((mon, curva, plazo, i + 1, a, b, abs((a or 0) - (b or 0))))
c1 = pd.DataFrame(rows, columns=["MONEDA", "CURVA", "PLAZO_AGRUPADO", "MES", "MACRO", "RDM", "DIF_ABS"])
res["C1_curvas_detalle"] = c1
res["C1_curvas_resumen"] = c1.groupby(["MONEDA", "CURVA", "PLAZO_AGRUPADO"]).DIF_ABS.agg(["count", "max"]).reset_index()

# C2 -----------------------------------------------------------------------
f = glob.glob(os.path.join(REPO, "Modelo DPF - Asignado", "3. Inputs y Outputs", "3.1 Inputs", "Muestra Tablas Inputs*"))[0]
mc = pd.read_excel(f, sheet_name="modelo_conductual")
prop = pd.read_csv(os.path.join(VM, "2. Resultados", "Asignado", "Supuesto_Conductual_DPF_Propuesta.csv"))
c2 = []
for (m, fl), d in prop.groupby(["Moneda", "Flag"]):
    j = mc.merge(d, left_on="PLAZO_CONTRACTUAL", right_on="Plazo")
    dif = (j.PLAZO_CONDUCTUAL - j.Interpolated_rmst).abs()
    c2.append((m, fl, len(j), int((dif < 1e-9).sum()), round(float((dif < 1e-9).mean() * 100), 2), float(dif.max())))
res["C2_modelo_conductual"] = pd.DataFrame(c2, columns=["MONEDA", "SEGMENTO", "PLAZOS_COMPARADOS", "COINCIDENCIAS", "COINCIDENCIA_%", "DIF_ABS_MAX_DIAS"])
s = mc.set_index("PLAZO_CONTRACTUAL").PLAZO_CONDUCTUAL
res["C2_no_monotonia_tabla"] = pd.DataFrame({"TRAMOS_DECRECIENTES": [int((s.diff() < 0).sum())],
                                             "PLAZO_MIN": [int(s[s.diff() < 0].index.min())], "PLAZO_MAX": [int(s[s.diff() < 0].index.max())]})

# C3 -----------------------------------------------------------------------
km = pd.read_excel(os.path.join(VM, "2. Resultados", "Presentaciones", "Tabla_Resultados_Finales.xlsx"), sheet_name="KM_RdM")
km["RETAIL_DIF_VS_NODO_ANTERIOR"] = km.RETAIL.diff()
km["NODO_DECRECIENTE"] = km.RETAIL_DIF_VS_NODO_ANTERIOR < 0
res["C3_nodos_RMST_RdM"] = km

# C4 -----------------------------------------------------------------------
b = pd.read_csv(os.path.join(REPO, "Modelo DPF - GAPS", "3. Inputs y Outputs", "3.1 Inputs", "Base_DPF_20260930.csv"), encoding="latin1")
c4 = []
for curva, lim in [("TESORERIA NO IFIS", 540), ("RETAIL", 1110)]:
    t = b[(b.CURVA == curva) & (b.PLAZO > lim)]
    c4.append((curva, lim, len(t), float(t.MONTO_PEN.sum())))
res["C4_exposicion_nodos_extrap"] = pd.DataFrame(c4, columns=["CURVA", "PLAZO_MAYOR_A", "OPERACIONES", "MONTO_PEN"])
res["C4_base_por_flag"] = b.groupby(["FLAG", "CURVA"]).MONTO_PEN.agg(["count", "sum"]).reset_index()

with pd.ExcelWriter(os.path.join(OUT, "contraste_validacion_metodologica.xlsx")) as w:
    for k, v in res.items():
        v.to_excel(w, sheet_name=k[:31], index=False)

print("C1 máx |macro - RdM| sin el nodo 570 de TESORERIA NO IFIS:",
      c1[~((c1.CURVA == "TESORERIA NO IFIS") & (c1.PLAZO_AGRUPADO == 570))].DIF_ABS.max())
print("C1 celdas con diferencia > 1e-4:")
print(c1[c1.DIF_ABS > 1e-4].groupby(["MONEDA", "CURVA", "PLAZO_AGRUPADO"]).MES.agg(["min", "max", "count"]))
print(res["C2_modelo_conductual"].to_string(index=False))
print(res["C2_no_monotonia_tabla"].to_string(index=False))
print(km[km.NODO_DECRECIENTE][["Plazo", "RETAIL", "RETAIL_DIF_VS_NODO_ANTERIOR"]].to_string(index=False))
print(res["C4_exposicion_nodos_extrap"].to_string(index=False))
