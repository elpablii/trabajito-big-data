-- ============================================================
-- ETL - DIMENSION TERRITORIO
-- Fuente: Sales.SalesTerritory
-- Destino: AdventureWorks_DW.Repositorio.DimTerritorio
-- ============================================================

USE AdventureWorks_DW;
GO

BEGIN TRANSACTION;

BEGIN TRY

    PRINT 'Iniciando carga de DimTerritorio...';

    INSERT INTO Repositorio.DimTerritorio (TerritoryID, Region, Pais)
    SELECT
        st.TerritoryID,
        st.Name         AS Region,
        st.CountryRegionCode  AS Pais
    FROM AdventureWorks.Sales.SalesTerritory st
    WHERE
        st.TerritoryID IS NOT NULL
        AND NOT EXISTS (
            SELECT 1
            FROM Repositorio.DimTerritorio dterr
            WHERE dterr.TerritoryID = st.TerritoryID
        );

    PRINT 'DimTerritorio cargada correctamente. Filas insertadas: ' + CAST(@@ROWCOUNT AS VARCHAR);

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR en carga de DimTerritorio: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
