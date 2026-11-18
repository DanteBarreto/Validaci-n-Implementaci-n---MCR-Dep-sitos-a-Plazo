-- Versión 1
-- Control de cambios
USE mb_dpf;
GO

DROP TABLE IF EXISTS mb_dpf.dbo.mb_dpf_mod;
GO

SELECT
	*
INTO
	mb_dpf.dbo.mb_dpf_mod
FROM
	mb_dpf.dbo.mb_dpf;
GO

UPDATE mb_dpf_mod
SET FLAG = LTRIM(RTRIM(FLAG));
GO

UPDATE mb_dpf_mod
SET DESCRIPCION_PRODUCTO = LTRIM(RTRIM(DESCRIPCION_PRODUCTO));
GO

-- Saldo por moneda
WITH CTE AS (
	SELECT
		FECHAPROCESO,
		MONEDA,
		SUM(CAPITAL) AS CAPITAL
	FROM
		[mb_dpf].[dbo].[mb_dpf_mod]
	GROUP BY
		FECHAPROCESO,
		MONEDA
)
SELECT
	DataHistorica.FECHAPROCESO,
	DataHistorica.MONEDA,
	CASE
		WHEN DataHistorica.MONEDA = 2 THEN DataHistorica.CAPITAL * TipoCambio.ER
		ELSE DataHistorica.CAPITAL
	END AS Saldo
FROM CTE DataHistorica
LEFT JOIN
	ALS_CONSOLIDADO.dbo.er TipoCambio
ON
	DataHistorica.FECHAPROCESO = TipoCambio.Fecha
ORDER BY
	DataHistorica.FECHAPROCESO,
	DataHistorica.MONEDA;
GO

SELECT
	COUNT(DISTINCT CLIENTE) AS CantidadClientes 
FROM
	mb_dpf_mod;
GO
--250603

SELECT
	COUNT(DISTINCT CUENTA) AS CantidadCuenta
FROM
	mb_dpf_mod;
GO
--804099
          
-- Saldos por FLAG
WITH CTE AS (
	SELECT
		FECHAPROCESO,
		MONEDA,
		FLAG,
		SUM(CAPITAL) AS CAPITAL
	FROM
		[mb_dpf].[dbo].[mb_dpf_mod]
	GROUP BY
		FECHAPROCESO,
		MONEDA,
		FLAG
),
CTE2 AS (
	SELECT
		DataHistorica.FECHAPROCESO,
		DataHistorica.FLAG,
		CASE
			WHEN DataHistorica.MONEDA = 2 THEN DataHistorica.CAPITAL * TipoCambio.ER
			ELSE DataHistorica.CAPITAL
		END AS Saldo
	FROM CTE DataHistorica
	LEFT JOIN
		ALS_CONSOLIDADO.dbo.er TipoCambio
	ON
		DataHistorica.FECHAPROCESO = TipoCambio.Fecha
)
SELECT
	FECHAPROCESO,
	FLAG,
	SUM(Saldo) AS Saldo
FROM 
	CTE2
GROUP BY
	FECHAPROCESO,
	FLAG
ORDER BY
	FECHAPROCESO,
	FLAG;
GO

-- Explorar DESCRIPCION_PRODUCTO
SELECT
	DESCRIPCION_PRODUCTO,
	COUNT(DISTINCT CUENTA) NroCuentas
FROM
	mb_dpf_mod
GROUP BY
	DESCRIPCION_PRODUCTO
ORDER BY
	DESCRIPCION_PRODUCTO;
GO

-- Explorar CODIGO_PRODUCTO
SELECT
	CODIGO_PRODUCTO,
	COUNT(DISTINCT CUENTA) NroCuentas
FROM
	mb_dpf_mod
GROUP BY
	CODIGO_PRODUCTO
ORDER BY
	CODIGO_PRODUCTO;
GO

-- Explorar PLAZO
SELECT
	PLAZO,
	COUNT(DISTINCT CUENTA) NroCuentas
FROM
	mb_dpf_mod
GROUP BY
	PLAZO
ORDER BY
	PLAZO;
