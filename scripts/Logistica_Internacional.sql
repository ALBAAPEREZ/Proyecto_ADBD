--
-- PostgreSQL database dump
--

\restrict MMV4aJlkcQiAj0uJqLs3i2MclUl0AObhegI5sKUFe35VFFHnbNnSbHqSiipRFTC

-- Dumped from database version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 17.6

-- Started on 2025-12-14 19:42:10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE "Logistica_Internacional";
--
-- TOC entry 3689 (class 1262 OID 17741)
-- Name: Logistica_Internacional; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "Logistica_Internacional" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'es_ES.UTF-8';


ALTER DATABASE "Logistica_Internacional" OWNER TO postgres;

\unrestrict MMV4aJlkcQiAj0uJqLs3i2MclUl0AObhegI5sKUFe35VFFHnbNnSbHqSiipRFTC
\connect "Logistica_Internacional"
\restrict MMV4aJlkcQiAj0uJqLs3i2MclUl0AObhegI5sKUFe35VFFHnbNnSbHqSiipRFTC

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 263 (class 1255 OID 17742)
-- Name: check_asignacion_match(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_asignacion_match() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.check_asignacion_match() OWNER TO postgres;

--
-- TOC entry 264 (class 1255 OID 18134)
-- Name: check_transportista_type(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_transportista_type() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.check_transportista_type() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 248 (class 1259 OID 17993)
-- Name: aduana; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aduana (
    id_aduana integer NOT NULL,
    id_envio integer,
    fecha_inicio date,
    fecha_fin date,
    estado character varying(20)
);


ALTER TABLE public.aduana OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 17992)
-- Name: aduana_id_aduana_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aduana_id_aduana_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.aduana_id_aduana_seq OWNER TO postgres;

--
-- TOC entry 3690 (class 0 OID 0)
-- Dependencies: 247
-- Name: aduana_id_aduana_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aduana_id_aduana_seq OWNED BY public.aduana.id_aduana;


--
-- TOC entry 262 (class 1259 OID 18089)
-- Name: aeronave; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aeronave (
    id_aeronave integer NOT NULL,
    id_transportista integer,
    matricula character varying(20),
    capacidad numeric(10,2)
);


ALTER TABLE public.aeronave OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 18088)
-- Name: aeronave_id_aeronave_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aeronave_id_aeronave_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.aeronave_id_aeronave_seq OWNER TO postgres;

--
-- TOC entry 3691 (class 0 OID 0)
-- Dependencies: 261
-- Name: aeronave_id_aeronave_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aeronave_id_aeronave_seq OWNED BY public.aeronave.id_aeronave;


--
-- TOC entry 254 (class 1259 OID 18035)
-- Name: almacen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.almacen (
    id_almacen integer NOT NULL,
    nombre character varying(100),
    id_pais integer
);


ALTER TABLE public.almacen OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 18034)
-- Name: almacen_id_almacen_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.almacen_id_almacen_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.almacen_id_almacen_seq OWNER TO postgres;

--
-- TOC entry 3692 (class 0 OID 0)
-- Dependencies: 253
-- Name: almacen_id_almacen_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.almacen_id_almacen_seq OWNED BY public.almacen.id_almacen;


--
-- TOC entry 242 (class 1259 OID 17930)
-- Name: asignacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.asignacion (
    id_asignacion integer NOT NULL,
    id_envio integer NOT NULL,
    id_ruta integer NOT NULL,
    id_transportista integer NOT NULL,
    fecha_programada date,
    estado character varying(30)
);


ALTER TABLE public.asignacion OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 17929)
-- Name: asignacion_id_asignacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.asignacion_id_asignacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.asignacion_id_asignacion_seq OWNER TO postgres;

--
-- TOC entry 3693 (class 0 OID 0)
-- Dependencies: 241
-- Name: asignacion_id_asignacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.asignacion_id_asignacion_seq OWNED BY public.asignacion.id_asignacion;


--
-- TOC entry 260 (class 1259 OID 18077)
-- Name: buque; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.buque (
    id_buque integer NOT NULL,
    id_transportista integer,
    nombre character varying(100),
    capacidad numeric(10,2)
);


ALTER TABLE public.buque OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 18076)
-- Name: buque_id_buque_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.buque_id_buque_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.buque_id_buque_seq OWNER TO postgres;

--
-- TOC entry 3694 (class 0 OID 0)
-- Dependencies: 259
-- Name: buque_id_buque_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.buque_id_buque_seq OWNED BY public.buque.id_buque;


--
-- TOC entry 218 (class 1259 OID 17768)
-- Name: cliente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cliente (
    id_cliente integer NOT NULL,
    nombre character varying(100) NOT NULL,
    direccion character varying(200),
    email character varying(120),
    telefono character varying(30)
);


ALTER TABLE public.cliente OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 17767)
-- Name: cliente_id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cliente_id_cliente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cliente_id_cliente_seq OWNER TO postgres;

--
-- TOC entry 3695 (class 0 OID 0)
-- Dependencies: 217
-- Name: cliente_id_cliente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cliente_id_cliente_seq OWNED BY public.cliente.id_cliente;


--
-- TOC entry 222 (class 1259 OID 17785)
-- Name: contenedor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contenedor (
    id_contenedor integer NOT NULL,
    tipo character varying(50),
    capacidad numeric(10,2),
    tara numeric(10,2)
);


ALTER TABLE public.contenedor OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 17784)
-- Name: contenedor_id_contenedor_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contenedor_id_contenedor_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contenedor_id_contenedor_seq OWNER TO postgres;

--
-- TOC entry 3696 (class 0 OID 0)
-- Dependencies: 221
-- Name: contenedor_id_contenedor_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contenedor_id_contenedor_seq OWNED BY public.contenedor.id_contenedor;


--
-- TOC entry 237 (class 1259 OID 17884)
-- Name: envio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.envio (
    id_envio integer NOT NULL,
    id_cliente integer NOT NULL,
    fecha_salida date,
    fecha_llegada date,
    estado character varying(30),
    CONSTRAINT envio_estado_check CHECK (((estado)::text = ANY ((ARRAY['Pendiente'::character varying, 'En tránsito'::character varying, 'Entregado'::character varying, 'Retrasado'::character varying])::text[])))
);


ALTER TABLE public.envio OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 17914)
-- Name: envio_contenedor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.envio_contenedor (
    id_envio integer NOT NULL,
    id_contenedor integer NOT NULL
);


ALTER TABLE public.envio_contenedor OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 17883)
-- Name: envio_id_envio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.envio_id_envio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.envio_id_envio_seq OWNER TO postgres;

--
-- TOC entry 3697 (class 0 OID 0)
-- Dependencies: 236
-- Name: envio_id_envio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.envio_id_envio_seq OWNED BY public.envio.id_envio;


--
-- TOC entry 250 (class 1259 OID 18006)
-- Name: factura; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.factura (
    id_factura integer NOT NULL,
    id_cliente integer,
    id_envio integer,
    fecha_emision date,
    total numeric(10,2)
);


