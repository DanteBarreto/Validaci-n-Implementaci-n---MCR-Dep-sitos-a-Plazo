-- Versión 1
-- Control de cambios
USE mb_dpf;
GO

DROP TABLE IF EXISTS mb_dpf;
GO

CREATE TABLE mb_dpf (
	FECHAPROCESO DATE,
	CLIENTE BIGINT,
	CUENTA BIGINT,
	FLAG NVARCHAR(50),
	DESCRIPCION_PRODUCTO NVARCHAR(50),
	CODIGO_PRODUCTO SMALLINT,
	PLAZO SMALLINT,
	CAPITAL DECIMAL(16,2),
	TASAINTERES DECIMAL(5,2),
	MONEDA TINYINT,
	FECHAVENCIMIENTO DATE,
	FECHAAPERTURA DATE
);
GO

-- Crear la tabla temporal
CREATE TABLE #TempTables (
    TableName NVARCHAR(255)
);
GO

-- Insertar nombres de tablas en la tabla temporal
INSERT INTO #TempTables (TableName)
VALUES 
	('mb_dpf_1503_2009_backup'),
	('mb_dpf_2010_2107_backup'),
	('mb_dpf_2108_2111_backup'),
	('mb_dpf_2112_2205_backup'),
	('mb_dpf_2206_2207_backup'),
	('mb_dpf_2208_2210_backup'),
	('mb_dpf_2211_2212_backup'),
	('mb_dpf_2301_2303_backup'),
	('mb_dpf_2304_2306_backup'),
	('mb_dpf_2307_2309_backup'),
	('mb_dpf_2310_2312_backup'),
	('mb_dpf_2401_2403_backup'),
	('mb_dpf_2404_2406_backup'),
	('mb_dpf_2407_2409_backup'),
	('mb_dpf_2410_2412_backup'),
	('mb_dpf_2501_2503_backup');

-- Iterar sobre los nombres de tablas y aplicar el INSERT INTO
DECLARE @TableName NVARCHAR(255);
DECLARE @sql NVARCHAR(MAX);

DECLARE TableCursor CURSOR FOR
SELECT TableName FROM #TempTables;

OPEN TableCursor;

FETCH NEXT FROM TableCursor INTO @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Aplicar el INSERT INTO para cada tabla
    SET @sql =  N'
        INSERT INTO mb_dpf
        SELECT 
			FECHAPROCESO, 
			CLIENTE, 
			CUENTA, 
			FLAG, 
			DESCRIPCION_PRODUCTO, 
			CODIGO_PRODUCTO, 
			PLAZO, 
			CAPITAL, 
			TASAINTERES, 
			MONEDA, 
			FECHAVENCIMIENTO, 
			FECHAAPERTURA 
		FROM ' + @TableName;

	EXEC sp_executesql @sql;

    FETCH NEXT FROM TableCursor INTO @TableName;
END;

CLOSE TableCursor;
DEALLOCATE TableCursor;
GO

-- Eliminar la tabla temporal
DROP TABLE #TempTables;
GO
