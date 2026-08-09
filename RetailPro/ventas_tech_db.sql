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

-- Borro primero las tablas que dependen de otras para evitar
-- problemas con las relaciones entre ellas.

DROP TABLE IF EXISTS dbo.ventas;
DROP TABLE IF EXISTS dbo.productos;
DROP TABLE IF EXISTS dbo.clientes;
DROP TABLE IF EXISTS dbo.categorias;
DROP TABLE IF EXISTS dbo.territorios;
GO


-- Creo las categorías que después voy a usar
-- para clasificar los productos.

CREATE TABLE dbo.categorias (
    id_categoria INT PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200)
);
GO


-- Creo los territorios para poder identificar
-- la región a la que pertenece cada cliente.

CREATE TABLE dbo.territorios (
    id_territorio INT PRIMARY KEY,
    region VARCHAR(50) NOT NULL
);
GO


-- En clientes guardo también el segmento y el territorio
-- para después poder analizar las ventas por tipo de cliente y región.

CREATE TABLE dbo.clientes (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    ciudad VARCHAR(50),
    segmento VARCHAR(50) NOT NULL,
    id_territorio INT NOT NULL,
    fecha_registro DATE NOT NULL,

    CONSTRAINT FK_clientes_territorios
        FOREIGN KEY (id_territorio)
        REFERENCES dbo.territorios(id_territorio)
);
GO


-- Cada producto queda relacionado con una categoría.
-- También guardo su precio, stock y si está activo.

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


-- Ventas relaciona al cliente con el producto que compró.
-- También guardo el canal porque en M5 voy a comparar
-- las operaciones Online y Presencial.

CREATE TABLE dbo.ventas (
    id_venta INT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    fecha_venta DATE NOT NULL,
    canal VARCHAR(20) NOT NULL,

    CONSTRAINT FK_ventas_clientes
        FOREIGN KEY (id_cliente)
        REFERENCES dbo.clientes(id_cliente),

    CONSTRAINT FK_ventas_productos
        FOREIGN KEY (id_producto)
        REFERENCES dbo.productos(id_producto)
);
GO

-- ── SECCIÓN 3: DML — CARGA INICIAL DE DATOS ───────────

-- Cargo primero las categorías porque los productos
-- necesitan tener una categoría asignada.

INSERT INTO dbo.categorias (
    id_categoria,
    nombre_categoria,
    descripcion
)
VALUES
    (1, 'Computación',    'Laptops, PCs y monitores'),
    (2, 'Accesorios',     'Periféricos y complementos'),
    (3, 'Audio',          'Auriculares y parlantes'),
    (4, 'Almacenamiento', 'Discos y memorias');
GO


-- Defino algunas regiones para después poder analizar
-- de dónde provienen los clientes y sus ventas.

INSERT INTO dbo.territorios (
    id_territorio,
    region
)
VALUES
    (1, 'AMBA'),
    (2, 'Centro'),
    (3, 'Cuyo'),
    (4, 'Norte');
GO


-- Cargo los clientes indicando su segmento y la región
-- a la que pertenecen.
-- Dejo un cliente sin compras para poder detectarlo
-- después con LEFT JOIN en el Módulo 5.

INSERT INTO dbo.clientes (
    id_cliente,
    nombre,
    email,
    ciudad,
    segmento,
    id_territorio,
    fecha_registro
)
VALUES
    (1, 'María López',    'maria@mail.com',  'Buenos Aires', 'Premium',     1, '2024-01-05'),
    (2, 'Carlos Ruiz',    'carlos@mail.com', 'Córdoba',      'Regular',     2, '2024-01-10'),
    (3, 'Ana Gómez',      'ana@mail.com',    'Rosario',      'Premium',     2, '2024-02-01'),
    (4, 'Pedro Sanz',     'pedro@mail.com',  'Mendoza',      'Corporativo', 3, '2024-02-15'),
    (5, 'Laura Torres',   'laura@mail.com',  'Tucumán',      'Regular',     4, '2024-03-01'),
    (6, 'Sofía Herrera',  'sofia@mail.com',  'Buenos Aires', 'Regular',     1, '2024-03-20');
GO


-- Cada producto queda relacionado con una categoría.
-- También dejo un producto sin ventas para identificarlo
-- después en la consulta de productos sin movimiento.

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
    (6, 'Teclado Mecánico',   2,   95.00, 40, 1),
    (7, 'Webcam Full HD',     2,   75.00, 25, 1);
GO


-- Cargo las ventas al final porque primero tienen que existir
-- los clientes y los productos.
-- También indico si cada operación fue Online o Presencial.

INSERT INTO dbo.ventas (
    id_venta,
    id_cliente,
    id_producto,
    cantidad,
    precio_unitario,
    fecha_venta,
    canal
)
VALUES
    -- Ventas de marzo
    (1,  1, 1, 2, 1200.00, '2024-03-05', 'Online'),
    (2,  2, 2, 5,   28.00, '2024-03-06', 'Presencial'),
    (3,  3, 3, 1,  450.00, '2024-03-07', 'Online'),
    (4,  1, 4, 2,  120.00, '2024-03-08', 'Presencial'),
    (5,  4, 5, 3,  130.00, '2024-03-10', 'Online'),
    (6,  2, 6, 4,   95.00, '2024-03-11', 'Presencial'),
    (7,  5, 1, 1, 1200.00, '2024-03-12', 'Online'),
    (8,  3, 2, 8,   28.00, '2024-03-13', 'Online'),
    (9,  4, 4, 1,  120.00, '2024-03-14', 'Presencial'),
    (10, 5, 3, 2,  450.00, '2024-03-15', 'Online'),

    -- Ventas de enero
    (11, 1, 1, 1, 1200.00, '2024-01-10', 'Presencial'),
    (12, 2, 2, 5,   28.00, '2024-01-18', 'Online'),

    -- Ventas de febrero
    (13, 3, 3, 2,  450.00, '2024-02-05', 'Online'),
    (14, 4, 5, 4,  130.00, '2024-02-14', 'Presencial'),
    (15, 5, 6, 3,   95.00, '2024-02-22', 'Online'),

    -- Ventas de abril
    (16, 1, 1, 2, 1200.00, '2024-04-03', 'Presencial'),
    (17, 2, 3, 2,  450.00, '2024-04-11', 'Online'),
    (18, 3, 4, 2,  120.00, '2024-04-19', 'Presencial'),
    (19, 4, 2, 5,   28.00, '2024-04-25', 'Online');
GO

-- ── SECCIÓN 4: VALIDACIÓN ──────────────────────────────

-- Uso SELECT * solamente acá para revisar que las tablas
-- se hayan creado y cargado correctamente.
-- Para un análisis real conviene elegir solo las columnas necesarias.

SELECT * FROM dbo.categorias;
SELECT * FROM dbo.territorios;
SELECT * FROM dbo.clientes;
SELECT * FROM dbo.productos;
SELECT * FROM dbo.ventas;
GO


