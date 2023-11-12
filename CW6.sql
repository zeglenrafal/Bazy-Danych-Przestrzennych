create extension postgis;
CREATE TABLE obiekty(id INT PRIMARY KEY, nazwa varchar(10), geom GEOMETRY );

INSERT INTO obiekty VALUES (1,'obiekt1', 'COMPOUNDCURVE( (0 1, 1 1), CIRCULARSTRING(1 1, 2 0, 3 1),CIRCULARSTRING(3 1, 4 2, 5 1), (5 1, 6 1))');
INSERT INTO obiekty VALUES (2,'obiekt2', 'CURVEPOLYGON(
                                        COMPOUNDCURVE( (10 6, 14 6), CIRCULARSTRING(14 6, 16 4, 14 2), CIRCULARSTRING(14 2, 12 0, 10 2), (10 2, 10 6)),
                                        COMPOUNDCURVE(CIRCULARSTRING(11 2,12 3, 13 2), CIRCULARSTRING(13 2, 12 1, 11 2)) )');
INSERT INTO obiekty VALUES (3,'obiekt3', 'CURVEPOLYGON(COMPOUNDCURVE((10 17, 12 13), (12 13, 7 15),(7 15, 10 17) ))');
INSERT INTO obiekty VALUES (4,'obiekt4', 'COMPOUNDCURVE( (20 20, 25 25), (25 25, 27 24),(27 24, 25 22),(25 22, 26 21), (26 21, 22 19),(22 19, 20.5 19.5))');
INSERT INTO obiekty VALUES (5,'obiekt5', 'MULTIPOINT(30 30 59, 38 32 234)');
INSERT INTO obiekty VALUES (6,'obiekt6', 'GEOMETRYCOLLECTION ( POINT(2 3), LINESTRING(1 1, 3 2))');


 --CW2
 SELECT ST_Area(ST_buffer(ST_Shortestline(ST_centroid(SELECT geom FROM obiekty WHERE nazwa ='obiekt3'),(SELECT geom FROM obiekty WHERE nazwa ='obiekt4')),5));
 
--CW3
UPDATE obiekty
SET geom  = 'COMPOUNDCURVE( (20 20, 25 25), (25 25, 27 24),(27 24, 25 22),(25 22, 26 21), (26 21, 22 19),(22 19, 20.5 19.5), (20.5 19.5, 20 20))' 
WHERE nazwa = 'obiekt4';
SELECT ST_asText(ST_BuildArea(geom)) FROM obiekty WHERE name='obiekt4';

--CW4
INSERT INTO obiekty VALUES(7,'obiekt7',ST_Union((SELECT geom FROM obiekty WHERE id ='3'),(SELECT geom FROM obiekty WHERE id ='4')));
--CW5
SELECT ST_Area(ST_Buffer(ST_Union(array(SELECT geom FROM obiekty WHERE ST_asText(geom) != '%CIRCULARSTRING%')),5));


SELECT ST_asText(geom) FROM obiekty;
