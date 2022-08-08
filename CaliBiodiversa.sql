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

-- Creation of the GBIF Key field in the Censo Arboreo de Cali spatial database

ALTER TABLE censo_arboreo ADD COLUMN gbif_key varchar(10);

-- GBIF key data linking

UPDATE censo_arboreo SET gbif_key = censo_arboreo_gbif.key FROM censo_arboreo_gbif WHERE nombre_cie = censo_arboreo_gbif.species;

-- Creation of the field for the backbone url link

ALTER TABLE censo_arboreo ADD COLUMN gbif_backbone varchar(90);

-- Creation of the url for linking in Censo Arboreo de Cali spatial database

UPDATE censo_arboreo SET gbif_backbone = 'https://www.gbif.org/species/' || gbif_key;

-- GBIF Key null records correction

SELECT DISTINCT nombre_cie FROM censo_arboreo WHERE gbif_key IS NULL GROUP BY nombre_cie ORDER BY nombre_cie;

UPDATE censo_arboreo SET gbif_key = '2775596' WHERE nombre_cie = 'Yucca arborescens';

UPDATE censo_arboreo SET gbif_backbone = 'https://www.gbif.org/species/' || gbif_key WHERE nombre_cie = 'Yucca arborescens';

SELECT DISTINCT gbif_backbone FROM censo_arboreo WHERE nombre_cie = 'Bucida buceras';

SELECT nombre_cie, COUNT(DISTINCT id_arbol) as arboles FROM censo_arboreo GROUP BY nombre_cie ORDER BY arboles DESC;