ALTER TABLE public.factura OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 18005)
-- Name: factura_id_factura_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.factura_id_factura_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.factura_id_factura_seq OWNER TO postgres;

--
-- TOC entry 3698 (class 0 OID 0)
-- Dependencies: 249
-- Name: factura_id_factura_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.factura_id_factura_seq OWNED BY public.factura.id_factura;


--
-- TOC entry 246 (class 1259 OID 17972)
-- Name: incidencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.incidencia (
    id_incidencia integer NOT NULL,
    id_envio integer,
    id_tipo_incidencia integer,
    descripcion text,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.incidencia OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 17971)
-- Name: incidencia_id_incidencia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.incidencia_id_incidencia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.incidencia_id_incidencia_seq OWNER TO postgres;

--
-- TOC entry 3699 (class 0 OID 0)
-- Dependencies: 245
-- Name: incidencia_id_incidencia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.incidencia_id_incidencia_seq OWNED BY public.incidencia.id_incidencia;


--
-- TOC entry 239 (class 1259 OID 17897)
-- Name: linea_envio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.linea_envio (
    id_linea_envio integer NOT NULL,
    id_envio integer NOT NULL,
    id_producto integer NOT NULL,
    cantidad integer NOT NULL,
    CONSTRAINT linea_envio_cantidad_check CHECK ((cantidad > 0))
);


ALTER TABLE public.linea_envio OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 17896)
-- Name: linea_envio_id_linea_envio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.linea_envio_id_linea_envio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.linea_envio_id_linea_envio_seq OWNER TO postgres;

--
-- TOC entry 3700 (class 0 OID 0)
-- Dependencies: 238
-- Name: linea_envio_id_linea_envio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.linea_envio_id_linea_envio_seq OWNED BY public.linea_envio.id_linea_envio;


--
-- TOC entry 256 (class 1259 OID 18047)
-- Name: movimiento_almacen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.movimiento_almacen (
    id_movimiento integer NOT NULL,
    id_envio integer,
    id_almacen integer,
    fecha timestamp without time zone,
    tipo character varying(20),
    CONSTRAINT movimiento_almacen_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['Entrada'::character varying, 'Salida'::character varying])::text[])))
);


ALTER TABLE public.movimiento_almacen OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 18046)
-- Name: movimiento_almacen_id_movimiento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.movimiento_almacen_id_movimiento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.movimiento_almacen_id_movimiento_seq OWNER TO postgres;

--
-- TOC entry 3701 (class 0 OID 0)
-- Dependencies: 255
-- Name: movimiento_almacen_id_movimiento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.movimiento_almacen_id_movimiento_seq OWNED BY public.movimiento_almacen.id_movimiento;


--
-- TOC entry 252 (class 1259 OID 18023)
-- Name: pago; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pago (
    id_pago integer NOT NULL,
    id_factura integer,
    fecha date,
    cantidad numeric(10,2),
    metodo character varying(30)
);


ALTER TABLE public.pago OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 18022)
-- Name: pago_id_pago_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pago_id_pago_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pago_id_pago_seq OWNER TO postgres;

--
-- TOC entry 3702 (class 0 OID 0)
-- Dependencies: 251
-- Name: pago_id_pago_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pago_id_pago_seq OWNED BY public.pago.id_pago;


--
-- TOC entry 216 (class 1259 OID 17751)
-- Name: pais; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pais (
    id_pais integer NOT NULL,
    nombre character varying(100) NOT NULL,
    iso character(2)
);


ALTER TABLE public.pais OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 17750)
-- Name: pais_id_pais_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pais_id_pais_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pais_id_pais_seq OWNER TO postgres;

--
-- TOC entry 3703 (class 0 OID 0)
-- Dependencies: 215
-- Name: pais_id_pais_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pais_id_pais_seq OWNED BY public.pais.id_pais;


--
-- TOC entry 224 (class 1259 OID 17792)
-- Name: producto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.producto (
    id_producto integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    peso numeric(10,2),
    volumen numeric(10,2)
);


ALTER TABLE public.producto OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17791)
-- Name: producto_id_producto_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.producto_id_producto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.producto_id_producto_seq OWNER TO postgres;

--
-- TOC entry 3704 (class 0 OID 0)
-- Dependencies: 223
-- Name: producto_id_producto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.producto_id_producto_seq OWNED BY public.producto.id_producto;


--
-- TOC entry 233 (class 1259 OID 17853)
-- Name: ruta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ruta (
    id_ruta integer NOT NULL,
    origen_terminal integer,
    destino_terminal integer,
    distancia numeric(10,2),
    modo character varying(20),
    CONSTRAINT chk_ruta_distinta CHECK ((origen_terminal <> destino_terminal)),
    CONSTRAINT ruta_modo_check CHECK (((modo)::text = ANY ((ARRAY['Aereo'::character varying, 'Maritimo'::character varying, 'Terrestre'::character varying])::text[])))
);


ALTER TABLE public.ruta OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 17852)
-- Name: ruta_id_ruta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ruta_id_ruta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ruta_id_ruta_seq OWNER TO postgres;

--
-- TOC entry 3705 (class 0 OID 0)
-- Dependencies: 232
-- Name: ruta_id_ruta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ruta_id_ruta_seq OWNED BY public.ruta.id_ruta;


--
-- TOC entry 235 (class 1259 OID 17872)
-- Name: tarifa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tarifa (
    id_tarifa integer NOT NULL,
    id_ruta integer,
    tipo_carga character varying(50),
    precio_base numeric(10,2),
    vigencia_inicio date,
    vigencia_fin date
);


ALTER TABLE public.tarifa OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 17871)
-- Name: tarifa_id_tarifa_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tarifa_id_tarifa_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tarifa_id_tarifa_seq OWNER TO postgres;

--
-- TOC entry 3706 (class 0 OID 0)
-- Dependencies: 234
-- Name: tarifa_id_tarifa_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tarifa_id_tarifa_seq OWNED BY public.tarifa.id_tarifa;


--
-- TOC entry 231 (class 1259 OID 17840)
-- Name: terminal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.terminal (
    id_terminal integer NOT NULL,
    nombre character varying(100),
    tipo character varying(20),
    id_pais integer,
    CONSTRAINT terminal_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['Aereo'::character varying, 'Maritimo'::character varying, 'Terrestre'::character varying])::text[])))
);


ALTER TABLE public.terminal OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 17839)
-- Name: terminal_id_terminal_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.terminal_id_terminal_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.terminal_id_terminal_seq OWNER TO postgres;

--
-- TOC entry 3707 (class 0 OID 0)
-- Dependencies: 230
-- Name: terminal_id_terminal_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.terminal_id_terminal_seq OWNED BY public.terminal.id_terminal;


