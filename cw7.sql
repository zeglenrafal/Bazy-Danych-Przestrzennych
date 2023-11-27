create extension postgis;
create extension postgis_raster;

SELECT * FROM raster_columns;

--Przyklad 1
CREATE TABLE zeglen.intersects AS
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

-- dodanie serial primary key:
alter table zeglen.intersects
add column rid SERIAL PRIMARY KEY;

-- utworzenie indeksu przestrzennego:
CREATE INDEX idx_intersects_rast_gist ON zeglen.intersects
USING gist (ST_ConvexHull(rast));

-- dodanie raster constraints:
SELECT AddRasterConstraints('zeglen'::name,
'intersects'::name,'rast'::name);

--Przyklad 2

CREATE TABLE zeglen.clip AS
SELECT ST_Clip(a.rast, b.geom, true), b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO';

alter table zeglen.clip
add column rid SERIAL PRIMARY KEY;

CREATE INDEX idx_clip_rast_gist ON zeglen.clip
USING gist (ST_ConvexHull(st_clip));

SELECT AddRasterConstraints('zeglen'::name,
'clip'::name,'st_clip'::name);

--Przyklad 3

CREATE TABLE zeglen.union AS
SELECT ST_Union(ST_Clip(a.rast, b.geom, true))
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast);

alter table zeglen.union
add column rid SERIAL PRIMARY KEY;

CREATE INDEX idx_union_rast_gist ON zeglen.union
USING gist (ST_ConvexHull(st_union));

SELECT AddRasterConstraints('zeglen'::name,
'union'::name,'st_union'::name);

--Przyklad 2.1

CREATE TABLE zeglen.porto_parishes AS
WITH r AS (
	SELECT rast FROM rasters.dem
	LIMIT 1
)
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

alter table zeglen.porto_parishes
add column rid SERIAL PRIMARY KEY;

CREATE INDEX idx_porto_rast_gist ON zeglen.porto_parishes
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zeglen'::name,
'porto_parishes'::name,'rast'::name);


--Przyklad 2.2
DROP TABLE zeglen.porto_parishes; --> drop table porto_parishes first
CREATE TABLE zeglen.porto_parishes AS
WITH r AS (
	SELECT rast FROM rasters.dem
	LIMIT 1
)
SELECT st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

alter table zeglen.porto_parishes
add column rid SERIAL PRIMARY KEY;

CREATE INDEX idx_porto_rast_gist ON zeglen.porto_parishes
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zeglen'::name,
'porto_parishes'::name,'rast'::name);

--Przyklad 2.3

DROP TABLE zeglen.porto_parishes; --> drop table porto_parishes first
CREATE TABLE zeglen.porto_parishes AS
WITH r AS (
	SELECT rast FROM rasters.dem
	LIMIT 1 
)
SELECT st_tile(st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-
32767)),128,128,true,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

alter table zeglen.porto_parishes
add column rid SERIAL PRIMARY KEY;

CREATE INDEX idx_porto_rast_gist ON zeglen.porto_parishes
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zeglen'::name,
'porto_parishes'::name,'rast'::name);


--Przyklad 3.1

CREATE TABLE zeglen.intersection as
SELECT
a.rid,(ST_Intersection(b.geom,a.rast)).geom,(ST_Intersection(b.geom,a.rast)
).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

-- Przykład 3.2 
CREATE TABLE zeglen.dumppolygons AS
SELECT
a.rid,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,
(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);





-- Przykład 4.1. 
CREATE TABLE zeglen.landsat_nir AS
SELECT rid, ST_Band(rast,4) AS rast
FROM rasters.landsat8;

CREATE INDEX idx_landsat_nir_rast_gist ON zeglen.landsat_nir
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zeglen'::name,
'landsat_nir'::name,'rast'::name);


-- Przykład 4.2 
CREATE TABLE zeglen.paranhos_dem AS
SELECT a.rid,ST_Clip(a.rast, b.geom,true) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

CREATE INDEX idx_paranhos_dem_rast_gist ON zeglen.paranhos_dem
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zeglen'::name,
'paranhos_dem'::name,'rast'::name);


-- Przykład 4.3
CREATE TABLE zeglen.paranhos_slope AS
SELECT a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast
FROM zeglen.paranhos_dem AS a;

