# Arquitectura de la Solución BI - Adventure Works

A continuación se presenta el código para generar el diagrama de arquitectura. Está escrito en formato **Mermaid**, el cual es un estándar muy popular. Puedes copiar el bloque de código a continuación y pegarlo en páginas como [Mermaid Live Editor](https://mermaid.live/) o usarlo directamente en Notion, GitHub, o Markdown.

```mermaid
graph LR
    %% Definición de Estilos
    classDef database fill:#f9f,stroke:#333,stroke-width:2px;
    classDef process fill:#bbf,stroke:#333,stroke-width:2px;
    classDef bi fill:#ff9,stroke:#333,stroke-width:2px;

    subgraph "Capa de Origen (Source)"
        A[(Base de Datos Transaccional<br/>SQL Server - AdventureWorks)]:::database
    end
    
    subgraph "Capa de Integración (Proceso ETL)"
        B[Extracción de Datos]:::process
        C[Transformación<br/>Limpieza y Modelado]:::process
        D[Carga de Datos]:::process
        
        B --> C
        C --> D
    end
    
    subgraph "Capa de Almacenamiento (Data Warehouse)"
        E[(Base de Datos OLAP<br/>Modelo Estrella / Copo de Nieve)]:::database
    end
    
    subgraph "Capa de Presentación (BI & Reportabilidad)"
        F[Power BI<br/>Perspectiva: Clientes]:::bi
        G[Power BI<br/>Perspectiva: Procesos/Producción]:::bi
        H[Power BI<br/>Perspectiva: Ventas]:::bi
    end

    %% Conexiones principales
    A ==>|Lectura de Datos| B
    D ==>|Escritura de Datos| E
    E ==>|Consulta (DirectQuery / Import)| F
    E ==>|Consulta (DirectQuery / Import)| G
    E ==>|Consulta (DirectQuery / Import)| H

```
