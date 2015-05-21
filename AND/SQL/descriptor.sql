--to add new parameters; must disconnect relationships then insert these repeated descriptors,
-- then edit the name and insert ids
insert into descriptor_type (descriptor_type_name,descriptor_type_desc,descriptor_type_length) 
select descriptor_type_name,descriptor_type_desc,descriptor_type_length 
   from descriptor_type
    where descriptor_type_id between 153 and 164

--add new descriptor_type_id's to descriptor_category_type
insert into descriptor_category_type (descriptor_category_id,descriptor_type_id) values(2,3)
  select'21',descriptor_type_id from descriptor_type where descriptor_type_id between 218 and 229

select * from descriptor_category_type where descriptor_category_id=2

--add new descriptor_category_id's to research_module_descriptor
insert into research_module_descriptor (res_module_id,descriptor_category_id) values(1,18)
select * from research_module_descriptor order by descriptor_category_id
select * from research_module_descriptor where descriptor_category_id=2


select * from sitetype_descriptor_category order by descriptor_order
update descriptor_category set res_sitetype_id=3 where descriptor_category_id=20

select * from descriptor_category_type where descriptor_category_id=2
select * from descriptor_category_type where descriptor_type_id=1
select * from sitetype_descriptor_category


insert into descriptor_category_type (descriptor_category_id,descriptor_type_id) values(2,4)
update descriptor_category_type set descriptor_category_id=18 where descriptor_category_id=1 and descriptor_type_id=1
delete descriptor_category_type where descriptor_type_id between 13 and 15

select * from climdb_variables where descriptor_category_id=18
select distinct descriptor_category_id from climdb_variables

--to view descriptor categories for a particular research module
select a.descriptor_category_id,a.descriptor_category_name,
	a.descriptor_category_desc, d.res_sitetype_id
	from descriptor_category a, research_module_descriptor b,sitetype_descriptor_category c,research_site_type d
	where a.descriptor_category_id=b.descriptor_category_id 
	and a.descriptor_category_id=c.descriptor_category_id 
	and c.res_sitetype_id=d.res_sitetype_id 
	and b.res_module_id=2
	order by d.res_sitetype_id,a.descriptor_order

--to view descriptor categories and their associated descriptor types
select b.descriptor_category_id,b.descriptor_category_desc,a.descriptor_type_id,
       a.descriptor_type_code,a.descriptor_type_name,a.descriptor_type_unit,a.descriptor_type_desc,d.res_sitetype_name
 from descriptor_type a, descriptor_category b, descriptor_category_type c, research_site_type d, sitetype_descriptor_category e
  where a.descriptor_type_id=c.descriptor_type_id and
	b.descriptor_category_id=c.descriptor_category_id and
	b.descriptor_category_id=e.descriptor_category_id and
	e.res_sitetype_id=d.res_sitetype_id
  order by e.res_sitetype_id,b.descriptor_order

select * from descriptor_category
select * from descriptor_type
select * from climdb_variables
select * from research_site_descriptor where descriptor_type_id=230 or descriptor_type_id=231

select s.site_code, rs.res_site_code, d.descriptor_type_id,d.descriptor_value
  from site s,research_site rs,research_site_descriptor d,research_site_module m
  where s.site_id=rs.site_id and rs.res_site_id=m.res_site_id and rs.res_site_id=d.res_site_id
  and m.res_module_id=2 and d.descriptor_type_id=1 and d.descriptor_value is not null
  order by s.site_code, rs.res_site_code

select s.site_code, rs.res_site_code, d.site_id,d.res_site_id, d.descriptor_type_id,d.descriptor_value
  from site s,research_site rs,research_site_descriptor d
  where s.site_id=rs.site_id and rs.res_site_id=d.res_site_id
  and d.descriptor_type_id=110 
  order by s.site_code, rs.res_site_code
select * from site 
select * from research_site where site_id=13 res_site_parent_id is null 
select * from research_site_sitetype where res_site_id=404
select * from research_site_descriptor where site_id=1
select * from climdb_agg where site_id=13

select * from research_site_descriptor where descriptor_type_id between 230 and 231
=134 and descriptor_value is not null

