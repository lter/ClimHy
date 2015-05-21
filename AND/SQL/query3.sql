  DROP TABLE #temp_union
  DROP TABLE #temp_dates
  DROP TABLE #temp0
  DROP TABLE #temp1
  DROP TABLE #temp2

  SELECT site_code, station, sampledate, value, flag
INTO #temp0
FROM climdb_raw
WHERE site_code='AND' and
	 station='PRIMET' and
	 variable='TMEA' and
	 sampledate>='19700401' and
	 sampledate<='19840131'

  SELECT site_code, station, sampledate, value, flag
INTO #temp1
FROM climdb_raw
WHERE site_code='AND' and
	 station='PRIMET' and
	 variable='PREC' and
	 sampledate>='19700401' and
	 sampledate<='19840131'

  SELECT site_code, station, sampledate, value, flag
INTO #temp2
FROM climdb_raw
WHERE site_code='AND' and
	 station='PRIMET' and
	 variable='TMAX' and
	 sampledate>='19700401' and
	 sampledate<='19840131'

  SELECT min(sampledate) as mindate, max(sampledate) as maxdate into #temp_union from #temp0
UNION SELECT min(sampledate) as mindate, max(sampledate) as maxdate from #temp1
UNION SELECT min(sampledate) as mindate, max(sampledate) as maxdate from #temp2

  SELECT 'AND' as site_code, 'PRIMET' as station, sampledate into #temp_dates
FROM masterdate
WHERE sampledate>=(select min(mindate) from #temp_union)
	and sampledate<=(select max(maxdate) from #temp_union)

  SELECT #temp_dates.site_code, #temp_dates.station, #temp_dates.sampledate,#temp0.value, #temp0.flag,#temp1.value, #temp1.flag,#temp2.value, #temp2.flag
FROM #temp_dates
FULL OUTER JOIN #temp0
ON #temp_dates.site_code= #temp0.site_code and #temp_dates.station= #temp0.station and #temp_dates.sampledate= #temp0.sampledate
FULL OUTER JOIN #temp1
ON #temp_dates.site_code= #temp1.site_code and #temp_dates.station= #temp1.station and #temp_dates.sampledate= #temp1.sampledate
FULL OUTER JOIN #temp2
ON #temp_dates.site_code= #temp2.site_code and #temp_dates.station= #temp2.station and #temp_dates.sampledate= #temp2.sampledate
ORDER BY #temp_dates.sampledate
