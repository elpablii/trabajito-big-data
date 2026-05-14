-- ============================================================
-- ETL - DIMENSION PRODUCTO
-- Fuente: Production.Product + Production.ProductSubcategory
--         + Production.ProductCategory
-- Destino: AdventureWorks_DW.Repositorio.DimProducto
-- ============================================================

USE AdventureWorks_DW;
GO

BEGIN TRANSACTION;

BEGIN TRY

    PRINT 'Iniciando carga de DimProducto...';

    INSERT INTO Repositorio.DimProducto (ProductID, NombreProducto, Categoria, Color)
    SELECT
        p.ProductID,
        p.Name                                                      AS NombreProducto,
        ISNULL(pc.Name, 'Sin Categoría')                           AS Categoria,
        ISNULL(p.Color, 'N/A')                                     AS Color
    FROM AdventureWorks.Production.Product p
    LEFT JOIN AdventureWorks.Production.ProductSubcategory ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    LEFT JOIN AdventureWorks.Production.ProductCategory pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
    WHERE
        p.ProductID IS NOT NULL
        AND NOT EXISTS (
            SELECT 1
            FROM Repositorio.DimProducto dp
            WHERE dp.ProductID = p.ProductID
        );

    PRINT 'DimProducto cargada correctamente. Filas insertadas: ' + CAST(@@ROWCOUNT AS VARCHAR);

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR en carga de DimProducto: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
