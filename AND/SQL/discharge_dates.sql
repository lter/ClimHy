select site_code,station,min(first_seen),max(most_recent) 
	from climdb_site_variable_dates where variable='DSCH' group by site_code,station

select site_code,min(first_seen) as first_seen,max(most_recent) as most_recent
	from climdb_site_variable_dates where variable='DSCH' group by site_code
	order by first_seen

select site_code,site_name,hydro_data_url,clim_data_url,usgs_data_url from site
select * from research_site_type