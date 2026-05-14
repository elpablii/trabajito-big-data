# Trabajito-big-data
Este es un trabajo de Big Data.

# MONTAR BASE DE DATOS TRANSACCIONAL

1. *Levantar docker*

```bash

docker-compose up -d
```

2. *Ejecutar comando para pasarle el archivo a docker (CMD)*

```bash

docker cp "C:\Ruta\A\Tu\Descarga\script.sql" adventure_works_db:/var/opt/mssql/data/
```

Cambia la ruta con la ubicación donde tienes script.sql

3. *Crear conexión a SQL server*

- Descargar extensión SQL Server en VS Code
- Ingresar al nuevo apartado que se crea en la barra lateral izquierda
- Crear una nueva conexión

`Server name`   --> localhost
`User name`     --> sa
`Password`      --> Password_123! *(Habilitar casilla 'Save Password')*
`Profile name`  --> Cualquier nombre

Y presionan **'Connect'**. Si les sale un coso de "Trust no sé qué" 
    después de apretar el botón Connect apretele nomas

4. *Ejecutar siguiente comando (CMD)*

```bash

docker exec -it adventure_works_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Password_123!" -C -i /var/opt/mssql/data/script.sql
```


5. *Refresh*

Vas al apartado de SQL server y refrescas el servidor, y podrás ver las
    tablas montadas con los datos cargados

# WAREHOUSE

1. Crear BD en el servidor creado de SQL Server

```sql 

CREATE DATABASE AdventureWorks_DW;
GO
```

2. Crear el esquema
```sql

CREATE SCHEMA Repositorio;
GO

-- DIMENSIONES (contexto de los datos)
CREATE TABLE Repositorio.DimProducto (
    ProductoKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    NombreProducto VARCHAR(100),
    Categoria VARCHAR(50),
    Color VARCHAR(20)
);

CREATE TABLE Repositorio.DimCliente (
    ClienteKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    NombreCompleto VARCHAR(150),
    SegmentoDemografico VARCHAR(50)
);

CREATE TABLE Repositorio.DimTerritorio (
    TerritorioKey INT IDENTITY(1,1) PRIMARY KEY,
    TerritoryID INT,
    Region VARCHAR(50),
    Pais VARCHAR(50)
);

CREATE TABLE Repositorio.DimTiempo (
    TiempoKey INT PRIMARY KEY,
    Fecha DATE,
    Anio INT,
    Mes INT,
    NombreMes VARCHAR(20)
);

-- TABLAS DE HECHOS (metricas y KPIs)
-- Para Perspectiva Ventas y Clientes
CREATE TABLE Repositorio.FactVentas (
    VentaKey INT IDENTITY(1,1) PRIMARY KEY,
    TiempoKey INT REFERENCES Repositorio.DimTiempo(TiempoKey),
    ClienteKey INT REFERENCES Repositorio.DimCliente(ClienteKey),
    ProductoKey INT REFERENCES Repositorio.DimProducto(ProductoKey),
    TerritorioKey INT REFERENCES Repositorio.DimTerritorio(TerritorioKey),
    Cantidad INT,
    MontoVenta DECIMAL(18,2),
    CostoProduccion DECIMAL(18,2),
    MargenUtilidad AS (MontoVenta - CostoProduccion)
);

-- Para Perspectiva Procesos (produccion)
CREATE TABLE Repositorio.FactProduccion (
    ProduccionKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductoKey INT REFERENCES Repositorio.DimProducto(ProductoKey),
    TiempoKey INT REFERENCES Repositorio.DimTiempo(TiempoKey),
    CantidadProducida INT,
    CantidadScrap INT,
    TiempoFabricacionDias INT
);
```

# PROCESO ETL

Los scripts ETL están en la carpeta `etl/` y poblan el Data Warehouse desde la BD transaccional AdventureWorks.

## Archivos ETL

| Archivo | Tabla destino | Fuentes |
|---|---|---|
| `01_ETL_DimTiempo.sql` | `DimTiempo` | `Sales.SalesOrderHeader` |
| `02_ETL_DimProducto.sql` | `DimProducto` | `Production.Product`, `ProductSubcategory`, `ProductCategory` |
| `03_ETL_DimCliente.sql` | `DimCliente` | `Sales.Customer`, `Person.Person` |
| `04_ETL_DimTerritorio.sql` | `DimTerritorio` | `Sales.SalesTerritory` |
| `05_ETL_FactVentas.sql` | `FactVentas` | `Sales.SalesOrderHeader`, `SalesOrderDetail` |
| `06_ETL_FactProduccion.sql` | `FactProduccion` | `Production.WorkOrder` |

## Ejecución (opción recomendada: script maestro)

Abre el archivo `etl/00_ETL_MASTER.sql` en VS Code con la extensión SQL Server y ejecútalo conectado al servidor `localhost`. Este orquestador corre todos los scripts en el orden correcto (dimensiones primero, hechos después) y al final muestra un resumen de filas cargadas por tabla.

> **Requisito previo:** Tener el DW creado con el esquema `Repositorio` (paso anterior) y el contenedor Docker corriendo.

## Ejecución individual (desde CMD / sqlcmd)

```bash
# Desde la carpeta etl/
sqlcmd -S localhost -U sa -P "Password_123!" -C -d AdventureWorks_DW -i 00_ETL_MASTER.sql
```

## Características del ETL

- **Carga incremental**: cada script verifica si el registro ya existe antes de insertar (evita duplicados en re-ejecuciones).
- **Transacciones**: cada carga está envuelta en `BEGIN TRANSACTION / COMMIT / ROLLBACK` para garantizar integridad.
- **Limpieza de datos**: manejo de nulos con `ISNULL`, construcción de nombres compuestos, y cálculo de `TiempoKey` estandarizado (`yyyyMMdd`).
- **Orden de dependencias**: dimensiones → hechos (las FK del DW siempre se resuelven correctamente).