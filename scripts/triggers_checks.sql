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
-- Restricciones sobre valores numéricos
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
-- Restricciones en entidades débiles
-- (Dependencia existencial y valores válidos)
-- =========================================================

-- Línea de Envío
ALTER TABLE linea_envio
ADD CONSTRAINT chk_linea_envio_cantidad
CHECK (cantidad > 0);

-- =========================================================
-- Restricciones temporales (coherencia de fechas)
-- =========================================================

-- Envío: la fecha de llegada no puede ser anterior a la salida
ALTER TABLE envio
ADD CONSTRAINT chk_fechas_envio
CHECK (
    fecha_llegada IS NULL
    OR fecha_llegada >= fecha_salida
);

-- =========================================================
-- Restricciones temporales (coherencia de fechas)
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
