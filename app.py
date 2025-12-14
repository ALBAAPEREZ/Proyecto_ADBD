import psycopg2
from flask import Flask, jsonify, request

app = Flask(__name__)

# --- 1. CONFIGURACIÓN DE LA BASE DE DATOS ---
def get_db_connection():
    try:
        conn = psycopg2.connect(
            host='localhost',
            database='Logistica_Internacional',
            user='postgres',
            password='Eric1234'
        )
        return conn
    except Exception as e:
        print(f"Error conectando a la BD: {e}")
        return None

# --- RUTA DE BIENVENIDA ---
@app.route('/', methods=['GET'])
def home():
    return jsonify({'mensaje': 'API de Logística Internacional Operativa', 'estado': 'online'})

# --- RUTA 1: OBTENER CLIENTES (GET) ---
@app.route('/api/clientes', methods=['GET'])
def obtener_clientes():
    conn = get_db_connection()
    if conn is None:
        return jsonify({'error': 'Error de conexión a BD'}), 500

    cur = conn.cursor()
    try:
        cur.execute('SELECT id_cliente, nombre, email, telefono FROM cliente;')
        filas = cur.fetchall()

        lista_clientes = []
        for fila in filas:
            lista_clientes.append({
                'id': fila[0],
                'nombre': fila[1],
                'email': fila[2],
                'telefono': fila[3]
            })
        return jsonify({'clientes': lista_clientes}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        cur.close()
        conn.close()

# --- RUTA 2: OBTENER ENVÍOS DE UN CLIENTE (GET) ---
@app.route('/api/envios', methods=['GET'])
def obtener_envios():
    id_cliente = request.args.get('id_cliente')

    if not id_cliente:
        return jsonify({'error': 'Falta el parámetro id_cliente'}), 400

    conn = get_db_connection()
    cur = conn.cursor()
    try:
        query = """
            SELECT id_envio, fecha_salida, estado, fecha_llegada
            FROM envio
            WHERE id_cliente = %s;
        """
        cur.execute(query, (id_cliente,))
        filas = cur.fetchall()

        lista_envios = []
        for fila in filas:
            lista_envios.append({
                'tracking_id': fila[0],
                'salida': str(fila[1]),
                'estado': fila[2],
                'llegada_estimada': str(fila[3]) if fila[3] else "Pendiente"
            })

        return jsonify({'envios': lista_envios}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        cur.close()
        conn.close()

# --- RUTA 3: CREAR UN NUEVO ENVÍO (POST) ---
@app.route('/api/envios/nuevo', methods=['POST'])
def crear_envio():
    datos = request.get_json()

    # Validamos que lleguen los datos
    if not datos or 'id_cliente' not in datos or 'fecha_salida' not in datos:
        return jsonify({'error': 'Faltan datos obligatorios (id_cliente, fecha_salida)'}), 400

    conn = get_db_connection()
    cur = conn.cursor()
    try:
        # Insertamos y devolvemos el ID generado
        query = """
            INSERT INTO envio (id_cliente, fecha_salida, estado)
            VALUES (%s, %s, 'Pendiente')
            RETURNING id_envio;
        """
        cur.execute(query, (datos['id_cliente'], datos['fecha_salida']))
        nuevo_id = cur.fetchone()[0]
        conn.commit() # Guardar cambios

        return jsonify({'mensaje': 'Envío creado con éxito', 'id_generado': nuevo_id}), 201
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        cur.close()
        conn.close()

# --- RUTA 4: ELIMINAR ENVÍO (DELETE) ---
@app.route('/api/envios/eliminar', methods=['DELETE'])
def eliminar_envio():
    id_envio = request.args.get('id_envio')

    if not id_envio:
        return jsonify({'error': 'Falta el parámetro id_envio'}), 400

    conn = get_db_connection()
    cur = conn.cursor()
    try:
        # Verificamos si existe primero
        cur.execute('SELECT id_envio FROM envio WHERE id_envio = %s', (id_envio,))
        if not cur.fetchone():
            return jsonify({'error': 'El envío no existe'}), 404

        # Borramos
        cur.execute('DELETE FROM envio WHERE id_envio = %s', (id_envio,))
        conn.commit()
        return jsonify({'mensaje': f'Envío {id_envio} eliminado correctamente'}), 200
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        cur.close()
        conn.close()

# --- ARRANQUE DEL SERVIDOR ---
if __name__ == '__main__':
    print("--> API LISTA EN PUERTO 8080")
    app.run(host='0.0.0.0', port=8080, debug=True)

