select distinct flag from climdb_raw
select * from climdb_raw where flag='T'
select * from climdb_raw where value='9999'
select distinct site_code from climdb_raw where flag='T'
select site_code,count(flag) from climdb_raw where flag='T' group by site_code
select * from climdb_raw where flag='T' and site_code='HFR'

--selects the distinct flags and a count of use for LTER sites (module 1) and only climate variables (descriptor_category_id<20 are hydro)
select cr.flag, count(*) from climdb_raw cr,research_site_module rsm, climdb_variables cv  
 where cr.res_site_id=rsm.res_site_id and rsm.res_module_id=1 and cr.variable=cv.variable and cv.descriptor_category_id<20
 group by cr.flag

--selects the distinct flags and a count of use for all sites, but only climate variables (descriptor_category_id<20 are hydro)
select cr.flag, count(*) from climdb_raw cr, climdb_variables cv  
 where cr.variable=cv.variable and cv.descriptor_category_id<20
 group by cr.flag

--selects the distinct flags and a count of use for all sites and variables
select cr.flag, count(*) from climdb_raw cr group by cr.flag

--selects the count of the specified flag by site for LTER sites (module 1) and only climate variables (descriptor_category_id<20 are hydro)
select cr.site_code,count(cr.flag) as 'T' from climdb_raw cr, research_site_module rsm, climdb_variables cv 
 where cr.res_site_id=rsm.res_site_id and rsm.res_module_id=1 and cr.variable=cv.variable and cr.flag='T' and cv.descriptor_category_id<20
 group by cr.site_code
 order by site_code

select * from research_module
select * from climdb_variables

--reports the total number of flagged values by station, variable for LTER sites (module 1); but the research_site_module part is incorrect
select cr.site_code,cr.station,cr.variable,count(cr.flag) as 'M', datediff(day,min(sampledate),max(sampledate))+1 as totaldays 
 from climdb_raw cr, research_site_module rsm 
 where cr.res_site_id=rsm.res_site_id and rsm.res_module_id=1 and cr.flag='M' 
 group by cr.site_code,cr.station,cr.variable
 order by cr.site_code,cr.station

select cr.site_code,cr.station,cr.variable,count(*) as 'Count', datediff(day,min(sampledate),max(sampledate))+1 as totaldays 
 from climdb_raw cr, research_site_module rsm 
 where cr.res_site_id=rsm.res_site_id and rsm.res_module_id=1
 group by cr.site_code,cr.station,cr.variable
 order by cr.site_code,cr.station

--reports the total number of values by station, variable and the total number of days to get at how many days are missing (not harvested)
select cr.site_code,cr.station,cr.variable,count(*) as 'Count', datediff(day,min(sampledate),max(sampledate))+1 as totaldays 
 from climdb_raw cr
 group by cr.site_code,cr.station,cr.variable
 order by cr.site_code,cr.station

select variable,count(*) from climdb_raw where (variable='PREC' or variable='SNOW') group by variable

select * from climdb_raw where station='H15MET' and variable='TMEA' and year(sampledate)=2002 and month(sampledate)=1
select * from climdb_raw where site_code='AND' and month(sampledate)=1 and flag='Q'
select * from climdb_raw where station='BWI' and variable='RH'

select * from climdb_agg where year=1997 and month=99 and site_code='FCE' and station='ROYALPALMR'
select * from climdb_agg where year=1997 and site_code='FCE' and station='ROYALPALMR'

