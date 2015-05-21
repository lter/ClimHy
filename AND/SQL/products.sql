--1. People: selects the personnel and their roles by site 
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
and spr.site_id=s.site_id and (s.site_id=rs.site_id and rs.res_site_parent_id is null) 
and rs.res_site_id=rsm.res_site_id and spr.res_module_id=2 
order by rs.res_site_code,pr.personnel_role_desc desc

--SQL_CMD #504 (original)
SELECT DISTINCT rs.res_site_code, 
 	rs.res_site_name, 
	'fullname'=
		rtrim(p.first_name)+' '+rtrim(p.middle_name)+' '+rtrim(p.last_name),
	pr.personnel_role_desc, 
 	p.email1, 
	s.site_url
FROM site_personnel_role spr, 
	personnel p, 
	personnel_role pr,
	site s,
	research_site rs, 
	research_site_module rsm
WHERE p.personnel_id=spr.personnel_id AND
	spr.personnel_role_id=pr.Personnel_role_id AND 
	spr.site_id=s.site_id AND 
	s.site_id=rs.site_id AND 
	rs.res_site_id=rsm.res_site_id AND 
	spr.res_module_id=2 AND 
	rs.res_site_parent_id is null AND
	spr.personnel_role_id!=6
ORDER BY rs.res_site_code, pr.personnel_role_desc desc

--SQL_CMD #504 (new to use URL from metadata)
SELECT DISTINCT rs.res_site_code, 
 	rs.res_site_name, 
	'fullname'=
		rtrim(p.first_name)+' '+rtrim(p.middle_name)+' '+rtrim(p.last_name),
	pr.personnel_role_desc, 
 	p.email1, 
	rsd.descriptor_value
FROM site_personnel_role spr, 
	personnel p, 
	personnel_role pr,
	site s,
	research_site rs, 
	research_site_descriptor rsd,
	research_site_module rsm
WHERE p.personnel_id=spr.personnel_id AND
	spr.personnel_role_id=pr.Personnel_role_id AND 
	spr.site_id=s.site_id AND 
	s.site_id=rs.site_id AND 
	rs.res_site_id=rsm.res_site_id AND 
	rs.res_site_id=rsd.res_site_id AND
	rsd.descriptor_type_id=233 AND
	spr.res_module_id=2 AND 
	rs.res_site_parent_id is null AND
	spr.personnel_role_id!=6
ORDER BY rs.res_site_code, pr.personnel_role_desc desc

--To get site URLs
SELECT  rs.res_site_code, 
 	rs.res_site_name, 
 	s.site_url, 
	rsd.descriptor_value
FROM 	site s,
	research_site rs, 
	research_site_descriptor rsd,
	research_site_module rsm
WHERE 	s.site_id=rs.site_id AND 
	rs.res_site_id=rsm.res_site_id AND 
	rs.res_site_id=rsd.res_site_id AND
	rsd.descriptor_type_id=233 AND
	rsm.res_module_id=2 AND 
	rs.res_site_parent_id is null 
ORDER BY rs.res_site_code


--2. Sites: selects contributing sites with oldest and newest dates of any variable from any station and most recent update.

--for all sites (no research module)
--creating site names and dates temp table (table 1)
drop table #all_sites
select vd.site_code, s.site_name,
  convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, 
  convert(character(12),max(vd.last_update),110) as last_update
  into #all_sites  
  from climdb_site_variable_dates vd, site s
  where vd.site_code=s.site_code
  group by vd.site_code,s.site_name order by vd.site_code
select * from #all_sites

--count met stns (table 2)
drop table #metstn
select vd.site_code, count(distinct(res_site_id)) as ms_stns into #metstn  
  from climdb_site_variable_dates vd
  where res_site_id in (select vd.res_site_id from climdb_site_variable_dates vd,research_site_sitetype st
     where vd.res_site_id=st.res_site_id and st.res_sitetype_id=4)
  group by vd.site_code order by vd.site_code
select * from #metstn

