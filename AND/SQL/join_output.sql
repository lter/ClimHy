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

select b.site_code,b.station,b.sampledate,b.value as tmean,b.flag as tmean_flag
 from climdb_raw b
 where b.site_code='AND' and b.station='PRIMET'
 and b.variable='TMEA' and b.sampledate>='19400101' and b.sampledate <= '20011104'


drop table #temp1
drop table #temp2
drop table #temp3
select a.site_code,a.station,a.sampledate,a.value as prec,a.flag as prec_flag
 into #temp1
 from climdb_raw a
 where a.site_code='AND' and a.station='PRIMET' 
 and a.variable='PREC' and a.sampledate>='19400101' and a.sampledate <= '20011104'
select b.site_code,b.station,b.sampledate,b.value as tmean,b.flag as tmean_flag
 into #temp2
 from climdb_raw b
 where b.site_code='AND' and b.station='PRIMET'
 and b.variable='TMEA' and b.sampledate>='19400101' and b.sampledate <= '20011104'
select c.site_code,c.station,c.sampledate,c.value as tmax,c.flag as tmax_flag
 into #temp3
 from climdb_raw c
 where c.site_code='AND' and c.station='PRIMET' 
 and c.variable='TMAX' and c.sampledate>='19400101' and c.sampledate <= '20011104'

select b.site_code, b.station,b.sampledate,a.prec,a.prec_flag,b.tmean,b.tmean_flag,
 c.tmax,c.tmax_flag
 from #temp1 a
  FULL OUTER JOIN #temp2 b
  ON a.station=b.station and a.sampledate=b.sampledate
   FULL OUTER JOIN #temp3 c
  ON b.station=c.station and b.sampledate=c.sampledate
  order by a.sampledate


