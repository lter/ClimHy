select * from research_site where site_id=4

update research_site_module
 set research_site_module.res_site_id=research_site.res_site_id
 from research_site inner join research_site_module
 on research_site.site_id = research_site_module.site_id

insert into research_site_module (res_site_id,site_id)
  select a.res_site_id,a.site_id 
   from research_site a
    where a.res_site_id>42 

insert into research_site_module (res_site_id,res_module_id) values(166,3)

select * from research_site_module where res_module_id=3
select * from research_site_module where res_module_id>278 res_site_id=4 and res_module_id is null
select * from research_site_module where res_site_id=20

insert into climdb_raw (site_code,station,variable,sampledate,value,flag)
select harvest_raw.site_code,harvest_raw.station,harvest_raw.variable,harvest_raw.sampledate,harvest_raw.value,harvest_raw.flag
from climdb_raw right outer join harvest_raw
	on climdb_raw.site_code = harvest_raw.site_code
	and climdb_raw.station = harvest_raw.station
	and climdb_raw.variable = harvest_raw.variable
	and climdb_raw.sampledate = harvest_raw.sampledate
where climdb_raw.site_code is null

select descriptor_category_desc,descriptor_type_name,descriptor_type_desc
 from descriptor_type a, descriptor_category b, descriptor_category_type c
  where a.descriptor_type_id=c.descriptor_type_id and
	b.descriptor_category_id=c.descriptor_category_id


--Helps select USGS stations from research_site_module
select rs.site_id,rs.res_site_id,rs.res_site_code,rs.res_site_name from research_site rs, research_site_module rsm,research_site_sitetype st
where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=3 and rs.res_site_parent_id is not null
and rs.res_site_id=st.res_site_id and st.res_sitetype_id=3
order by site_id

select * from climdb_raw where res_site_id between 372 and 375
select * from climdb_site_variable_dates where site_id=39

select distinct res_site_id,site_id,site_code,station from climdb_site_variable_dates where site_id=41 and variable='DSCH' order by res_site_id

select * from climdb_site_variable_dates where station='LEVEE31_7'

select distinct vd.res_site_id,vd.site_id,vd.site_code,vd.station,rsm.res_module_id 
 from climdb_site_variable_dates vd,research_site_module rsm
 where vd.res_site_id=rsm.res_site_id and vd.variable='DSCH' and vd.site_id=41
 order by vd.res_site_id

select * from research_site where site_id=25

insert into research_site_module values(356,3)
update research_site_module set res_module_id=3 where res_module_id=2 and res_site_id in(select res_site_id from research_site where site_id=25)


select * from research_site_module rsm, research_site rs
where rs.res_site_id=rsm.res_site_id and rs.site_id=41
