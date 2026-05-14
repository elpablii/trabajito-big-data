-- ============================================================
-- ETL - FACT PRODUCCION
-- Fuente: Production.WorkOrder + Production.WorkOrderRouting
-- Destino: AdventureWorks_DW.Repositorio.FactProduccion
-- NOTA: Ejecutar DESPUÉS de cargar todas las dimensiones
-- ============================================================

USE AdventureWorks_DW;
GO

BEGIN TRANSACTION;

BEGIN TRY

    PRINT 'Iniciando carga de FactProduccion...';

    INSERT INTO Repositorio.FactProduccion (
        ProductoKey,
        TiempoKey,
        CantidadProducida,
        CantidadScrap,
        TiempoFabricacionDias
    )
    SELECT
        -- Lookup Producto
        dp.ProductoKey,

        -- Lookup Tiempo (fecha de inicio de producción)
        CAST(FORMAT(wo.StartDate, 'yyyyMMdd') AS INT)   AS TiempoKey,

        -- Métricas de producción
        wo.OrderQty                                      AS CantidadProducida,
        wo.ScrappedQty                                   AS CantidadScrap,
        DATEDIFF(DAY, wo.StartDate, wo.EndDate)          AS TiempoFabricacionDias

    FROM AdventureWorks.Production.WorkOrder wo

    -- Join con dimensiones del DW
    INNER JOIN Repositorio.DimProducto dp
        ON wo.ProductID = dp.ProductID
    INNER JOIN Repositorio.DimTiempo dt
        ON dt.TiempoKey = CAST(FORMAT(wo.StartDate, 'yyyyMMdd') AS INT)

    WHERE
        wo.StartDate IS NOT NULL
        AND wo.EndDate IS NOT NULL
        -- Evitar duplicados
        AND NOT EXISTS (
            SELECT 1
            FROM Repositorio.FactProduccion fp
            INNER JOIN Repositorio.DimProducto dp2
                ON fp.ProductoKey = dp2.ProductoKey
            WHERE
                fp.TiempoKey       = CAST(FORMAT(wo.StartDate, 'yyyyMMdd') AS INT)
                AND dp2.ProductID  = wo.ProductID
                AND fp.CantidadProducida = wo.OrderQty
        );

    PRINT 'FactProduccion cargada correctamente. Filas insertadas: ' + CAST(@@ROWCOUNT AS VARCHAR);

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR en carga de FactProduccion: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