--
-- TOC entry 220 (class 1259 OID 17777)
-- Name: tipo_incidencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_incidencia (
    id_tipo_incidencia integer NOT NULL,
    nombre character varying(100),
    gravedad character varying(20),
    CONSTRAINT tipo_incidencia_gravedad_check CHECK (((gravedad)::text = ANY ((ARRAY['Leve'::character varying, 'Media'::character varying, 'Grave'::character varying])::text[])))
);


ALTER TABLE public.tipo_incidencia OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 17776)
-- Name: tipo_incidencia_id_tipo_incidencia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tipo_incidencia_id_tipo_incidencia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tipo_incidencia_id_tipo_incidencia_seq OWNER TO postgres;

--
-- TOC entry 3708 (class 0 OID 0)
-- Dependencies: 219
-- Name: tipo_incidencia_id_tipo_incidencia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tipo_incidencia_id_tipo_incidencia_seq OWNED BY public.tipo_incidencia.id_tipo_incidencia;


--
-- TOC entry 244 (class 1259 OID 17952)
-- Name: trackingevent; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trackingevent (
    id_evento integer NOT NULL,
    id_envio integer,
    id_terminal integer,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    descripcion text
);


ALTER TABLE public.trackingevent OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 17951)
-- Name: trackingevent_id_evento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.trackingevent_id_evento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.trackingevent_id_evento_seq OWNER TO postgres;

--
-- TOC entry 3709 (class 0 OID 0)
-- Dependencies: 243
-- Name: trackingevent_id_evento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.trackingevent_id_evento_seq OWNED BY public.trackingevent.id_evento;


--
-- TOC entry 226 (class 1259 OID 17802)
-- Name: transportista; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transportista (
    id_transportista integer NOT NULL,
    nombre character varying(100),
    tipo character varying(20),
    CONSTRAINT transportista_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['Aereo'::character varying, 'Maritimo'::character varying, 'Terrestre'::character varying])::text[])))
);


ALTER TABLE public.transportista OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 17809)
-- Name: transportista_aereo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transportista_aereo (
    id_transportista integer NOT NULL,
    codigo_iata character varying(10)
);


ALTER TABLE public.transportista_aereo OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 17801)
-- Name: transportista_id_transportista_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transportista_id_transportista_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transportista_id_transportista_seq OWNER TO postgres;

--
-- TOC entry 3710 (class 0 OID 0)
-- Dependencies: 225
-- Name: transportista_id_transportista_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.transportista_id_transportista_seq OWNED BY public.transportista.id_transportista;


--
-- TOC entry 228 (class 1259 OID 17819)
-- Name: transportista_maritimo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transportista_maritimo (
    id_transportista integer NOT NULL,
    codigo_imo character varying(20)
);


ALTER TABLE public.transportista_maritimo OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 17829)
-- Name: transportista_terrestre; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transportista_terrestre (
    id_transportista integer NOT NULL,
    matricula_base character varying(20)
);


ALTER TABLE public.transportista_terrestre OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 18065)
-- Name: vehiculo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehiculo (
    id_vehiculo integer NOT NULL,
    id_transportista integer,
    matricula character varying(20),
    capacidad numeric(10,2)
);


ALTER TABLE public.vehiculo OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 18064)
-- Name: vehiculo_id_vehiculo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vehiculo_id_vehiculo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehiculo_id_vehiculo_seq OWNER TO postgres;

--
-- TOC entry 3711 (class 0 OID 0)
-- Dependencies: 257
-- Name: vehiculo_id_vehiculo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vehiculo_id_vehiculo_seq OWNED BY public.vehiculo.id_vehiculo;


--
-- TOC entry 3388 (class 2604 OID 17996)
-- Name: aduana id_aduana; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aduana ALTER COLUMN id_aduana SET DEFAULT nextval('public.aduana_id_aduana_seq'::regclass);


--
-- TOC entry 3395 (class 2604 OID 18092)
-- Name: aeronave id_aeronave; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aeronave ALTER COLUMN id_aeronave SET DEFAULT nextval('public.aeronave_id_aeronave_seq'::regclass);


--
-- TOC entry 3391 (class 2604 OID 18038)
-- Name: almacen id_almacen; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.almacen ALTER COLUMN id_almacen SET DEFAULT nextval('public.almacen_id_almacen_seq'::regclass);


--
-- TOC entry 3383 (class 2604 OID 17933)
-- Name: asignacion id_asignacion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asignacion ALTER COLUMN id_asignacion SET DEFAULT nextval('public.asignacion_id_asignacion_seq'::regclass);


--
-- TOC entry 3394 (class 2604 OID 18080)
-- Name: buque id_buque; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.buque ALTER COLUMN id_buque SET DEFAULT nextval('public.buque_id_buque_seq'::regclass);


--
-- TOC entry 3373 (class 2604 OID 17771)
-- Name: cliente id_cliente; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente ALTER COLUMN id_cliente SET DEFAULT nextval('public.cliente_id_cliente_seq'::regclass);


--
-- TOC entry 3375 (class 2604 OID 17788)
-- Name: contenedor id_contenedor; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contenedor ALTER COLUMN id_contenedor SET DEFAULT nextval('public.contenedor_id_contenedor_seq'::regclass);


--
-- TOC entry 3381 (class 2604 OID 17887)
-- Name: envio id_envio; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.envio ALTER COLUMN id_envio SET DEFAULT nextval('public.envio_id_envio_seq'::regclass);


--
-- TOC entry 3389 (class 2604 OID 18009)
-- Name: factura id_factura; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.factura ALTER COLUMN id_factura SET DEFAULT nextval('public.factura_id_factura_seq'::regclass);


--
-- TOC entry 3386 (class 2604 OID 17975)
-- Name: incidencia id_incidencia; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidencia ALTER COLUMN id_incidencia SET DEFAULT nextval('public.incidencia_id_incidencia_seq'::regclass);


--
-- TOC entry 3382 (class 2604 OID 17900)
-- Name: linea_envio id_linea_envio; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linea_envio ALTER COLUMN id_linea_envio SET DEFAULT nextval('public.linea_envio_id_linea_envio_seq'::regclass);


--
-- TOC entry 3392 (class 2604 OID 18050)
-- Name: movimiento_almacen id_movimiento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movimiento_almacen ALTER COLUMN id_movimiento SET DEFAULT nextval('public.movimiento_almacen_id_movimiento_seq'::regclass);


--
-- TOC entry 3390 (class 2604 OID 18026)
-- Name: pago id_pago; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pago ALTER COLUMN id_pago SET DEFAULT nextval('public.pago_id_pago_seq'::regclass);


--
-- TOC entry 3372 (class 2604 OID 17754)
-- Name: pais id_pais; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pais ALTER COLUMN id_pais SET DEFAULT nextval('public.pais_id_pais_seq'::regclass);


--
-- TOC entry 3376 (class 2604 OID 17795)
-- Name: producto id_producto; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.producto ALTER COLUMN id_producto SET DEFAULT nextval('public.producto_id_producto_seq'::regclass);


