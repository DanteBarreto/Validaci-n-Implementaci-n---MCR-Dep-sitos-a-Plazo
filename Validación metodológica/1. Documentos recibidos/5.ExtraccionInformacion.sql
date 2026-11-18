-- Versión 1
-- Control de cambios
USE mb_dpf;
GO

-- Filtro Control 6. Eliminar registros luego de su fecha de cierre
DELETE FROM
	mb_dpf.dbo.mb_dpf_mod
WHERE 
	FECHAPROCESO > FECHAVENCIMIENTO
	AND FECHAVENCIMIENTO IS NOT NULL
	AND CAPITAL > 0;
GO

-- Filtro Control 9. Unicidad de fecha de vencimiento 
DELETE m
FROM mb_dpf.dbo.mb_dpf_mod m
JOIN (
    SELECT CUENTA, FECHAAPERTURA
    FROM mb_dpf.dbo.mb_dpf_mod
    GROUP BY CUENTA, FECHAAPERTURA
	HAVING COUNT(DISTINCT FECHAVENCIMIENTO) > 1
) t ON m.CUENTA = t.CUENTA AND m.FECHAAPERTURA = t.FECHAAPERTURA;
GO

-- Filtro Control 11. Unicidad de plazo
DELETE m
FROM mb_dpf.dbo.mb_dpf_mod m
JOIN (
    SELECT CUENTA, FECHAAPERTURA
    FROM mb_dpf.dbo.mb_dpf_mod
    GROUP BY CUENTA, FECHAAPERTURA
    HAVING COUNT(DISTINCT PLAZO) > 1
) t ON m.CUENTA = t.CUENTA AND m.FECHAAPERTURA = t.FECHAAPERTURA;
GO

-- Filtro Control 12. Unicidad CODIGO_PRODUCTO
DELETE m
FROM mb_dpf.dbo.mb_dpf_mod m
JOIN (
    SELECT CUENTA, FECHAAPERTURA
    FROM mb_dpf.dbo.mb_dpf_mod
    GROUP BY CUENTA, FECHAAPERTURA
    HAVING COUNT(DISTINCT CODIGO_PRODUCTO) > 1
) t ON m.CUENTA = t.CUENTA AND m.FECHAAPERTURA = t.FECHAAPERTURA;
GO

-- Filtro Control 16. Unicidad de Tasa de Interes
DELETE m
FROM mb_dpf.dbo.mb_dpf_mod m
JOIN (
    SELECT CUENTA, FECHAAPERTURA
    FROM mb_dpf.dbo.mb_dpf_mod
	WHERE DESCRIPCION_PRODUCTO NOT IN ('DPF FLEXIBLE HB MN', 'DPF FLEXIBLE MN')
    GROUP BY CUENTA, FECHAAPERTURA
    HAVING COUNT(DISTINCT TASAINTERES) > 1
) t ON m.CUENTA = t.CUENTA AND m.FECHAAPERTURA = t.FECHAAPERTURA;
GO

-- Control 20. Unicidad de Operacion por fecha
-- Primero filtramos CAPITAL = 0
DELETE FROM mb_dpf.dbo.mb_dpf_mod
WHERE CAPITAL = 0;
GO
-- Filtrar operaciones que tengas m�s de una observaci�n en su historia
DELETE m
FROM mb_dpf.dbo.mb_dpf_mod m
JOIN (
    SELECT CUENTA
    FROM mb_dpf.dbo.mb_dpf_mod
    WHERE CAPITAL > 0
    GROUP BY CUENTA, FECHAPROCESO
    HAVING COUNT(*) > 1
) t ON m.CUENTA = t.CUENTA;
GO

-- Crear campo plazo agrupado
ALTER TABLE
	mb_dpf_mod
ADD
	PlazoAgrupado2 int;
GO

-- Asignar plazo agrupado
UPDATE
	mb_dpf_mod
