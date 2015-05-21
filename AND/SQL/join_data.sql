where variable='PREC' and station = 'PRIMET'

select a.site_code, a.station,a.sampledate,a.value as prec,a.flag as prec_flag,b.value as tmean,b.flag as tmean_flag,
 c.value as tmax,c.flag as tmax_flag
 from climdb_raw a
  FULL OUTER JOIN climdb_raw b
  ON a.station=b.station and a.sampledate=b.sampledate
   FULL OUTER JOIN climdb_raw c
  ON a.station=c.station and a.sampledate=c.sampledate
 where a.site_code='AND' and a.station='PRIMET' and a.variable='PREC' and b.variable='TMEA' and c.variable='TMAX' 
 and a.sampledate>='19400101' and b.sampledate>='19400101' and c.sampledate>='19400101'
 and a.sampledate <= '20011104' and b.sampledate <= '20011104' and b.sampledate <= '20011104'
  order by a.sampledate

SELECT * FROM climdb_raw WHERE station = 'PRIMET' and variable = 'PREC'
	sampledate >= '19400101' and
	site_code = 'AND' and
	station = 'PRIMET' and
	variable = 'PREC'


CREATE table #temp_1 (sampledate varchar(8) not NULL, value varchar(10) NULL, flag varchar(1) NULL)
insert into #temp_1 (sampledate, value, flag)
SELECT sampledate, value, flag
FROM climdb_raw
WHERE sampledate >= '19790101' and
	sampledate <= '20011104' and
	site_code = 'AND' and
	station = 'PRIMET' and
	variable = 'PREC'

CREATE table #temp_2 (sampledate varchar(8) not NULL, value varchar(10) NULL, flag varchar(1) NULL)
insert into #temp_2 (sampledate, value, flag)
SELECT sampledate, value, flag
FROM climdb_raw
WHERE sampledate >= '19790101' and
	sampledate <= '20011104' and
	site_code = 'AND' and
	station = 'PRIMET' and
	variable = 'TMAX'

CREATE table #temp_3 (sampledate varchar(8) not NULL, value varchar(10) NULL, flag varchar(1) NULL)
insert into #temp_3 (sampledate, value, flag)
SELECT sampledate, value, flag
FROM climdb_raw
WHERE sampledate >= '19790101' and
	sampledate <= '20011104' and
	site_code = 'AND' and
	station = 'PRIMET' and
	variable = 'TMIN'

SELECT * FROM #temp_1,#temp_2,#temp_3 WHERE #temp_1.sampledate = #temp_2.sampledate and
#temp_2.sampledate = #temp_3.sampledate

select a.sampledate,a.value as prec,a.flag as prec_flag,b.value as tmean,b.flag as tmean_flag,
 c.value as tmax,c.flag as tmax_flag
 from #temp_1 a
  FULL OUTER JOIN #temp_2 b
  ON a.sampledate=b.sampledate
   FULL OUTER JOIN #temp_3 c
  ON a.sampledate=c.sampledate
 where a.variable='PREC' and b.variable='TMAX' and c.variable='TMIN' 
 and a.sampledate>='19790101' and b.sampledate>='19790101' and c.sampledate>='19790101'
 and a.sampledate <= '20011104' and b.sampledate <= '20011104' and b.sampledate <= '20011104'
  order by a.sampledate 
;
CREATE TEMPORARY TABLE temp_2
SELECT sampledate, value, flag
FROM climdb_raw
WHERE sampledate <= '19640131' and
	sampledate >= '19400401' and
	site_code = 'AND' and
	station = 'PRIMET' and
	variable = 'TMAX'
;
CREATE TEMPORARY TABLE temp_3
SELECT sampledate, value, flag
FROM climdb_raw
WHERE sampledate <= '19640131' and
	sampledate >= '19400401' and
	site_code = 'AND' and
	station = 'PRIMET' and
	variable = 'TMEA'
;

SELECT * INTO OUTFILE 'C:\\foo' FIELDS TERMINATED BY ',' FROM
temp_1,temp_2,temp_3 WHERE temp_1.sampledate = temp_2.sampledate and
temp_2.sampledate = temp_3.sampledate
;
