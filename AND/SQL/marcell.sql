select * from research_site where site_id=21
select * from research_site where res_site_id=246
select * from research_site_sitetype where res_site_id between 235 and 248
select * from research_site_module where res_site_id between 235 and 248

delete from research_site where res_site_id between 246 and 248
select * from research_site_sitetype where res_site_id=166
insert into research_site_sitetype (res_site_id,res_sitetype_id) values(242,4)

select distinct station from climdb_raw where site_id=21
select * from climdb_site_variable_dates where res_site_id=236 or res_site_id=246
select * from climdb_raw where (res_site_id=236 or res_site_id=246) and value is not null
  and variable='PREC'
  order by sampledate,variable
update research_site_descriptor set res_site_id=242 where  res_site_id=248

select distinct res_site_id,site_id,site_code,station,variable,last_update 
  from climdb_raw where (res_site_id=236 or res_site_id=246) and value is not null
  order by variable
