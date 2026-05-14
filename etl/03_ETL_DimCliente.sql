-- ============================================================
-- ETL - DIMENSION CLIENTE
-- Fuente: Sales.Customer + Person.Person + Person.Address
--         + Person.StateProvince + Person.CountryRegion
-- Destino: AdventureWorks_DW.Repositorio.DimCliente
-- ============================================================

USE AdventureWorks_DW;
GO

BEGIN TRANSACTION;

BEGIN TRY

    PRINT 'Iniciando carga de DimCliente...';

    INSERT INTO Repositorio.DimCliente (CustomerID, NombreCompleto, SegmentoDemografico)
    SELECT
        c.CustomerID,
        -- Construcción del nombre completo con limpieza de nulos
        LTRIM(RTRIM(
            ISNULL(p.FirstName, '') + ' ' +
            ISNULL(p.MiddleName + ' ', '') +
            ISNULL(p.LastName, '')
        ))                                                          AS NombreCompleto,
        -- Segmento demográfico: Individual o Empresa
        CASE
            WHEN c.PersonID IS NOT NULL THEN 'Persona Natural'
            WHEN c.StoreID  IS NOT NULL THEN 'Empresa'
            ELSE 'Sin Clasificar'
        END                                                         AS SegmentoDemografico
    FROM AdventureWorks.Sales.Customer c
    LEFT JOIN AdventureWorks.Person.Person p
        ON c.PersonID = p.BusinessEntityID
    WHERE
        c.CustomerID IS NOT NULL
        AND NOT EXISTS (
            SELECT 1
            FROM Repositorio.DimCliente dc
            WHERE dc.CustomerID = c.CustomerID
        );

    PRINT 'DimCliente cargada correctamente. Filas insertadas: ' + CAST(@@ROWCOUNT AS VARCHAR);

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR en carga de DimCliente: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