--count gs stns (table 3)
drop table #gsstn
select vd.site_code, count(distinct(res_site_id)) as gs_stns into #gsstn  
  from climdb_site_variable_dates vd
  where res_site_id in (select vd.res_site_id from climdb_site_variable_dates vd,research_site_sitetype st
    where vd.res_site_id=st.res_site_id and st.res_sitetype_id=3)
    group by vd.site_code order by vd.site_code
select * from #gsstn

--3-way join
select #all_sites.site_code,#all_sites.site_name,isnull(#metstn.ms_stns,0) as ms_stns,isnull(#gsstn.gs_stns,0) as gs_stns,
  #all_sites.first_seen,#all_sites.most_recent,#all_sites.last_update
  from #all_sites left join #metstn on #all_sites.site_code=#metstn.site_code
  left join #gsstn on #all_sites.site_code=#gsstn.site_code

------------------------------------------------------------------------------------------------------------
--for LTER or USFS sites (change res_module_id in first two queries)
--count met stns (table 1)
drop table #metstn
select vd.site_code, s.site_name,
  count(distinct(res_site_id)) as ms_stns,
  convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, 
  convert(character(12),max(vd.last_update),110) as last_update
  into #metstn  
  from climdb_site_variable_dates vd, site s
  where res_site_id in (select vd.res_site_id 
from climdb_site_variable_dates vd,research_site_sitetype st
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=4)
  and vd.site_code in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=3 and rs.res_site_parent_id is null)
  and vd.site_code=s.site_code
    group by vd.site_code,s.site_name order by vd.site_code

--count gs stns (table 2)
drop table #gsstn
select vd.site_code, s.site_name,count(distinct(res_site_id)) as gs_stns,convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, convert(character(12),max(vd.last_update),110) as last_update
  into #gsstn  
  from climdb_site_variable_dates vd, site s
  where res_site_id in (select vd.res_site_id from climdb_site_variable_dates vd,research_site_sitetype st
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=3)
  and vd.site_code in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=3 and rs.res_site_parent_id is null)
  and vd.site_code=s.site_code
    group by vd.site_code,s.site_name order by vd.site_code


--join for LTER (table 3 for module=1)
select ms.site_code, ms.site_name,isnull(ms.ms_stns,0) as ms_stns,isnull(gs.gs_stns,0) as gs_stns,
ms.first_seen,
ms.most_recent,
ms.last_update
  from #metstn ms left join #gsstn gs on gs.site_code=ms.site_code


--join for USFS (table 3 for module=2)
select gs.site_code, gs.site_name,gs.gs_stns as gs_stns,isnull(ms.ms_stns,0) as met_stns,
gs.first_seen,
gs.most_recent,
gs.last_update
  from #gsstn gs left join #metstn ms on gs.site_code=ms.site_code

select * from #gsstn
select * from #metstn
------------------------------------------------------------------------------------------------------------
--USGS (module 3)
select vd.site_code, s.site_name,
  count(distinct(res_site_id)) as gs_stns,
  convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, 
  convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd, site s
  where res_site_id in (select vd.res_site_id from climdb_site_variable_dates vd,research_site_sitetype st
    where vd.res_site_id=st.res_site_id and st.res_sitetype_id=3)
  and res_site_id in (select rsm.res_site_id from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=3)
  and vd.site_code in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=3 and rs.res_site_parent_id is null)
  and vd.site_code=s.site_code
    group by vd.site_code,s.site_name order by vd.site_code


--3. Stations: selects participating site by stations for all hydro and climate stations 
--with oldest and newest dates of any variable 
--and most recent update
--for research module 1 (climdb)
select vd.site_code,rst.res_sitetype_desc,rs.res_site_code,rs.res_site_name,
    convert(character(12),min(vd.first_seen),110) as first_seen,
    convert(character(12),max(vd.most_recent),110) as most_recent, 
    convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd, research_site rs, research_site_sitetype st,research_site_type rst
  where vd.variable in (select v.variable 
    from climdb_variables v, research_module_descriptor m 
    where v.descriptor_category_id=m.descriptor_category_id and (m.res_module_id=1 or m.res_module_id=2)) 
  and vd.res_site_id in (select rs.res_site_id from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and (rsm.res_module_id=1 or rsm.res_module_id=2)) 
  and vd.site_id in (select rs.site_id from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1 and rs.res_site_parent_id is null)
  and vd.res_site_id=rs.res_site_id and vd.res_site_id=st.res_site_id and rst.res_sitetype_id=st.res_sitetype_id
  group by vd.site_code,rst.res_sitetype_desc,rs.res_site_code,rs.res_site_name,st.res_sitetype_id 
  order by vd.site_code,st.res_sitetype_id desc,rs.res_site_code

