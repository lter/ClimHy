  DROP TABLE #temp_union
  DROP TABLE #temp_dates
  DROP TABLE #temp0

  SELECT site_code, station, sampledate, value, flag
INTO #temp0
FROM climdb_raw
WHERE site_code='AND' and
	 station='PRIMET' and
	 variable='TMEA' and
	 sampledate>='19800401' and
	 sampledate<='19840131'

  SELECT min(sampledate) as mindate, max(sampledate) as maxdate into #temp_union from #temp0

  SELECT 'AND' as site_code, 'PRIMET' as station, sampledate into #temp_dates
FROM masterdate
WHERE sampledate>=(select min(mindate) from #temp_union)
	and sampledate<=(select max(maxdate) from #temp_union)

  SELECT #temp_dates.site_code, #temp_dates.station, #temp_dates.sampledate,#temp0.value, #temp0.flag
FROM #temp_dates
FULL OUTER JOIN #temp0
ON #temp_dates.site_code= #temp0.site_code and #temp_dates.station= #temp0.station and #temp_dates.sampledate= #temp0.sampledate
ORDER BY #temp_dates.sampledate