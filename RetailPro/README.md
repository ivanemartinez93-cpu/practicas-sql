# RetailPro — Proyecto de análisis de ventas

RetailPro es un proyecto de análisis de datos desarrollado con SQL para estudiar el desempeño comercial de una empresa de retail.

El objetivo es transformar los datos de ventas en información útil para la toma de decisiones, analizando indicadores como facturación, cantidad de pedidos, ticket promedio, desempeño de productos y concentración de ventas por cliente.

## Herramientas utilizadas

- SQL Server
- SQL Server Management Studio (SSMS)
- GitHub
- Power BI

## Estructura del proyecto

La carpeta `RetailPro` contiene los siguientes archivos:

- `ventas_tech_db.sql`: crea la base de datos, las tablas y carga los datos necesarios para el proyecto.
- `m4_consultas_negocio.sql`: contiene consultas orientadas al análisis comercial mediante agregaciones, métricas, rankings y comparaciones.
- `m5_consultas_joins.sql`: integra información de distintas tablas mediante `INNER JOIN`, `LEFT JOIN` y `UNION ALL`.
- `README.md`: documentación general del proyecto.

## Análisis desarrollados

Las consultas permiten analizar, entre otros aspectos:

- facturación mensual;
- cantidad de pedidos;
- ticket promedio;
- productos con mayor aporte a la facturación;
- clientes con mayor participación en las ventas;
- relaciones entre ventas, clientes, productos y categorías.

## Orden de ejecución

1. Abrir SQL Server Management Studio y conectarse a la instancia correspondiente.

2. Ejecutar primero:

`ventas_tech_db.sql`

Este script crea la estructura de la base de datos y carga los datos necesarios.

3. Ejecutar luego:

`m4_consultas_negocio.sql`

Este archivo contiene las consultas de análisis comercial, métricas, rankings y comparaciones mensuales.

4. Finalmente ejecutar:

`m5_consultas_joins.sql`

Este script utiliza JOINs para relacionar la información almacenada en las diferentes tablas y ampliar el análisis.

## Enfoque del proyecto

El proyecto busca que las consultas SQL no se limiten a mostrar registros, sino que permitan responder preguntas de negocio y detectar patrones relevantes para la toma de decisiones comerciales.

La interpretación de los resultados se realiza verificando que cada conclusión pueda rastrearse hasta los datos obtenidos mediante las consultas SQL.

## Autor

Iván Emanuel Martínez
