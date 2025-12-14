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