-- ============================================================
-- PROYECTO: RetailPro
-- TÍTULO: Cruzando tablas para enriquecer el análisis
-- PRÁCTICA: Módulo 5 - Consultas con JOINs
-- AUTOR: Iván Emanuel Martínez
-- FECHA: 09/08/2026
-- MOTOR: SQL Server
-- ARCHIVO: m5_consultas_joins.sql
-- ============================================================

-- Trabajo sobre la base que preparé en el Módulo 3.
USE Ventas_Tech_DB;
GO

-- ============================================================
-- CONSULTA 1: VISTA BASE DEL PROYECTO
-- ============================================================

-- Cruzo las tablas para tener en una sola consulta
-- los datos de la venta, del cliente y del producto.
-- También traigo la región y la categoría para dejar
-- preparada la información que después voy a usar en Power BI.

SELECT
    v.fecha_venta AS fecha,
    cl.nombre AS cliente,
    cl.segmento,
    t.region,
    p.nombre_producto AS producto,
    c.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta,
    v.canal
FROM dbo.ventas AS v
INNER JOIN dbo.clientes AS cl
    ON v.id_cliente = cl.id_cliente
INNER JOIN dbo.territorios AS t
    ON cl.id_territorio = t.id_territorio
INNER JOIN dbo.productos AS p
    ON v.id_producto = p.id_producto
INNER JOIN dbo.categorias AS c
    ON p.id_categoria = c.id_categoria
ORDER BY v.fecha_venta;

-- ============================================================
-- CONSULTA 2: CLIENTES SIN VENTAS
-- ============================================================

-- Parto desde clientes porque quiero revisar a todos los registrados.
-- Con LEFT JOIN mantengo también a los que todavía no tienen compras.
-- Cuando id_venta queda en NULL significa que ese cliente no aparece en ventas.

SELECT
    cl.nombre AS cliente,
    cl.email,
    cl.fecha_registro
FROM dbo.clientes AS cl
LEFT JOIN dbo.ventas AS v
    ON cl.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

-- ============================================================
-- CONSULTA 3: PRODUCTOS SIN VENTAS
-- ============================================================

-- Parto desde productos porque quiero revisar todo el catálogo.
-- Con LEFT JOIN también conservo los productos que nunca se vendieron.
-- Traigo la categoría para que el resultado quede más claro.

SELECT
    p.nombre_producto AS producto,
    c.nombre_categoria AS categoria,
    p.precio
FROM dbo.productos AS p
INNER JOIN dbo.categorias AS c
    ON p.id_categoria = c.id_categoria
LEFT JOIN dbo.ventas AS v
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;

-- ============================================================
-- CONSULTA 4: CONSOLIDADO POR CANAL
-- ============================================================

-- Separo las ventas Online de las Presenciales y las vuelvo
-- a juntar con UNION ALL para conservar todas las operaciones.
-- Después agrupo por canal para comparar cuánto facturó cada uno.

SELECT
    canal,
    SUM(total_venta) AS total_facturado
FROM (

    SELECT
        'Online' AS canal,
        cantidad * precio_unitario AS total_venta
    FROM dbo.ventas
    WHERE canal = 'Online'

    UNION ALL

    SELECT
        'Presencial' AS canal,
        cantidad * precio_unitario AS total_venta
    FROM dbo.ventas
    WHERE canal = 'Presencial'

) AS ventas_por_canal

GROUP BY canal
ORDER BY total_facturado DESC;