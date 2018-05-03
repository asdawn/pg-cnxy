/*_______________________
cnxy for PostGIS
WGS84-GCJ02-BAIDU coordinate converter
NOT PRECISE, BUT SOMEHOW VALID FOR [[[SOME]]] KINDS OF 2D GEOMETRY [[[WITHIN CHINA]]]
Now, st_point, st_linestring, st_circularstring, st_polygon and the collection type of them are supported.
Copyleft 2018 
______________________*/
/*
Important Functions
1. coordinate transformation functions
names:
	BD_To_GCJ02,
	CGJ02_To_BD,
	WGS84_To_BD,
	BD_To_WGS84,
	GCJ02_To_WGS84,
	WGS84_To_GCJ02
available signatures:
	double[] funcitonName(double x, double y) 
	decimal[] funcitonName(decimal x, decimal y) 
	PointGeometry funcitonName(PointGeometry)

2. the main converter for 2D geometry
Geometry cnxy_transform(Geometry geom, TEXT trans)
	geom - geometry
	trans - transformation type (case INSENSITIVE). These types are: 
		'BD_To_GCJ02',
		'CGJ02_To_BD',
		'WGS84_To_BD',
		'BD_To_WGS84',
		'GCJ02_To_WGS84',
		'WGS84_To_GCJ02'	
*/

----GCJ02---
/*
GCJ02_To_WGS84 ,(x, y)->[x',y'], decimal
*/
DROP FUNCTION if exists GCJ02_To_WGS84(DECIMAL, DECIMAL);
CREATE FUNCTION GCJ02_To_WGS84(x DECIMAL, y DECIMAL) RETURNS DECIMAL[] AS $$
DECLARE 
    ret DECIMAL[];
    trans DECIMAL[];   
BEGIN
	trans := _transform(x, y);
    ret[0] := x * 2 - trans[0];
	ret[1] := y * 2 - trans[1];
    RETURN ret;
END;
$$ LANGUAGE plpgsql;

/*
GCJ02_To_WGS84, (x, y)->[x',y'], double
*/
DROP FUNCTION if exists GCJ02_To_WGS84(DOUBLE PRECISION,  DOUBLE PRECISION);
CREATE FUNCTION GCJ02_To_WGS84(x DOUBLE PRECISION, y DOUBLE PRECISION) RETURNS DOUBLE PRECISION[] AS $$
DECLARE
	retl DECIMAL[];
BEGIN
	ret := GCJ02_To_WGS84(x::decimal,y::decimal);
    return ret::double precision[];	
END;	
$$ LANGUAGE plpgsql;

/*
GCJ02_To_WGS84, (x, y)->ST_POINT(x',y'), POINT 
*/
DROP FUNCTION if exists GCJ02_To_WGS84(GEOMETRY);
CREATE FUNCTION GCJ02_To_WGS84(point GEOMETRY) RETURNS GEOMETRY AS $$
DECLARE
	ret DECIMAL[];
BEGIN
    ret = GCJ02_To_WGS84(st_x(point)::decimal, st_y(point)::decimal);
	return st_point(ret[0], ret[1]);
END;	
$$ LANGUAGE plpgsql;

/*
GCJ02_To_BD, (x, y)->[x',y'], decimal
*/
DROP FUNCTION if exists GCJ02_To_BD(DECIMAL,  DECIMAL);
CREATE FUNCTION GCJ02_To_BD(x DECIMAL, y DECIMAL) RETURNS DECIMAL[] AS $$
DECLARE 
    ret DECIMAL[];
    z DECIMAL;
    theta DECIMAL;
BEGIN
	z := sqrt(x * x + y * y) + 0.00002 * sin(y * _cnxy_x_pi());
	theta := atan2(y, x) + 0.000003 * cos(x *_cnxy_x_pi());
	ret[0] := z * cos(theta) + 0.0065;
	ret[1] := z * sin(theta) + 0.006;
    RETURN ret;
