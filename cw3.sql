CREATE extension postgis;
--4
SELECT * FROM popp;

WITH c_buildings AS
(SELECT popp.* FROM popp, majrivers WHERE f_codedesc = 'Building' AND ST_DWithin(popp.geom,majrivers.geom,1000)) 
SELECT count(*) FROM c_buildings;


SELECT popp.* INTO tableB FROM popp, majrivers WHERE f_codedesc = 'Building' AND ST_DWithin(popp.geom,majrivers.geom,1000);
SELECT * FROM tableB;

DROP TABLE tableB;
--5
SELECT airports.name, airports.geom, airports.elev INTO airportsNew FROM airports;
SELECT * FROM airportsNew; 

--a) 
SELECT airportsNew.name as zachod, ST_X(airportsNew.geom) FROM airportsNew ORDER BY ST_X(airportsNew.geom) LIMIT 1;
SELECT airportsNew.name as wschod, ST_X(airportsNew.geom) FROM airportsNew ORDER BY ST_X(airportsNew.geom) DESC LIMIT 1;

--b)
SELECT * FROM airportsNew;

INSERT INTO airportsNew VALUES 
('airportB',(SELECT ST_Centroid(ST_MakeLine((SELECT geom FROM airportsNew ORDER BY ST_X(airportsNew.geom) LIMIT 1),(SELECT geom FROM airportsNew ORDER BY ST_X(airportsNew.geom) DESC LIMIT 1)))),123);
SELECT * FROM airportsNew WHERE airportsNew.name ='airportB';
--6
SELECT ST_area(St_buffer(St_ShortestLine(airports.geom, lakes.geom), 1000)) AS area
FROM airports, lakes
WHERE lakes.names='Iliamna Lake' AND airports.name='AMBLER';
--7
SELECT * FROM trees;
SELECT vegdesc, SUM(ST_Area(trees.geom)) FROM trees,tundra,swamp WHERE ST_Contains(tundra.geom,trees.geom) OR ST_Contains(swamp.geom,trees.geom) GROUP BY vegdesc;
