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

--General queries about tree species in the district territory

SELECT nombre_cie AS nombre_tecnico, nombre_com AS nombre_comun, COUNT(DISTINCT id_arbol) AS num_ejemplares FROM censo_arboreo GROUP BY nombre_cie,
nombre_com ORDER BY num_ejemplares DESC;

/* Spatial linkage and integration of territorial information of the District of Cali in the GBIF databases of fauna species records
(Mammals, reptiles, anphibians and insects presence records)*/

ALTER TABLE fauna
ADD COLUMN land_use varchar(10) default 'No aplica',
ADD COLUMN comuna varchar(10) default 'No aplica',
ADD COLUMN barrio varchar(70) default 'No aplica',
ADD COLUMN corregimiento varchar(70) default 'No aplica';

-- Spatial segmentation of the pollinators PostGIS layer (Families: Apidae, Halictidae, Colletidae and Megachilidae presence records)

ALTER TABLE polinizadores
ADD COLUMN land_use varchar(10) default 'No aplica',
ADD COLUMN comuna varchar(10) default 'No aplica',
ADD COLUMN barrio varchar(70) default 'No aplica',
ADD COLUMN corregimiento varchar(70) default 'No aplica';

-- Spatial segmentation of the GBIF Plantae data for the Cali's administrative territory

ALTER TABLE gbif_plantae_cali
ADD COLUMN land_use varchar(10) default 'No aplica',
ADD COLUMN comuna varchar(10) default 'No aplica',
ADD COLUMN barrio varchar(70) default 'No aplica',
ADD COLUMN corregimiento varchar(70) default 'No aplica';

-- The process for the GBIF birds PostGIS layer is omitted because of the size of the layer...

-- land use segmentation

UPDATE fauna SET land_use = 'Urbano' FROM perimetro_urbano WHERE ST_INTERSECTS(fauna.geom, perimetro_urbano.geom);
UPDATE fauna SET land_use = 'Rural' FROM corregimientos WHERE ST_INTERSECTS(fauna.geom, corregimientos.geom);
UPDATE fauna SET land_use = 'Expansion' FROM perimetro_expansion WHERE ST_INTERSECTS(fauna.geom, perimetro_expansion.geom);

UPDATE gbif_plantae_cali SET land_use = 'Urbano' FROM perimetro_urbano WHERE ST_INTERSECTS(gbif_plantae_cali.geom, perimetro_urbano.geom);
UPDATE gbif_plantae_cali SET land_use = 'Rural' FROM corregimientos WHERE ST_INTERSECTS(gbif_plantae_cali.geom, corregimientos.geom);
UPDATE gbif_plantae_cali SET land_use = 'Expansion' FROM perimetro_expansion WHERE ST_INTERSECTS(gbif_plantae_cali.geom, perimetro_expansion.geom);

UPDATE polinizadores SET land_use = 'Urbano' FROM perimetro_urbano WHERE ST_INTERSECTS(polinizadores.geom, perimetro_urbano.geom);
UPDATE polinizadores SET land_use = 'Rural' FROM corregimientos WHERE ST_INTERSECTS(polinizadores.geom, corregimientos.geom);
UPDATE polinizadores SET land_use = 'Expansion' FROM perimetro_expansion WHERE ST_INTERSECTS(polinizadores.geom, perimetro_expansion.geom);

-- Comunas, neighborhoods and corregimientos segmentation

UPDATE fauna SET comuna = comunas.nombre FROM comunas WHERE ST_INTERSECTS(fauna.geom, comunas.geom);
UPDATE gbif_plantae_cali SET comuna = comunas.nombre FROM comunas WHERE ST_INTERSECTS(gbif_plantae_cali.geom, comunas.geom);
UPDATE polinizadores SET comuna= comunas.nombre FROM comunas WHERE ST_INTERSECTS(polinizadores.geom, comunas.geom);

UPDATE fauna SET barrio = barrios.barrio FROM barrios WHERE ST_INTERSECTS(fauna.geom, barrios.geom);
UPDATE gbif_plantae_cali SET barrio = barrios.barrio FROM barrios WHERE ST_INTERSECTS(gbif_plantae_cali.geom, barrios.geom);
UPDATE polinizadores SET barrio = barrios.barrio FROM barrios WHERE ST_INTERSECTS(polinizadores.geom, barrios.geom);

UPDATE fauna SET corregimiento = corregimientos.corregimie FROM corregimientos WHERE ST_INTERSECTS(fauna.geom, corregimientos.geom);
UPDATE gbif_plantae_cali SET corregimiento = corregimientos.corregimie FROM corregimientos WHERE ST_INTERSECTS(gbif_plantae_cali.geom, corregimientos.geom);
UPDATE polinizadores SET corregimiento = corregimientos.corregimie FROM corregimientos WHERE ST_INTERSECTS(polinizadores.geom, corregimientos.geom);

-- Calculation of biodiversity indicators for territorial entities of the District of Cali

