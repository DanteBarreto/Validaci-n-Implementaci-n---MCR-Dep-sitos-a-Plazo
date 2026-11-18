# -*- coding: utf-8 -*-
"""
Conciliación réplica vs output oficial – Módulo GAPS.
Uso: python3 conciliacion_gaps.py <ruta_repositorio> <carpeta_resultados_replica>
Tolerancia: 0,1 % relativa por bucket (aprobada por el usuario), además de los umbrales VIRF
(CDD-06 / CDD-13: coincidencia ≥ 99 %).
"""
import os, sys
import numpy as np
import pandas as pd

REPO, RES = sys.argv[1], sys.argv[2]
G = os.path.join(REPO, "Modelo DPF - GAPS", "3. Inputs y Outputs")
TOL = 0.001
K = ["CAT_PLANCON", "TIPO_PASIVO", "MONEDA", "GAP_AX7", "GAP_REPRECIO", "GAP_CE", "GAP_GER", "MARCAORIGEN", "MARCA_CONTA"]
V = ["MONTO", "INTERES_DEVENGADO", "INTERES_VENCIMIENTO", "PAGO_TOTAL", "INTERES_ANUAL"]

of = pd.read_csv(os.path.join(G, "3.2 Outputs", "Output_R01_Reporte_Base_DPF_20260930.csv"), encoding="latin1")
rp = pd.read_csv(os.path.join(RES, "replica_gaps_R01.csv"))
rp["MARCA_CONTA"] = rp["MARCA_CONTA"].str.replace("Ú", "�") if False else rp["MARCA_CONTA"]
of["MARCA_CONTA"] = of["MARCA_CONTA"].str.replace("P�BLICO", "PÚBLICO").str.replace("P\xdaBLICO", "PÚBLICO")

def conciliar(dim):
    a = of.groupby(dim)[V].sum(); b = rp.groupby(dim)[V].sum()
    m = a.join(b, lsuffix="_OFICIAL", rsuffix="_REPLICA", how="outer").fillna(0)
    for v in V:
        m[v + "_DIF"] = m[v + "_REPLICA"] - m[v + "_OFICIAL"]
        m[v + "_DIF_REL"] = np.where(m[v + "_OFICIAL"] != 0, m[v + "_DIF"] / m[v + "_OFICIAL"].abs(), np.where(m[v + "_DIF"] != 0, np.inf, 0))
        m[v + "_DENTRO_TOL"] = (m[v + "_DIF_REL"].abs() <= TOL) | (m[v + "_DIF"].abs() < 0.01)
    return m.reset_index()

res = {}
for name, dim in [("total", ["MONEDA"]), ("GAP_GER", ["MONEDA", "GAP_GER"]), ("GAP_AX7", ["MONEDA", "GAP_AX7"]),
                  ("GAP_REPRECIO", ["MONEDA", "GAP_REPRECIO"]), ("GAP_CE", ["MONEDA", "GAP_CE"]),
                  ("CAT_PLANCON", ["MONEDA", "CAT_PLANCON"]), ("clave_R01", K)]:
    res[name] = conciliar(dim)

# Detalle por operación y banda (particiones 94–96 disponibles)
det = pd.read_csv(os.path.join(RES, "replica_gaps_detalle.csv"))
ofd = pd.concat([pd.read_csv(os.path.join(G, "3.2 Outputs", "Resultados", f"Resultados_Base_DPF_20260930_{k}.csv"), encoding="latin1") for k in (94, 95, 96)])
ofd["BANDA"] = ofd.groupby("NUMERO_DESEMBOLSO").cumcount() + 1
d2 = det[det.NUMERO_DESEMBOLSO.isin(ofd.NUMERO_DESEMBOLSO)]
mm = ofd.merge(d2, on=["NUMERO_DESEMBOLSO", "BANDA"], how="outer", suffixes=("_OF", "_RP"), indicator=True)
detalle = pd.DataFrame({
    "filas_oficial": [len(ofd)], "filas_replica": [len(d2)], "filas_coincidentes": [int((mm._merge == "both").sum())],
    "capital_dif_abs_max": [float((mm.Capital - mm.MONTO_RP).abs().max())],
    "intereses_dif_abs_max": [float((mm.Intereses - mm.INTERES_VENCIMIENTO_RP).abs().max())],
    "ax7_coincide_%": [float((mm.Banda_GAP_AX7 == mm.GAP_AX7_RP).mean() * 100)],
    "ger_coincide_%": [float((mm.Banda_GAP_GER == mm.GAP_GER_RP).mean() * 100)],
})
res["detalle_94_96"] = detalle
ax = mm[mm.Banda_GAP_AX7 != mm.GAP_AX7_RP][["NUMERO_DESEMBOLSO", "BANDA", "FECHA_VTO", "Banda_GAP_AX7", "GAP_AX7_RP", "Capital"]]
res["detalle_dif_AX7"] = ax.head(500)

