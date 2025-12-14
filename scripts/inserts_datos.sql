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



