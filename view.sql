CREATE VIEW ViewForViz AS 
WITH 
MagTypeHelper AS
(
	SELECT m.id_type AS id_type, m.name AS name
    FROM (
		SELECT m.id_type AS id_type, m.name AS name, ROW_NUMBER() OVER(PARTITION BY m.id_type ORDER BY m.name) AS rankcol
		FROM MagnitudeTypes m
	) m
    WHERE m.rankcol = 1
),
MagIdToName AS
(
	SELECT t1.id AS id, t2.name AS name
    FROM MagnitudeTypes t1 JOIN MagTypeHelper t2 ON t1.id_type = t2.id_type
),
AgencyAndScore AS
(
	SELECT a.id, a.abbreviation as abb, COUNT(e.id) as score
    FROM Agence a LEFT JOIN Events e ON a.id = e.network
    GROUP BY a.id, a.abbreviation
),
EventHelper AS
(
	SELECT im.global_id AS id, 
		   e.longitude AS longitude, e.latitude as latitude, e.depth as depth,
           e.magnitude AS magnitude, m.name AS magnitude_type,
           e.gap AS gap, e.rms AS rms, e.dmin AS dmin, e.mmi AS mmi, e.cdi AS cdi,
           e.n_stations AS n_stations, e.felt AS felt, e.significance AS significance,
           e.tsunami AS marine,
           al.name AS alert, s.name as status,
           e.time AS time, e.updated AS updated, e.timezone_offset as timezone_offset,
           aas.name AS network, 
			ROW_NUMBER() OVER(PARTITION BY im.global_id ORDER BY ass.SCORE DESC) as rankcol
    FROM Events e
		JOIN IdMap im ON e.local_id = im.id
        JOIN AgencyAndScore aas ON e.network = aas.id
        JOIN Status s ON e.status = s.id
        JOIN Alerts al ON e.alert = al.id
        JOIN MagIdToName m ON e.magnitude_type = m.id
)
SELECT e.id AS id, 
		e.longitude AS longitude, e.latitude as latitude, e.depth as depth,
		e.magnitude AS magnitude, e.magnitude_type AS magnitude_type,
		e.gap AS gap, e.rms AS rms, e.dmin AS dmin, e.mmi AS mmi, e.cdi AS cdi,
		e.n_stations AS n_stations, e.felt AS felt, e.significance AS significance,
		e.marine AS marine,
		e.alert AS alert, e.status as status,
		e.time AS time, e.updated AS updated, e.timezone_offset as timezone_offset,
		e.network AS network
FROM EventHelper e
WHERE e.rankcol = 1;