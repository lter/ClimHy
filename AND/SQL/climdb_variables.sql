select * from climdb_variables

select * from climdb_raw where variable='WDIR' and value is not null
update climdb_raw set value=null, flag='M' where variable='SMAX' and convert(decimal(10,0),value) not between 0 and 33

select * from climdb_raw where variable='SMAX' and flag='M' and last_update>'2003-2-25'
select * from climdb_raw where site_code='KNZ' and station='HQ1MET' and sampledate='2001-02-19' and variable='SMAX'
select * from climdb_raw where convert(decimal(10,0),value) not between -60 and 50
select distinct variable from climdb_raw where value='-9999'

select * from masterdate


