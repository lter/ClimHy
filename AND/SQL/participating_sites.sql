--selects participating sites from climdb with oldest and newest dates of any variable from any station 
--and most recent update
select vd.site_code, s.site_name,count(distinct station) as no_stns,convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd, site s
  where vd.variable in (select v.variable from climdb_variables v, research_module_descriptor m 
    where v.descriptor_category_id=m.descriptor_category_id and m.res_module_id=1) 
  and vd.site_code in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1 and rs.res_site_parent_id is null)
  and vd.station in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1) 
  and vd.site_code=s.site_code
    group by vd.site_code,s.site_name order by vd.site_code 

--selects participating sites for LTER/hydrodb with oldest and newest dates of any variable from any station 
--and most recent update
select vd.site_code, s.site_name,count(distinct vd.station) as no_stns,convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd, site s
  where vd.variable in (select v.variable from climdb_variables v, research_module_descriptor m 
    where v.descriptor_category_id=m.descriptor_category_id and m.res_module_id=2) 
  and vd.site_id in (select rs.site_id from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=2 and rs.res_site_parent_id is null)
  and vd.station in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=2) 
  and vd.site_code=s.site_code
    group by vd.site_code,s.site_name order by vd.site_code 


--selects participating site by stations from climdb with oldest and newest dates of any variable 
--and most recent update
select vd.site_code, s.site_name,vd.station, rs.res_site_name,convert(character(12),min(vd.first_seen),110) as begin_date,
  convert(character(12),max(vd.most_recent),110) as end_date, convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd, research_site rs, site s
  where vd.variable in (select v.variable from climdb_variables v, research_module_descriptor m 
    where v.descriptor_category_id=m.descriptor_category_id and m.res_module_id=1) 
  and vd.station in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1) 
  and vd.site_code in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1 and rs.res_site_parent_id is null)
  and vd.site_id=rs.site_id and vd.station=rs.res_site_code and rs.site_id=s.site_id
  group by vd.site_code,s.site_name,vd.station,rs.res_site_name order by vd.site_code

--selects participating site by stations from climdb with recent Discharge data 
--with oldest and newest dates of any variable 
--and most recent update
select vd.site_code,vd.station,convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd, research_site rs
  where vd.variable in (select v.variable from climdb_variables v, research_module_descriptor m 
    where v.descriptor_category_id=m.descriptor_category_id and m.res_module_id=2) 
  and vd.res_site_id in (select rs.res_site_id from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=2) 
  and vd.site_id in (select rs.site_id from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1 and rs.res_site_parent_id is null)
  and vd.res_site_id=rs.res_site_id and vd.variable='DSCH'
  group by vd.site_code,vd.station order by vd.site_code,vd.station 

--selects participating site by stations for all LTER hydro and climate stations 
--with oldest and newest dates of any variable 
--and most recent update
select vd.site_code,vd.station,convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd, research_site rs
  where vd.variable in (select v.variable from climdb_variables v, research_module_descriptor m 
    where v.descriptor_category_id=m.descriptor_category_id and (m.res_module_id=1 or m.res_module_id=2)) 
  and vd.res_site_id in (select rs.res_site_id from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and (rsm.res_module_id=1 or rsm.res_module_id=2)) 
  and vd.site_id in (select rs.site_id from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1 and rs.res_site_parent_id is null)
  and vd.res_site_id=rs.res_site_id 
  group by vd.site_code,vd.station order by vd.site_code,vd.station


select convert(character(10),first_seen,110) from climdb_site_variable_dates
select * from site
select * from research_site where res_sitetype_id=4
select * from research_site_module where res_site_id>173 and res_site_id<215
update research_site_module
select * from climdb_variables
select * from climdb_raw where site_code='PIE'

--selects participating sites from hydrodb with oldest and newest dates of any variable from any station 
--and most recent update where discharge data is available.
select vd.site_code, s.site_name,count(distinct station) as no_stns,convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd, site s
  where vd.variable in (select v.variable from climdb_variables v, research_module_descriptor m 
    where v.descriptor_category_id=m.descriptor_category_id and m.res_module_id=2 and variable='DSCH') 
  and vd.site_code in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=2 and rs.res_site_parent_id is null)
  and vd.station in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=2) 
  and vd.site_code=s.site_code
    group by vd.site_code,s.site_name order by vd.site_code
 
--selects participating site by stations from hydrodb with oldest and newest dates of any variable 
--and most recent update where discharge data is available.
select vd.site_code, y.site_name, vd.station, s.description,convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd, stations s,site y
  where vd.variable in (select v.variable from climdb_variables v, research_module_descriptor m 
    where v.descriptor_category_id=m.descriptor_category_id and m.res_module_id=2  and variable='DSCH') 
  and vd.station in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=2) 
  and vd.site_code in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=2 and rs.res_site_parent_id is null)
  and vd.site_code=s.site_code and vd.station=s.station and s.site_code=y.site_code
  group by vd.site_code,y.site_name,vd.station,s.description order by vd.site_code

____________________________________________________________
--Play below this line...

--selects participating site by stations for all LTER hydro and climate stations 
--with oldest and newest dates of any variable 
--and most recent update
select vd.site_code,vd.station,convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd, research_site rs
  where vd.variable in (select v.variable from climdb_variables v, research_module_descriptor m 
    where v.descriptor_category_id=m.descriptor_category_id and (m.res_module_id=1 or m.res_module_id=2)) 
  and vd.res_site_id in (select rs.res_site_id from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and (rsm.res_module_id=1 or rsm.res_module_id=2)) 
  and vd.site_id in (select rs.site_id from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1 and rs.res_site_parent_id is null)
  and vd.res_site_id=rs.res_site_id 
  group by vd.site_code,vd.station order by vd.last_update desc vd.site_code,vd.station

select * from climdb_site_variable_dates order by site_code,station vd
where vd.res_site_id in (select rs.res_site_id from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1) 

select rs.site_id,rs.res_site_code from research_site rs

select * from research_site_module where res_site_id=17
insert into research_site_module (res_site_id,res_module_id) values(1,2)
select * from research_site