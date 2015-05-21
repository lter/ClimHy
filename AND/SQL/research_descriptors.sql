--These queries were written to deal with the irregular number of descriptors per category from each site.
--These irregularities came about from updating the schema and previously existing metadata.

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
insert into research_site_descriptor select '3','3',descriptor_type_id,' ',getdate()
  from descriptor_category_type
  where descriptor_category_id=21 and descriptor_type_id not in (
  select d.descriptor_type_id from research_site_descriptor d, descriptor_category_type c
  where c.descriptor_category_id=21 and d.res_site_id=92 and d.descriptor_type_id=c.descriptor_type_id)

--this command isn't working correctly; it results in an inner join
select * from #gotit g full outer join #categories c on g.descriptor_type_id=c.descriptor_type_id

--take 3
select * from #sites
select * from #gotit where res_site_id=156
select * from #categories
select g.res_site_id,c.descriptor_type_id from #gotit g JOIN  #categories c 
on g.descriptor_type_id=c.descriptor_type_id  --order by res_site_id
where g.res_site_id=156 and g.descriptor_type_id=c.descriptor_type_id and descriptor_type_id not in (select descriptor_type_id from #categories)

--temporary tables
drop table #sites
select d.res_site_id,d.site_id,c.descriptor_category_id,count(d.descriptor_type_id) as no_descriptors 
--  into #sites
  from research_site_descriptor d,descriptor_category_type c
  where d.descriptor_type_id=c.descriptor_type_id and c.descriptor_category_id=21
  group by d.res_site_id,d.site_id,c.descriptor_category_id
  having count(d.descriptor_type_id)<>11
  order by c.descriptor_category_id,d.res_site_id

select descriptor_type_id into #categories
  from descriptor_category_type
  where descriptor_category_id=21 
  
select d.res_site_id,d.descriptor_type_id into #gotit 
  from research_site_descriptor d right outer join descriptor_category_type ct
  on d.descriptor_type_id=ct.descriptor_type_id inner join #sites s
  on s.res_site_id=d.res_site_id
  where ct.descriptor_category_id=21 

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


select * from descriptor_category
select dct.descriptor_category_id,dt.* from descriptor_type dt, descriptor_category_type dct
  where dt.descriptor_type_id=dct.descriptor_type_id and dct.descriptor_category_id=3
select * from research_site_type
select * from climdb_variables

select res_site_id,site_id,site_code,station from climdb_site_variable_dates where variable='GRAD' 
  order by site_code, station

--to select specific descriptors (gs lat (7), gs long (8), met lat (21), met long (22), met elev (25)) for stations
select s.site_code,rs.res_site_code,rsd.descriptor_type_id,rsd.descriptor_value
	from research_site_descriptor rsd, descriptor_type dt, research_site rs,research_site_sitetype rss, site s
	where rsd.descriptor_type_id=dt.descriptor_type_id and rsd.res_site_id=rs.res_site_id 
	and rss.res_site_id=rs.res_site_id and s.site_id=rs.site_id 
	and (rss.res_sitetype_id=3 or rss.res_sitetype_id=4)
	and (dt.descriptor_type_id=7 or dt.descriptor_type_id=8) 
	order by s.site_code,rs.res_site_code


select csvd.site_code,csvd.station,rsd.descriptor_type_id,rsd.descriptor_value
	from research_site_descriptor rsd, descriptor_type dt, climdb_site_variable_dates csvd
	where rsd.descriptor_type_id=dt.descriptor_type_id and rsd.res_site_id=csvd.res_site_id 
	and (dt.descriptor_type_id=21 or dt.descriptor_type_id=22 or dt.descriptor_type_id=25) 
	and csvd.variable='TMEA' order by csvd.site_code,csvd.station



	