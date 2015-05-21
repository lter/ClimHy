--1. original query: selects the personnel and their roles by site for research module 1 (climdb)
--note...if middle_name is null, then fullname defaults to null (only on Rocky not on Spiraea).
--***This is multiple selecting personnel****
select distinct spr.site_id,spr.personnel_id,spr.res_module_id,'fullname'=rtrim(p.first_name)+' '+rtrim(p.middle_name)+' '+rtrim(p.last_name),
pr.personnel_role_desc,p.email1
from site_personnel_role spr, personnel p, personnel_role pr,
site s,research_site rs, research_site_module rsm
where p.personnel_id=spr.personnel_id and spr.personnel_role_id=pr.Personnel_role_id
and spr.site_id=s.site_id and s.site_id=rs.site_id and rs.res_site_id=rsm.res_site_id
and spr.res_module_id=1 and rs.res_site_parent_id is null
order by spr.site_id,pr.personnel_role_desc desc

--1. new query (People): selects the personnel and their roles by site 
--note...if middle_name is null, then fullname defaults to null (only on Rocky not on Spiraea).
--for research module 1 (climdb)
select distinct rs.res_site_code,rs.res_site_name,'fullname'=rtrim(p.first_name)+' '+rtrim(p.middle_name)+' '+rtrim(p.last_name),
pr.personnel_role_desc,p.email1
from site_personnel_role spr, personnel p, personnel_role pr,
site s,research_site rs, research_site_module rsm
where p.personnel_id=spr.personnel_id and spr.personnel_role_id=pr.Personnel_role_id
and spr.site_id=s.site_id and s.site_id=rs.site_id and rs.res_site_id=rsm.res_site_id
and spr.res_module_id=1 and rs.res_site_parent_id is null
order by rs.res_site_code,pr.personnel_role_desc desc

--for research module 2 (hydrodb)
select distinct rs.res_site_code,rs.res_site_name,'fullname'=rtrim(p.first_name)+' '+rtrim(p.middle_name)+' '+rtrim(p.last_name),
pr.personnel_role_desc,p.email1
from site_personnel_role spr, personnel p, personnel_role pr,
site s,research_site rs, research_site_module rsm
where p.personnel_id=spr.personnel_id and spr.personnel_role_id=pr.Personnel_role_id
and spr.site_id=s.site_id and s.site_id=rs.site_id and rs.res_site_id=rsm.res_site_id
and spr.res_module_id=2 and rs.res_site_parent_id is null
order by rs.res_site_code,pr.personnel_role_desc desc


--2. original/new query (Sites): selects participating sites from hydrodb with oldest and newest dates of any variable from any station 
--and most recent update where discharge data is available.
--for research module 1 (climdb)
select vd.site_code, s.site_name,count(res_site_id) as gsstns,convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd, site s
  where res_site_id in (select distinct vd.res_site_id from climdb_site_variable_dates vd,research_site rs,research_site_sitetype st
  where vd.res_site_id=rs.res_site_id and rs.res_site_id=st.res_site_id and st.res_sitetype_id=3)
  and vd.variable in (select v.variable from climdb_variables v, research_module_descriptor m 
    where v.descriptor_category_id=m.descriptor_category_id and m.res_module_id=2 and variable='DSCH') 
  and vd.site_code in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=2 and rs.res_site_parent_id is null)
  and vd.station in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=2) 
  and vd.site_code=s.site_code
    group by vd.site_code,s.site_name order by vd.site_code


--for research module 2 (hydrodb)
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

--3. original query: selects participating site by stations for all LTER hydro and climate stations 
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


--3. new query (Stations): selects participating site by stations for all LTER hydro and climate stations 
--with oldest and newest dates of any variable 
--and most recent update
--for research module 1 (climdb)
select vd.site_code,rst.res_sitetype_desc,rs.res_site_code,rs.res_site_name,convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd, research_site rs, research_site_sitetype st,research_site_type rst
  where vd.variable in (select v.variable from climdb_variables v, research_module_descriptor m 
    where v.descriptor_category_id=m.descriptor_category_id and (m.res_module_id=1 or m.res_module_id=2)) 
  and vd.res_site_id in (select rs.res_site_id from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and (rsm.res_module_id=1 or rsm.res_module_id=2)) 
  and vd.site_id in (select rs.site_id from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1 and rs.res_site_parent_id is null)
  and vd.res_site_id=rs.res_site_id and vd.res_site_id=st.res_site_id and rst.res_sitetype_id=st.res_sitetype_id
  group by vd.site_code,rst.res_sitetype_desc,rs.res_site_code,rs.res_site_name,st.res_sitetype_id 
  order by vd.site_code,st.res_sitetype_id desc,rs.res_site_code

--for research module 2 (hydrodb)
select vd.site_code,rst.res_sitetype_desc,rs.res_site_code,rs.res_site_name,convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd, research_site rs, research_site_sitetype st,research_site_type rst
  where vd.variable in (select v.variable from climdb_variables v, research_module_descriptor m 
    where v.descriptor_category_id=m.descriptor_category_id and (m.res_module_id=1 or m.res_module_id=2)) 
  and vd.res_site_id in (select rs.res_site_id from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and (rsm.res_module_id=1 or rsm.res_module_id=2)) 
  and vd.site_id in (select rs.site_id from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=2 and rs.res_site_parent_id is null)
  and vd.res_site_id=rs.res_site_id and rs.res_site_id=st.res_site_id and rst.res_sitetype_id=st.res_sitetype_id
  group by vd.site_code,rst.res_sitetype_desc,rs.res_site_code,rs.res_site_name,st.res_sitetype_id 
  order by vd.site_code,st.res_sitetype_id,rs.res_site_code
  
--4. original query (Variables): selects variable date ranges for each variable for each station.
select vd.site_code, vd.station,vd.variable,
  convert(varchar,min(vd.first_seen),110) as begin_date, convert(varchar,max(vd.most_recent),110) as end_date, 
  convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd
  where vd.variable in (select v.variable from climdb_variables v, research_module_descriptor m 
    where v.descriptor_category_id=m.descriptor_category_id and m.res_module_id=1)
  and vd.station in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1) 
  and vd.site_code in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1 and rs.res_site_parent_id is null) 
  group by vd.site_code,vd.station,vd.variable
  order by vd.site_code,vd.station,vd.variable

--4. working query (Variables): selects variable date ranges for each variable for each station.
--for research module 1 (climdb)
select vd.site_code, vd.station,v.variable_name,
  convert(varchar,min(vd.first_seen),110) as begin_date, convert(varchar,max(vd.most_recent),110) as end_date, 
  convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd,climdb_variables v
  where v.variable_name in (select v.variable_name from climdb_variables v
    where v.variable=vd.variable)
  and vd.station in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1) 
  and vd.site_code in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1 and rs.res_site_parent_id is null) 
  group by vd.site_code,vd.station,v.variable_name
  order by vd.site_code,vd.station,v.variable_name

--for research module 2 (hydrodb)
select vd.site_code, vd.station,v.variable_name,
  convert(varchar,min(vd.first_seen),110) as begin_date, convert(varchar,max(vd.most_recent),110) as end_date, 
  convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd,climdb_variables v
  where v.variable_name in (select v.variable_name from climdb_variables v
    where v.variable=vd.variable)
  and vd.station in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1) 
  and vd.site_code in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=2 and rs.res_site_parent_id is null) 
  group by vd.site_code,vd.station,v.variable_name
  order by vd.site_code,vd.station,v.variable_name
