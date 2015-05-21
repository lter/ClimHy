--harvest_raw
select * from harvest_raw where variable='TMAX' and year(sampledate)='1992'
select distinct site_code,res_site_id,station from harvest_raw 
select count(*) from harvest_raw where site_code='BNZ'
update harvest_raw set res_site_id=45,site_id=1
  from climdb_raw a, climdb_site_variable_dates d
  where a.site_code=d.site_code and a.station=d.station and a.variable=d.variable
select * from research_site where site_id=25

--climdb_raw
select * from climdb_raw where site_code='PAL' and station='MFM' and sampledate>'20070730' order by sampledate,variable
select convert(varchar(12),AVG(convert(numeric,VALUE))) from climdb_raw where res_site_id=400 and variable='TMAX' and year(sampledate)='1992' and month(sampledate)='1'
select * into temp_kbs from climdb_raw where site_code='KBS' and station='Augusta'
select * from climdb_raw where res_site_id=82 group by res_site_id,site_id,site_code,station,sampledate,variable,value,flag,last_update having count(*)>1 
select * from climdb_raw where (res_site_id=376 or res_site_id=379) and sampledate>'2002-09-30' and sampledate<'2003-11-01' order by sampledate
select distinct site_code,res_site_id,station from climdb_raw where site_code='KBS' order by res_site_id
select res_site_id,site_id,site_code,station,min(sampledate) as firstdate,max(sampledate) as lastdate,variable from climdb_raw 
  where station='LTERWS' group by res_site_id,site_id,site_code,station,variable
  order by res_site_id,site_id,site_code,station,variable,sampledate
select distinct site_code,station,last_update from climdb_raw where last_update>'2003-03-02'
select distinct res_site_id,site_id,site_code,station,variable from climdb_raw where res_site_id=192 site_code='CAP' station='PH'
select distinct res_site_id,site_id,site_code,station,variable from climdb_raw where variable='WDIR'
   where site_id=46 order by res_site_id
  and variable='PREC' and value is null order by res_site_id
select min(convert(decimal(5,1),value)),variable from climdb_raw where variable='ATM'
select max(convert(decimal(10,1),value)) from climdb_raw where variable='DSCH'
select * from climdb_raw where variable='VAP'
select * from climdb_raw where site_code='CAP' and variable='TMAX' and convert(decimal(5,1),value)>50 and convert(decimal(5,1),value)<999
select distinct site_code,station,year(sampledate) as year,month(sampledate) as month 
  from climdb_raw 
  where site_code='SEV'
  order by station,year,month
select site_code,max(last_update)as lastd from climdb_raw group by site_code,station order by lastd desc
select distinct station from climdb_raw where site_code='BNZ'
select count(*) from climdb_raw where variable='RWDI'         res_site_id=192 and variable='PREC'
select * from climdb_raw where res_site_id=64 and convert(decimal(5,1),value)>100
select * from climdb_raw where site_id=4 and last_update<'2003-04-07'
  order by sampledate
select * from climdb_raw where res_site_id=204 and variable<>'DSCH'
select * from climdb_raw where site_code='JRN' and station='FISHER' and year(sampledate)=2002


update climdb_raw set value=convert(decimal(10,0),value) where variable='ATM'
update climdb_raw set value=null where variable='GRAD' and value='' and flag='M'
update climdb_raw set res_site_id=682 where res_site_id=66 and sampledate>'20070730'
update climdb_raw set res_site_id=87 where res_site_id=86 and variable='TMIN'
update climdb_raw set station='S2-UP-MS' where res_site_id=246
update climdb_raw set station='S2-BOG-MS' where res_site_id=247
update climdb_raw set station='MFM' where res_site_id=682
update climdb_raw set res_site_id=215, station='MS05' where res_site_id=204 and variable<>'DSCH'

delete climdb_raw where res_site_id=49
delete climdb_raw where site_id=4
delete climdb_raw where site_code='BNZ'
delete climdb_agg where site_code='BNZ'
delete climdb_site_variable_dates where site_code='BNZ'
delete climdb_raw  where res_site_id=376 and sampledate>'2002-09-30' and sampledate<'2003-11-01'
delete climdb_site_variable_dates where site_id=21 and value is null


select count(*) from climdb_raw
ALTER TABLE harvest_raw
	DROP CONSTRAINT PK_harvest_raw

BULK INSERT harvest_raw FROM '\\GINKGO\forwww\lter\climdb\data\BNZ1.out'
WITH (
DATAFILETYPE = 'char',
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)

ALTER TABLE harvest_raw
	ADD CONSTRAINT PK_harvest_raw
	PRIMARY KEY (res_site_id,sampledate,variable)

select * from harvest_raw where rec()=4079

--Data Completeness of Central Database
select  v.variable_name, count(*) as d_pts from climdb_variables v, climdb_raw r
  where v.variable=r.variable and r.flag='M'
  group by v.variable_name
  order by d_pts desc

select * from climdb_variables
select count(*) from climdb_raw
select * from 

