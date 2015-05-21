SELECT site_code, station, year, month, v.variable, value, num_e, v.decimals
INTO temp0
FROM climdb_agg a, climdb_variables v
WHERE site_code='ARC' and
	 station='TLKMAIN' and
	 a.variable='TMAX' and
	 year>='1990' and
	 year<='1991' and
	 aggregate_type = 'MEAN' AND 
	 month != 99 AND v.variable = a.variable 

SELECT min(year) as mindate, max(year) as maxdate into temp_union FROM temp0

SELECT min(year) as mindate, max(year) as maxdate FROM temp0

SELECT 'ARC' as site_code, 'TLKMAIN' as station, DATEPART(year,sampledate) as year, DATEPART(month,sampledate) as month 
into temp_dates
FROM masterdate
WHERE DATEPART(year,sampledate)>=(SELECT min(mindate) FROM temp_union)
	AND DATEPART(year,sampledate)<=(SELECT max(maxdate) FROM temp_union)

SELECT DISTINCT temp_dates.year, temp_dates.month, temp_dates.site_code, temp_dates.station,temp0.value, temp0.num_e, temp0.decimals
FROM temp_dates
FULL OUTER JOIN temp0
ON temp_dates.site_code= temp0.site_code AND temp_dates.station= temp0.station AND temp_dates.year= temp0.year AND temp_dates.month = temp0.month
ORDER BY temp_dates.year, temp_dates.month