--
-- TOC entry 3379 (class 2604 OID 17856)
-- Name: ruta id_ruta; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ruta ALTER COLUMN id_ruta SET DEFAULT nextval('public.ruta_id_ruta_seq'::regclass);


--
-- TOC entry 3380 (class 2604 OID 17875)
-- Name: tarifa id_tarifa; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tarifa ALTER COLUMN id_tarifa SET DEFAULT nextval('public.tarifa_id_tarifa_seq'::regclass);


--
-- TOC entry 3378 (class 2604 OID 17843)
-- Name: terminal id_terminal; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminal ALTER COLUMN id_terminal SET DEFAULT nextval('public.terminal_id_terminal_seq'::regclass);


--
-- TOC entry 3374 (class 2604 OID 17780)
-- Name: tipo_incidencia id_tipo_incidencia; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_incidencia ALTER COLUMN id_tipo_incidencia SET DEFAULT nextval('public.tipo_incidencia_id_tipo_incidencia_seq'::regclass);


--
-- TOC entry 3384 (class 2604 OID 17955)
-- Name: trackingevent id_evento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trackingevent ALTER COLUMN id_evento SET DEFAULT nextval('public.trackingevent_id_evento_seq'::regclass);


--
-- TOC entry 3377 (class 2604 OID 17805)
-- Name: transportista id_transportista; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transportista ALTER COLUMN id_transportista SET DEFAULT nextval('public.transportista_id_transportista_seq'::regclass);


--
-- TOC entry 3393 (class 2604 OID 18068)
-- Name: vehiculo id_vehiculo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehiculo ALTER COLUMN id_vehiculo SET DEFAULT nextval('public.vehiculo_id_vehiculo_seq'::regclass);


--
-- TOC entry 3669 (class 0 OID 17993)
-- Dependencies: 248
-- Data for Name: aduana; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.aduana VALUES (1, 1, '2024-03-01', '2024-03-02', 'Aprobado');
INSERT INTO public.aduana VALUES (2, 3, '2024-03-11', NULL, 'En revisión');


--
-- TOC entry 3683 (class 0 OID 18089)
-- Dependencies: 262
-- Data for Name: aeronave; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.aeronave VALUES (3, 1, 'AG-001', 2500.00);
INSERT INTO public.aeronave VALUES (4, 2, 'SK-002', 3000.00);


--
-- TOC entry 3675 (class 0 OID 18035)
-- Dependencies: 254
-- Data for Name: almacen; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.almacen VALUES (1, 'Almacén Madrid', 1);
INSERT INTO public.almacen VALUES (2, 'Almacén París', 2);
INSERT INTO public.almacen VALUES (3, 'Almacén Berlín', 3);
INSERT INTO public.almacen VALUES (4, 'Almacén Shanghái', 5);


--
-- TOC entry 3663 (class 0 OID 17930)
-- Dependencies: 242
-- Data for Name: asignacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.asignacion VALUES (1, 1, 1, 1, '2024-03-01', 'Finalizado');
INSERT INTO public.asignacion VALUES (2, 2, 2, 2, '2024-03-05', 'En curso');
INSERT INTO public.asignacion VALUES (3, 3, 3, 3, '2024-03-10', 'Pendiente');
INSERT INTO public.asignacion VALUES (4, 4, 5, 5, '2024-03-12', 'Retrasado');


--
-- TOC entry 3681 (class 0 OID 18077)
-- Dependencies: 260
-- Data for Name: buque; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.buque VALUES (5, 3, 'Atlantic Carrier', 60000.00);
INSERT INTO public.buque VALUES (6, 4, 'Pacific Trader', 55000.00);


--
-- TOC entry 3639 (class 0 OID 17768)
-- Dependencies: 218
-- Data for Name: cliente; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cliente VALUES (1, 'TransGlobal S.A.', 'Calle Mayor 10, Madrid, España', 'info@transglobal.es', '+34 912345678');
INSERT INTO public.cliente VALUES (2, 'LogiFrance', '10 Rue de la Paix, París, Francia', 'contact@logifrance.fr', '+33 145678910');
INSERT INTO public.cliente VALUES (3, 'Berlin Cargo', 'Alexanderplatz 5, Berlín, Alemania', 'ventas@berlincargo.de', '+49 301234567');
INSERT INTO public.cliente VALUES (4, 'US Freight Inc.', '500 Market Street, Nueva York, USA', 'contact@usfreight.com', '+1 2125551234');


--
-- TOC entry 3643 (class 0 OID 17785)
-- Dependencies: 222
-- Data for Name: contenedor; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.contenedor VALUES (1, 'Contenedor 20 pies', 28.00, 2.30);
INSERT INTO public.contenedor VALUES (2, 'Contenedor 40 pies', 58.00, 3.50);
INSERT INTO public.contenedor VALUES (3, 'Contenedor Refrigerado', 25.00, 3.00);


--
-- TOC entry 3658 (class 0 OID 17884)
-- Dependencies: 237
-- Data for Name: envio; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.envio VALUES (1, 1, '2024-03-01', '2024-03-03', 'Entregado');
INSERT INTO public.envio VALUES (2, 2, '2024-03-05', '2024-03-07', 'En tránsito');
INSERT INTO public.envio VALUES (3, 3, '2024-03-10', '2024-03-20', 'Pendiente');
INSERT INTO public.envio VALUES (4, 4, '2024-03-12', '2024-03-25', 'Retrasado');


--
-- TOC entry 3661 (class 0 OID 17914)
-- Dependencies: 240
-- Data for Name: envio_contenedor; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.envio_contenedor VALUES (1, 1);
INSERT INTO public.envio_contenedor VALUES (1, 2);
INSERT INTO public.envio_contenedor VALUES (2, 2);
INSERT INTO public.envio_contenedor VALUES (3, 3);
INSERT INTO public.envio_contenedor VALUES (4, 1);


--
-- TOC entry 3671 (class 0 OID 18006)
-- Dependencies: 250
-- Data for Name: factura; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.factura VALUES (1, 1, 1, '2024-03-03', 12000.00);
INSERT INTO public.factura VALUES (2, 2, 2, '2024-03-07', 9000.00);
INSERT INTO public.factura VALUES (3, 3, 3, '2024-03-20', 18000.00);


--
-- TOC entry 3667 (class 0 OID 17972)
-- Dependencies: 246
-- Data for Name: incidencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.incidencia VALUES (1, 4, 1, 'Retraso por condiciones meteorológicas', '2025-12-13 16:29:55.843897');
INSERT INTO public.incidencia VALUES (2, 3, 2, 'Documentación incompleta en aduana', '2025-12-13 16:29:55.843897');