select  c.descriptor_category_desc, count(r.value) as d_pts from climdb_variables v, climdb_raw r, descriptor_category c
  where v.variable=r.variable and v.descriptor_category_id=c.descriptor_category_id
  group by c.descriptor_category_desc
  order by d_pts desc

--climdb_agg
select * from climdb_agg where site_code='JRN' and station='S2_ALL'
select * from climdb_agg where (res_site_id=421 or res_site_id=467) and (month=99 or (year>2000 and year<2005)) and variable='PREC' order by year,month
select * from climdb_agg where res_site_id=403 and month=99 and variable='PREC'
select * from climdb_agg where res_site_id=203 and variable<>'DSCH'
select * from climdb_agg where site_id=523 and variable='PREC' and month='99' and aggregate_type='MEAN'
select * from climdb_agg where last_update>'2003-02-17'
select distinct site_code,station,variable,aggregate_type,last_update from climdb_agg where last_update>'2003-02-17'
select * from climdb_agg where variable='ATM' and convert(decimal(5,1),value)<1
select distinct site_code,station from climdb_agg where variable='PREC'
select distinct site_code,station from climdb_agg where site_id is null
select distinct site_code,res_site_id,station from climdb_agg where site_code='LUQ'
select * from climdb_agg where year>1990 and year<1996 and
 ((site_code='CAS' and station='NFC408' and variable='PREC')
  or (site_code='AND' and station='PRIMET' and variable='PREC'))
  order by year,month
select count(*) from climdb_agg
delete climdb_agg where res_site_id=49
update climdb_agg set res_site_id=320 where res_site_id=319
  where site_code='JRN' and station='LTERWS'
update climdb_agg set station='S2Bog' where site_code='MAR' and station='S2_BOG'
update climdb_agg set res_site_id=87 where res_site_id=86
update climdb_agg set res_site_id=216, station='MS25' where res_site_id=203 and variable<>'DSCH'

truncate table climdb_agg

--climdb_site_variable_dates
select * from  climdb_site_variable_dates where res_site_id=376 or res_site_id=379
select * from  climdb_site_variable_dates where site_code='JRN' order by station and station='FISHER'
select distinct variable from  climdb_site_variable_dates
select distinct site_code,res_site_id,station from climdb_site_variable_dates where site_code='KBS' order by res_site_id
select * from  climdb_site_variable_dates where variable='GRAD' or variable='SM' or variable='ATM' or variable='VAP' or variable='SNOW'
select climdb_site_variable_dates.*,research_site.res_site_id as res_site_id into climb_site_variables 
  from climdb_site_variable_dates 
  left join research_site on 
  research_site.res_site_code=climdb_site_variable_dates.station
  and research_site.site_id=climdb_site_variable_dates.site_id
  and research_site.res_sitetype_id>2 
select * from climdb_site_variable_dates where site_code='JRN'
select * from climdb_site_variable_dates where res_site_id=404
select * from climdb_site_variables where variable not in (select variable from 
select climb_site_variables.*,climdb_site_variable_dates.site_code,climdb_site_variable_dates.station, 
  climdb_site_variable_dates.variable from climb_site_variables left join climdb_site_variable_dates on 
  climb_site_variables.site_code=climdb_site_variable_dates.site_code
  and climb_site_variables.station=climdb_site_variable_dates.station
  and climb_site_variables.variable=climdb_site_variable_dates.variable
select *site_code,station,variable,count(*) from  climb_site_variables group by site_code,station,variable having count(*)>1
select count(*) from climdb_site_variable_dates

delete climdb_site_variable_dates where res_site_id=49
update climdb_site_variable_dates set station='MS05' where res_site_id=215  
update climdb_site_variable_dates set res_site_id=379 where res_site_id=376 and variable<>'DSCH'
update climdb_site_variable_dates set station='S2Bog' where site_code='MAR' and station='S2_BOG'
update climdb_site_variable_dates set res_site_id=(select distinct research_site.res_site_id from research_site,climdb_site_variable_dates
  where research_site.res_site_code=climdb_site_variable_dates.station
  and research_site.site_id=climdb_site_variable_dates.site_id
  and research_site.res_sitetype_id>2)

update climdb_site_variable_dates set res_site_id=204 where res_site_id=201


select * from aggregate_type
select * from climdb_variables
select * from research_site where site_id=7



select * from climdb_raw where variable='WMIN' and convert(decimal(10,0),value) not between 0 and 40
update climdb_raw set value=null, flag='M' where variable='SMAX' and convert(decimal(10,0),value) not between 0 and 33

select * from climdb_raw where variable='SMAX' and flag='M' and last_update>'2003-2-25'
select * from climdb_raw where site_code='KNZ' and station='HQ1MET' and sampledate='2001-02-19' and variable='SMAX'
select * from climdb_raw where convert(decimal(10,0),value) not between -60 and 50
select distinct variable from climdb_raw where value='-9999'



delete research_site where res_site_id=49
select * from research_site_descriptor where res_site_id=49