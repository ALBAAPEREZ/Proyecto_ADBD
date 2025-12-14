--------------------------------
-- SCRIPTS DE CONSULTAS PARA VERIFICAR DATOS
--------------------------------

-- Seleccionar todos los envíos junto con el nombre del cliente asociado
SELECT c.nombre AS cliente, e.id_envio, e.estado, e.fecha_salida
FROM envio e
JOIN cliente c ON e.id_cliente = c.id_cliente;

-- Comprobar los productos en cada envío
SELECT e.id_envio, p.nombre AS producto, l.cantidad
FROM envio e
JOIN linea_envio l ON e.id_envio = l.id_envio
JOIN producto p ON l.id_producto = p.id_producto;

-- Comprobamos rutas con origen y destino
SELECT 
  r.id_ruta,
  t1.nombre AS origen,
  t2.nombre AS destino,
  r.modo
FROM ruta r
JOIN terminal t1 ON r.origen_terminal = t1.id_terminal
JOIN terminal t2 ON r.destino_terminal = t2.id_terminal;

-- Ccomporbamos pagos asociados a facturas
SELECT 
  f.id_factura,
  p.fecha,
  p.cantidad,
  p.metodo
FROM factura f
JOIN pago p ON f.id_factura = p.id_factura;

-- Comporbamos incidencias con su gravedad y tipo
SELECT 
  e.id_envio,
  ti.nombre AS tipo_incidencia,
  ti.gravedad,
  i.descripcion
FROM incidencia i
JOIN envio e ON i.id_envio = e.id_envio
JOIN tipo_incidencia ti ON i.id_tipo_incidencia = ti.id_tipo_incidencia;

-- Comporbamos movimientos de almacén asociados a envíos
SELECT 
  e.id_envio,
  a.nombre AS almacen,
  m.tipo,
  m.fecha
FROM movimiento_almacen m
JOIN envio e ON m.id_envio = e.id_envio
JOIN almacen a ON m.id_almacen = a.id_almacen;

-- Comprobar asignaciones de envíos a rutas y transportistas
SELECT 
    e.id_envio,
    tr.nombre AS transportista,
    r.id_ruta,
    r.modo,
    a.fecha_programada
FROM asignacion a
JOIN envio e ON a.id_envio = e.id_envio
JOIN transportista tr ON a.id_transportista = tr.id_transportista
JOIN ruta r ON a.id_ruta = r.id_ruta;

-------------------------------------------
-- INSERTS ERRONEOS PARA PROBAR RESTRICCIONES
-------------------------------------------

-- RUta con mismo terminal de origen y destino
INSERT INTO ruta (origen_terminal, destino_terminal, distancia, modo)
VALUES (1, 1, 500, 'Aereo');

-- Cantidad negativa en línea de envío
INSERT INTO linea_envio (id_envio, id_producto, cantidad)
VALUES (1, 1, -5);

-- Asignación con transportista de tipo incorrecto
INSERT INTO asignacion (id_envio, id_ruta, id_transportista, fecha_programada)
VALUES (1, 1, 5, '2024-04-01');

-- Fecha de fin de aduana anterior a fecha de inicio
INSERT INTO envio (id_cliente, fecha_salida, fecha_llegada, estado)
VALUES (1, '2024-06-10', '2024-06-01', 'Pendiente');

-- Tarifa con fecha de vigencia fin anterior a vigencia inicio
INSERT INTO tarifa (id_ruta, tipo_carga, precio_base, vigencia_inicio, vigencia_fin)
VALUES (1, 'General', 500, '2024-06-10', '2024-05-01');

-- Movimiento de almacén con tipo inválido
INSERT INTO movimiento_almacen (id_envio, id_almacen, fecha, tipo)
VALUES (1, 1, CURRENT_TIMESTAMP, 'Transferencia');

--------------------------------
-- CONSULTA REGLAS DE NEGOCIO
--------------------------------

-- Envíos retrasados con sus incidencias asociadas
SELECT e.id_envio, e.estado, i.descripcion
FROM envio e
JOIN incidencia i ON e.id_envio = i.id_envio
WHERE e.estado = 'Retrasado';

-- Envios sin pasar por aduana
SELECT e.id_envio
FROM envio e
LEFT JOIN aduana a ON e.id_envio = a.id_envio
WHERE a.id_aduana IS NULL;

-- Envios con incidencias graves
SELECT 
    e.id_envio,
    ti.nombre,
    ti.gravedad
FROM incidencia i
JOIN tipo_incidencia ti ON i.id_tipo_incidencia = ti.id_tipo_incidencia
JOIN envio e ON i.id_envio = e.id_envio
WHERE ti.gravedad = 'Grave';

-- Envios sin factura asociada
SELECT e.id_envio
FROM envio e
LEFT JOIN factura f ON e.id_envio = f.id_envio
WHERE f.id_factura IS NULL;

------------------------------------
-- CONSULTAS DE VERIFICACIÓN DE RESTRICCIONES
------------------------------------

-- Facturación total por cliente
SELECT c.nombre, SUM(f.total) AS facturacion_total
FROM cliente c
JOIN factura f ON c.id_cliente = f.id_cliente
GROUP BY c.nombre;

-- Seguimiento de un envío específico
SELECT e.id_envio, t.nombre AS terminal, te.fecha, te.descripcion
FROM trackingevent te
JOIN envio e ON te.id_envio = e.id_envio
JOIN terminal t ON te.id_terminal = t.id_terminal
WHERE e.id_envio = 1
ORDER BY te.fecha;

-- Número de asignaciones por tipo de transporte
SELECT r.modo, COUNT(a.id_asignacion) AS total_asignaciones
FROM asignacion a
JOIN ruta r ON a.id_ruta = r.id_ruta
GROUP BY r.modo;


-- Número de envíos por país de origen
SELECT 
    p.nombre AS pais,
    COUNT(e.id_envio) AS total_envios
FROM envio e
JOIN asignacion a ON e.id_envio = a.id_envio
JOIN ruta r ON a.id_ruta = r.id_ruta
JOIN terminal t ON r.origen_terminal = t.id_terminal
JOIN pais p ON t.id_pais = p.id_pais
GROUP BY p.nombre;

-- Total facturado por envío
SELECT 
    e.id_envio,
    SUM(f.total) AS total_facturado
FROM envio e
JOIN factura f ON e.id_envio = f.id_envio
GROUP BY e.id_envio;