END;
$$ LANGUAGE plpgsql;

/*
GCJ02_To_BD, (x, y)->[x',y'], double
*/
DROP FUNCTION if exists GCJ02_To_BD(DOUBLE PRECISION,  DOUBLE PRECISION);
CREATE FUNCTION GCJ02_To_BD(x DOUBLE PRECISION, y DOUBLE PRECISION) RETURNS DOUBLE PRECISION[] AS $$
DECLARE
	retl DECIMAL[];
BEGIN
	ret := GCJ02_To_BD(x::decimal,y::decimal);
    return ret::double precision[];	
END;	
$$ LANGUAGE plpgsql;

/*
GCJ02_To_BD, (x, y)->ST_POINT(x',y'), POINT 
*/
DROP FUNCTION if exists GCJ02_To_BD(GEOMETRY);
CREATE FUNCTION GCJ02_To_BD(point GEOMETRY) RETURNS GEOMETRY AS $$
DECLARE
	ret DECIMAL[];
BEGIN
    ret = GCJ02_To_BD(st_x(point)::decimal, st_y(point)::decimal);
	return st_point(ret[0], ret[1]);
END;	
$$ LANGUAGE plpgsql;

------BD--------
/*
BD_To_GCJ02, (x, y)->[x',y'], decimal
*/
DROP FUNCTION if exists BD_To_GCJ02(DECIMAL,  DECIMAL);
CREATE FUNCTION BD_To_GCJ02(bd_x DECIMAL, bd_y DECIMAL) RETURNS DECIMAL[] AS $$
DECLARE 
    ret DECIMAL[];
    x DECIMAL;
    y DECIMAL;
    z DECIMAL;
    theta DECIMAL;
BEGIN
	x := bd_x - 0.0065;
    y := bd_y - 0.006;
	z := sqrt(x * x + y * y) - 0.00002 * sin(y * _cnxy_x_pi());
	theta := atan2(y, x) - 0.000003 *cos(x * _cnxy_x_pi());
	ret[0] := z * cos(theta);
	ret[1] := z * sin(theta);
	RETURN ret;
END;
$$ LANGUAGE plpgsql;

/*
BD_To_GCJ02, (x, y)->[x',y'], double
*/
DROP FUNCTION if exists BD_To_GCJ02(DOUBLE PRECISION,  DOUBLE PRECISION);
CREATE FUNCTION BD_To_GCJ02(x DOUBLE PRECISION, y DOUBLE PRECISION) RETURNS DOUBLE PRECISION[] AS $$
DECLARE
	retl DECIMAL[];
BEGIN
	ret := BD_To_GCJ02(x::decimal,y::decimal);
    return ret::double precision[];	
END;	
$$ LANGUAGE plpgsql;

/*
BD_To_GCJ02, (x, y)->ST_POINT(x',y'), POINT 
*/
DROP FUNCTION if exists BD_To_GCJ02(GEOMETRY);
CREATE FUNCTION BD_To_GCJ02(point GEOMETRY) RETURNS GEOMETRY AS $$
DECLARE
	ret DECIMAL[];
BEGIN
    ret = BD_To_GCJ02(st_x(point)::decimal, st_y(point)::decimal);
	return st_point(ret[0], ret[1]);
END;	
$$ LANGUAGE plpgsql;

/*
BD_To_WGS84 , (x, y)->[x',y'], decimal
*/
DROP FUNCTION if exists BD_To_WGS84(DECIMAL,  DECIMAL);
CREATE FUNCTION BD_To_WGS84(x DECIMAL, y DECIMAL) RETURNS DECIMAL[] AS $$
DECLARE 
    ret DECIMAL[];
BEGIN
	--bd to 02
	ret = BD_To_GCJ02(x,y);
	RETURN GCJ02_To_WGS84(ret[0],ret[1]);
END;
$$ LANGUAGE plpgsql;