update research_site_descriptor set descriptor_type_id=222 where descriptor_type_id=15
delete research_site_descriptor where descriptor_type_id=222


--selects descriptor values for a site_id and descriptor category
select rs.res_site_code,rsd.*,dt.descriptor_type_name
from research_site_descriptor rsd,descriptor_type dt,research_site rs, descriptor_category_type dct
  where dct.descriptor_category_id=13 and dct.descriptor_type_id=dt.descriptor_type_id and rsd.site_id=42
  and rsd.descriptor_type_id=dt.descriptor_type_id and rsd.descriptor_value is not null
  and rsd.descriptor_value<>' ' and rs.res_site_id=rsd.res_site_id

--selects specific descriptor values for a site_id and descriptor category
select rs.res_site_code,rsd.*,dt.descriptor_type_name
from research_site_descriptor rsd,descriptor_type dt,research_site rs, descriptor_category_type dct
  where dct.descriptor_category_id=13 and dct.descriptor_type_id=dt.descriptor_type_id and rsd.site_id=42
  and rsd.descriptor_type_id=dt.descriptor_type_id and rsd.descriptor_value is not null
  and rsd.descriptor_value<>' ' and rs.res_site_id=rsd.res_site_id
  and rsd.descriptor_type_id=140

--selects specific descriptor values for all sites
select s.site_code,rs.res_site_code,rs.res_site_parent_id,dt.descriptor_type_name,rsd.descriptor_value
from site s,research_site_descriptor rsd,descriptor_type dt,research_site rs, descriptor_category_type dct
  where (rsd.descriptor_type_id=7 or rsd.descriptor_type_id=8 or rsd.descriptor_type_id=9 
  or rsd.descriptor_type_id=11 or rsd.descriptor_type_id=12 or rsd.descriptor_type_id=233 or rsd.descriptor_type_id=169)
  and dct.descriptor_type_id=dt.descriptor_type_id 
  and rsd.descriptor_type_id=dt.descriptor_type_id
  and rsd.descriptor_value is not null and rsd.descriptor_value<>' ' 
  and rs.res_site_id=rsd.res_site_id and s.site_id=rs.site_id
order by s.site_code, rs.res_site_code

--selects watersheds with a west bounding coordinate in hydrodb
select rs.res_site_code,rsd.* 
from research_site_descriptor rsd,descriptor_type dt, research_site_module rsm,research_site rs
  where dt.descriptor_type_id=166
  and rsd.descriptor_type_id=dt.descriptor_type_id and rsd.descriptor_value is not null
  and rsd.descriptor_value<>' ' and rsd.res_site_id=rsm.res_site_id and rsm.res_module_id=2
  and rs.res_site_id=rsd.res_site_id

--selects all bounding coordinates
select rs.res_site_code,rss.res_sitetype_id,rsd.*,dt.descriptor_type_name
from research_site_descriptor rsd,descriptor_type dt,research_site rs, research_site_sitetype rss
  where dt.descriptor_type_code like '%__coord%'
  and rsd.descriptor_type_id=dt.descriptor_type_id and rsd.descriptor_value is not null
  and rsd.descriptor_value<>' ' and rs.res_site_id=rsd.res_site_id and rs.res_site_id=rss.res_site_id

--selects all lats and longs
select rs.res_site_code,rss.res_sitetype_id,rsd.*,dt.descriptor_type_name,dt.descriptor_type_code
from research_site_descriptor rsd,descriptor_type dt,research_site rs, research_site_sitetype rss
  where (dt.descriptor_type_code like '%__lat' or dt.descriptor_type_code like '%__long')
  and rsd.descriptor_type_id=dt.descriptor_type_id and rsd.descriptor_value is not null
  and rsd.descriptor_value<>' ' and rs.res_site_id=rsd.res_site_id and rs.res_site_id=rss.res_site_id

