-- ============================================================
-- PROYECTO: RetailPro
-- TÍTULO: Extrayendo métricas clave con SQL
-- PRÁCTICA: Módulo 4 - Consultas SQL de negocio
-- AUTOR: Ivan Emanuel Martinez
-- FECHA: 05/08/2026
-- MOTOR: SQL Server
-- ARCHIVO: m4_consultas_negocio.sql
-- ============================================================

-- Trabajo sobre la base de datos creada en el Módulo 3.
-- La carga original tenía ventas solamente de marzo.
-- Para poder realizar una comparación mensual útil,
-- amplié en el Módulo 3 los datos de prueba con ventas
-- correspondientes a enero, febrero y abril.

USE Ventas_Tech_DB;
GO

-- ============================================================
-- CONSULTA 1: RESUMEN EJECUTIVO MENSUAL
-- ============================================================

-- Uso MONTH para separar las ventas según el mes.
-- Multiplico la cantidad por el precio para obtener lo facturado.
-- También cuento los pedidos y calculo el ticket promedio mensual.

SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    CAST(
        AVG(cantidad * precio_unitario)
        AS DECIMAL(10,2)
    ) AS ticket_promedio
FROM dbo.ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;


-- ============================================================
-- CONSULTA 2: RANKING DE PRODUCTOS
-- ============================================================

-- Agrupo las ventas por producto para conocer las unidades vendidas
-- y el dinero generado por cada uno.
-- Ordeno de mayor a menor y muestro los cinco primeros.

SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM dbo.ventas
GROUP BY id_producto
ORDER BY total_generado DESC;


-- ============================================================
-- CONSULTA 3: CLIENTES RECURRENTES
-- ============================================================

-- Agrupo las ventas por cliente y cuento sus pedidos.
-- Uso HAVING porque necesito quedarme solamente con los clientes
-- que realizaron más de una compra.

SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM dbo.ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;


-- ============================================================
-- CONSULTA 4: COMPARACIÓN CON EL PROMEDIO MENSUAL
-- ============================================================

-- Primero obtengo el total facturado y el promedio mensual.
-- Después uso CASE para indicar si cada mes quedó por encima,
-- por debajo o exactamente igual al promedio.

SELECT
    mes,
    total_facturado,
    promedio_mensual,

    CASE
        WHEN total_facturado > promedio_mensual
            THEN 'Por encima'
        WHEN total_facturado < promedio_mensual
            THEN 'Por debajo'
        ELSE 'Igual al promedio'
    END AS comparacion_con_promedio

FROM (
    SELECT
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado,

        (
            SELECT AVG(total_mensual)
            FROM (
                SELECT
                    SUM(cantidad * precio_unitario) AS total_mensual
                FROM dbo.ventas
                GROUP BY MONTH(fecha_venta)
            ) AS ventas_por_mes
        ) AS promedio_mensual

    FROM dbo.ventas
    GROUP BY MONTH(fecha_venta)

) AS resumen_mensual

ORDER BY mes;


-- ============================================================
-- DATOS QUE RESPALDAN LAS CONCLUSIONES
-- ============================================================


-- HALLAZGO 1: MES CON MAYOR FACTURACIÓN

-- Busco el mes que más facturó y calculo qué porcentaje
-- representa sobre toda la facturación analizada.

SELECT TOP 1
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,

    CAST(
        SUM(cantidad * precio_unitario) * 100.0 /
        (
            SELECT SUM(cantidad * precio_unitario)
            FROM dbo.ventas
        )
        AS DECIMAL(5,2)
    ) AS porcentaje_del_total

FROM dbo.ventas
GROUP BY MONTH(fecha_venta)
ORDER BY total_facturado DESC;


-- HALLAZGO 2: PRODUCTO CON MAYOR FACTURACIÓN

-- Busco el producto que más dinero generó.
-- También muestro sus unidades vendidas y su participación
-- dentro de la facturación total.

SELECT TOP 1
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado,

    CAST(
        SUM(cantidad * precio_unitario) * 100.0 /
        (
            SELECT SUM(cantidad * precio_unitario)
            FROM dbo.ventas
        )
        AS DECIMAL(5,2)
    ) AS porcentaje_del_total

FROM dbo.ventas
GROUP BY id_producto
ORDER BY total_generado DESC;


-- HALLAZGO 3: CLIENTE CON MAYOR GASTO

-- Busco el cliente que más gastó.
-- Además, muestro sus pedidos y el porcentaje que representa
-- sobre la facturación total.

SELECT TOP 1
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado,

    CAST(
        SUM(cantidad * precio_unitario) * 100.0 /
        (
            SELECT SUM(cantidad * precio_unitario)
            FROM dbo.ventas
        )
        AS DECIMAL(5,2)
    ) AS porcentaje_del_total

FROM dbo.ventas
GROUP BY id_cliente
ORDER BY total_gastado DESC;


-- ============================================================
-- CONCLUSIONES DEL ANÁLISIS
-- ============================================================

-- 1. Marzo fue el mes con mayor facturación, con USD 6.444,00,
--    y concentró el 48,93% de la facturación total analizada.

-- 2. El producto 1 lideró el ranking de facturación:
--    vendió 6 unidades, generó USD 7.200,00
--    y representó el 54,67% de la facturación total.

-- 3. El cliente 1 fue el cliente con mayor gasto:
--    realizó 4 pedidos por un total de USD 6.240,00
--    y concentró el 47,38% de la facturación total.