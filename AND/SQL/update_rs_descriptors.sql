--When adding new descriptor types, they need to be inserted into research_site_descriptor before they will show up in SiteDB (Updating Metadata).

select * from research_site
select rs.res_site_id,rs.site_id,s.site_url into #site from research_site rs, site s where res_site_parent_id IS NULL and rs.site_id=s.site_id
drop table #site
select * from #site
insert into research_site_descriptor select res_site_id,site_id,'233',site_url,getdate() from #site
 
select * from descriptor_category_type where type_order is null

--select the number of descriptors for a category
SELECT descriptor_type_id,type_order 
	FROM descriptor_category_type
	WHERE descriptor_category_id=1
	order by type_order

--select the sites that don't have the correct number of descriptors
select d.res_site_id,d.site_id,c.descriptor_category_id,count(d.descriptor_type_id) as no_descriptors 
  from research_site_descriptor d,descriptor_category_type c
  where d.descriptor_type_id=c.descriptor_type_id and c.descriptor_category_id=1
  group by d.res_site_id,d.site_id,c.descriptor_category_id
  having count(d.descriptor_type_id)<>13
  order by c.descriptor_category_id,d.res_site_id

--temporary tables
drop table #sites


select * from #sites where no_descriptors=3

select * from research_site_descriptor where site_id=34

--work in progress to update ws association using parent_id (12-15-03)
update research_site_descriptor set descriptor_value=(select rs.res_site_code 
  from research_site rs,research_site_descriptor rsd
  where rs.res_site_parent_id=rsd.res_site_id and rsd.res_site_id=44

select rs.res_site_code 
  from research_site rs,research_site_descriptor rsd
  where rs.res_site_parent_id=rsd.res_site_id and rsd.res_site_id=44 and rsd.descriptor_type_id=234

select * from research_site where site_id=1
select * from research_site_descriptor where res_site_id=75 and descriptor_type_id=234