--
-- TOC entry 3660 (class 0 OID 17897)
-- Dependencies: 239
-- Data for Name: linea_envio; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.linea_envio VALUES (1, 1, 1, 10);
INSERT INTO public.linea_envio VALUES (2, 1, 2, 20);
INSERT INTO public.linea_envio VALUES (3, 2, 3, 15);
INSERT INTO public.linea_envio VALUES (4, 2, 4, 5);
INSERT INTO public.linea_envio VALUES (5, 3, 5, 8);
INSERT INTO public.linea_envio VALUES (6, 4, 6, 12);


--
-- TOC entry 3677 (class 0 OID 18047)
-- Dependencies: 256
-- Data for Name: movimiento_almacen; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.movimiento_almacen VALUES (1, 1, 1, '2024-03-01 08:00:00', 'Entrada');
INSERT INTO public.movimiento_almacen VALUES (2, 1, 1, '2024-03-03 15:00:00', 'Salida');
INSERT INTO public.movimiento_almacen VALUES (3, 2, 2, '2024-03-05 09:00:00', 'Entrada');
INSERT INTO public.movimiento_almacen VALUES (4, 3, 4, '2024-03-11 10:30:00', 'Entrada');


--
-- TOC entry 3673 (class 0 OID 18023)
-- Dependencies: 252
-- Data for Name: pago; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.pago VALUES (1, 1, '2024-03-03', 12000.00, 'Transferencia');
INSERT INTO public.pago VALUES (2, 2, '2024-03-08', 9000.00, 'Tarjeta');
INSERT INTO public.pago VALUES (3, 3, '2024-03-21', 10000.00, 'Transferencia');


--
-- TOC entry 3637 (class 0 OID 17751)
-- Dependencies: 216
-- Data for Name: pais; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.pais VALUES (1, 'España', 'ES');
INSERT INTO public.pais VALUES (2, 'Francia', 'FR');
INSERT INTO public.pais VALUES (3, 'Alemania', 'DE');
INSERT INTO public.pais VALUES (4, 'Estados Unidos', 'US');
INSERT INTO public.pais VALUES (5, 'China', 'CN');


--
-- TOC entry 3645 (class 0 OID 17792)
-- Dependencies: 224
-- Data for Name: producto; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.producto VALUES (1, 'Ordenador portátil', 'Portátil empresarial 15"', 2.50, 0.00);
INSERT INTO public.producto VALUES (2, 'Teléfono móvil', 'Smartphone gama media', 0.30, 0.00);
INSERT INTO public.producto VALUES (3, 'Monitor', 'Monitor LED 24 pulgadas', 5.20, 0.06);
INSERT INTO public.producto VALUES (4, 'Impresora', 'Impresora láser', 8.00, 0.12);
INSERT INTO public.producto VALUES (5, 'Mesa oficina', 'Mesa de madera', 20.00, 0.80);
INSERT INTO public.producto VALUES (6, 'Silla oficina', 'Silla ergonómica', 10.00, 0.60);


--
-- TOC entry 3654 (class 0 OID 17853)
-- Dependencies: 233
-- Data for Name: ruta; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ruta VALUES (1, 1, 2, 1050.00, 'Aereo');
INSERT INTO public.ruta VALUES (2, 2, 3, 880.00, 'Aereo');
INSERT INTO public.ruta VALUES (3, 4, 5, 20000.00, 'Maritimo');
INSERT INTO public.ruta VALUES (4, 5, 6, 11000.00, 'Maritimo');
INSERT INTO public.ruta VALUES (5, 7, 8, 1200.00, 'Terrestre');
INSERT INTO public.ruta VALUES (6, 8, 9, 1000.00, 'Terrestre');
INSERT INTO public.ruta VALUES (7, 9, 10, 6500.00, 'Terrestre');


--
-- TOC entry 3656 (class 0 OID 17872)
-- Dependencies: 235
-- Data for Name: tarifa; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tarifa VALUES (6, 1, 'Electrónica', 3000.00, '2024-01-01', '2024-12-31');
INSERT INTO public.tarifa VALUES (7, 2, 'Oficina', 2500.00, '2024-01-01', '2024-12-31');
INSERT INTO public.tarifa VALUES (8, 3, 'Industrial', 8000.00, '2024-01-01', '2024-12-31');
INSERT INTO public.tarifa VALUES (9, 4, 'Comercial', 7500.00, '2024-01-01', '2024-12-31');
INSERT INTO public.tarifa VALUES (10, 5, 'Muebles', 1500.00, '2024-01-01', '2024-12-31');


--
-- TOC entry 3652 (class 0 OID 17840)
-- Dependencies: 231
-- Data for Name: terminal; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.terminal VALUES (1, 'Aeropuerto Madrid-Barajas', 'Aereo', 1);
INSERT INTO public.terminal VALUES (2, 'Aeropuerto París-CDG', 'Aereo', 2);
INSERT INTO public.terminal VALUES (3, 'Aeropuerto Berlín-Brandenburgo', 'Aereo', 3);
INSERT INTO public.terminal VALUES (4, 'Puerto de Hamburgo', 'Maritimo', 3);
INSERT INTO public.terminal VALUES (5, 'Puerto de Shanghái', 'Maritimo', 5);
INSERT INTO public.terminal VALUES (6, 'Puerto de Los Ángeles', 'Maritimo', 4);
INSERT INTO public.terminal VALUES (7, 'Terminal Madrid Norte', 'Terrestre', 1);
INSERT INTO public.terminal VALUES (8, 'Terminal París Este', 'Terrestre', 2);
INSERT INTO public.terminal VALUES (9, 'Terminal Berlín Oeste', 'Terrestre', 3);
INSERT INTO public.terminal VALUES (10, 'Terminal Nueva York', 'Terrestre', 4);


--
-- TOC entry 3641 (class 0 OID 17777)
-- Dependencies: 220
-- Data for Name: tipo_incidencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tipo_incidencia VALUES (1, 'Retraso por clima', 'Media');
INSERT INTO public.tipo_incidencia VALUES (2, 'Documento aduanero incompleto', 'Grave');
INSERT INTO public.tipo_incidencia VALUES (3, 'Daño en contenedor', 'Grave');
INSERT INTO public.tipo_incidencia VALUES (4, 'Cambio de ruta', 'Leve');


--
-- TOC entry 3665 (class 0 OID 17952)
-- Dependencies: 244
-- Data for Name: trackingevent; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.trackingevent VALUES (1, 1, 1, '2025-12-13 16:29:50.952112', 'Salida del aeropuerto de Madrid');
INSERT INTO public.trackingevent VALUES (2, 1, 2, '2025-12-13 16:29:50.952112', 'Llegada al aeropuerto de París');
INSERT INTO public.trackingevent VALUES (3, 2, 2, '2025-12-13 16:29:50.952112', 'Salida de París');
INSERT INTO public.trackingevent VALUES (4, 3, 4, '2025-12-13 16:29:50.952112', 'Carga en puerto de Hamburgo');