GO

-- Explorar TASAINTERES
SELECT
	TASAINTERES,
	COUNT(DISTINCT CUENTA) NroCuentas
FROM
	mb_dpf_mod
GROUP BY
	TASAINTERES
ORDER BY
	TASAINTERES;
GO

-- Explorar MONEDA
SELECT
	MONEDA,
	COUNT(DISTINCT CUENTA) NroCuentas
FROM
	mb_dpf_mod
GROUP BY
	MONEDA
ORDER BY
	MONEDA;
GO
--MONEDA	NroCuentas
--1	779654
--2	24445

-- Explorar FECHAVENCIMIENTO
SELECT
	FECHAVENCIMIENTO,
	COUNT(DISTINCT CUENTA) NroCuentas
FROM
	mb_dpf_mod
GROUP BY
	FECHAVENCIMIENTO
ORDER BY
	FECHAVENCIMIENTO;
GO

-- Explorar FECHAAPERTURA
SELECT
	FECHAAPERTURA,
	COUNT(DISTINCT CUENTA) NroCuentas
FROM
	mb_dpf_mod
GROUP BY
	FECHAAPERTURA
ORDER BY
	FECHAAPERTURA;
GO

-- Saldos por plazo
-- Crear campo plazo agrupado
ALTER TABLE
	mb_dpf_mod
ADD
	PlazoAgrupado int;
GO

-- Asignar plazo agrupado
UPDATE
	mb_dpf_mod
SET
	PlazoAgrupado = CASE
		WHEN PLAZO >= 1 AND PLAZO <= 3 THEN 1
		WHEN PLAZO >= 4 AND PLAZO <= 5 THEN 5
		WHEN PLAZO >= 6 AND PLAZO <= 8 THEN 7
		WHEN PLAZO >= 9 AND PLAZO <= 11 THEN 10
		WHEN PLAZO >= 12 AND PLAZO <= 18 THEN 15
		WHEN PLAZO >= 19 AND PLAZO <= 24 THEN 20
		WHEN PLAZO >= 25 AND PLAZO <= 35 THEN 30 -- (1m)
		WHEN PLAZO >= 40 AND PLAZO <= 50 THEN 45 -- (1 1/2m)
		WHEN PLAZO >= 55 AND PLAZO <= 65 THEN 60 -- (2m)
		WHEN PLAZO >= 85 AND PLAZO <= 95 THEN 90 -- (3m)
		WHEN PLAZO >= 115 AND PLAZO <= 125 THEN 120 -- (4m)
		WHEN PLAZO >= 145 AND PLAZO <= 155 THEN 150 -- (5m)
		WHEN PLAZO >= 175 AND PLAZO <= 190 THEN 180 -- (6m)
		WHEN PLAZO >= 205 AND PLAZO <= 215 THEN 210 -- (7m)
		WHEN PLAZO >= 235 AND PLAZO <= 245 THEN 240 -- (8m)
		WHEN PLAZO >= 265 AND PLAZO <= 275 THEN 270 -- (9m)
		WHEN PLAZO >= 295 AND PLAZO <= 305 THEN 300 -- (10m)
		WHEN PLAZO >= 325 AND PLAZO <= 335 THEN 330 -- (11m)
		WHEN PLAZO >= 350 AND PLAZO <= 370 THEN 360 -- (12m)
		WHEN PLAZO >= 380 AND PLAZO <= 400 THEN 390 -- (13m)
		WHEN PLAZO >= 410 AND PLAZO <= 430 THEN 420 -- (14m)
		WHEN PLAZO >= 440 AND PLAZO <= 460 THEN 450 -- (15m)
		WHEN PLAZO >= 470 AND PLAZO <= 490 THEN 480 -- (16m)
		WHEN PLAZO >= 510 AND PLAZO <= 520 THEN 510 -- (17m)
		WHEN PLAZO >= 530 AND PLAZO <= 550 THEN 540 -- (18m)
		WHEN PLAZO >= 560 AND PLAZO <= 580 THEN 570 -- (19m)
		WHEN PLAZO >= 590 AND PLAZO <= 610 THEN 600 -- (20m)
		WHEN PLAZO >= 620 AND PLAZO <= 640 THEN 630 -- (21m)
		WHEN PLAZO >= 650 AND PLAZO <= 670 THEN 660 -- (22m)
		WHEN PLAZO >= 680 AND PLAZO <= 700 THEN 690 -- (23m)
		WHEN PLAZO >= 705 AND PLAZO <= 735 THEN 720 -- (24m)
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
		WHEN PLAZO >= 1060 AND PLAZO <= 1100 THEN 1080 -- (36m)
		WHEN PLAZO >= 1101 AND PLAZO <= 1130 THEN 1110 --(37m)
		ELSE 2000
	END;