/*
BD_To_WGS84, (x, y)->[x',y'], double
*/
DROP FUNCTION if exists BD_To_WGS84(DOUBLE PRECISION,  DOUBLE PRECISION);
CREATE FUNCTION BD_To_WGS84(x DOUBLE PRECISION, y DOUBLE PRECISION) RETURNS DOUBLE PRECISION[] AS $$
DECLARE
	retl DECIMAL[];
BEGIN
	ret := BD_To_WGS84(x::decimal,y::decimal);
    return ret::double precision[];	
END;	
$$ LANGUAGE plpgsql;

/*
BD_To_WGS84, (x, y)->ST_POINT(x',y'), POINT 
*/
DROP FUNCTION if exists BD_To_WGS84(GEOMETRY);
CREATE FUNCTION BD_To_WGS84(point GEOMETRY) RETURNS GEOMETRY AS $$
DECLARE
	ret DECIMAL[];
BEGIN
    ret = BD_To_WGS84(st_x(point)::decimal, st_y(point)::decimal);
	return st_point(ret[0], ret[1]);
END;	
$$ LANGUAGE plpgsql;

---------WGS84-----------
/*
WGS84_to_GCJ02, (x, y)->[x',y'], decimal
*/
DROP FUNCTION if exists WGS84_to_GCJ02(DECIMAL,  DECIMAL);
CREATE FUNCTION WGS84_to_GCJ02(x DECIMAL, y DECIMAL) RETURNS DECIMAL[] AS $$
DECLARE
BEGIN
    RETURN _transform(x,y);
END;	
$$ LANGUAGE plpgsql;

/*
WGS84_to_GCJ02, (x, y)->[x',y'], double
*/
DROP FUNCTION if exists WGS84_to_GCJ02(DOUBLE PRECISION,  DOUBLE PRECISION);
CREATE FUNCTION WGS84_to_GCJ02(x DOUBLE PRECISION, y DOUBLE PRECISION) RETURNS DOUBLE PRECISION[] AS $$
DECLARE
	retl DECIMAL[];
BEGIN
	ret := WGS84_to_GCJ02(x::decimal,y::decimal);
    return ret::double precision[];
	
END;	
$$ LANGUAGE plpgsql;

/*
WGS84_to_GCJ02, (x, y)->ST_POINT(x',y'), POINT 
*/
DROP FUNCTION if exists WGS84_to_GCJ02(GEOMETRY);
CREATE FUNCTION WGS84_to_GCJ02(point GEOMETRY) RETURNS GEOMETRY AS $$
DECLARE
	ret DECIMAL[];
BEGIN
    ret = WGS84_to_GCJ02(st_x(point)::decimal, st_y(point)::decimal);
	return st_point(ret[0], ret[1]);
END;	
$$ LANGUAGE plpgsql;

/*
WGS84_To_BD, (x, y)->[x',y'], decimal
*/
DROP FUNCTION if exists WGS84_To_BD(DECIMAL,  DECIMAL);
CREATE FUNCTION WGS84_To_BD(x DECIMAL, y DECIMAL) RETURNS DECIMAL[] AS $$
DECLARE 
    ret DECIMAL[];
BEGIN
	--wgs84 to gcj02
	ret = WGS84_To_GCJ02(x,y);
	RETURN GCJ02_To_BD(ret[0],ret[1]);
END;
$$ LANGUAGE plpgsql;

/*
WGS84_To_BD, (x, y)->[x',y'], double
*/
DROP FUNCTION if exists WGS84_To_BD(DOUBLE PRECISION,  DOUBLE PRECISION);
CREATE FUNCTION WGS84_To_BD(x DOUBLE PRECISION, y DOUBLE PRECISION) RETURNS DOUBLE PRECISION[] AS $$
DECLARE
	retl DECIMAL[];
BEGIN
	ret := WGS84_To_BD(x::decimal,y::decimal);
    return ret::double precision[];	
