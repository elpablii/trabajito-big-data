-- ============================================================
-- MASTER ETL - ORQUESTADOR COMPLETO
-- Ejecuta todos los scripts ETL en el orden correcto:
--   1. Dimensiones (sin dependencias entre sí)
--   2. Tablas de hechos (dependen de las dimensiones)
--
-- Uso: Ejecutar este único archivo para poblar todo el DW.
-- ============================================================

USE AdventureWorks_DW;
GO

PRINT '================================================================';
PRINT ' INICIO DEL PROCESO ETL - AdventureWorks → AdventureWorks_DW   ';
PRINT ' Fecha/Hora: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '================================================================';
PRINT '';

-- ─────────────────────────────────────────────
-- PASO 1: DIMENSIONES
-- (Orden independiente, no hay FK entre ellas)
-- ─────────────────────────────────────────────

PRINT '>>> [1/6] Cargando DimTiempo...';
:r ".\01_ETL_DimTiempo.sql"

PRINT '>>> [2/6] Cargando DimProducto...';
:r ".\02_ETL_DimProducto.sql"

PRINT '>>> [3/6] Cargando DimCliente...';
:r ".\03_ETL_DimCliente.sql"

PRINT '>>> [4/6] Cargando DimTerritorio...';
:r ".\04_ETL_DimTerritorio.sql"

-- ─────────────────────────────────────────────
-- PASO 2: TABLAS DE HECHOS
-- (Requieren dimensiones ya cargadas)
-- ─────────────────────────────────────────────

PRINT '>>> [5/6] Cargando FactVentas...';
:r ".\05_ETL_FactVentas.sql"

PRINT '>>> [6/6] Cargando FactProduccion...';
:r ".\06_ETL_FactProduccion.sql"

-- ─────────────────────────────────────────────
-- REPORTE FINAL DE CONTEO
-- ─────────────────────────────────────────────

PRINT '';
PRINT '================================================================';
PRINT ' RESUMEN DE CARGA - CONTEO DE REGISTROS EN EL DW               ';
PRINT '================================================================';

SELECT 'DimTiempo'      AS Tabla, COUNT(*) AS TotalRegistros FROM Repositorio.DimTiempo
UNION ALL
SELECT 'DimProducto',   COUNT(*) FROM Repositorio.DimProducto
UNION ALL
SELECT 'DimCliente',    COUNT(*) FROM Repositorio.DimCliente
UNION ALL
SELECT 'DimTerritorio', COUNT(*) FROM Repositorio.DimTerritorio
UNION ALL
SELECT 'FactVentas',    COUNT(*) FROM Repositorio.FactVentas
UNION ALL
SELECT 'FactProduccion',COUNT(*) FROM Repositorio.FactProduccion;

PRINT '';
PRINT 'ETL completado exitosamente: ' + CONVERT(VARCHAR, GETDATE(), 120);
GO
