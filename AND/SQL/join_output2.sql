
drop table #temp1
drop table #temp2
drop table #temp3
drop table #temp4

/* Join multiple variables together for one site, station, and range of dates */
select 'AND' as site_code, 'PRIMET' as station,sampledate
 into #temp1
 from masterdate
 where sampledate>='19400101' and sampledate <= '20011104' 
select site_code,station,sampledate,value as prec,flag as prec_flag
 into #temp2
 from climdb_raw
 where site_code='AND' and station='PRIMET' 
 and variable='PREC' and sampledate>='19400101' and sampledate <= '20011104'
select site_code,station,sampledate,value as tmean,flag as tmean_flag
 into #temp3
 from climdb_raw
 where site_code='AND' and station='PRIMET'
 and variable='TMEA' and sampledate>='19400101' and sampledate <= '20011104'
select site_code,station,sampledate,value as tmax,flag as tmax_flag
 into #temp4
 from climdb_raw
 where site_code='AND' and station='PRIMET' 
 and variable='TMAX' and sampledate>='19400101' and sampledate <= '20011104'

select a.site_code, a.station,a.sampledate,b.prec,b.prec_flag,c.tmean,c.tmean_flag,
 d.tmax,d.tmax_flag
 from #temp1 a
  FULL OUTER JOIN #temp2 b
  ON a.site_code=b.site_code and a.station=b.station and a.sampledate=b.sampledate
   FULL OUTER JOIN #temp3 c
  ON a.site_code=c.site_code and a.station=c.station and a.sampledate=c.sampledate
   FULL OUTER JOIN #temp4 d
  ON a.site_code=d.site_code and a.station=d.station and a.sampledate=d.sampledate
  order by a.sampledate


