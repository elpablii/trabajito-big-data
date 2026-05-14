-- ============================================================
-- ETL - FACT VENTAS
-- Fuente: Sales.SalesOrderHeader + Sales.SalesOrderDetail
-- Destino: AdventureWorks_DW.Repositorio.FactVentas
-- NOTA: Ejecutar DESPUÉS de cargar todas las dimensiones
-- ============================================================

USE AdventureWorks_DW;
GO

BEGIN TRANSACTION;

BEGIN TRY

    PRINT 'Iniciando carga de FactVentas...';

    INSERT INTO Repositorio.FactVentas (
        TiempoKey,
        ClienteKey,
        ProductoKey,
        TerritorioKey,
        Cantidad,
        MontoVenta,
        CostoProduccion
    )
    SELECT
        -- Lookup Tiempo
        CAST(FORMAT(soh.OrderDate, 'yyyyMMdd') AS INT)  AS TiempoKey,

        -- Lookup Cliente (mediante surrogate key del DW)
        dc.ClienteKey,

        -- Lookup Producto (mediante surrogate key del DW)
        dp.ProductoKey,

        -- Lookup Territorio (mediante surrogate key del DW)
        dterr.TerritorioKey,

        -- Métricas
        sod.OrderQty                                    AS Cantidad,
        sod.LineTotal                                   AS MontoVenta,
        (p.StandardCost * sod.OrderQty)                AS CostoProduccion

    FROM AdventureWorks.Sales.SalesOrderHeader   soh
    INNER JOIN AdventureWorks.Sales.SalesOrderDetail  sod
        ON soh.SalesOrderID = sod.SalesOrderID

    -- Join con dimensiones del DW (claves de negocio → surrogate keys)
    INNER JOIN Repositorio.DimCliente dc
        ON soh.CustomerID = dc.CustomerID
    INNER JOIN Repositorio.DimProducto dp
        ON sod.ProductID = dp.ProductID
    INNER JOIN Repositorio.DimTerritorio dterr
        ON soh.TerritoryID = dterr.TerritoryID
    INNER JOIN Repositorio.DimTiempo dt
        ON dt.TiempoKey = CAST(FORMAT(soh.OrderDate, 'yyyyMMdd') AS INT)

    -- Costo estándar del producto fuente
    INNER JOIN AdventureWorks.Production.Product p
        ON sod.ProductID = p.ProductID

    WHERE
        soh.OrderDate IS NOT NULL
        -- Evitar duplicados (carga incremental simple)
        AND NOT EXISTS (
            SELECT 1
            FROM Repositorio.FactVentas fv
            INNER JOIN Repositorio.DimCliente dc2
                ON fv.ClienteKey = dc2.ClienteKey
            INNER JOIN Repositorio.DimProducto dp2
                ON fv.ProductoKey = dp2.ProductoKey
            WHERE
                fv.TiempoKey    = CAST(FORMAT(soh.OrderDate, 'yyyyMMdd') AS INT)
                AND dc2.CustomerID  = soh.CustomerID
                AND dp2.ProductID   = sod.ProductID
        );

    PRINT 'FactVentas cargada correctamente. Filas insertadas: ' + CAST(@@ROWCOUNT AS VARCHAR);

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR en carga de FactVentas: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
