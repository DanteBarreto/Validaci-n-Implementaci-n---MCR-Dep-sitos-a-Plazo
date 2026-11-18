# Resumen de la grabación – Proceso operativo DPF-GAPS

| Campo | Detalle |
|---|---|
| Reunión | *Flujo de Generación DPF-20261022_113213* (Teams), 22/10/2026, 28 min 45 s |
| Participantes | Wilmer Fernando Gastelu Zapata (ejecutor y expositor), Dante Barreto (validador) |
| Fuente analizada | Transcripción automática de Teams (`Grabaciones - GAPS/Flujo de Generación DPF - GAPS.docx`) y cuadros del video extraídos localmente |
| Limitación | El MP4 del repositorio está truncado: sólo se decodifican ≈65 s de 1.725 s. Los cuadros extraídos son de los minutos 0:05 (SharePoint *Model Risk › Implementación DPF - CE x ALM*) y 1:00 (carpeta *Macros ALM* en el servidor de archivos, con la carpeta *Macro DPF Prueba* creada a las 11:33). El tramo 0:06–8:46 es una sola intervención y no tiene marcas intermedias. |
| Módulo Asignado | **No tiene grabación.** Su proceso operativo sólo puede evaluarse con el manual V.0 y el SP, por lo que no hay evidencia del ejecutor real, del ambiente, de la periodicidad efectiva ni de las validaciones de resultados. |

## Síntesis

El ejecutor muestra una corrida de prueba del cierre de septiembre 2026: crea una carpeta, copia la macro del mes anterior y cambia la fecha. Luego ejecuta los botones 1 a 4 y, como el script R tarda ≈27 min, abre la corrida oficial de septiembre para mostrar los resultados y el log. Después muestra la carga del resultado a la Macro ALM. También explica cómo se completan los nodos de las curvas (se repite la curva del nodo posterior, sin interpolar) y la lógica de desgaste mensual. Informa que la macro y el R fueron desarrollados por el área, que el corporativo sólo entregó las curvas y orientó su aplicación, y que sólo existe un manual operativo.

## Pasos, ejecutores, fuentes, transformaciones manuales y controles