select vd.site_code,rst.res_sitetype_desc,rs.res_site_code,rs.res_site_name,
    convert(character(12),min(vd.first_seen),110) as first_seen,
    convert(character(12),max(vd.most_recent),110) as most_recent, 
    convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd, research_site rs, research_site_sitetype st,research_site_type rst
  where vd.site_id in (select rs.site_id 
    from research_site rs, research_site_module rsm, climdb_site_variable_dates vd 
    where (vd.site_id=rs.site_id and rs.res_site_parent_id is null) and rs.res_site_id=rsm.res_site_id 
      and rsm.res_module_id=1)
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
  

--4. Variable Date Ranges: selects variable date ranges for each variable for each station.
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

select vd.site_code, vd.station,v.variable_name,
  convert(varchar,min(vd.first_seen),110) as begin_date, convert(varchar,max(vd.most_recent),110) as end_date, 
  convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd,climdb_variables v
  where v.variable_name in (select v.variable_name from climdb_variables v where v.variable=vd.variable)
  and vd.site_id in (select rs.site_id from research_site rs, research_site_module rsm, climdb_site_variable_dates vd 
    where (vd.site_id=rs.site_id and rs.res_site_parent_id is null) and rs.res_site_id=rsm.res_site_id 
      and rsm.res_module_id=1)
   group by vd.site_code,vd.station,v.variable_name
  order by vd.site_code,vd.station,v.variable_name

SELECT vd.site_code,vd.station,v.variable_name,
  CONVERT(varchar,min(vd.first_seen),110) AS begin_date, CONVERT(varchar,max(vd.most_recent),110) AS end_date, 
  CONVERT(character(12),max(vd.last_update),110) AS last_update
  FROM climdb_site_variable_dates vd,climdb_variables v
  WHERE v.variable_name in (SELECT v.variable_name FROM climdb_variables v WHERE v.variable=vd.variable)
  and vd.site_id in (SELECT rs.res_site_id FROM research_site rs, research_site_module rsm, climdb_site_variable_dates vd 
    WHERE (vd.site_id=rs.site_id and rs.res_site_parent_id is null) and rs.res_site_id=rsm.res_site_id
      and rsm.res_module_id=1) 
  GROUP BY vd.site_code,vd.station,v.variable_name
  ORDER BY vd.site_code,vd.station,v.variable_name

select rs.res_site_code from research_site_module rsm, research_site rs 
  where rsm.res_site_id=rs.res_site_id and rsm.res_module_id=2 and rs.site_id=1

select rs.res_site_code,rsm.res_module_id from research_site_module rsm, research_site rs 
  where rsm.res_site_id=rs.res_site_id and rs.res_site_parent_id is null

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

select vd.site_code, vd.station,v.variable_name,
  convert(varchar,min(vd.first_seen),110) as begin_date, convert(varchar,max(vd.most_recent),110) as end_date, 
  convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd,climdb_variables v
  where v.variable_name in (select v.variable_name from climdb_variables v where v.variable=vd.variable)
  and vd.site_id in (select rs.site_id from research_site rs, research_site_module rsm, climdb_site_variable_dates vd 
    where (vd.site_id=rs.site_id and rs.res_site_parent_id is null) and rs.res_site_id=rsm.res_site_id and rsm.res_module_id=2)
   group by vd.site_code,vd.station,v.variable_name
  order by vd.site_code,vd.station,v.variable_name