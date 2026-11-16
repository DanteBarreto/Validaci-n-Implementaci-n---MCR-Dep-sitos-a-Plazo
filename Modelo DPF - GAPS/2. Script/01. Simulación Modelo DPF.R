library(TTR)
library(RODBC)
library(readxl)
library(sqldf)
library(stringr)
library(dplyr)


rm(list = ls()) # elemina todos los objetos previo al inicio del proceso
ruta <- dirname(rstudioapi::getActiveDocumentContext()$path) # Identifica la ruta/carpeta donde se ha guardado el presente archivo de R
setwd(ruta) # Fija la ruta del paso previo como el directorio de trabajo

############################### Funciones ###################################################


get_gap_ger <- function(plazo) {
  if (plazo <= 30) {
    "01_1M"
  } else if (plazo <= 60) {
    "02_2M"
  } else if (plazo <= 90) {
    "03_3M"
  } else if (plazo <= 120) {
    "04_4M"
  } else if (plazo <= 150) {
    "05_5M"
  } else if (plazo <= 180) {
    "06_6M"
  } else if (plazo <= 210) {
    "07_7M"
  } else if (plazo <= 240) {
    "08_8M"
  } else if (plazo <= 270) {
    "09_9M"
  } else if (plazo <= 300) {
    "10_10M"
  } else if (plazo <= 330) {
    "11_11M"
  } else if (plazo <= 360) {
    "12_12M"
  } else if (plazo <= 720) {
    "13_2A"
  } else if (plazo <= 1080) {
    "14_3A"
  } else if (plazo <= 1440) {
    "15_4A"
  } else if (plazo <= 1800) {
    "16_5A"
  } else if (plazo <= 2160) {
    "17_6A"
  } else if (plazo <= 2520) {
    "18_7A"
  } else if (plazo <= 2880) {
    "19_8A"
  } else if (plazo <= 3240) {
    "20_9A"
  } else if (plazo <= 3600) {
    "21_10A"
  } else if (plazo <= 3960) {
    "22_11A"
  } else if (plazo <= 4320) {
    "23_12A"
  } else if (plazo <= 4680) {
    "24_13A"
  } else if (plazo <= 5040) {
    "25_14A"
  } else if (plazo <= 5400) {
    "26_15A"
  } else if (plazo <= 5760) {
    "27_16A"
  } else if (plazo <= 6120) {
    "28_17A"
  } else if (plazo <= 6480) {
    "29_18A"
  } else if (plazo <= 6840) {
    "30_19A"
  } else if (plazo <= 7200) {
    "31_20A"
  } else {
    "32_>20A"
  }
}




get_gap_ax7 <- function(plazo) {
  if (plazo <= 7) {
    "01_1-7d"
  } else if (plazo <= 15) {
    "02_8-15d"
  } else if (plazo <= 30) {
    "03_16d-1M"
  } else if (plazo <= 60) {
    "04_2M"
  } else if (plazo <= 90) {
    "05_3M"
  } else if (plazo <= 180) {
    "06_4-6M"
  } else if (plazo <= 360) {
    "07_7M-1A"
  } else if (plazo <= 720) {
    "08_2A"
  } else if (plazo <= 1080) {
    "09_3A"
  } else if (plazo <= 1440) {
    "10_4A"
  } else if (plazo <= 1800) {
    "11_5A"
  } else if (plazo <= 3600) {
    "12_6-10A"
  } else if (plazo <= 7200) {
    "13_11-20A"
  } else {
    "14_+20A"
  }
}



get_gap_reprecio <- function(plazo) {
  if (plazo <= 30) {
    "01_1M"
  } else if (plazo <= 60) {
    "02_2M"
  } else if (plazo <= 90) {
    "03_3M"
  } else if (plazo <= 180) {
    "04_4-6M"
  } else if (plazo <= 360) {
    "05_7M-1A"
  } else if (plazo <= 720) {
    "06_2A"
  } else if (plazo <= 1080) {
    "07_3A"
  } else if (plazo <= 1440) {
    "08_4A"
  } else if (plazo <= 1800) {
    "09_5A"
  } else if (plazo <= 3600) {
    "10_6-10A"
  } else if (plazo <= 7200) {
    "11_11-20A"
  } else {
    "12_+20A"
  }
}