GO

-- Saldo por plazo
WITH CTE AS (
	SELECT
		FECHAPROCESO,
		MONEDA,
		PlazoAgrupado,
		SUM(CAPITAL) AS CAPITAL
	FROM
		mb_dpf_mod
	GROUP BY
		FECHAPROCESO,
		MONEDA,
		PlazoAgrupado
),
CTE2 AS (
	SELECT
		DataHistorica.FECHAPROCESO,
		DataHistorica.PlazoAgrupado,
		CASE
			WHEN DataHistorica.MONEDA = 2 THEN DataHistorica.CAPITAL * TipoCambio.ER
			ELSE DataHistorica.CAPITAL
		END AS Saldo
	FROM CTE DataHistorica
	LEFT JOIN
		ALS_CONSOLIDADO.dbo.er TipoCambio
	ON
		DataHistorica.FECHAPROCESO = TipoCambio.Fecha
)
SELECT
	FECHAPROCESO,
	PlazoAgrupado,
	SUM(Saldo) AS Saldo
FROM 
	CTE2
GROUP BY
	FECHAPROCESO,
	PlazoAgrupado
ORDER BY
	FECHAPROCESO,
	PlazoAgrupado;
GO

-- Saldo por apertura
-- Crear campo moneda en string
ALTER TABLE
	mb_dpf_mod
ADD
	MonedaStr NVARCHAR(3);
GO

-- Asignar Moneda en string
UPDATE	
	mb_dpf_mod
SET
	MonedaStr = CASE
		WHEN MONEDA = 1 THEN 'PEN'
		WHEN MONEDA = 2 THEN 'USD'
		END;
GO

-- Crear campo apertura
ALTER TABLE
	mb_dpf_mod
ADD
	Apertura NVARCHAR(50);
GO

-- Asignar apertura
UPDATE	
	mb_dpf.dbo.mb_dpf_mod
SET
	Apertura = MonedaStr + ' ' + FLAG + ' ' + CAST(PlazoAgrupado AS VARCHAR(10));
GO

-- Saldo
WITH CTE AS (
	SELECT
		FECHAPROCESO,
		MONEDA,
		Apertura,
		SUM(CAPITAL) AS CAPITAL
	FROM
		[mb_dpf].[dbo].[mb_dpf_mod]
	GROUP BY
		FECHAPROCESO,
		MONEDA,
		Apertura
),
CTE2 AS (
	SELECT
		DataHistorica.FECHAPROCESO,
		DataHistorica.Apertura,
		CASE
			WHEN DataHistorica.MONEDA = 2 THEN DataHistorica.CAPITAL * TipoCambio.ER
			ELSE DataHistorica.CAPITAL
		END AS Saldo
	FROM CTE DataHistorica
	LEFT JOIN
		ALS_CONSOLIDADO.dbo.er TipoCambio
	ON
		DataHistorica.FECHAPROCESO = TipoCambio.Fecha
),
CTE3 AS (
	SELECT
		FECHAPROCESO,
		Apertura,
		SUM(Saldo) AS Saldo
	FROM 
		CTE2
	GROUP BY
		FECHAPROCESO,
		Apertura
)
SELECT
	CAST(FORMAT(FECHAPROCESO, 'yyyyMM') + '01' AS DATE) AS FECHAPROCESO,
	Apertura,
	AVG(Saldo) AS Saldo
