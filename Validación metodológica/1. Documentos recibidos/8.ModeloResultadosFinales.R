# ------------------------------------------------------------------------------
# SCRIPT: Calcular Kaplan-Meier ponderado y RMST para depósitos a plazo fijo
# OBJETIVO: Estimar la supervivencia de depósitos agrupados en plazos
#
# AUTOR: Brando Calsi (T22867)
# FECHA: 2025-07-07
#
# VERSION: 1
# CONTROL DE CAMBIOS: NINGUNO
#
#
# ------------------------------------------------------------------------------

rm(list = ls())

# --- CONFIGURACIÓN DE ENTORNO ---
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# Cargar librerías necesarias
library(readr)       # readr_2.1.2 Para leer archivos CSV con read_delim()
library(dplyr)       # dplyr_1.0.9 Para manipular data frames: filter, mutate, bind_rows, etc.
library(tidyr)       # tidyr_1.2.0 Para crear combinaciones cruzadas con expand_grid()
library(lubridate)   # lubridate_1.8.0 Para manipular fechas: floor_date(), months(), %m+%, %m-%
library(survival)    # survival_3.3-1 Crear variable objeto esquema de supervivencia
library(flexsurv)    # flexsurv_2.3.2 Cálculo de la integral de curva (RMST)

# -----------------------------
# FUNCIÓN: Generar combinaciones de Moneda, Flag, Plazo y Ventanas
# -----------------------------
generar_combinaciones_con_ventanas <- function(monedas, flags, plazos, ventanas_meses,
                                               fecha_inicio, fecha_fin) {
  # Convertir las fechas de entrada a tipo Date (base R)
  fecha_inicio <- as.Date(fecha_inicio)
  fecha_fin <- as.Date(fecha_fin)
  
  # Crear todas las combinaciones posibles de los vectores
  # expand_grid() viene del paquete tidyr
  combinaciones <- tidyr::expand_grid(
    Moneda = monedas,
    Flag = flags,
    PlazoAgrupado = plazos,
    ventana_meses = ventanas_meses
  )
  
  # Lista vacía donde se guardarán los resultados
  resultado <- list()
  
  # Iterar sobre cada fila de combinaciones
  for (i in seq_len(nrow(combinaciones))) {
    fila <- combinaciones[i, ]
    
    # Extraer el tamaño de la ventana en meses
    meses <- fila$ventana_meses
    
    fecha_inicio <- lubridate::floor_date(fecha_fin, unit = "month") %m-% months(ceiling(fila$PlazoAgrupado / 30)) %m-% months(fila$ventana_meses)
    
    # Calcular las fechas de fin sumando meses a cada fecha de inicio
    fechas_fin <- fecha_inicio %m+% months(meses)
    
    # Crear data frame para esta combinación
    resultado[[i]] <- data.frame(
      Moneda = fila$Moneda,
      Flag = fila$Flag,
      PlazoAgrupado = fila$PlazoAgrupado,
      ventana_meses = meses,
      fecha_inicio = fecha_inicio
    )
  }
  
  # Unir todas las combinaciones de ventana en un solo data frame
  # bind_rows() es de dplyr
  final_df <- dplyr::bind_rows(resultado)
  
  return(final_df)
}

# -----------------------------
# PARÁMETROS DE CONFIGURACIÓN GENERAL
# -----------------------------
min_dias_diferencia <- 8        # Mínimo de días para considerar un depósito válido
min_obs <- 31                   # Mínimo de observaciones para calcular K-M y RMST
data_path <- "1.Datos/mb_dpf_mod_agg.csv" # Path al archivo de datos
fecha_inicio <- "2015-03-01"    # Inicio del análisis
fecha_fin <- "2025-04-01"       # Fin del análisis

# Generar combinaciones de ventanas móviles
ventanas_df <- generar_combinaciones_con_ventanas(
  monedas = c("PEN"),
  flags = c("RETAIL", "TESORERIA IFIS", "TESORERIA NO IFIS"),
  plazos = c(15, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330, 360, 390,
             540, 720, 750, 1080, 1110),
  ventanas_meses = c(36),
  fecha_inicio = fecha_inicio,
  fecha_fin = fecha_fin
)