get_gap_ce <- function(plazo) {
  if (plazo <= 30) {
    "1M"
  } else if (plazo <= 60) {
    "2M"
  } else if (plazo <= 90) {
    "3M"
  } else if (plazo <= 120) {
    "4M"
  } else if (plazo <= 150) {
    "5M"
  } else if (plazo <= 180) {
    "6M"
  } else if (plazo <= 210) {
    "7M"
  } else if (plazo <= 240) {
    "8M"
  } else if (plazo <= 270) {
    "9M"
  } else if (plazo <= 300) {
    "10M"
  } else if (plazo <= 330) {
    "11M"
  } else if (plazo <= 360) {
    "12M"
  } else if (plazo <= 720) {
    "2A"
  } else if (plazo <= 1080) {
    "3A"
  } else if (plazo <= 1440) {
    "4A"
  } else if (plazo <= 1800) {
    "5A"
  } else if (plazo <= 2160) {
    "6A"
  } else if (plazo <= 2520) {
    "7A"
  } else if (plazo <= 2880) {
    "8A"
  } else if (plazo <= 3240) {
    "9A"
  } else if (plazo <= 3600) {
    "10A"
  } else if (plazo <= 3960) {
    "11A"
  } else if (plazo <= 4320) {
    "12A"
  } else if (plazo <= 4680) {
    "13A"
  } else if (plazo <= 5040) {
    "14A"
  } else if (plazo <= 5400) {
    "15A"
  } else if (plazo <= 5760) {
    "16A"
  } else if (plazo <= 6120) {
    "17A"
  } else if (plazo <= 6480) {
    "18A"
  } else if (plazo <= 6840) {
    "19A"
  } else if (plazo <= 7200) {
    "20A"
  } else if (plazo <= 9000) {
    "21-25A"
  } else if (plazo <= 10800) {
    "26-30A"
  } else if (plazo <= 12600) {
    "31-35A"
  } else if (plazo <= 14400) {
    "36-40A"
  } else if (plazo <= 18000) {
    "41-50A"
  } else {
    ">50A"
  }
}

#############################################################################################


########### Parametrizaciones ############################################################## 
##### Colocamos el nombre del archivo csv que contiene todos los créditos con sus carácterísticas
Parametros <- read.csv(paste0(ruta,"/Data_Parametros.csv"))
Nombre_Archivo_Base <- Parametros[Parametros$Descripcion == "Nombre_Archivo_Base",2]

##### Por memoria, el archivo previo se dividirá en pequeños archivos en Disco Duro. Aquí especificamos el numero maximo de registros que tendrá cada archivo subdividido
Rangos_Division_Archivos = as.numeric(Parametros[Parametros$Descripcion == "Rangos_Division_Archivos",2])

Version_script = "Herramienta de Simulaci?n de DPF Setiembre_2025. Versi?n 1.0" #### Versi?n del script. Actualizar cuando se produzcan cambios en el c?digo

############################################################################################


#### Generando una tabla para el registro de los tiempos
Tiempos <- data.frame(
  "Detalle" = c("Inicio"), 
  "Fecha" = c(""), 
  "Hora" = c(""),
  "Progreso_Archivos" = c(""))
Tiempos[1,2] <- as.character(Sys.Date())
Tiempos[1,3] <- as.character(format(Sys.time(), "%X"))
##############################################################################################


### Carga de bases iniciales #################################################################
DPF_Total <- read.csv(paste0(ruta,"/",Nombre_Archivo_Base,".csv"), fileEncoding = "latin1", header = TRUE)
Curvas_DPF <- read_excel(paste0(paste0(ruta,"/CURVAS.xlsx")),sheet = "CURVAS")
##############################################################################################

#### El valor de la fecha de la data puede variar de formato de un equipo a otro, por ello se están considerando dos casuísticas
if (str_detect(DPF_Total[1,1],pattern = "/")) {
  DPF_Total$FECHA_PROCESO <- as.Date(DPF_Total$FECHA_PROCESO, format = '%d/%m/%Y')
  DPF_Total$FECHA_APT <- as.Date(DPF_Total$FECHA_APT, format = '%d/%m/%Y')
  DPF_Total$FECHA_VTO <- as.Date(DPF_Total$FECHA_VTO, format = '%d/%m/%Y')
}

