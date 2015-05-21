select * from personnel_mailing_list where mailing_list_id=3
select * from mailing_list

--based on mailing list
--some personnel appear twice because of association with two sites;
--for unique mailing list use second query.
select distinct pml.personnel_id,p.email1,p.last_name,s.site_code 
  from site_personnel_role spr, personnel p, site s, personnel_mailing_list pml 
  where spr.personnel_id=p.personnel_id and pml.personnel_id=p.personnel_id 
    and spr.site_id=s.site_id and pml.mailing_list_id=2
  order by p.email1
--unique mailinglist
select distinct pml.personnel_id,p.email1,p.last_name
  from personnel p, personnel_mailing_list pml 
  where pml.personnel_id=p.personnel_id and pml.mailing_list_id=2
  order by p.email1


--based on research module
select distinct spr.personnel_id,p.last_name,s.site_code 
  from site_personnel_role spr, personnel p, site s 
  where spr.personnel_id=p.personnel_id and spr.site_id=s.site_id and res_module_id=2
order by s.site_code,p.last_name

--based on research module and personnel role
select distinct spr.personnel_id,p.last_name,s.site_code from site_personnel_role spr, personnel p, site s  
  where spr.personnel_id=p.personnel_id and spr.site_id=s.site_id and res_module_id=2 
  and (personnel_role_id=3 or personnel_role_id=5) 
order by s.site_code,p.last_name

SELECT email1 FROM personnel p,personnel_mailing_list l
WHERE l.mailing_list_id=2 AND l.personnel_id = p.personnel_id

select * from personnel where email1 = 'aellsworth@fs.fed.us '


<--Need to zap personnel_mailing_list to insert info
delete personnel_mailing_list where mailing_list_id=2

<--Once updated need to update maillist files-->
<-------set defa to g:\metadatabase\maillist-->
<-------do climhymail-->

<--use this to insert hydrodb (mailing_list_id=1) data contacts-->
insert into personnel_mailing_list (mailing_list_id,personnel_id) 
 select distinct '1', personnel_id from site_personnel_role 
 where res_module_id=2 and (personnel_role_id=3 or personnel_role_id=5)
<--use this to update hydrodb-->
update personnel_mailing_list set mailing_list_id=1,personnel_id=(select distinct personnel_id
from site_personnel_role where res_module_id=2 and (personnel_role_id=3 or personnel_role_id=5))

<--use this to insert hydrodb_all (mailing_list_id=2) all personnel-->
insert into personnel_mailing_list (mailing_list_id,personnel_id) 
 select distinct '2', personnel_id from site_personnel_role where res_module_id=2
<--use this to update hydrodb_all-->
update personnel_mailing_list set mailing_list_id=2,personnel_id=(select distinct personnel_id
from site_personnel_role where res_module_id=2)

<--use this to insert climdb (mailing_list_id=3) data contacts-->
insert into personnel_mailing_list (mailing_list_id,personnel_id) 
 select distinct '3', personnel_id from site_personnel_role 
 where res_module_id=1 and (personnel_role_id=3 or personnel_role_id=5)
<--use this to update climdb-->
update personnel_mailing_list set mailing_list_id=3,personnel_id=(select distinct personnel_id
from site_personnel_role where res_module_id=1 and (personnel_role_id=3 or personnel_role_id=5))

<--use this to insert climdb_all (mailing_list_id=4) all personnel-->
insert into personnel_mailing_list (mailing_list_id,personnel_id) 
 select distinct '4', personnel_id from site_personnel_role where res_module_id=1
<--use this to update climdb_all-->
update personnel_mailing_list set mailing_list_id=4,personnel_id=(select distinct personnel_id
from site_personnel_role where res_module_id=1)

_________________________________________________________________
insert into personnel_mailing_list (mailing_list_id,personnel_id) 
 select distinct '1', personnel_id
 from site_personnel_role where res_module_id=2

delete personnel_mailing_list where mailing_list_id=2