END;	
$$ LANGUAGE plpgsql;

/*
WGS84_To_BD, (x, y)->ST_POINT(x',y'), POINT 
*/
DROP FUNCTION if exists WGS84_To_BD(GEOMETRY);
CREATE FUNCTION WGS84_To_BD(point GEOMETRY) RETURNS GEOMETRY AS $$
DECLARE
	ret DECIMAL[];
BEGIN
    ret = WGS84_To_BD(st_x(point)::decimal, st_y(point)::decimal);
	return st_point(ret[0], ret[1]);
END;	
$$ LANGUAGE plpgsql;

/***************************************private****************************************/
/*
_outOfChina
NOT PRECISE
*/
DROP FUNCTION if exists _outOfChina(DECIMAL,  DECIMAL);
CREATE FUNCTION _outOfChina(x DECIMAL, y DECIMAL) RETURNS BOOLEAN AS $$
DECLARE   
BEGIN
	IF x < 72.004 OR x > 137.8347 THEN
        RETURN TRUE;
    END IF;
    IF y < 0.8293 OR y > 55.8271 THEN
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

/*
_transform	
*/
DROP FUNCTION if exists _transform(DECIMAL, DECIMAL);
CREATE FUNCTION _transform(x DECIMAL, y DECIMAL) RETURNS DECIMAL[] AS $$
DECLARE
    ret DECIMAL[];
    dLat DECIMAL;
    dLon DECIMAL;
    radLat DECIMAL;
    magic DECIMAL;
    sqrtMagic DECIMAL;
BEGIN
	IF _outOfChina(x,y) THEN
        ret[0] = x;
        ret[1] = y;
        RETURN ret;
    END IF;
    dLat := _transformY(x - 105.0, y - 35.0);
	dLon := _transformX(x - 105.0, y - 35.0);
	radLat := y / 180.0 * PI();
	magic := sin(radLat);
	magic := 1 - _cnxy_ee() * magic * magic;
	sqrtMagic := sqrt(magic);
	dLat := (dLat * 180.0) / ((_cnxy_a() * (1 - _cnxy_ee())) / (magic * sqrtMagic) * PI());
	dLon := (dLon * 180.0) / (_cnxy_a() / sqrtMagic * cos(radLat) * PI());
	ret[0]:=x + dLon;
    ret[1] := y + dLat;
	return ret;
END;
$$ LANGUAGE plpgsql;

/*
_transformY
*/
DROP FUNCTION if exists _transformY(DECIMAL, DECIMAL);
CREATE FUNCTION _transformY(x DECIMAL, y DECIMAL) RETURNS DECIMAL AS $$
DECLARE
    ret DECIMAL;	
BEGIN
	 ret := -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x));
	 ret := ret + (20.0 * sin(6.0 * x *  PI()) + 20.0 * sin(2.0 * x * PI())) * 2.0 / 3.0;
	 ret := ret + (20.0 * sin(y *  PI()) + 40.0 * sin(y / 3.0 * PI())) * 2.0 / 3.0;
	 ret := ret +  (160.0 * sin(y / 12.0 *  PI()) + 320 * sin(y * PI() / 30.0)) * 2.0 / 3.0;
	 return ret;
END;
$$ LANGUAGE plpgsql;

/*
_transformX
*/
DROP FUNCTION if exists _transformX(DECIMAL, DECIMAL);
CREATE FUNCTION _transformX(x DECIMAL, y DECIMAL) RETURNS DECIMAL AS $$
DECLARE
    ret DECIMAL;	
BEGIN
	ret := 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x));
	ret := ret + (20.0 * sin(6.0 * x * PI()) + 20.0 * sin(2.0 * x * PI())) * 2.0 / 3.0;
	ret := ret + (20.0 * sin(x * PI()) + 40.0 * sin(x / 3.0 * PI())) * 2.0 / 3.0;
	ret := ret + (150.0 * sin(x / 12.0 * PI()) + 300.0 * sin(x / 30.0 * PI())) * 2.0 / 3.0;
	RETURN ret;