if (str_detect(DPF_Total[1,1],pattern = "-")) {
  DPF_Total$FECHA_PROCESO <- as.Date(DPF_Total$FECHA_PROCESO, format = '%Y-%m-%d')
  DPF_Total$FECHA_APT <- as.Date(DPF_Total$FECHA_APT, format = '%Y-%m-%d')
  DPF_Total$FECHA_VTO <- as.Date(DPF_Total$FECHA_VTO, format = '%Y-%m-%d')
}

##############################################################################################

#### Se crean carpetas donde se copiarán los archivos. En caso de existir se eliminan y se vuelven a crear
if (!dir.exists("Archivos")) {
  dir.create("Archivos")  
} else {
  unlink("Archivos", recursive = TRUE)
  dir.create("Archivos")
}


if (!dir.exists("Resultados")) {
  dir.create("Resultados")  
} else {
  unlink("Resultados", recursive = TRUE)
  dir.create("Resultados")
}
##############################################################################################

#### Dividiendo la base EGP_Total en archivos pequeños

Rangos_Archivos <- Rangos_Division_Archivos ##### Se utiliza el numero maximo de registros que tendrá cada archivo subdividido. Esta variable se parametriza al inicio. 
Total_Registros <- nrow(DPF_Total)
Numero_Rangos <- ceiling(Total_Registros / Rangos_Archivos) # Redondear hacia arriba el número de rangos para la creación del número de archivos
Listado_Archivos <- c()

for (i in 1:Numero_Rangos) {
  
  Rango_Desde <- ((Rangos_Archivos * (i - 1)) + 1)
  Rango_Hasta <- min(Rangos_Archivos * i,Total_Registros)
  Archivo_Rango <- DPF_Total[Rango_Desde : Rango_Hasta,]
  write.csv(Archivo_Rango,paste0(ruta,"/Archivos/",Nombre_Archivo_Base,"_",i,".csv"),row.names = FALSE)
  Listado_Archivos[i] <- paste0(Nombre_Archivo_Base,"_",i,".csv")
}

##############################################################################################

#### En esta parte se empieza a procesar cada operaci?n

Contador_Tiempos <- 0