--selects all lats and longs
select rs.res_site_code,rss.res_sitetype_id,rsd.*,dt.descriptor_type_name,dt.descriptor_type_code
from research_site_descriptor rsd,descriptor_type dt,research_site rs, research_site_sitetype rss, research_site_module rsm
  where dt.descriptor_type_code ='gs_lat' and rsm.res_module_id=3
  and rsm.res_site_id=rs.res_site_id
  and rsd.descriptor_type_id=dt.descriptor_type_id and rsd.descriptor_value is not null
  and rsd.descriptor_value<>' ' and rs.res_site_id=rsd.res_site_id and rs.res_site_id=rss.res_site_id


select * from descriptor_type where descriptor_type_name is null
select * from descriptor_type where descriptor_type_code like '%_west_coord%'

delete from descriptor_type where descriptor_type_id=223

update descriptor_type set descriptor_type_name='Watershed west bounding coordinate' 
  where descriptor_type_code like '%_west_coord%'
update descriptor_type set descriptor_type_desc='in decimal degrees - 5 decimal places' 
  where descriptor_type_code like '%_west_coord%'
delete descriptor_type where descriptor_type_id between 13 and 15

SELECT * FROM climdb_variables WHERE descriptor_category_id=2
SELECT * FROM descriptor_category_type	WHERE descriptor_type_id=223
delete FROM descriptor_category	WHERE descriptor_category_id=2
update research_module_descriptor set descriptor_category_id=1 where res_module_id=1 and descriptor_category_id=2
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


--research_site_descriptor 
select count(res_site_id) 
	from research_site_descriptor 
	where res_site_id=2 and
	descriptor_type_id in
	(select descriptor_type_id 
		from descriptor_category_type
		where descriptor_category_id=1)
		

insert research_site_descriptor
	(res_site_id,site_id,descriptor_type_id)
	select a.res_site_id,a.site_id,b.descriptor_type_id
		from research_site a,descriptor_category_type b
		where a.res_site_id=1 and site_id=1 and b.descriptor_category_id=1 

select * from research_site_descriptor where descriptor_type_id=17
  and descriptor_value <>' ' and descriptor_value is not null

--delete from research_site_descriptor where descriptor_type_id=223

--selects the number of descriptors for each category
select descriptor_category_id,count(descriptor_type_id) as no_descriptors from descriptor_category_type
  group by descriptor_category_id

--selects sites that don't have the correct number of descriptors
select d.res_site_id,d.site_id,c.descriptor_category_id,count(d.descriptor_type_id) as no_descriptors 
  from research_site_descriptor d,descriptor_category_type c
  where d.descriptor_type_id=c.descriptor_type_id and c.descriptor_category_id=20
  group by d.res_site_id,d.site_id,c.descriptor_category_id
  having count(d.descriptor_type_id)<>12
  order by c.descriptor_category_id,d.res_site_id

--selects descriptor_type_id not in research_site_descriptor (same as above)
select d.res_site_id,d.site_id,c.descriptor_category_id,count(d.descriptor_type_id) as no_descriptors 
  from research_site_descriptor d inner join descriptor_category_type c
  on d.descriptor_type_id=c.descriptor_type_id where c.descriptor_category_id=21
  group by d.res_site_id,d.site_id,c.descriptor_category_id
  having count(d.descriptor_type_id)<>11
  order by c.descriptor_category_id,d.res_site_id

--missing descriptors
select s.res_site_id,s.site_id,c.descriptor_type_id 
  from research_site_descriptor d right outer join descriptor_category_type c
  on d.descriptor_type_id=c.descriptor_type_id inner join #sites s
  on s.res_site_id=d.res_site_id
  where c.descriptor_category_id=21
  and c.descriptor_type_id not in (select c.descriptor_type_id 
  from research_site_descriptor d, descriptor_category_type c
  where c.descriptor_category_id=21 and d.res_site_id=156 and d.descriptor_type_id=c.descriptor_type_id
  group by d.res_site_id,d.site_id,c.descriptor_type_id
  having count(d.descriptor_type_id)<>11) 

--missing descriptors
select c.descriptor_type_id
  from descriptor_category_type c
  where c.descriptor_category_id=1 and c.descriptor_type_id not in (
  select d.res_site_id,d.descriptor_type_id from research_site_descriptor d, descriptor_category_type c, #sites s
  where c.descriptor_category_id=1 and d.res_site_id=s.res_site_id 
  and d.descriptor_type_id=c.descriptor_type_id)