END;
$$ LANGUAGE plpgsql;

/************************geom converter*************************/
/*
cnxy_point
	single point converter.
	point - point geometry
	trans - transformation type (case INSENSITIVE). These types are: 
		'BD_To_GCJ02',
		'CGJ02_To_BD',
		'WGS84_To_BD',
		'BD_To_WGS84',
		'GCJ02_To_WGS84',
		'WGS84_To_GCJ02'
*/
DROP FUNCTION if exists cnxy_point(Geometry, text);
CREATE FUNCTION cnxy_point(point Geometry, trans text) RETURNS Geometry AS $$
DECLARE
	ucase text;
BEGIN
	ucase := upper(trans);
	IF ucase = 'WGS84_TO_GCJ02' THEN
		return WGS84_To_GCJ02(point);
	ELSIF ucase = 'WGS84_TO_BD' THEN
		return WGS84_To_BD(point);
	ELSIF ucase = 'GCJ02_TO_BD' THEN
		return GCJ02_To_BD(point);		
	ELSIF ucase = 'GCJ02_TO_WGS84' THEN
		return GCJ02_TO_WGS84(point);
	ELSIF ucase = 'BD_TO_WGS84' THEN
		return BD_To_WGS84(point);
	ELSIF ucase = 'BD_TO_GCJ02' THEN
		return BD_To_GCJ02(point);
	ELSE
		RAISE EXCEPTION 'Not supported transformation: %', ucase ;
	END IF;
END;
$$ LANGUAGE plpgsql;

/*
cnxy_transform
	The main converter for 2D geometry.
	geom - geometry
	trans - transformation type (case INSENSITIVE). These types are: 
		'BD_To_GCJ02',
		'CGJ02_To_BD',
		'WGS84_To_BD',
		'BD_To_WGS84',
		'GCJ02_To_WGS84',
		'WGS84_To_GCJ02'	
*/
DROP FUNCTION if exists cnxy_transform(Geometry, text);
CREATE FUNCTION cnxy_transform(geom Geometry, trans text) RETURNS Geometry AS $$
DECLARE
	ucase text;	
	isMulti boolean;
BEGIN
	IF geom is NULL THEN
		RETURN NULL;
	END IF;
	isMulti := ST_IsCollection(geom);
	IF  isMulti=TRUE THEN
		RETURN _transformMulti(geom, trans);
	ELSE 
		RETURN _transformSingle(geom, trans);	
	END IF;
END;
$$ LANGUAGE plpgsql;

/************************private*****************************/
/*
_transformPoints
	a batch converter for Points as geometry[]
*/
DROP FUNCTION if exists _transformPoints(Geometry[], text);
CREATE FUNCTION _transformPoints(geoms Geometry[], trans text) RETURNS Geometry[] AS $$
DECLARE
	points Geometry[];	
	i int;
	n int;
BEGIN
	n = array_upper(geoms, 1); 
	FOR i IN 1..n LOOP		
		points[i] := cnxy_point(geoms[i], trans);		
	END LOOP;
	RETURN points;
END;
$$ LANGUAGE plpgsql;

/*
_transformMulti
	a multipart geom converter. 
	DO NOT USE IT WITH SINGLE PART GEOMETRY, THOUGH IT IS LIKELY TO WORK.
*/
DROP FUNCTION if exists _transformMulti(Geometry, text);
CREATE FUNCTION _transformMulti(geoms Geometry, trans text) RETURNS Geometry AS $$
DECLARE
	parts Geometry[];	
	i int;
	n int;
