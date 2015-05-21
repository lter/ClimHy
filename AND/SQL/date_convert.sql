select convert(varchar(8),sampledate,112) as sampledate from harvest_raw where site_code='AND' order by sampledate
select convert(varchar(24),sampledate,113) as sampledate from harvest_raw where site_code='AND' order by sampledate
select convert(varchar(5),sampledate,14) as sampletime from harvest_raw where site_code='AND' order by sampledate
select convert(varchar(5),sampledate,8) as sampletime from harvest_raw where site_code='AND' order by sampledate
select convert(varchar(8),sampledate,112) as sampledate,
   ' The time is ' ,
   convert(varchar(2),datename(hh,sampledate))+convert(varchar(2),datename(mi,sampledate)) as time 
   from harvest_raw where site_code='AND'
select convert(varchar(8),sampledate,112) as sampledate,
   ' The time is ' ,
   datename(hh,sampledate)+datename(mi,sampledate) as time 
   from harvest_raw where site_code='AND'
select convert(varchar(8),sampledate,112) as sampledate,
   ' The time is ' ,
   convert(varchar(2),datepart(hh,sampledate))+convert(varchar(2),datepart(mi,sampledate)) as time 
   from harvest_raw where site_code='AND'