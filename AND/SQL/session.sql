select * from download order by datetime desc
select * from session order by datetime desc
select * from personnel order by last_name
select * from personnel_role
select * from site_personnel_role where personnel_id=88
update site_personnel_role set personnel_role_id=7 where personnel_id=144

select distinct ip_address from session order by datetime
select distinct date(datetime),ip_address from session order by datetime
select * from session where ip_address='  '

select distinct file_type from download
select * from download where file_type='test'
select * from download where session_id=117250
update download set file_type='tab' where file_type=' tab'

select file_type,count(*) from download group by file_type
select purpose,count(*) from session group by purpose

--Summaries
select * from download where datetime between '20090101' and '20091231' order by datetime desc
select * from session where datetime > '20060831' order by datetime desc
select max(datetime) from session
select file_type,count(*) from download where datetime > '20060831' group by file_type
select file_type,count(*) from download group by file_type
select year(datetime) as year,file_type,count(*) from download group by year(datetime),file_type order by file_type,year
select year(datetime),file_type,count(*) from download where year(datetime)=2009 group by year(datetime),file_type 
select requestor,purpose,count(*) from session where datetime > '20060831' group by requestor,purpose


--Statistics (last run on 9-15-2010)
--from Climdb at OSU; moved to LNO on 6-30-2010; so data from 2003 to end of June 2010
--begin with 7-1-2010 from LNO server
Total Downloads since inception of web site (2003): 
17,268 downloads
7865 data set downloaded
7329 plots created
2074 views of data

Downloads by year:
Year	files	plots	view
2003	309	1240	291
2004	267	566	98
2005	717	829	191
2006	1886	978	335
2007	946	816	210
2008	1259	888	347
2009	1150	946	281
2010	1331	1066	321

--The following are summarized from stats.sql
We have over 9 million daily values in our database.
333 measurement stations
26 LTER sites
3 ILTER sites
22 USFS sites
12 sites with USGS stations
21 total measurement parameters
