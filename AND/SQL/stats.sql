--total measurement stations
select distinct res_site_id from climdb_raw order by res_site_id
select distinct res_site_id,site_code,station from climdb_site_variable_dates order by site_code,station
--total measurement parameters
select distinct variable from climdb_raw
--total daily values
select count(*) from climdb_raw
--number of met stations (total)
select distinct vd.res_site_id,vd.station,vd.site_code 
  from climdb_raw vd,research_site_sitetype st 
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=4
  ORDER BY vd.site_code,vd.station
--number of met stations by module
--number of LTER met stations (does include the cross-over stations; 6 LTER sites)
select distinct vd.res_site_id,vd.station,vd.site_code 
  from climdb_raw vd,research_site_sitetype st, research_site_module rsm
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=4
  and vd.res_site_id=rsm.res_site_id and rsm.res_module_id=1
  ORDER BY vd.site_code,vd.station
--number of LTER met stations (does not include the cross-over stations; 6 LTER sites)
select distinct vd.res_site_id,vd.station,vd.site_code 
  from climdb_raw vd,research_site_sitetype st, research_site_module rsm
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=4
  and vd.res_site_id=rsm.res_site_id and rsm.res_module_id=1
  and vd.res_site_id not in 
 (select res_site_id from research_site_module where res_module_id=2)
  ORDER BY vd.site_code,vd.station
--number of LTER met stations (cross-over stations only; 6 LTER sites)
select distinct vd.res_site_id,vd.station,vd.site_code 
  from climdb_raw vd,research_site_sitetype st, research_site_module rsm
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=4
  and vd.res_site_id=rsm.res_site_id and rsm.res_module_id=1
  and vd.res_site_id in 
 (select res_site_id from research_site_module where res_module_id=2)
  ORDER BY vd.site_code,vd.station
--number of USFS met stations (does include the cross-over stations; 6 LTER sites)
select distinct vd.res_site_id,vd.station,vd.site_code 
  from climdb_raw vd,research_site_sitetype st, research_site_module rsm
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=4
  and vd.res_site_id=rsm.res_site_id and rsm.res_module_id=2
  ORDER BY vd.site_code,vd.station
--number of USFS met stations (does not include the cross-over stations; 6 LTER sites)
select distinct vd.res_site_id,vd.station,vd.site_code 
  from climdb_raw vd,research_site_sitetype st, research_site_module rsm
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=4
  and vd.res_site_id=rsm.res_site_id and rsm.res_module_id=2
  and vd.res_site_id not in 
 (select res_site_id from research_site_module where res_module_id=1)
  ORDER BY vd.site_code,vd.station
--number of gauging stations (total)
select distinct vd.res_site_id,vd.site_code,vd.station 
  from climdb_raw vd,research_site_sitetype st
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=3 
  ORDER BY vd.site_code,vd.station
--number of non-USGS gauging stations
select distinct vd.res_site_id,vd.site_code,vd.station from climdb_raw vd,research_site_sitetype st
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=3 
  and vd.res_site_id not in 
  (select res_site_id from research_site_module where res_module_id=3)
--number of gauging stations by module
--number of USFS gauging stations (total)
select distinct vd.res_site_id,vd.site_code,vd.station 
  from climdb_raw vd,research_site_sitetype st, research_site_module rsm
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=3 
  and vd.res_site_id=rsm.res_site_id and rsm.res_module_id=2
  ORDER BY vd.site_code,vd.station
--number of USFS gauging stations (does not include USGS stations or the cross-over stations; 6 LTER sites)
select distinct vd.res_site_id,vd.site_code,vd.station 
  from climdb_raw vd,research_site_sitetype st, research_site_module rsm
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=3 
  and vd.res_site_id=rsm.res_site_id and rsm.res_module_id=2
  and vd.res_site_id not in 
 (select res_site_id from research_site_module where res_module_id=3 or res_module_id=1)
  ORDER BY vd.site_code,vd.station
--number of USFS gauging stations (does not include USGS stations, but does include cross-over stations)
select distinct vd.res_site_id,vd.site_code,vd.station 
  from climdb_raw vd,research_site_sitetype st, research_site_module rsm
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=3 
  and vd.res_site_id=rsm.res_site_id and rsm.res_module_id=2
  and vd.res_site_id not in 
 (select res_site_id from research_site_module where res_module_id=3)
  ORDER BY vd.site_code,vd.station