--
-- TOC entry 3647 (class 0 OID 17802)
-- Dependencies: 226
-- Data for Name: transportista; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.transportista VALUES (1, 'AirGlobal', 'Aereo');
INSERT INTO public.transportista VALUES (2, 'SkyLogistics', 'Aereo');
INSERT INTO public.transportista VALUES (3, 'Oceanic Lines', 'Maritimo');
INSERT INTO public.transportista VALUES (4, 'BlueSea Cargo', 'Maritimo');
INSERT INTO public.transportista VALUES (5, 'RoadExpress', 'Terrestre');
INSERT INTO public.transportista VALUES (6, 'EuroTruck', 'Terrestre');


--
-- TOC entry 3648 (class 0 OID 17809)
-- Dependencies: 227
-- Data for Name: transportista_aereo; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.transportista_aereo VALUES (1, 'AGL');
INSERT INTO public.transportista_aereo VALUES (2, 'SKY');


--
-- TOC entry 3649 (class 0 OID 17819)
-- Dependencies: 228
-- Data for Name: transportista_maritimo; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.transportista_maritimo VALUES (3, 'IMO1234567');
INSERT INTO public.transportista_maritimo VALUES (4, 'IMO7654321');


--
-- TOC entry 3650 (class 0 OID 17829)
-- Dependencies: 229
-- Data for Name: transportista_terrestre; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.transportista_terrestre VALUES (5, 'RE-BASE');
INSERT INTO public.transportista_terrestre VALUES (6, 'ET-BASE');


--
-- TOC entry 3679 (class 0 OID 18065)
-- Dependencies: 258
-- Data for Name: vehiculo; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.vehiculo VALUES (1, 5, 'RE-1234', 18000.00);
INSERT INTO public.vehiculo VALUES (2, 6, 'ET-5678', 22000.00);
INSERT INTO public.vehiculo VALUES (3, 5, 'RE-1234', 18000.00);
INSERT INTO public.vehiculo VALUES (4, 6, 'ET-5678', 22000.00);


--
-- TOC entry 3712 (class 0 OID 0)
-- Dependencies: 247
-- Name: aduana_id_aduana_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.aduana_id_aduana_seq', 2, true);


--
-- TOC entry 3713 (class 0 OID 0)
-- Dependencies: 261
-- Name: aeronave_id_aeronave_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.aeronave_id_aeronave_seq', 4, true);


--
-- TOC entry 3714 (class 0 OID 0)
-- Dependencies: 253
-- Name: almacen_id_almacen_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.almacen_id_almacen_seq', 4, true);


--
-- TOC entry 3715 (class 0 OID 0)
-- Dependencies: 241
-- Name: asignacion_id_asignacion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.asignacion_id_asignacion_seq', 4, true);


--
-- TOC entry 3716 (class 0 OID 0)
-- Dependencies: 259
-- Name: buque_id_buque_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.buque_id_buque_seq', 6, true);


--
-- TOC entry 3717 (class 0 OID 0)
-- Dependencies: 217
-- Name: cliente_id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cliente_id_cliente_seq', 4, true);


--
-- TOC entry 3718 (class 0 OID 0)
-- Dependencies: 221
-- Name: contenedor_id_contenedor_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contenedor_id_contenedor_seq', 3, true);


--
-- TOC entry 3719 (class 0 OID 0)
-- Dependencies: 236
-- Name: envio_id_envio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.envio_id_envio_seq', 5, true);


--
-- TOC entry 3720 (class 0 OID 0)
-- Dependencies: 249
-- Name: factura_id_factura_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.factura_id_factura_seq', 3, true);


--
-- TOC entry 3721 (class 0 OID 0)
-- Dependencies: 245
-- Name: incidencia_id_incidencia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.incidencia_id_incidencia_seq', 2, true);


--
-- TOC entry 3722 (class 0 OID 0)
-- Dependencies: 238
-- Name: linea_envio_id_linea_envio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.linea_envio_id_linea_envio_seq', 6, true);


--
-- TOC entry 3723 (class 0 OID 0)
-- Dependencies: 255
-- Name: movimiento_almacen_id_movimiento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.movimiento_almacen_id_movimiento_seq', 4, true);


--
-- TOC entry 3724 (class 0 OID 0)
-- Dependencies: 251
-- Name: pago_id_pago_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pago_id_pago_seq', 3, true);


--
-- TOC entry 3725 (class 0 OID 0)
-- Dependencies: 215
-- Name: pais_id_pais_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pais_id_pais_seq', 5, true);


--
-- TOC entry 3726 (class 0 OID 0)
-- Dependencies: 223
-- Name: producto_id_producto_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.producto_id_producto_seq', 6, true);


--
-- TOC entry 3727 (class 0 OID 0)
-- Dependencies: 232
-- Name: ruta_id_ruta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ruta_id_ruta_seq', 7, true);


--
-- TOC entry 3728 (class 0 OID 0)
-- Dependencies: 234
-- Name: tarifa_id_tarifa_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tarifa_id_tarifa_seq', 10, true);


--
-- TOC entry 3729 (class 0 OID 0)
-- Dependencies: 230
-- Name: terminal_id_terminal_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.terminal_id_terminal_seq', 10, true);


--
-- TOC entry 3730 (class 0 OID 0)
-- Dependencies: 219
-- Name: tipo_incidencia_id_tipo_incidencia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tipo_incidencia_id_tipo_incidencia_seq', 4, true);


--
-- TOC entry 3731 (class 0 OID 0)
-- Dependencies: 243
-- Name: trackingevent_id_evento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.trackingevent_id_evento_seq', 4, true);


--
-- TOC entry 3732 (class 0 OID 0)
-- Dependencies: 225
-- Name: transportista_id_transportista_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transportista_id_transportista_seq', 6, true);


--
-- TOC entry 3733 (class 0 OID 0)
-- Dependencies: 257
-- Name: vehiculo_id_vehiculo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vehiculo_id_vehiculo_seq', 4, true);


--
-- TOC entry 3445 (class 2606 OID 17998)
-- Name: aduana aduana_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aduana
    ADD CONSTRAINT aduana_pkey PRIMARY KEY (id_aduana);


--
-- TOC entry 3459 (class 2606 OID 18094)
-- Name: aeronave aeronave_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aeronave
    ADD CONSTRAINT aeronave_pkey PRIMARY KEY (id_aeronave);


--
-- TOC entry 3451 (class 2606 OID 18040)
-- Name: almacen almacen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.almacen
    ADD CONSTRAINT almacen_pkey PRIMARY KEY (id_almacen);


--
-- TOC entry 3439 (class 2606 OID 17935)
-- Name: asignacion asignacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asignacion
    ADD CONSTRAINT asignacion_pkey PRIMARY KEY (id_asignacion);


--
-- TOC entry 3457 (class 2606 OID 18082)
-- Name: buque buque_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.buque
    ADD CONSTRAINT buque_pkey PRIMARY KEY (id_buque);


--
-- TOC entry 3409 (class 2606 OID 17775)
-- Name: cliente cliente_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_email_key UNIQUE (email);