| Paso | Minuto (transcripción) | Actividad mostrada / descrita | Quién ejecuta | Fuente de datos | Transformación manual | Control mostrado o mencionado | Diferencia con documentación |
|---|---|---|---|---|---|---|---|
| R-01 | 0:04–0:06 (imagen 0:05) | Presentación de carpeta compartida (SharePoint 'Model Risk › Implementación DPF - CE x ALM': carpeta 'Macro DPF' y manual v2) y del manual operativo. | W. F. Gastelu (presenta) | — | — | — | Consistente. |
| R-02 | 0:06–8:46 (bloque sin marcas intermedias; imagen 1:00) | Se crea una carpeta de trabajo nueva ('Macro DPF Prueba' en …\01 - Reportes y Monitoreo\Mensual\2026\Setiembre\Macros ALM), se copia la macro del mes anterior (agosto) y se cambia la fecha. | W. F. Gastelu | Macro del mes previo | Copia manual de archivo y cambio manual de fecha | — | Consistente con Pasos 1-2 del manual. La ejecución mostrada es de prueba (carpeta 'Prueba'). |
| R-03 | 0:06–8:46 | Botón 1 'Importar': copia el script R desde el repositorio; se indica que no se modifica desde agosto 2025 'como un control para evitar que se modifique'. | W. F. Gastelu | Ruta repositorio R | Copia | Script en ruta de respaldo no modificado (declarado, sin evidencia de permisos) | Consistente con Paso 3. |
| R-04 | 0:06–8:46 | Botón 2 'Importar base a hoja Data': trae la data de DPF generada por 'un proceso, con un job'. El ejecutor elimina manualmente las filas posteriores a la última fila porque 'a veces… se bloquea, manda un error'. | W. F. Gastelu | Base DPF (job diario) | Eliminación manual de filas | — | Paso no documentado (INC-04). |
| R-05 | 0:06–8:46 | Botón 3 'Completar hojas Data y Curvas': marcas origen (insumo para Macro ALM) y generación de CURVAS para todos los plazos a partir de nodos remitidos ('Brandon'). Avance mostrado con contador (%). | W. F. Gastelu | Curvas GAP Modelo; Aux; Calculadora | — | Contador de avance | Consistente con Paso 5. |
| R-06 | 9:06–10:09 | Se advierte que las rutas de la macro son internas y fallarán fuera de la red; el archivo original 'tiene datos' sensibles, por lo que no se entrega íntegro. | W. F. Gastelu / D. Barreto | — | — | — | Limitación para réplica. |
| R-07 | 10:09–14:37 | Botón 4 genera los CSV/Excel para R (curvas, data, parámetros); ejecución del script R (≈27 min en la corrida oficial de septiembre); botón 5 'Verificar generación R' importa tiempos de inicio/fin; botón 6 'Exportar resultados' genera Data_Macro_ALM_DPF y lo copia a la carpeta de trabajo y a bases diarias. | W. F. Gastelu | Archivos generados | — | Log de tiempos (Output_R02) y tabla de estado | Consistente con Pasos 6-9. Log del repositorio: 27 min 44 s. |
| R-08 | 14:43–17:58 | Macro ALM del mes: botón 2 'Copia y pegando bases' importa el resultado DPF a la hoja DPF, que alimenta (por fórmulas) las hojas de GAPS. Se menciona que la estructura proviene de la de prepago. | W. F. Gastelu | Data_Macro_ALM_DPF | Copia/pega por macro | — | Consistente con Paso 10. Macro ALM no incluida en el repositorio. |
| R-09 | 18:05–21:21 | Explicación de la hoja Calculadora y de las curvas: nodos remitidos (p. ej. 390 y 540 días); los nodos intermedios toman 'la misma curva del nodo posterior' ('no hacemos una interpolación'); sin curva el proceso 'bota error'. | W. F. Gastelu | Curvas GAP Modelo | — | — | Sólo se menciona el relleno con nodo posterior; el manual y el código incluyen además el relleno hacia nodos superiores (INC-19). |
| R-10 | 21:21–22:57 | Metodología de desgaste: porción que se retira cada mes sobre el saldo remanente; lo que queda va al vencimiento; lógica coordinada con el corporativo. | W. F. Gastelu | — | — | — | Consistente con §4 del manual. |
| R-11 | 23:04–23:58 | La macro y el código R fueron desarrollados por el equipo del área; el corporativo (Riesgo de Mercado BCP) entregó las curvas y orientó su aplicación. | W. F. Gastelu / D. Barreto | — | — | — | Responsabilidad de desarrollo no consignada en el manual. |
| R-12 | 24:43–26:08 | Sólo existe manual operativo (no manual de implementación); los supuestos están en la sección 4 y el código R está comentado. | W. F. Gastelu | — | — | — | Relevante para DOC-03 a DOC-12. |
| R-13 | 26:35–28:27 | Problemas de descarga de archivos desde SharePoint (archivos con error); se propone reenviar comprimido. | W. F. Gastelu / D. Barreto | — | — | — | Consistente con el MP4 truncado del repositorio (INC-15). |

## Diferencias con la documentación

1. El **borrado manual de filas** en la hoja Data (bloque 0:06–8:46) no está en el manual.
2. El relleno de curvas se explica sólo con el nodo posterior (19:42–21:13). El manual y el código incluyen además un segundo proceso hacia nodos superiores.
3. La ejecución oficial fue el 02/10/2026 (log). El manual fija el último día calendario del mes.
4. Según la grabación, la macro y el R los desarrolló el área (23:28). El manual no consigna roles de desarrollo ni de conformidad.
5. No se mostró ningún control de calidad de datos de entrada. El cuadre de monto de la hoja Parámetros (H20:H22) existe en la macro, pero no se mencionó.