for (i_archivo in 1:length(Listado_Archivos)) { # Se va recorriendo cada archivo subdividido
  
  Contador_Tiempos <- Contador_Tiempos + 1
  
  DPF_Archivo <- read.csv(paste0(ruta,"/Archivos/",Listado_Archivos[i_archivo]))
  Columnas_Adicionales <-matrix(NA,nrow = nrow(DPF_Archivo),10)
  colnames(Columnas_Adicionales) <- c("Nodo_Curva","Desgaste","Banda_Mes","Capital","Intereses","Flujo","Banda_GAP_GER","Banda_GAP_AX7","Banda_GAP_REPRECIO","Banda_GAP_CE")
  DPF_Archivo <- cbind(DPF_Archivo,Columnas_Adicionales) 
  
  DPF_Archivo$Nodo_Curva <- as.numeric(DPF_Archivo$Nodo_Curva) 
  DPF_Archivo$Desgaste <- as.numeric(DPF_Archivo$Desgaste) 
  DPF_Archivo$Banda_Mes <- as.numeric(DPF_Archivo$Banda_Mes) 
  DPF_Archivo$Capital <- as.numeric(DPF_Archivo$Capital) 
  DPF_Archivo$Intereses <- as.numeric(DPF_Archivo$Intereses) 
  
  DPF_Archivo_Consolidado <- DPF_Archivo[0,]
  
  for (i_registro in 1:nrow(DPF_Archivo)) { 
    
    DPF_Archivo_Registro <- DPF_Archivo[i_registro,]
    DPF_Archivo_Registro_Acumulado <- DPF_Archivo_Registro
    
    Curva_Nombre <- DPF_Archivo_Registro$CURVA[1]
    
    if (Curva_Nombre != "CONTRACTUAL") {
      
      Cantidad_Meses_Apertura <- ceiling((as.numeric(as.Date(DPF_Archivo_Registro$FECHA_VTO[1])) - as.numeric(as.Date(DPF_Archivo_Registro$FECHA_APT[1])))/30)
      Cantidad_Meses_Remanentes <- max(min(ceiling((as.numeric(as.Date(DPF_Archivo_Registro$FECHA_VTO[1])) - as.numeric(as.Date(DPF_Archivo_Registro$FECHA_PROCESO[1])))/30),Cantidad_Meses_Apertura),1)
      
      Cantidad_Meses_Transcurridos <- Cantidad_Meses_Apertura - Cantidad_Meses_Remanentes
      Curva_Nombre <- DPF_Archivo_Registro$CURVA[1]
      
      # Curva de desgaste
      
      Curva_DPF_Registro <- Curvas_DPF[Curvas_DPF$Moneda == DPF_Archivo_Registro$MONEDA & Curvas_DPF$Curva == DPF_Archivo_Registro$CURVA & Curvas_DPF$Meses == Cantidad_Meses_Apertura,]
      Curva_DPF_Registro <- data.frame(Curva_DPF_Registro[5:(Cantidad_Meses_Apertura + 4)])
      
      # Repetir filas según cantidad de meses
      
      if (Cantidad_Meses_Remanentes >= 2 & Curva_Nombre != "CONTRACTUAL") {
        for (i_registro_banda in 2:Cantidad_Meses_Remanentes) { 
          DPF_Archivo_Registro_Acumulado <- rbind(DPF_Archivo_Registro_Acumulado,DPF_Archivo_Registro[1,])
        }
      }
      
      Desgaste_Acumulado <- 0
      for (i_registro_banda in 1:Cantidad_Meses_Remanentes) { ## Completando Datos
        
        # Curva de desgaste
        DPF_Archivo_Registro_Acumulado$Nodo_Curva[i_registro_banda] <- Cantidad_Meses_Transcurridos + i_registro_banda
        DPF_Archivo_Registro_Acumulado$Desgaste[i_registro_banda] <- Curva_DPF_Registro[1,DPF_Archivo_Registro_Acumulado$Nodo_Curva[i_registro_banda]]
        
        # Bandas
        DPF_Archivo_Registro_Acumulado$Banda_Mes[i_registro_banda] <- i_registro_banda
        DPF_Archivo_Registro_Acumulado$Banda_GAP_GER[i_registro_banda] <- get_gap_ger(DPF_Archivo_Registro_Acumulado$Banda_Mes[i_registro_banda]*30)
        
        if (DPF_Archivo_Registro_Acumulado$Banda_Mes[i_registro_banda]*30 == 30) {
          DPF_Archivo_Registro_Acumulado$Banda_GAP_AX7[i_registro_banda]  <- get_gap_ax7(as.numeric(format(as.Date(DPF_Archivo_Registro_Acumulado$FECHA_VTO[i_registro_banda]),"%d")))
        }else{
          DPF_Archivo_Registro_Acumulado$Banda_GAP_AX7[i_registro_banda] <- get_gap_ax7(DPF_Archivo_Registro_Acumulado$Banda_Mes[i_registro_banda]*30)
        }
        
        DPF_Archivo_Registro_Acumulado$Banda_GAP_REPRECIO[i_registro_banda] <- get_gap_reprecio(DPF_Archivo_Registro_Acumulado$Banda_Mes[i_registro_banda]*30)
        DPF_Archivo_Registro_Acumulado$Banda_GAP_CE[i_registro_banda] <- get_gap_ce(DPF_Archivo_Registro_Acumulado$Banda_Mes[i_registro_banda]*30)
        
        
        # Campo Capital
        Saldo_Cierre <- as.numeric(DPF_Archivo_Registro_Acumulado$MONTO[i_registro_banda])
        
        if (i_registro_banda == 1) {
          DPF_Archivo_Registro_Acumulado$Capital[i_registro_banda] <- round(as.numeric(DPF_Archivo_Registro_Acumulado$Desgaste[i_registro_banda]) * (as.numeric(Saldo_Cierre) - as.numeric(Desgaste_Acumulado)),2)
          Desgaste_Acumulado <- Desgaste_Acumulado + DPF_Archivo_Registro_Acumulado$Capital[i_registro_banda]
        }else{
          DPF_Archivo_Registro_Acumulado$Capital[i_registro_banda] <- round(as.numeric(DPF_Archivo_Registro_Acumulado$Desgaste[i_registro_banda]) * (as.numeric(Saldo_Cierre) - as.numeric(Desgaste_Acumulado)),2)
          Desgaste_Acumulado <- Desgaste_Acumulado + DPF_Archivo_Registro_Acumulado$Capital[i_registro_banda]
        }
        
        # Campo interés
        
        if (i_registro_banda == Cantidad_Meses_Remanentes) {
          DPF_Archivo_Registro_Acumulado$Intereses[i_registro_banda] <- round(DPF_Archivo_Registro_Acumulado$Capital[i_registro_banda] * ((1+DPF_Archivo_Registro_Acumulado$TEA[i_registro_banda])^(DPF_Archivo_Registro_Acumulado$PLAZO[i_registro_banda]/360)-1),2)
        }else{
          DPF_Archivo_Registro_Acumulado$Intereses[i_registro_banda] <- 0
        }
        
        # Campo Flujo
        
        DPF_Archivo_Registro_Acumulado$Flujo[i_registro_banda] <- DPF_Archivo_Registro_Acumulado$Capital[i_registro_banda] + DPF_Archivo_Registro_Acumulado$Intereses[i_registro_banda]
        
        # Colocando saldos de data original en una sola fila, la última
        
        if (i_registro_banda == Cantidad_Meses_Remanentes) {
          DPF_Archivo_Registro_Acumulado$INTERES_DEVENGADO[i_registro_banda] <- round(DPF_Archivo_Registro_Acumulado$INTERES_DEVENGADO[i_registro_banda],2)
          DPF_Archivo_Registro_Acumulado$INTERES_VENCIMIENTO[i_registro_banda] <- round(DPF_Archivo_Registro_Acumulado$INTERES_VENCIMIENTO[i_registro_banda],2)
          DPF_Archivo_Registro_Acumulado$INTERES_ANUAL[i_registro_banda] <- round(DPF_Archivo_Registro_Acumulado$INTERES_ANUAL[i_registro_banda],2)
          DPF_Archivo_Registro_Acumulado$PAGO_TOTAL[i_registro_banda] <- round(DPF_Archivo_Registro_Acumulado$PAGO_TOTAL[i_registro_banda],2)
        }else{
          DPF_Archivo_Registro_Acumulado$INTERES_DEVENGADO[i_registro_banda]  <- 0
          DPF_Archivo_Registro_Acumulado$INTERES_VENCIMIENTO[i_registro_banda]  <- 0
          DPF_Archivo_Registro_Acumulado$INTERES_ANUAL[i_registro_banda]  <- 0
          DPF_Archivo_Registro_Acumulado$PAGO_TOTAL[i_registro_banda]  <- 0
        }
        
      }
    } else{
      
      DPF_Archivo_Registro_Acumulado$Capital[1] <- DPF_Archivo_Registro_Acumulado$MONTO[1]
      DPF_Archivo_Registro_Acumulado$Intereses[1] <- DPF_Archivo_Registro_Acumulado$INTERES_VENCIMIENTO[1]
      DPF_Archivo_Registro_Acumulado$Flujo[1] <- DPF_Archivo_Registro_Acumulado$PAGO_TOTAL[1]
      DPF_Archivo_Registro_Acumulado$Banda_GAP_GER[1] <- DPF_Archivo_Registro_Acumulado$GAP_GER[1]
      DPF_Archivo_Registro_Acumulado$Banda_GAP_AX7[1] <- DPF_Archivo_Registro_Acumulado$GAP_AX7[1]
      DPF_Archivo_Registro_Acumulado$Banda_GAP_REPRECIO[1] <- DPF_Archivo_Registro_Acumulado$GAP_REPRECIO[1]
      DPF_Archivo_Registro_Acumulado$Banda_GAP_CE[1] <- DPF_Archivo_Registro_Acumulado$GAP_CE[1]
    }
    
    DPF_Archivo_Consolidado <- rbind(DPF_Archivo_Consolidado,DPF_Archivo_Registro_Acumulado)
  } 
  
  write.csv(DPF_Archivo_Consolidado,paste0(ruta,"/Resultados/Resultados_",Listado_Archivos[i_archivo]),fileEncoding = "latin1",row.names = FALSE)
  
  if (i_archivo == 1) {
    Reporte_Hoja1 <- sqldf("select CAT_PLANCON,	TIPO_PASIVO, MONEDA, Banda_GAP_AX7 as GAP_AX7, Banda_GAP_REPRECIO as GAP_REPRECIO, 
    Banda_GAP_CE as GAP_CE, Banda_GAP_GER as GAP_GER, sum(Capital) as MONTO, sum(INTERES_DEVENGADO) as INTERES_DEVENGADO, 
    sum(Intereses) as INTERES_VENCIMIENTO, sum(Flujo) as PAGO_TOTAL, sum(INTERES_ANUAL) as INTERES_ANUAL,MARCAORIGEN_C as MARCAORIGEN, MARCA_CONTA
    from DPF_Archivo_Consolidado group by CAT_PLANCON,	TIPO_PASIVO , MONEDA, Banda_GAP_AX7 , Banda_GAP_REPRECIO , 
    Banda_GAP_CE , Banda_GAP_GER, MARCAORIGEN_C, MARCA_CONTA")
    
    Reporte_Hoja1_Consolidado <- Reporte_Hoja1 
    
  }else{
    Reporte_Hoja1 <- sqldf("select CAT_PLANCON,	TIPO_PASIVO, MONEDA, Banda_GAP_AX7 as GAP_AX7, Banda_GAP_REPRECIO as GAP_REPRECIO, 
    Banda_GAP_CE as GAP_CE, Banda_GAP_GER as GAP_GER, sum(Capital) as MONTO, sum(INTERES_DEVENGADO) as INTERES_DEVENGADO, 
    sum(Intereses) as INTERES_VENCIMIENTO, sum(Flujo) as PAGO_TOTAL, sum(INTERES_ANUAL) as INTERES_ANUAL,MARCAORIGEN_C as MARCAORIGEN, MARCA_CONTA
    from DPF_Archivo_Consolidado group by CAT_PLANCON,	TIPO_PASIVO , MONEDA, Banda_GAP_AX7 , Banda_GAP_REPRECIO , 
    Banda_GAP_CE , Banda_GAP_GER, MARCAORIGEN_C, MARCA_CONTA")
    
    Reporte_Hoja1_Consolidado <- rbind(Reporte_Hoja1_Consolidado,Reporte_Hoja1) 
  }
  
  ### Registro de Tiempos en Log
  
  Tiempos[Contador_Tiempos + 1,1] <- Listado_Archivos[i_archivo]
  Tiempos[Contador_Tiempos + 1,2] <- as.character(Sys.Date())
  Tiempos[Contador_Tiempos + 1,3] <- as.character(format(Sys.time(), "%X"))
  Tiempos[Contador_Tiempos + 1,4] <- paste0(i_archivo,"/",length(Listado_Archivos),": ",round((i_archivo/length(Listado_Archivos)) * 100,digits = 2),"%")
  
  write.table(Tiempos,paste0(ruta,"/Output_R02_Log_Tiempos.txt"),row.names = FALSE, sep = ";")
  
}

Reporte_Hoja1_Final <- sqldf("select CAT_PLANCON,	TIPO_PASIVO, MONEDA, GAP_AX7, GAP_REPRECIO, 
GAP_CE, GAP_GER, sum(MONTO) as MONTO, sum(INTERES_DEVENGADO) as INTERES_DEVENGADO, 
sum(INTERES_VENCIMIENTO) as INTERES_VENCIMIENTO, sum(PAGO_TOTAL) as PAGO_TOTAL, sum(INTERES_ANUAL) as INTERES_ANUAL, MARCAORIGEN, MARCA_CONTA
from Reporte_Hoja1_Consolidado group by CAT_PLANCON, TIPO_PASIVO, MONEDA, GAP_AX7, GAP_REPRECIO, 
GAP_CE, GAP_GER, MARCAORIGEN, MARCA_CONTA")

write.csv(Reporte_Hoja1_Final,paste0(ruta,"/Output_R01_Reporte_",Nombre_Archivo_Base,".csv"),fileEncoding = "latin1",row.names = FALSE)

### Registro de tiempo final en Log
Tiempos[Contador_Tiempos + 2,1] <- "Fin"
Tiempos[Contador_Tiempos + 2,2] <- as.character(Sys.Date())
Tiempos[Contador_Tiempos + 2,3] <- as.character(format(Sys.time(), "%X"))
Tiempos[Contador_Tiempos + 2,4] <- ""

### Registro de versi?n de Script en Log 
Tiempos[Contador_Tiempos + 3,1] <- Version_script
Tiempos[Contador_Tiempos + 3,2] <- ""
Tiempos[Contador_Tiempos + 3,3] <- ""
Tiempos[Contador_Tiempos + 3,4] <- ""


### Guardar Log
write.table(Tiempos,paste0(ruta,"/Output_R02_Log_Tiempos.txt"),row.names = FALSE, sep = ";")