--
-- TOC entry 3411 (class 2606 OID 17773)
-- Name: cliente cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);


--
-- TOC entry 3415 (class 2606 OID 17790)
-- Name: contenedor contenedor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contenedor
    ADD CONSTRAINT contenedor_pkey PRIMARY KEY (id_contenedor);


--
-- TOC entry 3437 (class 2606 OID 17918)
-- Name: envio_contenedor envio_contenedor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.envio_contenedor
    ADD CONSTRAINT envio_contenedor_pkey PRIMARY KEY (id_envio, id_contenedor);


--
-- TOC entry 3433 (class 2606 OID 17890)
-- Name: envio envio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.envio
    ADD CONSTRAINT envio_pkey PRIMARY KEY (id_envio);


--
-- TOC entry 3447 (class 2606 OID 18011)
-- Name: factura factura_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_pkey PRIMARY KEY (id_factura);


--
-- TOC entry 3443 (class 2606 OID 17980)
-- Name: incidencia incidencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidencia
    ADD CONSTRAINT incidencia_pkey PRIMARY KEY (id_incidencia);


--
-- TOC entry 3435 (class 2606 OID 17903)
-- Name: linea_envio linea_envio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linea_envio
    ADD CONSTRAINT linea_envio_pkey PRIMARY KEY (id_linea_envio);


--
-- TOC entry 3453 (class 2606 OID 18053)
-- Name: movimiento_almacen movimiento_almacen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movimiento_almacen
    ADD CONSTRAINT movimiento_almacen_pkey PRIMARY KEY (id_movimiento);


--
-- TOC entry 3449 (class 2606 OID 18028)
-- Name: pago pago_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_pkey PRIMARY KEY (id_pago);


--
-- TOC entry 3405 (class 2606 OID 17758)
-- Name: pais pais_iso_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pais
    ADD CONSTRAINT pais_iso_key UNIQUE (iso);


--
-- TOC entry 3407 (class 2606 OID 17756)
-- Name: pais pais_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pais
    ADD CONSTRAINT pais_pkey PRIMARY KEY (id_pais);


--
-- TOC entry 3417 (class 2606 OID 17799)
-- Name: producto producto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.producto
    ADD CONSTRAINT producto_pkey PRIMARY KEY (id_producto);


--
-- TOC entry 3429 (class 2606 OID 17860)
-- Name: ruta ruta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ruta
    ADD CONSTRAINT ruta_pkey PRIMARY KEY (id_ruta);


--
-- TOC entry 3431 (class 2606 OID 17877)
-- Name: tarifa tarifa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tarifa
    ADD CONSTRAINT tarifa_pkey PRIMARY KEY (id_tarifa);


--
-- TOC entry 3427 (class 2606 OID 17846)
-- Name: terminal terminal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminal
    ADD CONSTRAINT terminal_pkey PRIMARY KEY (id_terminal);


--
-- TOC entry 3413 (class 2606 OID 17783)
-- Name: tipo_incidencia tipo_incidencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_incidencia
    ADD CONSTRAINT tipo_incidencia_pkey PRIMARY KEY (id_tipo_incidencia);


--
-- TOC entry 3441 (class 2606 OID 17960)
-- Name: trackingevent trackingevent_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trackingevent
    ADD CONSTRAINT trackingevent_pkey PRIMARY KEY (id_evento);


--
-- TOC entry 3421 (class 2606 OID 17813)
-- Name: transportista_aereo transportista_aereo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transportista_aereo
    ADD CONSTRAINT transportista_aereo_pkey PRIMARY KEY (id_transportista);


--
-- TOC entry 3423 (class 2606 OID 17823)
-- Name: transportista_maritimo transportista_maritimo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transportista_maritimo
    ADD CONSTRAINT transportista_maritimo_pkey PRIMARY KEY (id_transportista);


--
-- TOC entry 3419 (class 2606 OID 17808)
-- Name: transportista transportista_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transportista
    ADD CONSTRAINT transportista_pkey PRIMARY KEY (id_transportista);


--
-- TOC entry 3425 (class 2606 OID 17833)
-- Name: transportista_terrestre transportista_terrestre_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transportista_terrestre
    ADD CONSTRAINT transportista_terrestre_pkey PRIMARY KEY (id_transportista);


--
-- TOC entry 3455 (class 2606 OID 18070)
-- Name: vehiculo vehiculo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehiculo
    ADD CONSTRAINT vehiculo_pkey PRIMARY KEY (id_vehiculo);


--
-- TOC entry 3492 (class 2620 OID 18100)
-- Name: asignacion trg_check_asignacion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_check_asignacion BEFORE INSERT OR UPDATE ON public.asignacion FOR EACH ROW EXECUTE FUNCTION public.check_asignacion_match();


--
-- TOC entry 3489 (class 2620 OID 18135)
-- Name: transportista_aereo trg_validate_aereo; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_validate_aereo BEFORE INSERT OR UPDATE ON public.transportista_aereo FOR EACH ROW EXECUTE FUNCTION public.check_transportista_type();


--
-- TOC entry 3490 (class 2620 OID 18136)
-- Name: transportista_maritimo trg_validate_maritimo; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_validate_maritimo BEFORE INSERT OR UPDATE ON public.transportista_maritimo FOR EACH ROW EXECUTE FUNCTION public.check_transportista_type();


--
-- TOC entry 3491 (class 2620 OID 18137)
-- Name: transportista_terrestre trg_validate_terrestre; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_validate_terrestre BEFORE INSERT OR UPDATE ON public.transportista_terrestre FOR EACH ROW EXECUTE FUNCTION public.check_transportista_type();


--
-- TOC entry 3479 (class 2606 OID 17999)
-- Name: aduana aduana_id_envio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aduana
    ADD CONSTRAINT aduana_id_envio_fkey FOREIGN KEY (id_envio) REFERENCES public.envio(id_envio);


--
-- TOC entry 3488 (class 2606 OID 18095)
-- Name: aeronave aeronave_id_transportista_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aeronave
    ADD CONSTRAINT aeronave_id_transportista_fkey FOREIGN KEY (id_transportista) REFERENCES public.transportista_aereo(id_transportista);


--
-- TOC entry 3483 (class 2606 OID 18041)
-- Name: almacen almacen_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.almacen
    ADD CONSTRAINT almacen_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES public.pais(id_pais);


--
-- TOC entry 3472 (class 2606 OID 17936)
-- Name: asignacion asignacion_id_envio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asignacion
    ADD CONSTRAINT asignacion_id_envio_fkey FOREIGN KEY (id_envio) REFERENCES public.envio(id_envio) ON DELETE CASCADE;


--
-- TOC entry 3473 (class 2606 OID 17941)
-- Name: asignacion asignacion_id_ruta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asignacion
    ADD CONSTRAINT asignacion_id_ruta_fkey FOREIGN KEY (id_ruta) REFERENCES public.ruta(id_ruta);


