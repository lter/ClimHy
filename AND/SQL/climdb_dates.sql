select * from research_site
select * from climdb_site_variable_dates where site_id=28
select * from  climdb_site_variable_dates where site_code='GRE' and variable='PREC' and res_site_id between 608 and 622
select * from  climdb_agg where site_code='GRE' and variable='PREC' and res_site_id between 608 and 622
select * from  climdb_raw where site_code='GRE' and variable='PREC' and res_site_id between 608 and 622


--update climdb_site_variable_dates set res_site_id=236 where res_site_id=246 and variable='DSCH'
--DELETE climdb_site_variable_dates where site_code='JRN' and variable='PREC' and res_site_id between 608 and 622
--delete climdb_agg where site_code='JRN' and variable='PREC' and res_site_id between 608 and 622
--delete climdb_raw where site_code='JRN' and variable='PREC' and res_site_id between 608 and 622

--Renewing climdb_site_variable_dates
select * into dates_temp from climdb_site_variable_dates 
select * from dates_temp
--DELETE climdb_site_variable_dates

--INSERT INTO climdb_site_variable_dates 
 SELECT  res_site_id,
	 site_id,
	 site_code,
	 station,variable, 
     min(sampledate) AS first_seen,
     max(sampledate) AS most_recent,
     max(last_update) AS last_update
 FROM climdb_raw
 WHERE 
res_site_id in (SELECT distinct res_site_id FROM climdb_raw where site_id=17)
 GROUP BY site_code,station,variable,site_id,res_site_id

select * from climdb_site_variable_dates 
