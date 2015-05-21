select * from descriptor_type where descriptor_type_id=27
select a.site_id,a.site_name from site a , research_site_module b
	where a.site_id=b.site_id and b.res_module_id=2

select a.descriptor_category_id,a.descriptor_category_name,
	a.descriptor_category_desc, a.res_sitetype_id
	from descriptor_category a, research_module_descriptor b
	where a.descriptor_category_id=b.descriptor_category_id 
	and b.res_module_id=1
	order by res_sitetype_id

select a.res_site_id,a.res_site_code
	from research_site a
	where a.site_id=1 and a.res_sitetype_id=3
	order by a.res_site_code

select count(res_site_id) 
	from research_site_descriptor 
	where res_site_id=2 and
	descriptor_type_id in
	(select descriptor_type_id 
		from descriptor_category_type
		where descriptor_category_id=1)
		

--insert research_site_descriptor
	(res_site_id,site_id,descriptor_type_id)
	select a.res_site_id,a.site_id,b.descriptor_type_id
		from research_site a,descriptor_category_type b
		where a.res_site_id=1 and site_id=1 and b.descriptor_category_id=1 

select * from research_site_descriptor where descriptor_value<>'44.2000'
  site_id=14
  descriptor_value<>'44.2000'

select * from research_site_descriptor where descriptor_type_id=28
  where descriptor_type_id>187 and descriptor_type_id<192
  and descriptor_value <>''

--To get bounding coordinates of sites
select rs.res_site_code,dt.descriptor_type_name,d.descriptor_value 
  from research_site rs, descriptor_type dt, research_site_descriptor d
  where d.descriptor_type_id>187 and d.descriptor_type_id<192 and d.descriptor_value <>''
  and rs.res_site_id=d.res_site_id and d.descriptor_type_id=dt.descriptor_type_id

--To get bounding coordinates of watersheds
select s.site_code,rs.res_site_code,dt.descriptor_type_name,d.descriptor_value 
  from site s,research_site rs, descriptor_type dt, research_site_descriptor d
  where d.descriptor_type_id>164 and d.descriptor_type_id<169 and d.descriptor_value <>''
  and rs.res_site_id=d.res_site_id and d.descriptor_type_id=dt.descriptor_type_id
  and rs.site_id=s.site_id

--To get lats and longs of gauging and meteorologic stations
select rs.res_site_id,s.site_code,rs.res_site_code,rss.res_sitetype_id, dt.descriptor_type_name,d.descriptor_value 
  from site s,research_site rs, research_site_sitetype rss,descriptor_type dt, research_site_descriptor d
  where (d.descriptor_type_id=7 or d.descriptor_type_id=8 or d.descriptor_type_id=21 
  or d.descriptor_type_id=22) and d.descriptor_value <>''
  and rs.res_site_id=d.res_site_id and d.descriptor_type_id=dt.descriptor_type_id
  and rs.site_id=s.site_id and rs.res_site_id=rss.res_site_id
  order by s.site_code,rs.res_site_code

select site_code,latitude_dec,longitude_dec from site where latitude_dec is not null


--To get site level descriptors for ClimDB
select a.descriptor_type_name, a.descriptor_type_desc, b.descriptor_value
	from descriptor_type a,research_site_descriptor b
	where b.res_site_id=1 and 
	a.descriptor_type_id=b.descriptor_type_id and
	a.descriptor_type_id in
	(select descriptor_type_id from descriptor_category_type
		where descriptor_category_id=1)


select * from site where latitude_dec is not null
select * from research_site_descriptor where descriptor_type_id=188
descriptor_value<>'44.2000'
descriptor_type_id=188 and site_id=1
select * from climdb_raw
update research_site_descriptor
  set descriptor_value=(select latitude_dec from site s,research_site rs,research_site_descriptor rsd
  where rsd.res_site_id=rs.res_site_id and rs.site_id=s.site_id and rsd.descriptor_type_id=188 and rsd.site_id=1) 
  from site s,research_site rs,research_site_descriptor rsd
  where rsd.res_site_id=rs.res_site_id and rs.site_id=s.site_id and rsd.descriptor_type_id=188 and rsd.site_id=1


update research_site_descriptor
	set descriptor_value='The hydrologic regime is...'
	where res_site_id=1 and descriptor_type_id=1

select s.site_code,rs.res_site_code,dt.descriptor_type_name,d.descriptor_value 
  from site s,research_site rs, descriptor_type dt, research_site_descriptor d
  where s.site_code='MAR'and rs.res_site_id=d.res_site_id 
  and d.descriptor_type_id=dt.descriptor_type_id and rs.site_id=s.site_id
  order by s.site_code,rs.res_site_code

select rs.res_site_code,dt.descriptor_type_name,d.descriptor_value 
  from research_site rs, descriptor_type dt, research_site_descriptor d
  where d.descriptor_type_id=188 and d.descriptor_value <>'' and d.descriptor_value is not null
  and rs.res_site_id=d.res_site_id and d.descriptor_type_id=dt.descriptor_type_id

select rs.res_site_code,dt.descriptor_type_name,d.descriptor_value 
  from research_site rs, descriptor_type dt, research_site_descriptor d
  where d.descriptor_type_id=188 
  and rs.res_site_id=d.res_site_id and d.descriptor_type_id=dt.descriptor_type_id