ventanas_df <- ventanas_df %>%
  mutate(observaciones = NA_real_, rmst = NA_real_)  # NA para columna numérica (ej. resultado RMST)

# -----------------------------
# LECTURA Y FILTRADO DE DATOS
# -----------------------------
df <- read_delim(
  data_path, 
  delim = ",",
  locale = locale(decimal_mark = "."),
  col_types = cols(
    Cliente = col_integer(),
    Cuenta = col_character(),
    Moneda = col_character(),
    Flag = col_character(),
    PlazoAgrupado = col_integer(),
    PlazoAgrupado2 = col_integer(),
    Plazo = col_integer(),
    Capital = col_double(),
    TasaInteres = col_double(),
    DiferenciaDias = col_integer(),
    FlagStatus = col_integer(),
    FechaApertura = col_date(format = "%Y-%m-%d"),
    FechaVencimiento = col_date(format = "%Y-%m-%d"),
    MinFechaProceso = col_date(format = "%Y-%m-%d"),
    MaxFechaProceso = col_date(format = "%Y-%m-%d"))
) %>% 
  # --- FILTRAR DATOS BASE ---
  filter(DiferenciaDias >= min_dias_diferencia)

# -----------------------------
# BUCLE PRINCIPAL SOBRE CADA COMBINACIÓN
# -----------------------------
curvas_km <- list()
for (i in seq_len(nrow(ventanas_df))) {
  fila <- ventanas_df[i, ]
  
  # Filtrar contratos por segmento y ventana temporal
  df_filtrado <- df %>% filter(
    Moneda == fila$Moneda,
    Flag == fila$Flag,
    PlazoAgrupado2 == fila$PlazoAgrupado,
    FechaApertura >= fila$fecha_inicio
  )
  
  ventanas_df$observaciones[i] <- nrow(df_filtrado)
  
  if (nrow(df_filtrado) < min_obs) next  # Evitar resultados espurios
  
  cat(sprintf(
    "[%03d] %s - %s - %d días - %d mes(es) | Ventana: %s a %s | Obs: %d\n",
    i, fila$Moneda, fila$Flag, fila$PlazoAgrupado, fila$ventana_meses,
    as.character(fila$fecha_inicio), as.character(fila$fecha_fin),
    nrow(df_filtrado)
  ))
  
  # ESCALAR PESOS: Ajuste proporcional del capital para ponderar la importancia económica
  df_filtrado <- df_filtrado %>%
    mutate(CapitalEscalado = Capital / sum(Capital) * n())
  
  # OBJETO DE SUPERVIVENCIA PARA K-M: duración + evento
  surv_obj <- survival::Surv(time = df_filtrado$DiferenciaDias, event = df_filtrado$FlagStatus)
  
  # AJUSTAR KAPLAN-MEIER PONDERADO POR CAPITAL
  fit_km <- tryCatch(
    survival::survfit(surv_obj ~ 1, weights = df_filtrado$CapitalEscalado),
    error = function(e) NULL
  )
  
  if (!is.null(fit_km)) {
    rmst_valor <- tryCatch({
      # Extraer tiempos y supervivencias
      tiempos <- fit_km$time
      supervivencia <- fit_km$surv
      
      # Usar rmst_max_t como límite superior del grupo actual
      rmst_max_t <- max(df_filtrado$DiferenciaDias, na.rm=TRUE)
      # rmst_max_t <- fila$PlazoAgrupado
      
      tiempos_trunc <- pmin(tiempos, rmst_max_t)    # Truncar tiempos al límite máximo
      diffs <- diff(c(0, tiempos_trunc))           # Diferencias de tiempo
      sum(diffs * supervivencia)                   # RMST: área bajo la curva truncada
      
    }, error = function(e) {
      message(sprintf("Iteración %d error en RMST (%s), se usará promedio ponderado", i, e$message))
      
      # Fallback: promedio ponderado, con control de casos extremos
      capital_total <- sum(df_filtrado$Capital, na.rm = TRUE)
      if (capital_total > 0) {
        sum(df_filtrado$Capital * df_filtrado$DiferenciaDias, na.rm = TRUE) / capital_total
      } else {
        NA_real_ # caso extremo
      }
    })
    
    ventanas_df$rmst[i] <- rmst_valor
    
    if (!is.null(fit_km)) {
      # Guardar la curva original en data.frame
      curva_df <- data.frame(
        id = i,
        Moneda = fila$Moneda,
        Flag = fila$Flag,
        PlazoAgrupado = fila$PlazoAgrupado,
        ventana_meses = fila$ventana_meses,
        fecha_inicio = fila$fecha_inicio,
        time = fit_km$time,
        surv = fit_km$surv,
        lower = fit_km$lower,
        upper = fit_km$upper
      )
      
      # COMPLETAR CURVA DESDE t = 0 HASTA t_max
      t_max <- max(curva_df$time, na.rm = TRUE)
      df_tiempo <- data.frame(time = 0:t_max)
      
      curva_completa <- df_tiempo %>%
        left_join(curva_df, by = "time") %>%
        arrange(time)
      
      # Asegurar que t = 0 tenga surv = 1 si no estaba definido
      if (is.na(curva_completa$surv[1])) {
        curva_completa$surv[1] <- 1
        curva_completa$lower[1] <- 1
        curva_completa$upper[1] <- 1
      }
      
      # Llenar hacia abajo los valores de supervivencia para días sin eventos
      curva_completa <- curva_completa %>%
        tidyr::fill(surv, lower, upper, .direction = "down")
      
      # Rellenar columnas de identificación que faltan
      curva_completa$id <- i
      curva_completa$Moneda <- fila$Moneda
      curva_completa$Flag <- fila$Flag
      curva_completa$PlazoAgrupado <- fila$PlazoAgrupado
      curva_completa$ventana_meses <- fila$ventana_meses
      curva_completa$fecha_inicio <- fila$fecha_inicio
      
      # Agregar al listado total
      curvas_km[[length(curvas_km) + 1]] <- curva_completa
    }
     
  }
}

