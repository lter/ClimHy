select * from climdb_site_variable_dates where last_update is null

where site_code='GCE'
update climdb_site_variable_dates set last_update='2000-06-01' where last_update is null

where last_update>'2002-01-01'


select * from climdb_raw where last_update is null
where site_code='GCE'
update climdb_raw set last_update='2000-06-01' where last_update is null