--
-- TOC entry 3474 (class 2606 OID 17946)
-- Name: asignacion asignacion_id_transportista_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asignacion
    ADD CONSTRAINT asignacion_id_transportista_fkey FOREIGN KEY (id_transportista) REFERENCES public.transportista(id_transportista);


--
-- TOC entry 3487 (class 2606 OID 18083)
-- Name: buque buque_id_transportista_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.buque
    ADD CONSTRAINT buque_id_transportista_fkey FOREIGN KEY (id_transportista) REFERENCES public.transportista_maritimo(id_transportista);


--
-- TOC entry 3470 (class 2606 OID 17924)
-- Name: envio_contenedor envio_contenedor_id_contenedor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.envio_contenedor
    ADD CONSTRAINT envio_contenedor_id_contenedor_fkey FOREIGN KEY (id_contenedor) REFERENCES public.contenedor(id_contenedor);


--
-- TOC entry 3471 (class 2606 OID 17919)
-- Name: envio_contenedor envio_contenedor_id_envio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.envio_contenedor
    ADD CONSTRAINT envio_contenedor_id_envio_fkey FOREIGN KEY (id_envio) REFERENCES public.envio(id_envio) ON DELETE CASCADE;


--
-- TOC entry 3467 (class 2606 OID 17891)
-- Name: envio envio_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.envio
    ADD CONSTRAINT envio_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);


--
-- TOC entry 3480 (class 2606 OID 18012)
-- Name: factura factura_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);


--
-- TOC entry 3481 (class 2606 OID 18017)
-- Name: factura factura_id_envio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_id_envio_fkey FOREIGN KEY (id_envio) REFERENCES public.envio(id_envio);


--
-- TOC entry 3477 (class 2606 OID 17981)
-- Name: incidencia incidencia_id_envio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidencia
    ADD CONSTRAINT incidencia_id_envio_fkey FOREIGN KEY (id_envio) REFERENCES public.envio(id_envio);


--
-- TOC entry 3478 (class 2606 OID 17986)
-- Name: incidencia incidencia_id_tipo_incidencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidencia
    ADD CONSTRAINT incidencia_id_tipo_incidencia_fkey FOREIGN KEY (id_tipo_incidencia) REFERENCES public.tipo_incidencia(id_tipo_incidencia);


--
-- TOC entry 3468 (class 2606 OID 17904)
-- Name: linea_envio linea_envio_id_envio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linea_envio
    ADD CONSTRAINT linea_envio_id_envio_fkey FOREIGN KEY (id_envio) REFERENCES public.envio(id_envio) ON DELETE CASCADE;


--
-- TOC entry 3469 (class 2606 OID 17909)
-- Name: linea_envio linea_envio_id_producto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linea_envio
    ADD CONSTRAINT linea_envio_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES public.producto(id_producto);


--
-- TOC entry 3484 (class 2606 OID 18059)
-- Name: movimiento_almacen movimiento_almacen_id_almacen_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movimiento_almacen
    ADD CONSTRAINT movimiento_almacen_id_almacen_fkey FOREIGN KEY (id_almacen) REFERENCES public.almacen(id_almacen);


--
-- TOC entry 3485 (class 2606 OID 18054)
-- Name: movimiento_almacen movimiento_almacen_id_envio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movimiento_almacen
    ADD CONSTRAINT movimiento_almacen_id_envio_fkey FOREIGN KEY (id_envio) REFERENCES public.envio(id_envio);


--
-- TOC entry 3482 (class 2606 OID 18029)
-- Name: pago pago_id_factura_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_id_factura_fkey FOREIGN KEY (id_factura) REFERENCES public.factura(id_factura) ON DELETE CASCADE;


--
-- TOC entry 3464 (class 2606 OID 17866)
-- Name: ruta ruta_destino_terminal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ruta
    ADD CONSTRAINT ruta_destino_terminal_fkey FOREIGN KEY (destino_terminal) REFERENCES public.terminal(id_terminal);


--
-- TOC entry 3465 (class 2606 OID 17861)
-- Name: ruta ruta_origen_terminal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ruta
    ADD CONSTRAINT ruta_origen_terminal_fkey FOREIGN KEY (origen_terminal) REFERENCES public.terminal(id_terminal);


--
-- TOC entry 3466 (class 2606 OID 17878)
-- Name: tarifa tarifa_id_ruta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tarifa
    ADD CONSTRAINT tarifa_id_ruta_fkey FOREIGN KEY (id_ruta) REFERENCES public.ruta(id_ruta) ON DELETE CASCADE;


--
-- TOC entry 3463 (class 2606 OID 17847)
-- Name: terminal terminal_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.terminal
    ADD CONSTRAINT terminal_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES public.pais(id_pais);


--
-- TOC entry 3475 (class 2606 OID 17961)
-- Name: trackingevent trackingevent_id_envio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trackingevent
    ADD CONSTRAINT trackingevent_id_envio_fkey FOREIGN KEY (id_envio) REFERENCES public.envio(id_envio);


--
-- TOC entry 3476 (class 2606 OID 17966)
-- Name: trackingevent trackingevent_id_terminal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trackingevent
    ADD CONSTRAINT trackingevent_id_terminal_fkey FOREIGN KEY (id_terminal) REFERENCES public.terminal(id_terminal);


--
-- TOC entry 3460 (class 2606 OID 17814)
-- Name: transportista_aereo transportista_aereo_id_transportista_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transportista_aereo
    ADD CONSTRAINT transportista_aereo_id_transportista_fkey FOREIGN KEY (id_transportista) REFERENCES public.transportista(id_transportista) ON DELETE CASCADE;


--
-- TOC entry 3461 (class 2606 OID 17824)
-- Name: transportista_maritimo transportista_maritimo_id_transportista_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transportista_maritimo
    ADD CONSTRAINT transportista_maritimo_id_transportista_fkey FOREIGN KEY (id_transportista) REFERENCES public.transportista(id_transportista) ON DELETE CASCADE;


--
-- TOC entry 3462 (class 2606 OID 17834)
-- Name: transportista_terrestre transportista_terrestre_id_transportista_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transportista_terrestre
    ADD CONSTRAINT transportista_terrestre_id_transportista_fkey FOREIGN KEY (id_transportista) REFERENCES public.transportista(id_transportista) ON DELETE CASCADE;


--
-- TOC entry 3486 (class 2606 OID 18071)
-- Name: vehiculo vehiculo_id_transportista_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehiculo
    ADD CONSTRAINT vehiculo_id_transportista_fkey FOREIGN KEY (id_transportista) REFERENCES public.transportista_terrestre(id_transportista);


-- Completed on 2025-12-14 19:42:24

--
-- PostgreSQL database dump complete
--

\unrestrict MMV4aJlkcQiAj0uJqLs3i2MclUl0AObhegI5sKUFe35VFFHnbNnSbHqSiipRFTC