FROM 
	CTE3
GROUP BY
	FORMAT(FECHAPROCESO, 'yyyyMM'),
	Apertura
ORDER BY
	FECHAPROCESO,
	Apertura;
GO

-- Colocaciones
SELECT
	MonedaStr,
	FLAG,
	PlazoAgrupado,
	CAST(FORMAT(FECHAPROCESO, 'yyyyMM') + '01' AS DATE) AS FECHAPROCESO,
	COUNT(1) AS Counts,
	SUM(CAPITAL) AS Capital,
	SUM(TASAINTERES * CAPITAL) AS TasaTimesCapital,
	CASE
		WHEN SUM(CAPITAL) = 0 THEN NULL
		ELSE SUM(TASAINTERES * CAPITAL) / SUM(CAPITAL) / 100
	END AS TasaPonderada
FROM
	mb_dpf.dbo.mb_dpf_mod
WHERE
	FECHAPROCESO = FECHAAPERTURA
	AND CAPITAL > 0
GROUP BY
	MonedaStr,
	FLAG,
	PlazoAgrupado,
	FORMAT(FECHAPROCESO, 'yyyyMM');
GO

-- Colocaciones ultimo a�o
SELECT
	MonedaStr,
	FLAG,
	PlazoAgrupado,
	Apertura,
	COUNT(1) AS Counts,
	SUM(CAPITAL) AS Capital,
	SUM(TASAINTERES * CAPITAL) AS TasaTimesCapital,
	CASE
		WHEN SUM(CAPITAL) = 0 THEN NULL
		ELSE SUM(TASAINTERES * CAPITAL) / SUM(CAPITAL) / 100
	END AS TasaPonderada
FROM
	mb_dpf.dbo.mb_dpf_mod
WHERE
	FECHAPROCESO = FECHAAPERTURA
	AND CAPITAL > 0
	AND FECHAPROCESO BETWEEN '2024-01-01' AND '2025-12-31'
GROUP BY
	MonedaStr,
	FLAG,
	PlazoAgrupado,
	Apertura;
GO

-- Colocaciones (Plazo sin agrupado)
SELECT
	MonedaStr,
	FLAG AS Flag,
	PLAZO as Plazo,
	CAST(FORMAT(FECHAPROCESO, 'yyyyMM') + '01' AS DATE) AS FECHAPROCESO,
	COUNT(1) AS Counts,
	SUM(CAPITAL) AS Capital,
	SUM(TASAINTERES * CAPITAL) AS TasaTimesCapital,
	CASE
		WHEN SUM(CAPITAL) = 0 THEN NULL
		ELSE SUM(TASAINTERES * CAPITAL) / SUM(CAPITAL) / 100
	END AS TasaPonderada
FROM
	mb_dpf.dbo.mb_dpf_mod
WHERE
	FECHAPROCESO = FECHAAPERTURA
	AND CAPITAL > 0
GROUP BY
	MonedaStr,
	FLAG,
	PLAZO,
	FORMAT(FECHAPROCESO, 'yyyyMM');
GO

-- Colocaciones ultimo a�o (Plazo sin agrupado)
SELECT
	MonedaStr,
	FLAG AS Flag,
	PLAZO as Plazo,
	COUNT(1) AS Counts,
	SUM(CAPITAL) AS Capital,
	SUM(TASAINTERES * CAPITAL) AS TasaTimesCapital,
	CASE
		WHEN SUM(CAPITAL) = 0 THEN NULL
		ELSE SUM(TASAINTERES * CAPITAL) / SUM(CAPITAL) / 100
	END AS TasaPonderada
FROM
	mb_dpf.dbo.mb_dpf_mod
WHERE
	FECHAPROCESO = FECHAAPERTURA
	AND CAPITAL > 0
	AND FECHAPROCESO BETWEEN '2024-01-01' AND '2025-12-31'
GROUP BY
	MonedaStr,
	FLAG,
	PLAZO
ORDER BY
	MonedaStr,
	FLAG,
	PLAZO;
GO
