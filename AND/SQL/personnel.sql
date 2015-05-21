select * from site
select * from site_personnel_role where site_id=13 and res_module_id=1
select * from site_personnel_role where personnel_id=161
select * from personnel where personnel_id=120
select * from personnel where last_name='Collins'
select * from personnel where email1 like '%aelling@fs.fed.us%'
select * from personnel_role
select * from site where site_id=21



Select s.site_code,'fullname'=rtrim(p.first_name)+' '+rtrim(p.middle_name)+' '+rtrim(p.last_name), pr.personnel_role_desc
  from personnel as p, site_personnel_role as spr, site as s, personnel_role as pr
  where p.personnel_id=spr.personnel_id and spr.site_id=s.site_id and spr.personnel_role_id=pr.Personnel_role_id and p.personnel_id=120

select s.site_id,spr.personnel_id,'fullname'=rtrim(p.first_name)+' '+rtrim(p.middle_name)+' '+rtrim(p.last_name),
	pr.personnel_role_desc,spr.res_module_id, email1
	from personnel as p, site_personnel_role as spr, personnel_role as pr,
	site as s,research_site as rs,research_site_module as rsm
	where p.personnel_id=spr.personnel_id and spr.personnel_role_id=pr.Personnel_role_id
	and spr.site_id=s.site_id and s.site_id=rs.site_id and rs.res_site_id=rsm.res_site_id
	and rsm.res_module_id=1 and rs.res_site_parent_id is null
	order by spr.site_id,spr.personnel_role_id

--ClimDB LTER data set and metadata contacts

select distinct s.site_code,'fullname'=rtrim(p.first_name)+' '+rtrim(p.middle_name)+' '+rtrim(p.last_name),email1
	from personnel as p, site_personnel_role as spr, personnel_role as pr,
	site as s,research_site as rs,research_site_module as rsm
	where p.personnel_id=spr.personnel_id and spr.personnel_role_id=pr.Personnel_role_id
	and spr.site_id=s.site_id and s.site_id=rs.site_id and rs.res_site_id=rsm.res_site_id
	and spr.res_module_id=1 and (spr.personnel_role_id=3 or spr.personnel_role_id=5)
	and rs.res_site_parent_id is null
	order by s.site_code,fullname,email1


select * res_site_id from research_site_module rsm where res_module_id=1
select *  from research_site_module

SELECT s.site_id,s.site_code,s.site_name
	from site as s,research_site as rs,research_site_module as rsm
	where s.site_id=rs.site_id and rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1 and rs.res_site_parent_id is null
	order by s.site_code

select b.site_id,b.personnel_id,'fullname'=rtrim(a.first_name)+' '+rtrim(a.middle_name)+' '+rtrim(a.last_name),  " & _
		" c.personnel_role_desc  " & _
		" from climdb..personnel as a, climdb..site_personnel_role as b, climdb..personnel_role as c,  " & _
		" climdb..site as d,climdb..research_site as e, climdb..research_site_module as f  " & _
		" where a.personnel_id=b.personnel_id and b.personnel_role_id=c.Personnel_role_id  " & _
		" and b.site_id=d.site_id and d.site_id=e.site_id and e.res_site_id=f.res_site_id  " & _
		" and f.res_module_id=1 and e.res_site_parent_id is null  " & _
		" order by b.site_id,b.personnel_role_id


INSERT INTO site_personnel_role
(site_id,personnel_id,personnel_role_id,res_module_id)
VALUES (7,58,1,3)

update site_personnel_role set personnel_role_id=5 
 where site_id=7 and personnel_id=58 and personnel_role_id=1 and res_module_id=3
