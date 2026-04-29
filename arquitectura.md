flowchart LR
    %% Configuración de Orientación y Espaciado
    direction LR

    subgraph Source ["1. Capa de Origen (OLTP)"]
        A[("BD Transaccional<br/>AdventureWorks<br/>(SQL Server)")]
    end

    subgraph ETL ["2. Integración (Proceso ETL)"]
        direction LR
        B["Extracción"] 
        C["Transformación<br/>y Limpieza"] 
        D["Carga de Datos"]
        
        B --> C --> D
    end

    subgraph DW ["3. Almacenamiento (Data Warehouse)"]
        E[("Base de Datos OLAP<br/>Modelo Estrella /<br/>Copo de Nieve")]
    end

    subgraph BI ["4. Presentación (Power BI)"]
        F["📊 Perspectiva: Clientes<br/>(Demografía y Retención)"]
        G["⚙️ Perspectiva: Procesos<br/>(Inventario y Manufactura)"]
        H["💰 Perspectiva: Ventas<br/>(Ingresos y Rendimiento)"]
    end

    %% Conexiones Principales con etiquetas claras
    A ===|Lectura| B
    D ===|Poblamiento DW| E
    
    %% Conexiones de Salida
    E -.-> F
    E -.-> G
    E -.-> H

    %% Estilos para mejorar legibilidad y evitar solapamientos
    classDef database fill:#e1f5fe,stroke:#0288d1,stroke-width:2px,color:#000
    classDef process fill:#fff3e0,stroke:#f57c00,stroke-width:2px,color:#000
    classDef bi fill:#e8f5e9,stroke:#388e3c,stroke-width:2px,color:#000

    class A,E database
    class B,C,D process
    class F,G,H bi