# -----------------------------
# EXPORTAR RESULTADOS
# -----------------------------
write.csv(ventanas_df, "3.Resultados/rmst_km_final.csv", row.names = FALSE)

# Unir todas las curvas en un solo data.frame
curvas_km_df <- dplyr::bind_rows(curvas_km)

# Exportar a CSV
write.csv(curvas_km_df, "3.Resultados/curvas_kaplan_meier.csv", row.names = FALSE)

# Filtrar solo los tiempos múltiplos de 30, incluyendo el día 0
curvas_km_mensual <- curvas_km_df %>%
  filter(time %% 30 == 0)

# Agrupar por cada curva identificada por estos campos
curvas_km_mensual <- curvas_km_mensual %>%
  group_by(id, Moneda, Flag, PlazoAgrupado, ventana_meses, fecha_inicio) %>%
  mutate(
    surv = if_else(time == max(time), 0, surv),         # Asignar 0 al último tiempo
    lower = if_else(time == max(time), 0, lower),       # Ajustar también los intervalos
    upper = if_else(time == max(time), 0, upper)
  ) %>%
  ungroup()

curvas_km_mensual <- curvas_km_mensual %>%
  arrange(id, time) %>%
  group_by(id, Moneda, Flag, PlazoAgrupado, ventana_meses, fecha_inicio) %>%
  mutate(
    surv_lag = lag(surv),
    delta_surv = if_else(
      is.na(surv_lag) | surv_lag == 0, NA_real_, 1 - (surv / surv_lag)
    )
  ) %>%
  select(-surv_lag) %>%  # eliminar columna temporal
  ungroup()

# Filtrar solo los tiempos mayores a 0
# curvas_km_mensual <- curvas_km_mensual %>%
#   filter(time > 0)


# Guardar el nuevo resultado con delta calculado
write.csv(curvas_km_mensual, "3.Resultados/curvas_kaplan_meier_mensual_final_con_delta.csv", row.names = FALSE)
