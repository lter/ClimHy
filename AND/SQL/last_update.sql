--A two step process to aggregate the latest update date and update another table.

select site_code,station,variable,max(last_update) as date into junk from climdb_raw 
  group by site_code,station,variable 

select * from junk

update climdb_site_variable_dates 
  set last_update=cr.date 
  from climdb_site_variable_dates vd, junk cr
  where vd.site_code=cr.site_code and vd.station=cr.station and vd.variable=cr.variable