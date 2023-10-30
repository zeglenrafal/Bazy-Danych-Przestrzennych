SELECT * FROM t2018_kar_buildings;

-- 1) Znajdź budynki, które zostały wybudowane lub wyremontowane 
--	  na przestrzeni roku (zmiana pomiędzy 2018 a 2019).
SELECT * INTO changed
FROM t2019_kar_buildings  
WHERE NOT EXISTS (
	SELECT polygon_id FROM t2018_kar_buildings WHERE ST_Equals(t2019_kar_buildings.geom, t2018_kar_buildings.geom) 
);
SELECT*FROM changed;
-- 2) Znajdź ile nowych POI pojawiło się w promieniu 500 m
-- 	  od wyremontowanych lub wybudowanych budynków, które znalezione
--    zostały w zadaniu 1. Policz je wg ich kategorii.
WITH poi
AS
(
	SELECT * FROM t2019_kar_poi_table 
	WHERE NOT EXISTS (SELECT * FROM t2018_kar_poi_table
				WHERE t2019_kar_poi_table.poi_id = t2018_kar_poi_table.poi_id)
)
SELECT poi.type, COUNT(ST_Contains(ST_Buffer(changed.geom, 500), poi.geom))
FROM changed , poi
GROUP BY poi.type;

-- 3 Utwórz nową tabelę o nazwie ‘streets_reprojected’, która zawierać będzie dane z tabeli
--	  T2019_KAR_STREETS przetransformowane do układu współrzędnych DHDN.Berlin/Cassini.


CREATE TABLE streets_reprojected AS(
	SELECT gid, link_id, st_name, ref_in_id, nref_in_id,func_class, speed_cat, fr_speed_l, to_speed_l, dir_travel, 
	ST_Transform(ST_SetSRID(geom,4326), 3068) AS geom FROM t2019_kar_streets
)
DROP TABLE streets_reprojected;

SELECT ST_AsText(geom) FROM streets_reprojected;
SELECT ST_AsText(geom) FROM t2019_kar_streets;

-- 4 Stwórz tabelę o nazwie ‘input_points’ i dodaj do niej dwa rekordy o geometrii punktowej.

CREATE TABLE input_points (id INT PRIMARY KEY,geom GEOMETRY);
INSERT INTO input_points VALUES 
(1,ST_GeomFromText('POINT(8.36093 49.03174)', 4326)),
(2,ST_GeomFromText('POINT(8.39876 49.00644)', 4326));
SELECT * FROM input_points;

DROP TABLE input_points;
-- 5 Zaktualizuj dane w tabeli ‘input_points’ tak, aby punkty te były w układzie
--	  współrzędnych DHDN.Berlin/Cassini. Wyświetl współrzędne za pomocą funkcji ST_AsText().

ALTER TABLE input_points ALTER COLUMN geom 
TYPE geometry('POINT', 3068) USING ST_Transform(ST_SetSRID(geom,4326),3068);

SELECT ST_AsText(geom) FROM input_points;

-- 6 Znajdź wszystkie skrzyżowania, które znajdują się w odległości 200 m od linii
--	  zbudowanej z punktów w tabeli ‘input_points’. Wykorzystaj tabelę T2019_STREET_NODE. 
--	  Dokonaj reprojekcji geometrii, aby była zgodna z resztą tabel.	

SELECT * FROM t2019_kar_street_node  
WHERE ST_Contains(
		ST_Transform(
		  ST_Buffer(
			ST_ShortestLine(
				(SELECT geom FROM input_points WHERE input_points.id = 1),			  
				(SELECT geom FROM input_points WHERE input_points.id =2)
			)
		  , 200)
		, 4326)
	  , geom); 
	
-- 7 Policz jak wiele sklepów sportowych (‘Sporting Goods Store’ - tabela POIs)
--	  znajduje się w odległości 300 m od parków (LAND_USE_A).

WITH parks
AS
(
	SELECT ST_Union(ST_Buffer(geom, 300)) 
	AS geom
	FROM t2019_kar_land_use_a
	WHERE type = 'Park (City/County)'
)
SELECT COUNT(*) FROM t2019_kar_poi_table, parks 
WHERE type = 'Sporting Goods Store'
AND ST_Contains(parks.geom,t2019_kar_poi_table.geom );

-- 8 Znajdź punkty przecięcia torów kolejowych (RAILWAYS) z ciekami (WATER_LINES).
--	  Zapisz znalezioną geometrię do osobnej tabeli o nazwie ‘T2019_KAR_BRIDGES’.
SELECT ST_Intersection(t2019_kar_railways.geom, t2019_kar_water_lines.geom) INTO T2019_KAR_BRIDGES
FROM t2019_kar_railways , t2019_kar_water_lines ;

SELECT * FROM T2019_KAR_BRIDGES;