BEGIN	
	--split, transform then restore
	n = ST_NumGeometries(geoms); 
	FOR i IN 1..n LOOP
		parts[i] := ST_GeometryN(geoms, i);			
		--even a multipoint vith one point is a collection
		IF ST_IsCollection(parts[i]) = FALSE THEN --single		
			parts[i] = _transformSingle(parts[i], trans);
		ELSIF ST_IsCollection(parts[i]) = TRUE THEN --multi
			parts[i] = _transformMulti(parts[i], trans);
		ELSE
			RAISE EXCEPTION 'Not supported geometry: %', ST_AsText(parts[i]) ;
		END IF;
	END LOOP;
	RETURN ST_collect(parts);
END;
$$ LANGUAGE plpgsql;

/*
_transformSingle
	a single geom converter. 
*/
DROP FUNCTION if exists _transformSingle(Geometry, text);
CREATE FUNCTION _transformSingle(geom Geometry, trans text) RETURNS Geometry AS $$
DECLARE
	geomType text;
	points geometry[];
	line geometry;
	lines geometry[] DEFAULT NULL;
	n int;
	i int;
BEGIN
	IF geom is NULL THEN
		return null;
	END IF;
	geomType = lower(ST_GeometryType(geom));
	CASE geomType
		WHEN 'st_point' THEN
			RETURN cnxy_point(geom, trans);
		WHEN 'st_linestring' THEN			
			points := array(select (st_dumppoints(st_collect(geom))).geom);
			RETURN ST_makeLine(_transformPoints(points, trans));
		WHEN 'st_circularstring' THEN			
			points := array(select (st_dumppoints(st_collect(geom))).geom);
			RETURN ST_lineToCurve(ST_makeLine(_transformPoints(points, trans)));
		WHEN 'st_polygon' THEN
			/*
				A polygon have one exterior ring (line), and maybe some interior rings (lines).
				All of these rings should be processed then combined to get the converted polygon.			 
			*/
			line := ST_ExteriorRing(geom);		
			n :=  ST_NumInteriorRings(geom);			
			line := _transformSingle(line, trans);--st_circularstring
			IF n>0 THEN
				FOR i IN 1 .. n LOOP
					lines[i] := ST_InteriorRingN(geom, i);--st_circularstring
					lines[i] := _transformSingle(lines[i], trans);
				END LOOP;
			END IF;
			IF (n=0) OR (n is null) THEN
				RETURN ST_MakePolygon(line);
			ELSE--with interiors
				RETURN ST_MakePolygon(line, lines);
			END IF;
		ELSE
			RAISE EXCEPTION 'Not supported geometry type: %', geomType;     
	END CASE;
END;
$$ LANGUAGE plpgsql;

/**********************const******************************/
/*
_cnxy_radius
	Radius of the earth.  	
*/
DROP FUNCTION if exists _cnxy_radius();
CREATE FUNCTION _cnxy_radius() RETURNS DECIMAL AS $$
DECLARE	
BEGIN
	RETURN 6371229;
END;
$$ LANGUAGE plpgsql;

/*
_cnxy_a
	Radius of the earth.  	
*/
DROP FUNCTION if exists _cnxy_a();
CREATE FUNCTION _cnxy_a() RETURNS DECIMAL AS $$
DECLARE	
BEGIN
	RETURN 6378245.0;
END;
$$ LANGUAGE plpgsql;

/*
_cnxy_ee
	Radius of the earth.  	
*/
DROP FUNCTION if exists _cnxy_ee();
CREATE FUNCTION _cnxy_ee() RETURNS DECIMAL AS $$
DECLARE	
BEGIN
	RETURN 0.00669342162296594323;
END;
$$ LANGUAGE plpgsql;

/*
_cnxy_x_pi
	Radius of the earth.  	
*/
DROP FUNCTION if exists _cnxy_x_pi();
CREATE FUNCTION _cnxy_x_pi() RETURNS DECIMAL AS $$
DECLARE	
BEGIN
	RETURN PI() * 3000.0 / 180.0;
END;
$$ LANGUAGE plpgsql;