# Prueba de causa raíz: aplicar la regla del código R (l.372-376) a la banda 1 (AX7 por día del vencimiento)
base = pd.read_csv(os.path.join(G, "3.1 Inputs", "Base_DPF_20260930.csv"), encoding="latin1")
dia_vto = dict(zip(base.NUMERO_DESEMBOLSO, pd.to_datetime(base.FECHA_VTO, format="%d/%m/%Y").dt.day))
contr = set(base.NUMERO_DESEMBOLSO[base.CURVA == "CONTRACTUAL"])
def ax7(v):
    for l, s in [(7, "01_1-7d"), (15, "02_8-15d"), (30, "03_16d-1M"), (60, "04_2M")]:
        if v <= l:
            return s
sens = det.copy()
msk = (sens.BANDA == 1) & (~sens.NUMERO_DESEMBOLSO.isin(contr))
sens.loc[msk, "GAP_AX7"] = sens.loc[msk, "NUMERO_DESEMBOLSO"].map(dia_vto).map(ax7)
sens.to_csv(os.path.join(RES, "replica_gaps_detalle_sensibilidad_AX7.csv"), index=False)
K8 = [k for k in K if k != "MARCA_CONTA"]
s_of = of.groupby(K8)[V].sum(); s_rp = sens.groupby(K8)[V].sum()
sj = s_of.join(s_rp, lsuffix="_OFICIAL", rsuffix="_REPLICA", how="outer").fillna(0)
for v in ["MONTO", "INTERES_VENCIMIENTO"]:
    sj[v + "_DIF"] = sj[v + "_REPLICA"] - sj[v + "_OFICIAL"]
    sj[v + "_FUERA_TOL"] = (sj[v + "_DIF"].abs() >= 0.01) & ((sj[v + "_DIF"] / sj[v + "_OFICIAL"].replace(0, np.nan)).abs().fillna(np.inf) > TOL)
res["sensibilidad_AX7_codigo"] = sj.reset_index()
print("Sensibilidad AX7 (regla del código): claves", len(sj), "fuera de tol MONTO:", int(sj.MONTO_FUERA_TOL.sum()),
      "INT:", int(sj.INTERES_VENCIMIENTO_FUERA_TOL.sum()), "máx |dif| MONTO:", round(float(sj.MONTO_DIF.abs().max()), 2))

with pd.ExcelWriter(os.path.join(RES, "conciliacion_gaps.xlsx")) as w:
    for k, v in res.items():
        v.to_excel(w, sheet_name=k[:31], index=False)
for k in ["total", "GAP_GER", "GAP_AX7", "clave_R01"]:
    m = res[k]
    print(k, "buckets:", len(m), "fuera de tol (MONTO):", int((~m.MONTO_DENTRO_TOL).sum()), "(INT_VTO):", int((~m.INTERES_VENCIMIENTO_DENTRO_TOL).sum()),
          "max|rel| MONTO:", round(float(m.MONTO_DIF_REL.replace(np.inf, np.nan).abs().max()), 6))
print(res["total"][["MONEDA"] + [v + s for v in ["MONTO", "INTERES_VENCIMIENTO", "PAGO_TOTAL"] for s in ["_OFICIAL", "_REPLICA", "_DIF_REL"]]].to_string())
print(detalle.T)
