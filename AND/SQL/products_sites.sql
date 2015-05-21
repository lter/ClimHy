--2. Sites: selects contributing sites with oldest and newest dates of any variable from any station and most recent update.

--for all sites (no research module)
--creating site names and dates temp table (table 1)
drop table #all_sites
select vd.site_code, s.site_name,
  convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, 
  convert(character(12),max(vd.last_update),110) as last_update
  into #all_sites  
  from climdb_site_variable_dates vd, site s
  where vd.site_code=s.site_code
  group by vd.site_code,s.site_name order by vd.site_code
select * from #all_sites

--count met stns (table 2)
drop table #metstn
select vd.site_code, count(distinct(res_site_id)) as ms_stns into #metstn  
  from climdb_site_variable_dates vd
  where res_site_id in (select vd.res_site_id from climdb_site_variable_dates vd,research_site_sitetype st
     where vd.res_site_id=st.res_site_id and st.res_sitetype_id=4)
  group by vd.site_code order by vd.site_code
select * from #metstn

--count gs stns (table 3)
drop table #gsstn
select vd.site_code, count(distinct(res_site_id)) as gs_stns into #gsstn  
  from climdb_site_variable_dates vd
  where res_site_id in (select vd.res_site_id from climdb_site_variable_dates vd,research_site_sitetype st
    where vd.res_site_id=st.res_site_id and st.res_sitetype_id=3)
    group by vd.site_code order by vd.site_code
select * from #gsstn

--3-way join
select #all_sites.site_code,#all_sites.site_name,isnull(#metstn.ms_stns,0) as ms_stns,isnull(#gsstn.gs_stns,0) as gs_stns,
  #all_sites.first_seen,#all_sites.most_recent,#all_sites.last_update
  from #all_sites left join #metstn on #all_sites.site_code=#metstn.site_code
  left join #gsstn on #all_sites.site_code=#gsstn.site_code

------------------------------------------------------------------------------------------------------------
--for LTER or USFS sites (change res_module_id in first two queries)
--count met stns (table 1)
drop table #metstn
select vd.site_code, s.site_name,
  count(distinct(res_site_id)) as stns,
  convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, 
  convert(character(12),max(vd.last_update),110) as last_update
  into #metstn  
  from climdb_site_variable_dates vd, site s
  where res_site_id in (select vd.res_site_id 
from climdb_site_variable_dates vd,research_site_sitetype st
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=4)
  and vd.site_code in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1 and rs.res_site_parent_id is null)
  and vd.site_code=s.site_code
    group by vd.site_code,s.site_name order by vd.site_code

--count gs stns (table 2)
drop table #gsstn
select vd.site_code, s.site_name,count(distinct(res_site_id)) as gs_stns,convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, convert(character(12),max(vd.last_update),110) as last_update
  into #gsstn  
  from climdb_site_variable_dates vd, site s
  where res_site_id in (select vd.res_site_id from climdb_site_variable_dates vd,research_site_sitetype st
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=3)
  and vd.site_code in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1 and rs.res_site_parent_id is null)
  and vd.site_code=s.site_code
    group by vd.site_code,s.site_name order by vd.site_code


--join for LTER (table 3 for module=1)
select ms.site_code, ms.site_name,isnull(ms.ms_stns,0) as ms_stns,isnull(gs.gs_stns,0) as gs_stns,
ms.first_seen,
ms.most_recent,
ms.last_update
  from #metstn ms left join #gsstn gs on gs.site_code=ms.site_code


--join for USFS (table 3 for module=2)
select gs.site_code, gs.site_name,gs.gs_stns as gs_stns,isnull(ms.stns,0) as met_stns,
gs.first_seen,
gs.most_recent,
gs.last_update
  from #gsstn gs left join #metstn ms on gs.site_code=ms.site_code


------------------------------------------------------------------------------------------------------------
--USGS (module 3)
select vd.site_code, s.site_name,
  count(distinct(res_site_id)) as gs_stns,
  convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, 
  convert(character(12),max(vd.last_update),110) as last_update
  from climdb_site_variable_dates vd, site s
  where res_site_id in (select vd.res_site_id from climdb_site_variable_dates vd,research_site_sitetype st
    where vd.res_site_id=st.res_site_id and st.res_sitetype_id=3)
  and res_site_id in (select rsm.res_site_id from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=3)
  and vd.site_code in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=3 and rs.res_site_parent_id is null)
  and vd.site_code=s.site_code
    group by vd.site_code,s.site_name order by vd.site_code