select c.descriptor_type_id
  from descriptor_category_type c
  where c.descriptor_category_id=1 and c.descriptor_type_id not in (
  select d.descriptor_type_id from research_site_descriptor d, descriptor_category_type c
  where c.descriptor_category_id=1 and d.res_site_id=3 and d.descriptor_type_id=c.descriptor_type_id)

--Insert missing descriptors (use #gotit to select the sites with the wrong number of descriptors)
--(1) need to edit res_site_id and site_id in select statement and res_site_id in where clause
insert into research_site_descriptor select '414','47',descriptor_type_id,' ',getdate()
  from descriptor_category_type
  where descriptor_category_id=1 and descriptor_type_id not in (
  select d.descriptor_type_id from research_site_descriptor d, descriptor_category_type c
  where c.descriptor_category_id=1 and d.res_site_id=414 and d.descriptor_type_id=c.descriptor_type_id)

--(2)this is for adding one specific descriptor_type_id; need to edit the descriptor_type_id in the select statement
--and the descriptor_category_id and descriptor_type_id count in that category in the where clause
insert into research_site_descriptor select d.res_site_id,d.site_id,234,'',getdate()
  from research_site_descriptor d,descriptor_category_type c
  where d.descriptor_type_id=c.descriptor_type_id and c.descriptor_category_id=3
  group by d.res_site_id,d.site_id,c.descriptor_category_id
  having count(d.descriptor_type_id)<>12

--this command isn't working correctly; it results in an inner join
select * from #gotit g full outer join #categories c on g.descriptor_type_id=c.descriptor_type_id

--take 3
select * from #sites where no_descriptors=3
select * from #gotit where res_site_id=156
select * from #categories
select g.res_site_id,c.descriptor_type_id from #gotit g JOIN  #categories c 
on g.descriptor_type_id=c.descriptor_type_id  --order by res_site_id
where g.res_site_id=156 and g.descriptor_type_id=c.descriptor_type_id and descriptor_type_id not in (select descriptor_type_id from #categories)

--temporary tables
drop table #categories
drop table #gotit
drop table #sites
select d.res_site_id,d.site_id,c.descriptor_category_id,count(d.descriptor_type_id) as no_descriptors 
  --into #sites
  from research_site_descriptor d,descriptor_category_type c
  where d.descriptor_type_id=c.descriptor_type_id and c.descriptor_category_id=3
  group by d.res_site_id,d.site_id,c.descriptor_category_id
  having count(d.descriptor_type_id)<>12
  order by c.descriptor_category_id,d.res_site_id

select descriptor_type_id --into #categories
  from descriptor_category_type
  where descriptor_category_id=3 
  
select d.res_site_id,d.descriptor_type_id into #gotit 
  from research_site_descriptor d right outer join descriptor_category_type ct
  on d.descriptor_type_id=ct.descriptor_type_id inner join #sites s
  on s.res_site_id=d.res_site_id
  where ct.descriptor_category_id=1 

select g.res_site_id,g.site_id,c.descriptor_type_id from #gotit g

--join
--select res_site_id's where descriptors are missing
drop table #sites
select d.res_site_id,d.site_id,c.descriptor_category_id,count(d.descriptor_type_id) as no_descriptors 
--  into #sites
  from research_site_descriptor d,descriptor_category_type c
  where d.descriptor_type_id=c.descriptor_type_id and c.descriptor_category_id=21
  group by d.res_site_id,d.site_id,c.descriptor_category_id
  having count(d.descriptor_type_id)<>11
  order by c.descriptor_category_id,d.res_site_id



select * from research_site_descriptor
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
select s.site_code,rs.res_site_code,rs.res_site_name,dt.descriptor_type_name,d.descriptor_value 
  from site s,research_site rs, descriptor_type dt, research_site_descriptor d
  where (d.descriptor_type_id=7 or d.descriptor_type_id=8 or d.descriptor_type_id=21 
  or d.descriptor_type_id=22) and d.descriptor_value <>''
  and rs.res_site_id=d.res_site_id and d.descriptor_type_id=dt.descriptor_type_id
  and rs.site_id=s.site_id
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

