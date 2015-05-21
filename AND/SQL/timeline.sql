--timeline for site and variables with date ranges
select vd.site_code, v.variable_name,
  convert(varchar,min(vd.first_seen),110) as begin_date, convert(varchar,max(vd.most_recent),110) as end_date, 
  convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd,climdb_variables v
  where v.variable_name in (select v.variable_name from climdb_variables v
    where v.variable=vd.variable)
  and vd.station in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1) 
  and vd.site_code in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1 and rs.res_site_parent_id is null) 
  group by vd.site_code,v.variable_name
  order by vd.site_code,v.variable_name


--original query
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