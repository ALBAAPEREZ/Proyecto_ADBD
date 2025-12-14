-- Creación de la base de datos
DROP DATABASE IF EXISTS Logistica_Internacional;
CREATE DATABASE Logistica_Internacional;

-- Conexión al esquema público
\c Logistica_Internacional
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

-- 1. Tablas Maestras (Independientes)
CREATE TABLE pais (
    id_pais SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    iso CHAR(2) UNIQUE
);

CREATE TABLE cliente (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200),
    email VARCHAR(120) UNIQUE,
    telefono VARCHAR(30)
);

CREATE TABLE tipo_incidencia (
    id_tipo_incidencia SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    gravedad VARCHAR(20) CHECK (gravedad IN ('Leve', 'Media', 'Grave'))
);

CREATE TABLE contenedor (
    id_contenedor SERIAL PRIMARY KEY,
    tipo VARCHAR(50),
    capacidad NUMERIC(10,2),
    tara NUMERIC(10,2)
);

CREATE TABLE producto (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    peso NUMERIC(10,2),
    volumen NUMERIC(10,2)
);

-- 2. Herencia (IS_A) - Supertipo
CREATE TABLE transportista (
    id_transportista SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    tipo VARCHAR(20) CHECK (tipo IN ('Aereo','Maritimo','Terrestre'))
);

-- 3. Herencia (IS_A) - Subtipos
CREATE TABLE transportista_aereo (
    id_transportista INT PRIMARY KEY REFERENCES transportista(id_transportista) ON DELETE CASCADE,
    codigo_iata VARCHAR(10)
);

CREATE TABLE transportista_maritimo (
    id_transportista INT PRIMARY KEY REFERENCES transportista(id_transportista) ON DELETE CASCADE,
    codigo_imo VARCHAR(20)
);

CREATE TABLE transportista_terrestre (
    id_transportista INT PRIMARY KEY REFERENCES transportista(id_transportista) ON DELETE CASCADE,
    matricula_base VARCHAR(20)
);

-- 4. Infraestructura y Rutas
CREATE TABLE terminal (
    id_terminal SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    tipo VARCHAR(20) CHECK (tipo IN ('Aereo','Maritimo','Terrestre')),
    id_pais INT REFERENCES pais(id_pais)
);

CREATE TABLE ruta (
    id_ruta SERIAL PRIMARY KEY,
    origen_terminal INT REFERENCES terminal(id_terminal),
    destino_terminal INT REFERENCES terminal(id_terminal),
    distancia NUMERIC(10,2),
    -- CORRECCION: Eliminado 'Aereo' duplicado del check original
    modo VARCHAR(20) CHECK (modo IN ('Aereo','Maritimo','Terrestre')), 
    -- RESTRICCIÓN: Origen != Destino
    CONSTRAINT chk_ruta_distinta CHECK (origen_terminal <> destino_terminal)
);

-- CORRECCIÓN: Tabla Tarifa ahora vinculada a Ruta (antes estaba aislada)
CREATE TABLE tarifa (
    id_tarifa SERIAL PRIMARY KEY,
    id_ruta INT REFERENCES ruta(id_ruta) ON DELETE CASCADE,
    tipo_carga VARCHAR(50),
    precio_base NUMERIC(10,2),
    vigencia_inicio DATE,
    vigencia_fin DATE
);

-- 5. Operaciones Principales (Envios)
CREATE TABLE envio (
    id_envio SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL REFERENCES cliente(id_cliente),
    fecha_salida DATE,
    fecha_llegada DATE,
    estado VARCHAR(30) CHECK (estado IN ('Pendiente','En tránsito','Entregado','Retrasado'))
);

-- ENTIDAD DÉBIL: linea_envio
CREATE TABLE linea_envio (
    id_linea_envio SERIAL PRIMARY KEY,
    id_envio INT NOT NULL REFERENCES envio(id_envio) ON DELETE CASCADE,
    id_producto INT NOT NULL REFERENCES producto(id_producto),
    cantidad INT NOT NULL CHECK (cantidad > 0)
);

CREATE TABLE envio_contenedor (
    id_envio INT REFERENCES envio(id_envio) ON DELETE CASCADE,
    id_contenedor INT REFERENCES contenedor(id_contenedor),
    PRIMARY KEY (id_envio, id_contenedor)
);

