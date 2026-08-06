-- ═══════════════════════════════════════════════════════
-- Ventas_Tech_DB — Script SQL de Ingeniería de Datos
-- Autor: Iván Emanuel Martínez
-- Fecha: 2026-07-30
-- Motor: SQL Server
-- ═══════════════════════════════════════════════════════


-- ── SECCIÓN 1: CREACIÓN DE LA BASE DE DATOS ───────────

-- Trabajamos desde master para comprobar si la base ya existe.
USE master;
GO

-- Si no existe, crea Ventas_Tech_DB.
IF DB_ID(N'Ventas_Tech_DB') IS NULL
BEGIN
    EXEC(N'CREATE DATABASE Ventas_Tech_DB');
END;
GO

-- Selecciona la base donde se crearán las tablas.
USE Ventas_Tech_DB;
GO


-- ── SECCIÓN 2: DDL — DEFINICIÓN DEL ESQUEMA ───────────

-- DROP elimina las tablas si existen.
-- Se borran primero las que tienen FK para respetar dependencias.
DROP TABLE IF EXISTS dbo.ventas;
DROP TABLE IF EXISTS dbo.productos;
DROP TABLE IF EXISTS dbo.clientes;
DROP TABLE IF EXISTS dbo.categorias;
GO


-- Categorías se crea primero porque productos dependerá de ella.
CREATE TABLE dbo.categorias (
    id_categoria INT PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200)
);
GO


-- Clientes se crea antes que ventas porque será referenciada por una FK.
CREATE TABLE dbo.clientes (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    ciudad VARCHAR(50),
    fecha_registro DATE NOT NULL
);
GO


-- Productos se relaciona con categorías mediante id_categoria.
CREATE TABLE dbo.productos (
    id_producto INT PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    id_categoria INT NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    activo TINYINT NOT NULL DEFAULT 1,

    CONSTRAINT FK_productos_categorias
        FOREIGN KEY (id_categoria)
        REFERENCES dbo.categorias(id_categoria)
);
GO


-- Ventas es la tabla central y relaciona clientes con productos.
CREATE TABLE dbo.ventas (
    id_venta INT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    fecha_venta DATE NOT NULL,

    CONSTRAINT FK_ventas_clientes
        FOREIGN KEY (id_cliente)
        REFERENCES dbo.clientes(id_cliente),

    CONSTRAINT FK_ventas_productos
        FOREIGN KEY (id_producto)
        REFERENCES dbo.productos(id_producto)
);
GO


-- ── SECCIÓN 3: DML — CARGA INICIAL DE DATOS ───────────

-- Se cargan primero las categorías porque productos depende de ellas.
INSERT INTO dbo.categorias (
    id_categoria,
    nombre_categoria,
    descripcion
)
VALUES
    (1, 'Computación', 'Laptops, PCs y monitores'),
    (2, 'Accesorios', 'Periféricos y complementos'),
    (3, 'Audio', 'Auriculares y parlantes'),
    (4, 'Almacenamiento', 'Discos y memorias');
GO


-- Los clientes deben existir antes de registrar sus ventas.
INSERT INTO dbo.clientes (
    id_cliente,
    nombre,
    email,
    ciudad,
    fecha_registro
)
VALUES
    (1, 'María López',  'maria@mail.com',  'Buenos Aires', '2024-01-05'),
    (2, 'Carlos Ruiz',  'carlos@mail.com', 'Córdoba',       '2024-01-10'),
    (3, 'Ana Gómez',    'ana@mail.com',    'Rosario',       '2024-02-01'),
    (4, 'Pedro Sanz',   'pedro@mail.com',  'Mendoza',       '2024-02-15'),
    (5, 'Laura Torres', 'laura@mail.com',  'Tucumán',       '2024-03-01');
GO


-- Cada producto utiliza una categoría previamente cargada.
INSERT INTO dbo.productos (
    id_producto,
    nombre_producto,
    id_categoria,
    precio,
    stock,
    activo
)
VALUES
    (1, 'Laptop Pro 15',      1, 1200.00, 15, 1),
    (2, 'Mouse Inalámbrico',  2,   28.00, 80, 1),
    (3, 'Monitor 4K 27"',     1,  450.00, 12, 1),
    (4, 'Auriculares BT Pro', 3,  120.00, 35, 1),
    (5, 'SSD Externo 1TB',    4,  130.00, 18, 1),
    (6, 'Teclado Mecánico',   2,   95.00, 40, 1);
GO


-- Ventas se carga al final porque necesita clientes y productos existentes.
INSERT INTO dbo.ventas (
    id_venta,
    id_cliente,
    id_producto,
    cantidad,
    precio_unitario,
    fecha_venta
)
VALUES
    (1,  1, 1, 2, 1200.00, '2024-03-05'),
    (2,  2, 2, 5,   28.00, '2024-03-06'),
    (3,  3, 3, 1,  450.00, '2024-03-07'),
    (4,  1, 4, 2,  120.00, '2024-03-08'),
    (5,  4, 5, 3,  130.00, '2024-03-10'),
    (6,  2, 6, 4,   95.00, '2024-03-11'),
    (7,  5, 1, 1, 1200.00, '2024-03-12'),
    (8,  3, 2, 8,   28.00, '2024-03-13'),
    (9,  4, 4, 1,  120.00, '2024-03-14'),
    (10, 5, 3, 2,  450.00, '2024-03-15'),
        -- Agrego ventas de otros meses para poder comparar
    -- los resultados mensuales en el Módulo 4.

    -- Ventas de enero
    (11, 1, 1, 1, 1200.00, '2024-01-10'),
    (12, 2, 2, 5,   28.00, '2024-01-18'),

    -- Ventas de febrero
    (13, 3, 3, 2,  450.00, '2024-02-05'),
    (14, 4, 5, 4,  130.00, '2024-02-14'),
    (15, 5, 6, 3,   95.00, '2024-02-22'),

    -- Ventas de abril
    (16, 1, 1, 2, 1200.00, '2024-04-03'),
    (17, 2, 3, 2,  450.00, '2024-04-11'),
    (18, 3, 4, 2,  120.00, '2024-04-19'),
    (19, 4, 2, 5,   28.00, '2024-04-25');
GO


-- ── SECCIÓN 4: VALIDACIÓN ──────────────────────────────

-- SELECT * muestra todas las columnas y registros de cada tabla.
SELECT * FROM dbo.categorias;
SELECT * FROM dbo.clientes;
SELECT * FROM dbo.productos;
SELECT * FROM dbo.ventas;


