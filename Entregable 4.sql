-- Motor utilizado: PostgreSQL 16
-- ============================================================================
-- SCRIPT DE INGENIERÍA DE DATOS - VENTAS_TECH_DB
-- ============================================================================

-- SECCIÓN 1 — DROP TABLES
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;

-- SECCIÓN 2 — CREATE TABLES
CREATE TABLE categorias (
	id_categoria INT PRIMARY KEY,
	nombre_categoria VARCHAR(50) NOT NULL,
	descripcion VARCHAR(200)
);

CREATE TABLE clientes (
	id_cliente INT PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL,
	email VARCHAR(100) UNIQUE,
	ciudad VARCHAR(50),
	fecha_registro DATE NOT NULL
);

CREATE TABLE productos (
	id_producto INT PRIMARY KEY,
	nombre_producto VARCHAR(100) NOT NULL,
	id_categoria INT NOT NULL,
	precio DECIMAL(10,2) NOT NULL,
	stock INT DEFAULT 0,
	activo BOOLEAN DEFAULT TRUE,
	CONSTRAINT fk_productos_categorias
		FOREIGN KEY (id_categoria) 
		REFERENCES categorias(id_categoria)
);

CREATE TABLE ventas (
	id_venta INT PRIMARY KEY,
	id_cliente INT NOT NULL,
	id_producto INT NOT NULL,
	cantidad INT NOT NULL,
	precio_unitario DECIMAL(10,2) NOT NULL,
	fecha_venta DATE NOT NULL,
	CONSTRAINT fk_ventas_clientes 
		FOREIGN KEY (id_cliente)
		REFERENCES clientes(id_cliente),
	CONSTRAINT fk_ventas_productos
		FOREIGN KEY (id_producto)
		REFERENCES productos(id_producto) 
);

-- SECCIÓN 3 — INSERT DATA
INSERT INTO categorias (id_categoria, nombre_categoria, descripcion) VALUES
  (1, 'Computación',    'Laptops, PCs y monitores'),
  (2, 'Accesorios',     'Periféricos y complementos'),
  (3, 'Audio',          'Auriculares y parlantes'),
  (4, 'Almacenamiento', 'Discos y memorias');

INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
  (1, 'María López',  'maria@mail.com',  'Buenos Aires', '2024-01-05'),
  (2, 'Carlos Ruiz',  'carlos@mail.com', 'Córdoba',      '2024-01-10'),
  (3, 'Ana Gómez',    'ana@mail.com',    'Rosario',      '2024-02-01'),
  (4, 'Pedro Sanz',   'pedro@mail.com',  'Mendoza',      '2024-02-15'),
  (5, 'Laura Torres', 'laura@mail.com',  'Tucumán',      '2024-03-01');

INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES -- Corregido id_producto
  (1, 'Laptop Pro 15',      1, 1200.00, 15, TRUE),
  (2, 'Mouse Inalámbrico',  2,   28.00, 80, TRUE),
  (3, 'Monitor 4K 27',      1,  450.00, 12, TRUE),
  (4, 'Auriculares BT Pro', 3,  120.00, 35, TRUE),
  (5, 'SSD Externo 1TB',    4,  130.00, 18, TRUE),
  (6, 'Teclado Mecánico',   2,   95.00, 40, TRUE);

INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
  ( 1, 1, 1, 2, 1200.00, '2024-03-05'),
  ( 2, 2, 2, 5,   28.00, '2024-03-06'),
  ( 3, 3, 3, 1,  450.00, '2024-03-07'),
  ( 4, 1, 4, 2,  120.00, '2024-03-08'),
  ( 5, 4, 5, 3,  130.00, '2024-03-10'),
  ( 6, 2, 6, 4,   95.00, '2024-03-11'),
  ( 7, 5, 1, 1, 1200.00, '2024-03-12'),
  ( 8, 3, 2, 8,   28.00, '2024-03-13'),
  ( 9, 4, 4, 1,  120.00, '2024-03-14'),
  (10, 5, 3, 2,  450.00, '2024-03-15');

-- SECCIÓN 4 — VALIDACIÓN
SELECT * FROM categorias;
SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM ventas;


-- 1. Resumen Ejecutivo Mensual

SELECT
	EXTRACT(MONTH FROM fecha_venta) AS mes,
	SUM (cantidad * precio_unitario) AS total_facturado,
	COUNT (id_venta) AS cantidad_pedidos,
	ROUND(AVG(cantidad * precio_unitario), 2) AS ticket_promedio
FROM ventas
GROUP BY EXTRACT(MONTH FROM fecha_venta)
ORDER BY mes;

-- 2. Ranking de Productos

SELECT
	id_producto,
	SUM(cantidad * precio_unitario) AS total_facturado
	FROM ventas
	GROUP BY id_producto
	ORDER BY total_facturado DESC
	LIMIT 5;

-- 3. Clientes recurrentes

SELECT
	id_cliente,
	COUNT(id_venta) AS cantidad_pedidos,
	SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(id_venta) > 1
ORDER BY cantidad_pedidos DESC, total_gastado DESC;

-- 4. Meses por encima/por debajo del promedio

WITH facturacion_mensual AS (
	SELECT
		EXTRACT(MONTH FROM fecha_venta) AS mes,
		SUM(cantidad * precio_unitario) AS total_facturado
	FROM ventas
	GROUP BY EXTRACT(MONTH FROM fecha_venta)
)
SELECT
	mes,
	total_facturado,
	CASE
		WHEN total_facturado >= (SELECT AVG (total_facturado) FROM facturacion_mensual)
		THEN 'Por encima'
		ELSE 'Por debajo'
	END AS rendimiento_respecto_promedio
FROM facturacion_mensual
ORDER BY mes;

-- 5. Comentarios finales:

/* 	a) Se ha notado que el producto 'id_producto = 1' (Laptop Pro 15) es el que mas ha
generado ingresos a pesar de que las ventas de la misma han sido minimas. Las ganancias
de las mismas fueron de $3.600,00, la cual representa el 55.86%.
	b) Se informa que los 5 clientes registrados han hecho la misma cantidad de compras
lo que indica que son compradores recurrentes. Se remarca que el id_cliente = 1 
'Maria Lopez' ha sido la que mas ha gastado ($2.640,00 en total).
	c) Se tomo registro de un total de 10 transacciones, el cual arroja un ticket
promedio de $644,40. El id_producto = 2 (Mouse Inalambrico) es el item mas comercializado
de la tienda (13 unidades en total); aun asi el mismo no es parte del Top 5 de facturacion
($364,00) dado que el mismo posee un bajo precio unitario ($28,00).