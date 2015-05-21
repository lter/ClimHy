--selects participating sites from climdb with oldest and newest dates of any variable from any station 
--and most recent update
select vd.site_code, s.site_name,s.loc1,s.loc2,s.site_url,
  count(distinct station) as no_stns,convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd, site s
  where vd.variable in (select v.variable from climdb_variables v, research_module_descriptor m 
    where v.descriptor_category_id=m.descriptor_category_id and m.res_module_id=1) 
  and vd.site_code in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1 and rs.res_site_parent_id is null)
  and vd.station in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1) 
  and vd.site_code=s.site_code
    group by vd.site_code,s.site_name,s.loc1,s.loc2,s.site_url order by vd.site_code 

--selects participating sites for LTER/hydrodb with oldest and newest dates of any variable from any station 
--and most recent update
select vd.site_code, s.site_name,s.loc1,s.loc2,s.site_url,
  count(distinct vd.station) as no_stns,convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd, site s
  where vd.variable in (select v.variable from climdb_variables v, research_module_descriptor m 
    where v.descriptor_category_id=m.descriptor_category_id and m.res_module_id=2) 
  and vd.site_id in (select rs.site_id from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=2 and rs.res_site_parent_id is null)
  and vd.station in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=2) 
  and vd.site_code=s.site_code
    group by vd.site_code,s.site_name,s.loc1,s.loc2,s.site_url order by vd.site_code 