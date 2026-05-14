-- ============================================================
-- ETL - DIMENSION TIEMPO
-- Fuente: Fechas extraídas de Sales.SalesOrderHeader
-- Destino: AdventureWorks_DW.Repositorio.DimTiempo
-- ============================================================

USE AdventureWorks_DW;
GO

BEGIN TRANSACTION;

BEGIN TRY

    PRINT 'Iniciando carga de DimTiempo...';

    -- Limpieza previa (carga incremental segura)
    -- Solo inserta fechas que aún no existen
    INSERT INTO Repositorio.DimTiempo (TiempoKey, Fecha, Anio, Mes, NombreMes)
    SELECT DISTINCT
        CAST(FORMAT(soh.OrderDate, 'yyyyMMdd') AS INT)   AS TiempoKey,
        CAST(soh.OrderDate AS DATE)                       AS Fecha,
        YEAR(soh.OrderDate)                               AS Anio,
        MONTH(soh.OrderDate)                              AS Mes,
        DATENAME(MONTH, soh.OrderDate)                    AS NombreMes
    FROM AdventureWorks.Sales.SalesOrderHeader soh
    WHERE
        soh.OrderDate IS NOT NULL
        AND NOT EXISTS (
            SELECT 1
            FROM Repositorio.DimTiempo dt
            WHERE dt.TiempoKey = CAST(FORMAT(soh.OrderDate, 'yyyyMMdd') AS INT)
        );

    PRINT 'DimTiempo cargada correctamente. Filas insertadas: ' + CAST(@@ROWCOUNT AS VARCHAR);

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR en carga de DimTiempo: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
