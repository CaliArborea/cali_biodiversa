-- Table: censo_arboreo

-- DROP TABLE censo_arboreo;

CREATE TABLE censo_arboreo
(
  id serial NOT NULL,
  geom geometry(MultiPoint,3115),
  operador character varying(254),
  id_barrio character varying(254),
  comuna character varying(254),
  nombre_bar character varying(254),
  id_arbol integer,
  nombre_com character varying(254),
  nombre_cie character varying(254),
  vegetacion character varying(254),
  edad character varying(254),
  emplazamie character varying(254),
  altura_arb numeric,
  dap character varying(254),
  copa character varying(254),
  norte character varying(254),
  este character varying(254),
  latitud character varying(254),
  longitud character varying(254),
  notables character varying(254),
  observacio character varying(254),
  rango_altu character varying(254),
  pod_tip_es character varying(254),
  arb_energ character varying(254),
  poda_opera character varying(254),
  CONSTRAINT censo_arboreo_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE censo_arboreo OWNER TO postgres;

-- Querying scientific names of tree species

SELECT DISTINCT(nombre_cie) FROM censo_arboreo;