-- Comunas
ALTER TABLE comunas
ADD COLUMN num_arboles int default 0,
ADD COLUMN especies_arboles int default 0, 
ADD COLUMN spec_gbif_plant int default 0,
ADD COLUMN spec_mammals int default 0,
ADD COLUMN spec_reptile int default 0,
ADD COLUMN spec_anphibian int default 0,
ADD COLUMN spec_insects int default 0,
ADD COLUMN spec_pollinators int default 0; 

UPDATE comunas SET num_arboles = (SELECT COUNT(DISTINCT id_arbol) FROM censo_arboreo WHERE ST_INTERSECTS(comunas.geom, censo_arboreo.geom));
UPDATE comunas SET especies_arboles = (SELECT COUNT(DISTINCT nombre_cie) FROM censo_arboreo WHERE ST_INTERSECTS(comunas.geom, censo_arboreo.geom));
UPDATE comunas SET spec_gbif_plant = (SELECT COUNT(DISTINCT species) FROM gbif_plantae_cali WHERE ST_INTERSECTS(comunas.geom, gbif_plantae_cali.geom));
UPDATE comunas SET spec_mammals = (SELECT COUNT(DISTINCT species) FROM fauna WHERE ST_INTERSECTS(comunas.geom, fauna.geom) AND fauna.class = 'Mammalia');
UPDATE comunas SET spec_reptile = (SELECT COUNT(DISTINCT species) FROM fauna WHERE ST_INTERSECTS(comunas.geom, fauna.geom) AND fauna.class = 'Reptilia');
UPDATE comunas SET spec_anphibian = (SELECT COUNT(DISTINCT species) FROM fauna WHERE ST_INTERSECTS(comunas.geom, fauna.geom) AND fauna.class = 'Amphibia');
UPDATE comunas SET spec_insects = (SELECT COUNT(DISTINCT species) FROM fauna WHERE ST_INTERSECTS(comunas.geom, fauna.geom) AND fauna.class = 'Insecta');
UPDATE comunas SET spec_pollinators = (SELECT COUNT(DISTINCT species) FROM polinizadores WHERE ST_INTERSECTS(comunas.geom, polinizadores.geom));

-- Neighborhoods
ALTER TABLE barrios
ADD COLUMN num_arboles int default 0,
ADD COLUMN especies_arboles int default 0, 
ADD COLUMN spec_gbif_plant int default 0,
ADD COLUMN spec_mammals int default 0,
ADD COLUMN spec_reptile int default 0,
ADD COLUMN spec_anphibian int default 0,
ADD COLUMN spec_insects int default 0,
ADD COLUMN spec_pollinators int default 0; 


UPDATE barrios SET num_arboles = (SELECT COUNT(DISTINCT id_arbol) FROM censo_arboreo WHERE ST_INTERSECTS(barrios.geom, censo_arboreo.geom));
UPDATE barrios SET especies_arboles = (SELECT COUNT(DISTINCT nombre_cie) FROM censo_arboreo WHERE ST_INTERSECTS(barrios.geom, censo_arboreo.geom));
UPDATE barrios SET spec_gbif_plant = (SELECT COUNT(DISTINCT species) FROM gbif_plantae_cali WHERE ST_INTERSECTS(barrios.geom, gbif_plantae_cali.geom));
UPDATE barrios SET spec_mammals = (SELECT COUNT(DISTINCT species) FROM fauna WHERE ST_INTERSECTS(barrios.geom, fauna.geom) AND fauna.class = 'Mammalia');
UPDATE barrios SET spec_reptile = (SELECT COUNT(DISTINCT species) FROM fauna WHERE ST_INTERSECTS(barrios.geom, fauna.geom) AND fauna.class = 'Reptilia');
UPDATE barrios SET spec_anphibian = (SELECT COUNT(DISTINCT species) FROM fauna WHERE ST_INTERSECTS(barrios.geom, fauna.geom) AND fauna.class = 'Amphibia');
UPDATE barrios SET spec_insects = (SELECT COUNT(DISTINCT species) FROM fauna WHERE ST_INTERSECTS(barrios.geom, fauna.geom) AND fauna.class = 'Insecta');
UPDATE barrios SET spec_pollinators = (SELECT COUNT(DISTINCT species) FROM polinizadores WHERE ST_INTERSECTS(barrios.geom, polinizadores.geom));

-- Corregimientos (Rural land use)
ALTER TABLE corregimientos
ADD COLUMN num_arboles int default 0,
ADD COLUMN especies_arboles int default 0, 
ADD COLUMN spec_gbif_plant int default 0,
ADD COLUMN spec_mammals int default 0,
ADD COLUMN spec_reptile int default 0,
ADD COLUMN spec_anphibian int default 0,
ADD COLUMN spec_insects int default 0,
ADD COLUMN spec_pollinators int default 0; 


