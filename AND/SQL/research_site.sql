--research_site
select * from site
select * from research_site where site_id=13 order by res_sitetype_id or site_id=17
select * from research_site where site_id=39 order by res_site_code
select * from research_site where res_site_parent_id is not null
select * from research_site where res_site_parent_id=31
select * from research_site where res_site_code='PIE'


select res_site_code from research_site where res_sitetype_id>2 
  group by res_sitetype_id,res_site_code having count(*)>1 

--reseach sites by res_sitetype_id
select st.res_sitetype_id,rs.res_site_id,rs.res_site_code,rs.res_site_name 
  from research_site rs,research_site_sitetype st
  where st.res_site_id=rs.res_site_id and st.res_sitetype_id=4
  order by st.res_sitetype_id

--reseach sites by res_sitetype_id
select st.res_sitetype_id,rs.res_site_id,rs.res_site_code,rs.res_site_name 
  from research_site rs,research_site_sitetype st
  where st.res_site_id=rs.res_site_id 
  order by rs.res_site_code,rs.res_site_name

select * from descriptor_category_type dct,research_site_descriptor rsd 
  where dct.descriptor_category_id=18 and dct.descriptor_type_id=rsd.descriptor_type_id and rsd.site_id=37

-----deletes and updates
delete from research_site_descriptor where res_site_id=41 and descriptor_type_id=1
delete from research_site where res_site_id=89
update research_site set res_site_code='S2Bog' where res_site_code='S2_BOG'
update research_site set res_site_id=202 where res_site_id=157
update research_site set res_site_parent_id=null where res_site_id=414
delete from research_site_sitetype where res_site_id=64 and res_sitetype_id=4
--delete from research_site_module where res_site_id=318
--delete from research_site where res_site_id=397

--site
select * from site 
select * from site where site_code='BNZ'
select * from site where usgs_data_url<>''
update site set loc1='Las Cruces' where site_id=17

--selects distinct stations based on sitetype (ms or gs)
SELECT DISTINCT r.res_site_id, r.res_site_code
FROM research_site r, site s, research_site_sitetype st
WHERE 	st.res_sitetype_id = 2 AND
	r.res_site_id=st.res_site_id AND 
	s.site_id = r.site_id AND 
	s.site_code = 'HBR'

SELECT r.res_site_id, r.res_site_code
FROM research_site r, site s, research_site_sitetype st
WHERE 	st.res_sitetype_id = 4 AND
	r.res_site_id=st.res_site_id AND 
	s.site_id = r.site_id AND 
	s.site_code = 'HBR'

exec sp_changeobjectowner 'dates_temp' , 'dbo'

--research_site_sitetype
select * from research_site_sitetype where res_sitetype_id=3
select * from research_site_sitetype where res_site_id=89
select rss.res_site_id,rs.res_site_code,rss.res_sitetype_id 
  from research_site_sitetype rss,research_site rs
  where rss.res_site_id=rs.res_site_id and rs.site_id=13
select * from research_site_sitetype where res_site_id>503 and res_site_id<510
select * from research_site_type

delete from research_site_sitetype where res_site_id=89

--select res_site_codes based on res_sitetype_id for a given site_id
select st.res_site_id,r.site_id,r.res_site_code,r.res_site_name,st.res_sitetype_id
   from research_site r, research_site_sitetype st
  where r.res_site_id=st.res_site_id and r.site_id=1

select res_site_id from research_site_sitetype group by res_site_id having count(*)>1 
select rss.res_site_id,rs.res_site_code,s.site_code,rss.res_sitetype_id from research_site_sitetype rss,research_site rs,site s 
  where  rss.res_site_id=rs.res_site_id and rs.site_id=s.site_id and rss.res_site_id in 
 (select res_site_id from research_site_sitetype group by res_site_id having count(*)>1 )
insert research_site_sitetype (res_site_id,res_sitetype_id) values(64,4)
insert research_site_sitetype select res_site_id,res_sitetype_id 
 from research_site a, research_site_type b
 where res_site_id=a.res_site_id and res_sitetype_id=b.res_sitetype_id
delete from research_site_sitetype where res_site_id=157 and res_sitetype_id=4
update research_site_sitetype set res_sitetype_id=2 where res_site_id=157 and res_sitetype_id=3

--research_site_module
select * from research_site_module where res_module_id=3
select * from research_site_module where res_site_id=92
select * from research_site_module where res_site_id>166 and res_site_id<170 and res_module_id is null

select rs.* from research_site rs, research_site_module rsm
  where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=2 and rs.site_id=13

--select res_site_codes based on res_module_id for a given site_id
select rm.res_site_id,r.site_id,r.res_site_code,rm.res_module_id
   from research_site r, research_site_module rm
  where r.res_site_id=rm.res_site_id and r.site_id=14 and rm.res_module_id=1

select rm.res_site_id,r.res_site_code,r.site_id from research_site_module rm, research_site r
where r.res_site_id=rm.res_site_id and rm.res_module_id <>3
group by rm.res_site_id,r.res_site_code,r.site_id having count(*)>1 

--Delete using an inner join
delete research_site_module from research_site_module rm inner join research_site r
  on r.res_site_id=rm.res_site_id
  where r.site_id=18 and rm.res_module_id=2

delete from research_site_module where res_site_id=89 and res_module_id=2
insert research_site_module (res_site_id,res_module_id) values(325,3)
update research_site_module set res_site_id=326 where res_site_id=397 and res_module_id=3

--research_site_descriptor
select * from research_site_descriptor where descriptor_type_id between 218 and 229 and site_id=1
select * from research_site_descriptor where last_update<'2003-02-17'
select count(*) from research_site_descriptor
select * from research_site_descriptor where res_site_id=92

delete research_site_descriptor where res_site_id=89

select * from descriptor_category_type where descriptor_type_id between 218 and 229
select * from descriptor_category_type where descriptor_category_id=21
select * from descriptor_category where descriptor_category_id=21
select * from descriptor_type where descriptor_type_id between 218 and 229
select descriptor_category_id,res_sitetype_id into sitetype_descriptor_category from descriptor_category
select * from sitetype_descriptor_category where res_sitetype_id=4

---insert
insert sitetype_descriptor_category  (descriptor_category_id,res_sitetype_id) values(20,3)


select distinct research_site.res_site_id from research_site,climdb_site_variable_dates
  where research_site.res_site_code=climdb_site_variable_dates.station
  and research_site.site_id=climdb_site_variable_dates.site_id
  and research_site.res_sitetype_id>2 order by research_site.res_site_id

	
select * from research_site_descriptor where site_id=26
delete research_site_descriptor where res_site_id=401

select * from climdb_raw where res_site_id=89
select * from descriptor_type

--products people display
--Need to have a record in research_site_descriptor (update metastat - Research Area Information)
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
	spr.res_module_id=1 AND 
	rs.res_site_parent_id is null AND
	spr.personnel_role_id!=6 and rs.res_site_id=674
ORDER BY rs.res_site_code, pr.personnel_role_desc desc


	