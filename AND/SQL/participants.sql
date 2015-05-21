--selects site_code and site_name from table site for all sites in module 1 (climdb).
SELECT s.site_id,s.site_code,s.site_name 
  from site s,research_site rs, research_site_module rsm
  where s.site_id=rs.site_id and rs.res_site_id=rsm.res_site_id 
  and rsm.res_module_id=1 and rs.res_site_parent_id is null
  order by s.site_id

--selects the personnel and their roles by site for research module 1 (climdb)
--note...if middle_name is null, then fullname defaults to null (only on Rocky not on Spiraea).
--***This is multiple selecting personnel****
select distinct spr.site_id,spr.personnel_id,spr.res_module_id,'fullname'=rtrim(p.first_name)+' '+rtrim(p.middle_name)+' '+rtrim(p.last_name),
pr.personnel_role_desc,p.email1
from site_personnel_role spr, personnel p, personnel_role pr,
site s,research_site rs, research_site_module rsm
where p.personnel_id=spr.personnel_id and spr.personnel_role_id=pr.Personnel_role_id
and spr.site_id=s.site_id and s.site_id=rs.site_id and rs.res_site_id=rsm.res_site_id
and spr.res_module_id=1 and rs.res_site_parent_id is null
order by spr.site_id,pr.personnel_role_desc desc

select * from site_personnel_role where site_id=1 and res_module_id=1