UPDATE corregimientos SET spec_gbif_plant = (SELECT COUNT(DISTINCT species) FROM gbif_plantae_cali WHERE ST_INTERSECTS(corregimientos.geom, gbif_plantae_cali.geom));
UPDATE corregimientos SET spec_mammals = (SELECT COUNT(DISTINCT species) FROM fauna WHERE ST_INTERSECTS(corregimientos.geom, fauna.geom) AND fauna.class = 'Mammalia');
UPDATE corregimientos SET spec_reptile = (SELECT COUNT(DISTINCT species) FROM fauna WHERE ST_INTERSECTS(corregimientos.geom, fauna.geom) AND fauna.class = 'Reptilia');
UPDATE corregimientos SET spec_anphibian = (SELECT COUNT(DISTINCT species) FROM fauna WHERE ST_INTERSECTS(corregimientos.geom, fauna.geom) AND fauna.class = 'Amphibia');
UPDATE corregimientos SET spec_insects = (SELECT COUNT(DISTINCT species) FROM fauna WHERE ST_INTERSECTS(corregimientos.geom, fauna.geom) AND fauna.class = 'Insecta');
UPDATE corregimientos SET spec_pollinators = (SELECT COUNT(DISTINCT species) FROM polinizadores WHERE ST_INTERSECTS(corregimientos.geom, polinizadores.geom));


-- Simpson index calculation for each territorial entity

-- Comunas
ALTER TABLE comunas
ADD COLUMN rec_gbif_plant int default 0,
ADD COLUMN rec_mammals int default 0,
ADD COLUMN rec_reptile int default 0,
ADD COLUMN rec_anphibian int default 0,
ADD COLUMN rec_insects int default 0,
ADD COLUMN rec_pollinators int default 0;

UPDATE comunas SET rec_gbif_plant = (SELECT COUNT(DISTINCT gbif_plantae_cali.id) FROM gbif_plantae_cali WHERE ST_INTERSECTS(comunas.geom, gbif_plantae_cali.geom));
UPDATE comunas SET rec_mammals = (SELECT COUNT(DISTINCT fauna.id) FROM fauna WHERE ST_INTERSECTS(comunas.geom, fauna.geom) AND fauna.class = 'Mammalia');
UPDATE comunas SET rec_reptile = (SELECT COUNT(DISTINCT fauna.id) FROM fauna WHERE ST_INTERSECTS(comunas.geom, fauna.geom) AND fauna.class = 'Reptilia');
UPDATE comunas SET rec_anphibian = (SELECT COUNT(DISTINCT fauna.id) FROM fauna WHERE ST_INTERSECTS(comunas.geom, fauna.geom) AND fauna.class = 'Amphibia');
UPDATE comunas SET rec_insects = (SELECT COUNT(DISTINCT fauna.id) FROM fauna WHERE ST_INTERSECTS(comunas.geom, fauna.geom) AND fauna.class = 'Insecta');
UPDATE comunas SET rec_pollinators = (SELECT COUNT(DISTINCT polinizadores.id) FROM polinizadores WHERE ST_INTERSECTS(comunas.geom, polinizadores.geom));

CREATE TABLE species_com1(id serial primary key, species varchar(80), records int);
CREATE TABLE plant_com1(id serial primary key, species varchar(80), records int);
CREATE TABLE mammals_com1(id serial primary key, species varchar(80), records int);
CREATE TABLE reptile_com1(id serial primary key, species varchar(80), records int);
CREATE TABLE anphibian_com1(id serial primary key, species varchar(80), records int);
CREATE TABLE insects_com1(id serial primary key, species varchar(80), records int);
CREATE TABLE pollinators_com1(id serial primary key, species varchar(80), records int);

INSERT INTO species_com1(species, records) SELECT nombre_cie AS species, COUNT(DISTINCT id_arbol) AS records FROM censo_arboreo WHERE censo_arboreo.comuna = '1' GROUP BY species ORDER BY records DESC;

ALTER TABLE comunas 
ADD COLUMN simps_indx_arbol float8;

UPDATE comunas SET simps_indx_arbol = 1 - (SELECT SUM(power(species_com1.records,2)) / power(num_arboles,2) FROM species_com1 WHERE comuna = '1');

-- GBIF Backbone URL field creation for fauna PostGIS layers

ALTER TABLE fauna ADD COLUMN gbif_backbone varchar(120);
ALTER TABLE gbif_plantae_cali ADD COLUMN gbif_backbone varchar(120);
ALTER TABLE polinizadores ADD COLUMN gbif_backbone varchar(120);

UPDATE fauna SET gbif_backbone = 'https://www.gbif.org/species/' || taxonkey;
UPDATE gbif_plantae_cali SET gbif_backbone = 'https://www.gbif.org/species/' || taxonkey;
UPDATE polinizadores SET gbif_backbone = 'https://www.gbif.org/species/' || taxonkey;

-- Construction of the strategic ecosystems buffer (Protection areas)
-- Rivers

CREATE TABLE ap_rios(id serial primary key, nombre varchar(50), geom geometry(Polygon, 3115));

INSERT INTO ap_rios(geom, nombre) SELECT ST_Buffer(geom, 30), nombre FROM rios;

-- Wetlands

CREATE TABLE ap_humedales(id serial primary key, nombre varchar(80), geom geometry(Polygon, 3115));

INSERT INTO ap_humedales(geom, nombre) SELECT ST_Buffer(geom, 30), nombre FROM humedales;