--number of USFS stations that are USGS gauges
select distinct vd.res_site_id,vd.site_code,vd.station 
  from climdb_raw vd,research_site_sitetype st, research_site_module rsm
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=3 
  and vd.res_site_id=rsm.res_site_id and rsm.res_module_id=3
  and vd.res_site_id in 
 (select res_site_id from research_site_module where res_module_id=2)
  ORDER BY vd.site_code,vd.station
--number of LTER gauging stations (total)
select distinct vd.res_site_id,vd.site_code,vd.station 
  from climdb_raw vd,research_site_sitetype st, research_site_module rsm
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=3 
  and vd.res_site_id=rsm.res_site_id and rsm.res_module_id=1
  ORDER BY vd.site_code,vd.station
--number of USGS stations
select distinct vd.res_site_id,vd.site_code,vd.station 
  from climdb_raw vd,research_site_sitetype st,research_site_module rsm 
  where vd.res_site_id=st.res_site_id and vd.res_site_id=rsm.res_site_id and st.res_sitetype_id=3 
    and rsm.res_module_id=3 order by vd.site_code,vd.station
--main parameters measured
select distinct variable, count(variable) from climdb_raw group by variable order by count(variable) desc
--total number of sites
select distinct cr.site_code from climdb_site_variable_dates cr,research_site rs,research_site_module rsm
  where rs.res_site_id=cr.res_site_id and rs.res_site_id=rsm.res_site_id order by cr.site_code
--number of LTER sites (includes ILTER)
select distinct cr.site_code from climdb_site_variable_dates cr,research_site rs,research_site_module rsm
  where rs.res_site_id=cr.res_site_id and rs.res_site_id=rsm.res_site_id and rsm.res_module_id=1
--number of USFS sites
select distinct cr.site_code from climdb_site_variable_dates cr,research_site rs,research_site_module rsm
  where rs.res_site_id=cr.res_site_id and rs.res_site_id=rsm.res_site_id and rsm.res_module_id=2
--number of sites with USGS gauging stations
select distinct cr.site_code from climdb_site_variable_dates cr,research_site rs,research_site_module rsm
  where rs.res_site_id=cr.res_site_id and rs.res_site_id=rsm.res_site_id and rsm.res_module_id=3

select * from climdb_site_variable_dates where site_code='HBR'
select * from research_site where site_id=14
select rsm.res_module_id,rs.res_site_code from research_site_module rsm,research_site rs,climdb_raw cr 
  where rs.res_site_id=rsm.res_site_id and rs.site_id=14 and rs.res_site_id=cr.res_site_id

--participants
SELECT vd.site_code, 
	s.site_name,
	CONVERT(character(12),min(vd.first_seen),110) as first_seen,
	CONVERT(character(12),max(vd.most_recent),110) as most_recent, 
	CONVERT(character(12),max(vd.last_update),110) as last_update
INTO #all_sites  
FROM climdb_site_variable_dates vd, site s
WHERE vd.site_code=s.site_code
GROUP BY vd.site_code,s.site_name 
ORDER BY vd.site_code

select vd.site_code, count(distinct(res_site_id)) as ms_stns 
into #metstn  
  from climdb_site_variable_dates vd
  where res_site_id in (select vd.res_site_id from climdb_site_variable_dates vd,research_site_sitetype st
     where vd.res_site_id=st.res_site_id and st.res_sitetype_id=4)
  group by vd.site_code order by vd.site_code

select vd.site_code, count(distinct(res_site_id)) as gs_stns 
into #gsstn  
  from climdb_site_variable_dates vd
  where res_site_id in (select vd.res_site_id from climdb_site_variable_dates vd,research_site_sitetype st
    where vd.res_site_id=st.res_site_id and st.res_sitetype_id=3)
    group by vd.site_code order by vd.site_code

select #all_sites.site_code,#all_sites.site_name,isnull(#metstn.ms_stns,0) as ms_stns,isnull(#gsstn.gs_stns,0) as gs_stns,
  #all_sites.first_seen,#all_sites.most_recent,#all_sites.last_update
  from #all_sites left join #metstn on #all_sites.site_code=#metstn.site_code
  left join #gsstn on #all_sites.site_code=#gsstn.site_code

