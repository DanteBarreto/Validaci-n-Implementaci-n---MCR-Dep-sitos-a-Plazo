# Versión 1
# Control de cambios
import numpy as np  # version 1.26.4
import pandas as pd  # version 2.2.3
from datetime import datetime  # libreria base de python 3.9.21
from dateutil.relativedelta import relativedelta  # libreria base de python 3.9.21

# --- Parámetros del usuario ---
path_rmst = "rmst_km_ajustado.csv"
path_datos = "mb_dpf_mod_agg.csv"
fecha_inicio_split = pd.to_datetime("2021-01-01")  # Comienza el test después de 5 años
fecha_fin = pd.to_datetime("2024-04-01")

# --- Leer datos ---
# df_rmst = pd.read_csv(path_rmst, sep=";")
df_rmst = pd.read_csv(path_rmst, parse_dates=["fecha_fin"], sep=",")
# df_rmst.fecha_fin = pd.to_datetime(df_rmst.fecha_fin, format="%d/%m/%Y")
df_datos = pd.read_csv(path_datos, parse_dates=["FechaApertura"])

# --- Inicializar lista de resultados ---
resultados_split = []

for window in [12, 24, 36]:

    # --- Generar cortes mensuales desde el 6° año ---
    fecha_corte = fecha_inicio_split

    while fecha_corte <= fecha_fin - relativedelta(months=window - 1):
        print(f"Evaluando corte: {fecha_corte.date()}")

        df_train = df_datos[df_datos["FechaApertura"] < fecha_corte].copy()
        df_test = df_datos[
            (df_datos["FechaApertura"] >= fecha_corte)
            & (df_datos["FechaApertura"] < fecha_corte + relativedelta(months=window))
        ].copy()

        if df_test.empty or df_train.empty:
            fecha_corte += relativedelta(months=1)
            continue

        # Seleccionar última RMST por ventana
        rmst_train = (
            df_rmst[df_rmst["fecha_fin"] < fecha_corte]
            .sort_values(["ventana_meses", "fecha_fin"])
            .groupby(["Moneda", "Flag", "PlazoAgrupado", "ventana_meses"])
            .last()
            .reset_index()[
                [
                    "Moneda",
                    "Flag",
                    "PlazoAgrupado",
                    "ventana_meses",
                    "fecha_fin",
                    "rmst",
                ]
            ]
        )
        rmst_train = rmst_train.loc[rmst_train.fecha_fin == rmst_train.fecha_fin.max()]
        rmst_avg = rmst_train.groupby(
            ["Moneda", "Flag", "PlazoAgrupado"], as_index=False
        )["rmst"].mean()
        rmst_avg["ventana_meses"] = 100
        rmst_train = pd.concat([rmst_train, rmst_avg], ignore_index=True)
        rmst_train.drop(columns="fecha_fin", axis=1, inplace=True)
        rmst_train.dropna(inplace=True)
        rmst_train.rmst = rmst_train.rmst.round().astype(int)
        rmst_train.ventana_meses = rmst_train.ventana_meses.astype(int)

        df_test = df_test.merge(rmst_train, on=["Moneda", "Flag", "PlazoAgrupado"])
        mbe_ponderado = df_test.groupby(
            ["Moneda", "Flag", "PlazoAgrupado", "ventana_meses"], as_index=False
        ).apply(
            lambda x: sum((x["rmst"] - x["DiferenciaDias"]) ** 2 * x["Capital"])
            / x["Capital"].sum(),
            include_groups=False,
        )
        mbe_ponderado.rename(columns={None: "mbe_ponderado"}, inplace=True)
        mbe_ponderado[["test_window", "fecha_corte"]] = [window, fecha_corte]

        resultados_split.append(mbe_ponderado)

        fecha_corte += relativedelta(months=1)

# --- Consolidar resultados ---
df_resultados = pd.concat(resultados_split, ignore_index=True)
df_resultados.to_csv("train_test_km.csv", sep=";", index=False)

# --- Promedio de error por ventana ---
errores_promedio = (
    df_resultados.groupby(["Flag", "test_window", "ventana_meses"])["mbe_ponderado"]
    .mean()
    .reset_index()
)
errores_promedio = errores_promedio.sort_values(
    ["Flag", "test_window", "mbe_ponderado"]
)
errores_promedio["mbe_ponderado"] = np.sqrt(errores_promedio["mbe_ponderado"])

print("\nPromedio del MBE ponderado por ventana:")
errores_promedio

errores_promedio.to_csv("errores_promedio_km.csv", sep=";", index=False)
