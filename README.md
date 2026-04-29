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

Y te aguantas mas o menos 10 minutos a que termine por gil 

5. *Refresh*

Vas al apartado de SQL server y refrescas el servidor, y podrás ver las
    tablas montadas con los datos cargados