select * from research_site

--Update site_id and res_site_id in climdb_site_variable_dates:
update climdb_site_variable_dates set site_id=research_site.site_id 
  from research_site inner join climdb_site_variable_dates
  on research_site.res_site_code=climdb_site_variable_dates.site_code

update climdb_site_variable_dates set res_site_id=research_site.res_site_id 
  from research_site inner join climdb_site_variable_dates
  on research_site.res_site_code=climdb_site_variable_dates.station
  and research_site.site_id=climdb_site_variable_dates.site_id
  and research_site.res_sitetype_id>2


--Update site_id and res_site_id in climdb_agg:
update climdb_agg set site_id=research_site.site_id 
  from research_site inner join climdb_agg
  on research_site.res_site_code=climdb_agg.site_code

update climdb_agg set res_site_id=research_site.res_site_id 
  from research_site inner join climdb_agg
  on research_site.res_site_code=climdb_agg.station
  and research_site.site_id=climdb_agg.site_id
  and research_site.res_sitetype_id>2

--Update site_id and res_site_id in climdb_raw:
update climdb_raw set site_id=research_site.site_id 
  from research_site inner join climdb_raw
  on research_site.res_site_code=climdb_raw.site_code

update climdb_raw set res_site_id=research_site.res_site_id 
  from research_site inner join climdb_raw
  on research_site.res_site_code=climdb_raw.station
  and research_site.site_id=climdb_raw.site_id
  and research_site.res_sitetype_id>2


select distinct res_site_id,site_id,site_code,station from climdb_site_variable_dates order by site_code,station
select
select count(*) from climdb_raw
select * from climdb_site_variable_dates
select count(*) from climdb_agg
select * from climdb_agg

update climdb_site_variable_dates set site_id=(select distinct research_site.site_id 
  from research_site,climdb_site_variable_dates
  where research_site.res_site_code='AND')

update climdb_site_variable_dates set site_id=1,res_site_id=2