-- RELACIÓN TERNARIA: Asignación
CREATE TABLE asignacion (
    id_asignacion SERIAL PRIMARY KEY,
    id_envio INT NOT NULL REFERENCES envio(id_envio) ON DELETE CASCADE,
    id_ruta INT NOT NULL REFERENCES ruta(id_ruta),
    id_transportista INT NOT NULL REFERENCES transportista(id_transportista),
    fecha_programada DATE,
    estado VARCHAR(30)
);

-- 6. Seguimiento e Incidencias
CREATE TABLE trackingevent (
    id_evento SERIAL PRIMARY KEY,
    id_envio INT REFERENCES envio(id_envio),
    id_terminal INT REFERENCES terminal(id_terminal),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT
);

CREATE TABLE incidencia (
    id_incidencia SERIAL PRIMARY KEY,
    id_envio INT REFERENCES envio(id_envio),
    id_tipo_incidencia INT REFERENCES tipo_incidencia(id_tipo_incidencia),
    descripcion TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE aduana (
    id_aduana SERIAL PRIMARY KEY,
    id_envio INT REFERENCES envio(id_envio),
    fecha_inicio DATE,
    fecha_fin DATE,
    estado VARCHAR(20)
);

-- 7. Facturación y Almacén
CREATE TABLE factura (
    id_factura SERIAL PRIMARY KEY,
    id_cliente INT REFERENCES cliente(id_cliente),
    id_envio INT REFERENCES envio(id_envio), -- Vinculada al envio
    fecha_emision DATE,
    total NUMERIC(10,2)
);

CREATE TABLE pago (
    id_pago SERIAL PRIMARY KEY,
    id_factura INT REFERENCES factura(id_factura) ON DELETE CASCADE,
    fecha DATE,
    cantidad NUMERIC(10,2),
    metodo VARCHAR(30)
);

CREATE TABLE almacen (
    id_almacen SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    id_pais INT REFERENCES pais(id_pais)
);

CREATE TABLE movimiento_almacen (
    id_movimiento SERIAL PRIMARY KEY,
    id_envio INT REFERENCES envio(id_envio),
    id_almacen INT REFERENCES almacen(id_almacen),
    fecha TIMESTAMP,
    tipo VARCHAR(20) CHECK (tipo IN ('Entrada','Salida'))
);

CREATE TABLE vehiculo (
    id_vehiculo SERIAL PRIMARY KEY,
    id_transportista INT REFERENCES transportista_terrestre(id_transportista),
    matricula VARCHAR(20),
    capacidad NUMERIC(10,2)
);

CREATE TABLE buque (
    id_buque SERIAL PRIMARY KEY,
    id_transportista INT REFERENCES transportista_maritimo(id_transportista),
    nombre VARCHAR(100),
    capacidad NUMERIC(10,2)
);

CREATE TABLE aeronave (
    id_aeronave SERIAL PRIMARY KEY,
    id_transportista INT REFERENCES transportista_aereo(id_transportista),
    matricula VARCHAR(20),
    capacidad NUMERIC(10,2)
);

-- ---------------------------------------------------------
-- TRIGGER 1: Implementación de Exclusividad en Herencia (IS_A)
-- Garantiza que un transportista 'Aereo' no se inserte en tabla 'Maritimo'
-- ---------------------------------------------------------
CREATE OR REPLACE FUNCTION check_transportista_type() RETURNS TRIGGER AS $$
DECLARE
    tipo_real VARCHAR;
BEGIN
    SELECT tipo INTO tipo_real FROM transportista WHERE id_transportista = NEW.id_transportista;
    
    IF (TG_TABLE_NAME = 'transportista_aereo' AND tipo_real <> 'Aereo') THEN
        RAISE EXCEPTION 'Error: ID corresponde a otro tipo de transporte, no Aereo.';
    ELSIF (TG_TABLE_NAME = 'transportista_maritimo' AND tipo_real <> 'Maritimo') THEN
        RAISE EXCEPTION 'Error: ID corresponde a otro tipo de transporte, no Maritimo.';
    ELSIF (TG_TABLE_NAME = 'transportista_terrestre' AND tipo_real <> 'Terrestre') THEN
        RAISE EXCEPTION 'Error: ID corresponde a otro tipo de transporte, no Terrestre.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_aereo BEFORE INSERT OR UPDATE ON transportista_aereo
FOR EACH ROW EXECUTE FUNCTION check_transportista_type();

CREATE TRIGGER trg_validate_maritimo BEFORE INSERT OR UPDATE ON transportista_maritimo
FOR EACH ROW EXECUTE FUNCTION check_transportista_type();

CREATE TRIGGER trg_validate_terrestre BEFORE INSERT OR UPDATE ON transportista_terrestre
FOR EACH ROW EXECUTE FUNCTION check_transportista_type();
-- ---------------------------------------------------------
-- TRIGGER 2: Validación Semántica en Relación Ternaria
-- Garantiza que si la ruta es Aerea, el transportista sea Aereo
-- ---------------------------------------------------------
CREATE OR REPLACE FUNCTION check_asignacion_match() RETURNS TRIGGER AS $$
DECLARE
    modo_ruta VARCHAR;
    tipo_transp VARCHAR;
BEGIN
    SELECT modo INTO modo_ruta FROM ruta WHERE id_ruta = NEW.id_ruta;
    SELECT tipo INTO tipo_transp FROM transportista WHERE id_transportista = NEW.id_transportista;
    
    IF (modo_ruta <> tipo_transp) THEN
        RAISE EXCEPTION 'Incoherencia semántica: No se puede asignar un transportista % a una ruta %', tipo_transp, modo_ruta;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_asignacion BEFORE INSERT OR UPDATE ON asignacion
FOR EACH ROW EXECUTE FUNCTION check_asignacion_match();


-- =========================================================
-- 5.1. Restricciones sobre valores numéricos
-- (Evitan valores negativos o incoherentes)
-- =========================================================

-- Producto
ALTER TABLE producto
ADD CONSTRAINT chk_producto_peso
CHECK (peso >= 0);

ALTER TABLE producto
ADD CONSTRAINT chk_producto_volumen
CHECK (volumen >= 0);

-- Contenedor
ALTER TABLE contenedor
ADD CONSTRAINT chk_contenedor_capacidad
CHECK (capacidad > 0);

ALTER TABLE contenedor
ADD CONSTRAINT chk_contenedor_tara
CHECK (tara >= 0);
-- Ruta
ALTER TABLE ruta
ADD CONSTRAINT chk_ruta_distancia
CHECK (distancia > 0);

-- Tarifa
ALTER TABLE tarifa
ADD CONSTRAINT chk_tarifa_precio
CHECK (precio_base >= 0);

-- Vehículo
ALTER TABLE vehiculo
ADD CONSTRAINT chk_vehiculo_capacidad
CHECK (capacidad > 0);

-- Buque
ALTER TABLE buque
ADD CONSTRAINT chk_buque_capacidad
CHECK (capacidad > 0);

-- Aeronave
ALTER TABLE aeronave
ADD CONSTRAINT chk_aeronave_capacidad
CHECK (capacidad > 0);

-- Factura
ALTER TABLE factura
ADD CONSTRAINT chk_factura_total
CHECK (total >= 0);

-- Pago
ALTER TABLE pago
ADD CONSTRAINT chk_pago_cantidad
CHECK (cantidad > 0);

-- =========================================================
-- 5.2. Restricciones en entidades débiles
-- (Dependencia existencial y valores válidos)
-- =========================================================

-- Línea de Envío
ALTER TABLE linea_envio
ADD CONSTRAINT chk_linea_envio_cantidad
CHECK (cantidad > 0);

-- =========================================================
-- 5.3. Restricciones temporales (coherencia de fechas)
-- =========================================================

-- Envío: la fecha de llegada no puede ser anterior a la salida
ALTER TABLE envio
ADD CONSTRAINT chk_fechas_envio
CHECK (
    fecha_llegada IS NULL
    OR fecha_llegada >= fecha_salida
);

-- =========================================================
-- 5.3. Restricciones temporales (coherencia de fechas)
-- =========================================================

-- Envío: la fecha de llegada no puede ser anterior a la salida
ALTER TABLE envio
ADD CONSTRAINT chk_fechas_envio
CHECK (
    fecha_llegada IS NULL
    OR fecha_llegada >= fecha_salida
);

-- Tarifa: vigencia correcta
ALTER TABLE tarifa
ADD CONSTRAINT chk_tarifa_fechas
CHECK (
    vigencia_fin IS NULL
    OR vigencia_fin >= vigencia_inicio
);

-- Aduana: fechas de inicio y fin coherentes
ALTER TABLE aduana
ADD CONSTRAINT chk_aduana_fechas
CHECK (
    fecha_fin IS NULL
    OR fecha_fin >= fecha_inicio
);

-- =========================================================
-- Restricciones de dominios cerrados
-- (Valores permitidos según reglas de negocio)
-- =========================================================

-- Envío
ALTER TABLE envio
ADD CONSTRAINT chk_envio_estado
CHECK (estado IN ('Pendiente','En tránsito','Entregado','Retrasado'));

-- Tipo de Incidencia
ALTER TABLE tipo_incidencia
ADD CONSTRAINT chk_gravedad_incidencia
CHECK (gravedad IN ('Leve','Media','Grave'));

-- Terminal
ALTER TABLE terminal
ADD CONSTRAINT chk_terminal_tipo
CHECK (tipo IN ('Aereo','Maritimo','Terrestre'));

-- Ruta
ALTER TABLE ruta
ADD CONSTRAINT chk_ruta_modo
CHECK (modo IN ('Aereo','Maritimo','Terrestre'));

-- Movimiento de Almacén
ALTER TABLE movimiento_almacen
ADD CONSTRAINT chk_movimiento_tipo
CHECK (tipo IN ('Entrada','Salida'));


-- Transportista
ALTER TABLE transportista
ADD CONSTRAINT chk_transportista_tipo
CHECK (tipo IN ('Aereo','Maritimo','Terrestre'));

-- =========================================================
-- Restricciones estructurales adicionales
-- =========================================================

-- Ruta: el terminal de origen y destino deben ser distintos
ALTER TABLE ruta
ADD CONSTRAINT chk_origen_destino_distintos
CHECK (origen_terminal <> destino_terminal);

----------------------------------------------------------
-- Inserciones
----------------------------------------------------------

INSERT INTO pais (nombre, iso) VALUES
('España', 'ES'),
('Francia', 'FR'),
('Alemania', 'DE'),
('Estados Unidos', 'US'),
('China', 'CN');

INSERT INTO cliente (nombre, direccion, email, telefono) VALUES
('TransGlobal S.A.', 'Calle Mayor 10, Madrid, España', 'info@transglobal.es', '+34 912345678'),
('LogiFrance', '10 Rue de la Paix, París, Francia', 'contact@logifrance.fr', '+33 145678910'),
('Berlin Cargo', 'Alexanderplatz 5, Berlín, Alemania', 'ventas@berlincargo.de', '+49 301234567'),
('US Freight Inc.', '500 Market Street, Nueva York, USA', 'contact@usfreight.com', '+1 2125551234');

INSERT INTO tipo_incidencia (nombre, gravedad) VALUES
('Retraso por clima', 'Media'),
('Documento aduanero incompleto', 'Grave'),
('Daño en contenedor', 'Grave'),
('Cambio de ruta', 'Leve');

INSERT INTO contenedor (tipo, capacidad, tara) VALUES
('Contenedor 20 pies', 28.0, 2.3),
('Contenedor 40 pies', 58.0, 3.5),
('Contenedor Refrigerado', 25.0, 3.0);

INSERT INTO producto (nombre, descripcion, peso, volumen) VALUES
('Ordenador portátil', 'Portátil empresarial 15"', 2.5, 0.004),
('Teléfono móvil', 'Smartphone gama media', 0.3, 0.001),
('Monitor', 'Monitor LED 24 pulgadas', 5.2, 0.06),
('Impresora', 'Impresora láser', 8.0, 0.12),
('Mesa oficina', 'Mesa de madera', 20.0, 0.8),
('Silla oficina', 'Silla ergonómica', 10.0, 0.6);

INSERT INTO transportista (nombre, tipo) VALUES
('AirGlobal', 'Aereo'),
('SkyLogistics', 'Aereo'),
('Oceanic Lines', 'Maritimo'),
('BlueSea Cargo', 'Maritimo'),
('RoadExpress', 'Terrestre'),
('EuroTruck', 'Terrestre');

INSERT INTO transportista_aereo (id_transportista, codigo_iata) VALUES
(1, 'AGL'),
(2, 'SKY');

INSERT INTO transportista_maritimo (id_transportista, codigo_imo) VALUES
(3, 'IMO1234567'),
(4, 'IMO7654321');

INSERT INTO transportista_terrestre (id_transportista, matricula_base) VALUES
(5, 'RE-BASE'),
(6, 'ET-BASE');

INSERT INTO terminal (nombre, tipo, id_pais) VALUES
('Aeropuerto Madrid-Barajas', 'Aereo', 1),
('Aeropuerto París-CDG', 'Aereo', 2),
('Aeropuerto Berlín-Brandenburgo', 'Aereo', 3),
('Puerto de Hamburgo', 'Maritimo', 3),
('Puerto de Shanghái', 'Maritimo', 5),
('Puerto de Los Ángeles', 'Maritimo', 4),
('Terminal Madrid Norte', 'Terrestre', 1),
('Terminal París Este', 'Terrestre', 2),
('Terminal Berlín Oeste', 'Terrestre', 3),
('Terminal Nueva York', 'Terrestre', 4);

INSERT INTO ruta (origen_terminal, destino_terminal, distancia, modo) VALUES
(1, 2, 1050, 'Aereo'),
(2, 3, 880, 'Aereo'),
(4, 5, 20000, 'Maritimo'),
(5, 6, 11000, 'Maritimo'),
(7, 8, 1200, 'Terrestre'),
(8, 9, 1000, 'Terrestre'),
(9, 10, 6500, 'Terrestre');

INSERT INTO tarifa (id_ruta, tipo_carga, precio_base, vigencia_inicio, vigencia_fin) VALUES
(1, 'Electrónica', 3000, '2024-01-01', '2024-12-31'),
(2, 'Oficina', 2500, '2024-01-01', '2024-12-31'),
(3, 'Industrial', 8000, '2024-01-01', '2024-12-31'),
(4, 'Comercial', 7500, '2024-01-01', '2024-12-31'),
(5, 'Muebles', 1500, '2024-01-01', '2024-12-31');

INSERT INTO envio (id_cliente, fecha_salida, fecha_llegada, estado) VALUES
(1, '2024-03-01', '2024-03-03', 'Entregado'),
(2, '2024-03-05', '2024-03-07', 'En tránsito'),
(3, '2024-03-10', '2024-03-20', 'Pendiente'),
(4, '2024-03-12', '2024-03-25', 'Retrasado');

INSERT INTO linea_envio (id_envio, id_producto, cantidad) VALUES
(1, 1, 10),
(1, 2, 20),
(2, 3, 15),
(2, 4, 5),
(3, 5, 8),
(4, 6, 12);

INSERT INTO envio_contenedor (id_envio, id_contenedor) VALUES
(1, 1),
(1, 2),
(2, 2),
(3, 3),
(4, 1);

INSERT INTO asignacion (id_envio, id_ruta, id_transportista, fecha_programada, estado) VALUES
(1, 1, 1, '2024-03-01', 'Finalizado'),
(2, 2, 2, '2024-03-05', 'En curso'),
(3, 3, 3, '2024-03-10', 'Pendiente'),
(4, 5, 5, '2024-03-12', 'Retrasado');

INSERT INTO trackingevent (id_envio, id_terminal, descripcion) VALUES
(1, 1, 'Salida del aeropuerto de Madrid'),
(1, 2, 'Llegada al aeropuerto de París'),
(2, 2, 'Salida de París'),
(3, 4, 'Carga en puerto de Hamburgo');

INSERT INTO incidencia (id_envio, id_tipo_incidencia, descripcion) VALUES
(4, 1, 'Retraso por condiciones meteorológicas'),
(3, 2, 'Documentación incompleta en aduana');

INSERT INTO aduana (id_envio, fecha_inicio, fecha_fin, estado) VALUES
(1, '2024-03-01', '2024-03-02', 'Aprobado'),
(3, '2024-03-11', NULL, 'En revisión');

INSERT INTO almacen (nombre, id_pais) VALUES
('Almacén Madrid', 1),
('Almacén París', 2),
('Almacén Berlín', 3),
('Almacén Shanghái', 5);

INSERT INTO movimiento_almacen (id_envio, id_almacen, fecha, tipo) VALUES
(1, 1, '2024-03-01 08:00', 'Entrada'),
(1, 1, '2024-03-03 15:00', 'Salida'),
(2, 2, '2024-03-05 09:00', 'Entrada'),
(3, 4, '2024-03-11 10:30', 'Entrada');

INSERT INTO factura (id_cliente, id_envio, fecha_emision, total) VALUES
(1, 1, '2024-03-03', 12000),
(2, 2, '2024-03-07', 9000),
(3, 3, '2024-03-20', 18000);

INSERT INTO pago (id_factura, fecha, cantidad, metodo) VALUES
(1, '2024-03-03', 12000, 'Transferencia'),
(2, '2024-03-08', 9000, 'Tarjeta'),
(3, '2024-03-21', 10000, 'Transferencia');

INSERT INTO vehiculo (id_transportista, matricula, capacidad) VALUES
(5, 'RE-1234', 18000),
(6, 'ET-5678', 22000);

INSERT INTO buque (id_transportista, nombre, capacidad) VALUES
(3, 'Atlantic Carrier', 60000),
(4, 'Pacific Trader', 55000);

INSERT INTO aeronave (id_transportista, matricula, capacidad) VALUES
(1, 'AG-001', 2500),
(2, 'SK-002', 3000);



