<--This add_station.sql helps in populating the appropriate tables to add a new station.
<--This assumes that the site is already in the database.

<--First hand populate table research_site; use p:\fsdb\climdb_local\add_site.doc as a guide

<--Then populate stations based on research_site using the following query;
<-- need to input the appropriate site_code (replace 'AND') and change the where statement
<-- to reflect the new res_site_id (res_site_id>148)
insert into stations (site_code,station,description)
  select 'CAP',res_site_code,res_site_name
  from research_site where res_site_id>255 and res_site_id<277

<--Next populate research_site_module using the following query;
<-- need to change the where statement to reflect the new res_site_id (res_site_id>148), as above,
<-- and input the research_module (1=climate, 2=hydrology)
insert into research_site_module (res_site_id,res_module_id) 
  select res_site_id,'1' from research_site 
  where res_site_id>480 and res_site_id<504

<--Next populate research_site_sitetype using the following query;
<-- need to change the where statement to reflect the new res_site_id (res_site_id>148), as above,
<-- and input the research_module (1=climate, 2=hydrology)
insert into research_site_sitetype (res_site_id,res_sitetype_id) 
  select res_site_id,'4' from research_site 
  where res_site_id>480 and res_site_id<504

<--Other useful commands:
select * from research_site where site_id=14 order by res_site_code
select * from research_site_module where res_site_id=21
select * from research_site where site_id=42
select * from site where site_code='FCE'
delete stations where site_code='AND' and latitude_dec is null
select * from research_site_sitetype where res_sitetype_id=3

select * from research_site_sitetype where res_site_id>467 and res_site_id<479
delete from research_site_sitetype where res_site_id=478 and res_sitetype_id=4
insert into research_site_sitetype (res_site_id,res_sitetype_id) values(471,3)

select * from research_site_module where res_site_id>467 and res_site_id<479 and res_module_id is null
delete from research_site_module where res_site_id>42
insert into research_site_module (res_site_id,res_module_id) values(478,2)

select * from research_site where res_site_id>250

SELECT DISTINCT res_site_id, res_site_code
FROM research_site r, site s
WHERE 	res_sitetype_id = 4 AND 
	s.site_id = r.site_id AND 
	s.site_code = 'CAP'

select * from site 
select * from research_site_module
select * from personnel_role