CREATE INDEX idx_paranhos_slope_rast_gist ON zeglen.paranhos_slope
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zeglen'::name,
'paranhos_slope'::name,'rast'::name);


-- Przykład 4.4. 
CREATE TABLE zeglen.paranhos_slope_reclass AS
SELECT a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3',
'32BF',0)
FROM zeglen.paranhos_slope AS a;

CREATE INDEX idx_paranhos_slope_reclass_rast_gist ON zeglen.paranhos_slope_reclass
USING gist (ST_ConvexHull(st_reclass));

SELECT AddRasterConstraints('zeglen'::name,
'paranhos_slope_reclass'::name,'st_reclass'::name);


-- Przykład 4.5.
SELECT st_summarystats(a.rast) AS stats
FROM zeglen.paranhos_dem AS a;


-- Przykład 4.6. 
SELECT st_summarystats(ST_Union(a.rast))
FROM zeglen.paranhos_dem AS a;


-- Przykład 4.7
WITH t AS (
	SELECT st_summarystats(ST_Union(a.rast)) AS stats
	FROM zeglen.paranhos_dem AS a
)
SELECT (stats).min,(stats).max,(stats).mean FROM t;


-- Przykład 4.8. 
WITH t AS (
	SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast,
	b.geom,true))) AS stats
	FROM rasters.dem AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
	group by b.parish
)
SELECT parish,(stats).min,(stats).max,(stats).mean FROM t;


-- Przykład 4.9. - ST_Value
SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM
rasters.dem a, vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;


-- Przykład 10. - ST_TPI
create table zeglen.tpi30 as 
select ST_TPI(a.rast,1) as rast
from rasters.dem a;

CREATE INDEX idx_tpi30_rast_gist ON zeglen.tpi30
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zeglen'::name,
'tpi30'::name,'rast'::name);
--  1 min 19s

-- Problem do samodzielnego rozwiązania
CREATE TABLE zeglen.tpi30_2 as 
select ST_TPI(a.rast,1) as rast
from rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

CREATE INDEX idx_tpi30_2_rast_gist ON zeglen.tpi30_2
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zeglen'::name,
'tpi30_2'::name,'rast'::name);
-- 2 sec 756ms



-- Przykład 5.1. 
CREATE TABLE zeglen.porto_ndvi AS
WITH r AS (
	SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
	FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
	r.rid,ST_MapAlgebra(r.rast, 1, r.rast, 4,
	'([rast2.val] - [rast1.val]) / ([rast2.val] +
	[rast1.val])::float','32BF'
) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi_rast_gist ON zeglen.porto_ndvi
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zeglen'::name,
'porto_ndvi'::name,'rast'::name);


-- Przykład 2. – Funkcja zwrotna
create or replace function zeglen.ndvi(
	value double precision [] [] [],
	pos integer [][],
	VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
	--RAISE NOTICE 'Pixel Value: %', value [1][1][1];-->For debug purposes
	RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value
	[1][1][1]); --> NDVI calculation!
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;

CREATE TABLE zeglen.porto_ndvi2 AS
WITH r AS (
	SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
	FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
	r.rid,ST_MapAlgebra(r.rast, ARRAY[1,4],
	'zeglen.ndvi(double precision[],
	integer[],text[])'::regprocedure, --> This is the function!
	'32BF'::text
) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi2_rast_gist ON zeglen.porto_ndvi2
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zeglen'::name,
'porto_ndvi2'::name,'rast'::name);




-- Przykład 6.1. - ST_AsTiff
SELECT ST_AsTiff(ST_Union(rast))
FROM zeglen.porto_ndvi;


-- Przykład 6.2. - ST_AsGDALRaster
SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
FROM zeglen.porto_ndvi;


SELECT ST_GDALDrivers();


-- Przykład 6.3 
CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
	ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
	'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM zeglen.porto_ndvi;
----------------------------------------------
SELECT lo_export(loid, 'D:\dane\myraster.tiff') --> Save the file in a place where
-- the user postgres have access. In windows a flash drive usualy works fine.
FROM tmp_out;
----------------------------------------------
SELECT lo_unlink(loid)
FROM tmp_out; 