SET
	PlazoAgrupado2 = CASE
		WHEN PLAZO >= 1 AND PLAZO <= 3 THEN 1
		WHEN PLAZO >= 4 AND PLAZO <= 5 THEN 5
		WHEN PLAZO >= 6 AND PLAZO <= 8 THEN 7
		WHEN PLAZO >= 9 AND PLAZO <= 11 THEN 10
		WHEN PLAZO >= 12 AND PLAZO <= 17 THEN 15
		WHEN PLAZO >= 18 AND PLAZO <= 25 THEN 20
		WHEN PLAZO >= 26 AND PLAZO <= 35 THEN 30 -- (1m)
		WHEN PLAZO >= 36 AND PLAZO <= 52 THEN 45 -- (1 1/2m)
		WHEN PLAZO >= 53 AND PLAZO <= 75 THEN 60 -- (2m)
		WHEN PLAZO >= 76 AND PLAZO <= 105 THEN 90 -- (3m)
		WHEN PLAZO >= 106 AND PLAZO <= 135 THEN 120 -- (4m)
		WHEN PLAZO >= 136 AND PLAZO <= 165 THEN 150 -- (5m)
		WHEN PLAZO >= 166 AND PLAZO <= 195 THEN 180 -- (6m)
		WHEN PLAZO >= 196 AND PLAZO <= 225 THEN 210 -- (7m)
		WHEN PLAZO >= 226 AND PLAZO <= 255 THEN 240 -- (8m)
		WHEN PLAZO >= 256 AND PLAZO <= 285 THEN 270 -- (9m)
		WHEN PLAZO >= 286 AND PLAZO <= 315 THEN 300 -- (10m)
		WHEN PLAZO >= 316 AND PLAZO <= 345 THEN 330 -- (11m)
		WHEN PLAZO >= 346 AND PLAZO <= 375 THEN 360 -- (12m)
		WHEN PLAZO >= 376 AND PLAZO <= 405 THEN 390 -- (13m)
		WHEN PLAZO >= 406 AND PLAZO <= 435 THEN 420 -- (14m)
		WHEN PLAZO >= 436 AND PLAZO <= 465 THEN 450 -- (15m)
		WHEN PLAZO >= 466 AND PLAZO <= 495 THEN 480 -- (16m)
		WHEN PLAZO >= 496 AND PLAZO <= 525 THEN 510 -- (17m)
		WHEN PLAZO >= 526 AND PLAZO <= 555 THEN 540 -- (18m)
		WHEN PLAZO >= 556 AND PLAZO <= 585 THEN 570 -- (19m)
		WHEN PLAZO >= 586 AND PLAZO <= 615 THEN 600 -- (20m)
		WHEN PLAZO >= 616 AND PLAZO <= 645 THEN 630 -- (21m)
		WHEN PLAZO >= 646 AND PLAZO <= 675 THEN 660 -- (22m)
		WHEN PLAZO >= 676 AND PLAZO <= 705 THEN 690 -- (23m)
		WHEN PLAZO >= 706 AND PLAZO <= 735 THEN 720 -- (24m)
		WHEN PLAZO >= 736 AND PLAZO <= 765 THEN 750 -- (25m)
		WHEN PLAZO >= 766 AND PLAZO <= 795 THEN 780 -- (26m)
		WHEN PLAZO >= 796 AND PLAZO <= 825 THEN 810 -- (27m)
		WHEN PLAZO >= 826 AND PLAZO <= 855 THEN 840 -- (28m)
		WHEN PLAZO >= 856 AND PLAZO <= 885 THEN 870 -- (29m)
		WHEN PLAZO >= 886 AND PLAZO <= 915 THEN 900 -- (30m)
		WHEN PLAZO >= 916 AND PLAZO <= 945 THEN 930 -- (31m)
		WHEN PLAZO >= 946 AND PLAZO <= 975 THEN 960 -- (32m)
		WHEN PLAZO >= 976 AND PLAZO <= 1005 THEN 990 -- (33m)
		WHEN PLAZO >= 1006 AND PLAZO <= 1035 THEN 1020 -- (34m)
		WHEN PLAZO >= 1036 AND PLAZO <= 1065 THEN 1050 -- (35m)
		WHEN PLAZO >= 1066 AND PLAZO <= 1095 THEN 1080 -- (36m)
		WHEN PLAZO >= 1096 AND PLAZO <= 1130 THEN 1110 --(37m)
		ELSE NULL
	END;
GO

DROP TABLE IF EXISTS mb_dpf.dbo.mb_dpf_mod_agg;
GO

-- Extraer informaci�n por operaci�n
SELECT
	CUENTA AS Cuenta,
	FECHAAPERTURA AS FechaApertura,
	MIN(CLIENTE) AS Cliente,
	MIN(MonedaStr) AS Moneda,
	MIN(FLAG) AS Flag,
	MIN(FECHAVENCIMIENTO) AS FechaVencimiento,
	AVG(PlazoAgrupado) AS PlazoAgrupado,
	AVG(PlazoAgrupado2) AS PlazoAgrupado2,
	AVG(PLAZO) AS Plazo,
	--MIN(PLAZO) AS MinPlazo,
	--MAX(PLAZO) AS MaxPlazo,
	ROUND(AVG(CAPITAL), 2) AS Capital,
	--MIN(CAPITAL) AS MinCAPITAL,
	--MAX(CAPITAL) AS MaxCAPITAL,
	ROUND(AVG(TASAINTERES), 2) AS TasaInteres,
	--MIN(TASAINTERES) AS MinTASAINTERES,
	--MAX(TASAINTERES) AS MaxTASAINTERES,
	MIN(FECHAPROCESO) AS MinFechaProceso,
	MAX(FECHAPROCESO) AS MaxFechaProceso,
	--COUNT(1) AS ObservationCounts,
	--COUNT(DISTINCT FECHAPROCESO) AS UniqueFechaProceso,
	DATEDIFF(DAY, MIN(FECHAPROCESO), MAX(FECHAPROCESO)) + 1 AS DiferenciaDias,
	CASE
		WHEN MAX(FECHAPROCESO) = '2025-03-31' THEN 0
		ELSE 1
	END AS FlagStatus
INTO
	mb_dpf.dbo.mb_dpf_mod_agg
FROM
	mb_dpf.dbo.mb_dpf_mod
WHERE
	FECHAAPERTURA >= '2015-03-01'
	AND PlazoAgrupado2 IS NOT NULL
GROUP BY
	CUENTA,
	FECHAAPERTURA;
GO

--SELECT * FROM mb_dpf.dbo.mb_dpf_mod_agg;
