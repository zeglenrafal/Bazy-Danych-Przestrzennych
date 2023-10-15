--1
CREATE EXTENSION postgis;
--2
CREATE TABLE budynki(id int, geometria GEOMETRY, nazwa varchar(50));
CREATE TABLE drogi(id int, geometria GEOMETRY, nazwa varchar(50));
CREATE TABLE punkty_informacyjne(id int, geometria GEOMETRY, nazwa varchar(50));
--3
INSERT INTO budynki VALUES (1, ST_GeomFromText('POLYGON((8 1.5, 10.5 1.5, 10.5 4, 8 4, 8 1.5))'), 'BuildingA'),
	(2, ST_GeomFromText('POLYGON((4 5, 6 5, 6 7, 4 7, 4 5))'), 'BuildingB'),
	(3, ST_GeomFromText('POLYGON((3 6, 5 6, 5 8, 3 8, 3 6))'), 'BuildingC'),
	(4, ST_GeomFromText('POLYGON((9 8, 10 8, 10 9, 9 9, 9 8))'), 'BuildingD'),
	(5, ST_GeomFromText('POLYGON((1 1, 2 1, 2 2, 1 2, 1 1))'), 'BuildingF');

SELECT * FROM budynki;

INSERT INTO punkty_informacyjne VALUES (1, ST_GeomFromText('POINT(1.0 3.5)'), 'G'),
(2, ST_GeomFromText('POINT(5.5 1.5)'), 'H'),
(3, ST_GeomFromText('POINT(9.5 6.0)'), 'I'),
(4, ST_GeomFromText('POINT(6.5 6.0)'), 'J'),
(5, ST_GeomFromText('POINT(6.0 9.5)'), 'K');
	
SELECT * FROM punkty_informacyjne;
	
INSERT INTO drogi VALUES (1, ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)'), 'RoadX'),
(2, ST_GeomFromText('LINESTRING(7.5 10.5, 7.5 0)'), 'RoadY');

SELECT * FROM drogi;

--a
SELECT sum(ST_Length(geometria)) FROM drogi;
--b
SELECT ST_asText(geometria), ST_Area(geometria), ST_Perimeter(geometria) FROM budynki WHERE nazwa='BuildingA'
--c
SELECT nazwa, ST_Area(geometria) as Pole_Powierzchni FROM budynki ORDER BY nazwa
--d
SELECT nazwa, ST_Perimeter(geometria) as Obwod FROM budynki ORDER BY ST_Area(geometria) DESC limit 2
--e
SELECT ST_Distance((SELECT geometria FROM budynki WHERE nazwa='BuildingC'),(SELECT geometria FROM punkty_informacyjne WHERE nazwa='G'))
--f
SELECT St_Area(geometria) - ST_Area(ST_Intersection((SELECT geometria FROM budynki WHERE nazwa = 'BuildingC'),(SELECT ST_Buffer((SELECT geometria FROM budynki WHERE nazwa = 'BuildingB'),0.5)))) FROM budynki WHERE nazwa='BuildingC'
--g
SELECT * FROM budynki WHERE ST_Y(ST_Centroid(geometria)) > ST_Y((SELECT ST_Centroid(geometria) FROM drogi WHERE nazwa ='RoadX')) 

SELECT ST_Area(ST_SymDifference(geometria, ST_GeomFromText('POLYGON((4 7,6 7,6 8,4 8,4 7))', -1))) FROM budynki WHERE nazwa = 'BuildingC';