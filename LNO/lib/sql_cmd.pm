use strict;
# each sqlcmd in the FUNDME package has a number associated with it.
# harvest numbers 1 - 9
# ingest numbers 11-99
# siteDB/sitePDF numbers 100 - 199
# digest numbers 200 - 299
# plot numbers 300 - 399
# chump numbers 400 - 499
# products numbers 500-599
# web service numbers 600-699
# variable_desc numbers 700-701
# get_cmd is one long SWITCH control
#
# This connects to rocky\lter
# using the schema as of 11-24-2003

sub get_cmd{
my @which = @_;
my $sqlcmd;

# sql commands for harvest 

SWITCH: {
	if ($which[0] =~ /^1$/) {
		my $data_url = $which[1];
$sqlcmd = 
"SELECT distinct s.site_code, rsd.descriptor_value 
FROM site s,
research_site_descriptor rsd,
research_site r
WHERE s.site_id = r.site_id 
AND r.res_site_id = rsd.res_site_id 
AND rsd.descriptor_type_id = $data_url";
		last SWITCH; }

	if ($which[0] =~ /^2$/) {
		my $data_url = $which[1];
		my $module = $which[2];
$sqlcmd = 
"SELECT distinct s.site_code, s.site_name 
FROM site s,
research_site_module m,
research_site r
WHERE s.site_id = r.site_id 
AND r.res_site_id = m.res_site_id ";
		last SWITCH; }

	if ($which[0] =~ /^3$/) {
		my $site = $which[1];
		my $module = $which[2];
$sqlcmd = 
"SELECT p.email1, p.first_name, p.last_name 
FROM personnel p,
site_personnel_role r,
site s
WHERE p.email1 != 'null' AND s.site_id = r.site_id
AND r.personnel_id = p.personnel_id AND s.site_code = '$site' 
AND r.personnel_role_id = '3' AND r.res_module_id = '$module'";

		last SWITCH; }
	
# sql commands for ingestion

	if ($which[0] =~ /^11$/) {
$sqlcmd = 
	'SELECT variable_name, variable 
	FROM climdb_variables';

		last SWITCH; }
	
	if ($which[0] =~ /^12$/) {
		my $site_code = $which[1];
$sqlcmd = 
	"SELECT site_id, site_name,	site_code
	FROM site
	WHERE site_code = '$site_code'";

		last SWITCH; }

	if ($which[0] =~ /^13$/) {
		my $res_site_code = $which[1];
		my $site_id = $which[2];
$sqlcmd = 
	"SELECT r.res_site_id, st.res_sitetype_id, r.res_site_code, r.site_id
	FROM research_site r, research_site_sitetype st
	WHERE r.res_site_code = '$res_site_code' AND
		r.res_site_id=st.res_site_id AND
		st.res_sitetype_id>2 AND
		r.site_id = '$site_id'";

		last SWITCH; }

	if ($which[0] =~ /^14$/) {

$sqlcmd = 
'SELECT variable, QC_MIN, QC_MAX, descriptor_category_id 
FROM climdb_variables';

		last SWITCH; }
	
	if ($which[0] =~ /^15$/) {
		my $what = $which[1];
		my $category = $which[2];
		my $res_site_id = $which[3];
$sqlcmd = 
"SELECT r.descriptor_value, t.descriptor_type_code
FROM research_site_descriptor r,
descriptor_type t,
descriptor_category_type c
WHERE r.descriptor_type_id = t.descriptor_type_id AND 
t.descriptor_type_id = c.descriptor_type_id AND
t.descriptor_type_code like '%$what' AND 
c.descriptor_category_id = '$category' AND 
r.res_site_id = '$res_site_id'" ;

		last SWITCH; }
	
# sql commands for siteDB.pl
	
	if ($which[0] =~ /^101$/) {
$sqlcmd = 
	"SELECT s.site_id, 
		s.site_name,
		s.site_code
	FROM site s, 
		research_site r,
		research_site_module m 
	WHERE s.site_id=r.site_id AND 
		r.res_site_id = m.res_site_id 
	order by s.site_name";
		last SWITCH; }

	if ($which[0] =~ /^102a$/) {
$sqlcmd = 
	"SELECT c.descriptor_category_id, 
		c.descriptor_category_desc,
		c.descriptor_order
	FROM descriptor_category c,
		research_module_descriptor b
	WHERE c.descriptor_category_id=b.descriptor_category_id 
	order by c.descriptor_order";
		last SWITCH; }
	
	if ($which[0] =~ /^102b$/) {
		my $site_id = $which[1];
$sqlcmd = 
	"SELECT site_name 
	FROM site
	WHERE site_id='$site_id'";
		last SWITCH; }
	
	if ($which[0] =~ /^102c$/) {
		my $descriptor_category_id = $which[1];
$sqlcmd = 
	"SELECT descriptor_category_desc 
	FROM descriptor_category
	WHERE descriptor_category_id ='$descriptor_category_id'";
		last SWITCH; }

	if ($which[0] =~ /^103$/) {
		my $descriptor_category_id = $which[1];
$sqlcmd = 
	"SELECT res_sitetype_id 
	FROM sitetype_descriptor_category
	WHERE descriptor_category_id = $descriptor_category_id";
		last SWITCH; }
	
	if ($which[0] =~ /^104$/) {
		shift;
		my $site_id = shift;
		my @res_sitetype_id = @_;
		my $string = "(st.res_sitetype_id = $res_sitetype_id[0] ";
		for (my $i=1; $i<=$#res_sitetype_id; $i++) {
			$string .= "OR st.res_sitetype_id = $res_sitetype_id[$i] ";}
$sqlcmd = 
	"SELECT r.res_site_id, r.res_site_code
	FROM research_site r, research_site_sitetype st
	WHERE r.site_id=$site_id AND 
		r.res_site_id=st.res_site_id AND
		$string )
	order by r.res_site_code";
		last SWITCH; }
	
	if ($which[0] =~ /^105$/) {
		my $descriptor_category_id= $which[1];
$sqlcmd = 
	"SELECT descriptor_category_desc 
	FROM descriptor_category 
	WHERE descriptor_category_id = $descriptor_category_id";
		last SWITCH; }
	
	if ($which[0] =~ /^106a$/) {
		my $descriptor_category_id = $which[1];
$sqlcmd = 
	"SELECT descriptor_type_id 
	FROM descriptor_category_type
	WHERE descriptor_category_id=$descriptor_category_id
	ORDER BY type_order	";
		last SWITCH; }
	
	if ($which[0] =~ /^106b$/) {
		my $res_site_id = $which[1];
		my $descriptor_type_id = $which[2];
$sqlcmd = 
	"SELECT count(res_site_id) 
	FROM research_site_descriptor
	WHERE res_site_id=$res_site_id AND 
	descriptor_type_id = $descriptor_type_id";
		last SWITCH; }
	
	if ($which[0] =~ /^106c$/) {
		my $res_site_id = $which[1];
$sqlcmd = 
	"SELECT res_site_code 
	FROM research_site
	WHERE res_site_id=$res_site_id";
		last SWITCH; }
	
	if ($which[0] =~ /^107$/) {
		my $res_site_id = $which[1];
		my $site_id = $which[2];
		my $descriptor_category_id = $which[3];
$sqlcmd = 
	"INSERT research_site_descriptor
	(res_site_id,site_id,descriptor_type_id)
		SELECT r.res_site_id,r.site_id,b.descriptor_type_id
		FROM research_site r, descriptor_category_type b
		WHERE r.res_site_id=$res_site_id AND site_id=$site_id AND 
			b.descriptor_category_id=$descriptor_category_id"; 
		last SWITCH; }
	
	if ($which[0] =~ /^108$/) {
		my $res_site_id = $which[1];
		my $descriptor_category_id = $which[2];
	
$sqlcmd = 
	"SELECT a.descriptor_type_id, a.descriptor_type_desc,
		a.descriptor_type_name,
		a.descriptor_type_length, ltrim(rtrim(b.descriptor_value)),
		a.descriptor_type_unit
	FROM descriptor_type a, research_site_descriptor b, descriptor_category_type c
	WHERE b.res_site_id=$res_site_id AND 
		a.descriptor_type_id=b.descriptor_type_id AND
		b.descriptor_type_id=c.descriptor_type_id AND
		a.descriptor_type_id in (
			SELECT descriptor_type_id 
			FROM descriptor_category_type
			WHERE descriptor_category_id=$descriptor_category_id)
		ORDER BY c.type_order";
		last SWITCH; }
	
	if ($which[0] =~ /^109$/) {
		my $update = $which[1];
		my $res_site_id = $which[2];
		my $id = $which[3];
$sqlcmd = 
	"UPDATE research_site_descriptor
	SET descriptor_value='$update',
		last_update = getdate()
	WHERE res_site_id=$res_site_id AND descriptor_type_id='$id'";
		last SWITCH; }
	
	if ($which[0] =~ /^110$/) {
		my $descriptor_category_id = $which[1];
$sqlcmd = 
	"SELECT d.descriptor_type_id, d.descriptor_type_name
	FROM descriptor_type d, descriptor_category_type c
	WHERE d.descriptor_type_id = c.descriptor_type_id AND
		c.descriptor_category_id = '$descriptor_category_id'
	";
		last SWITCH; }
	
	if ($which[0] =~ /^111$/) {
		my $update_hash = $which[1];
		my $site_id = $which[2];
$sqlcmd = 
	"UPDATE site
	SET data_url = '$update_hash'
	WHERE site_id=$site_id";
		last SWITCH; }

# extra commands for sitePDF.pl

	if ($which[0] =~ /^150$/) {
		my $site_id = $which[1];
$sqlcmd = 
	"SELECT rtrim(site_code), rtrim(site_name), rtrim(loc1), 
			rtrim(loc2), rtrim(latitude_dec), rtrim(longitude_dec), 
			rtrim(site_url)
	FROM site
	WHERE site_id=$site_id";
		last SWITCH; }

	if ($which[0] =~ /^151$/) {
		shift;
		my $site_id = shift;
		my $res_sitetype_id = shift;
$sqlcmd = 
	"SELECT r.res_site_id, r.res_site_code, rtrim(r.res_site_name)
	FROM research_site r, research_site_sitetype st
	WHERE r.site_id=$site_id AND 
		r.res_site_id=st.res_site_id AND
		st.res_sitetype_id = $res_sitetype_id
	ORDER BY r.res_site_code";
		last SWITCH; }
		
	if ($which[0] =~ /^152$/) {
		my $res_sitetype_id = $which[1];
$sqlcmd = 
	"SELECT dc.descriptor_category_id, 
		rtrim(dc.descriptor_category_desc),
		dc.descriptor_order
	FROM descriptor_category dc,
	sitetype_descriptor_category sdc
	WHERE sdc.res_sitetype_id = $res_sitetype_id AND
		dc.descriptor_category_id = sdc.descriptor_category_id";
		last SWITCH; }

	if ($which[0] =~ /^153$/) {
		my $res_site_id = $which[1];
		my $descriptor_category_id = $which[2];
$sqlcmd = 
"SELECT  count(b.descriptor_value)
	FROM descriptor_type a, 
		research_site_descriptor b, 
		descriptor_category_type c
	WHERE b.res_site_id=$res_site_id AND 
		a.descriptor_type_id=b.descriptor_type_id AND
		b.descriptor_type_id=c.descriptor_type_id AND
		a.descriptor_type_id in (SELECT descriptor_type_id 
	FROM descriptor_category_type
	WHERE descriptor_category_id=$descriptor_category_id)";
		last SWITCH; }

	if ($which[0] =~ /^154$/) {
		my $res_site_id = $which[1];
		my $res_sitetype_id = $which[2];
$sqlcmd = 
"SELECT COUNT(rsd.descriptor_value)
FROM sitetype_descriptor_category sdc,
	research_site_descriptor rsd,
	research_site_sitetype rss
WHERE rsd.res_site_id = $res_site_id AND
	rsd.res_site_id = rss.res_site_id AND
	rss.res_sitetype_id = sdc.res_sitetype_id AND
	sdc.res_sitetype_id = $res_sitetype_id AND
	rsd.descriptor_value != 'null'";
		last SWITCH;}
	
# sql commands for digestion
	
	if ($which[0] =~ /^201$/) {
$sqlcmd = 
	"TRUNCATE TABLE harvest_raw";
		last SWITCH; }
	
	if ($which[0] =~ /^202$/) {
$sqlcmd = 
	"ALTER TABLE harvest_raw
	DROP CONSTRAINT PK_harvest_raw";
		last SWITCH; }

	if ($which[0] =~ /^203$/) {
$sqlcmd = 
"BULK INSERT harvest_raw FROM '$which[1]'
WITH (
DATAFILETYPE = 'char',
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)";
		last SWITCH; }
	
	if ($which[0] =~ /^204$/) {
$sqlcmd = 
	"select distinct site_code,station,sampledate from harvest_raw
  	  group by site_code,station,sampledate,variable
  	  having count(*)>1";
		last SWITCH; }
	
	if ($which[0] =~ /^205$/) {
$sqlcmd = 
	"ALTER TABLE harvest_raw
	ADD CONSTRAINT PK_harvest_raw
	PRIMARY KEY (res_site_id,sampledate,variable)";
		last SWITCH; }

# see note in xdigest.pm
	if ($which[0] =~ /^205a$/) {
		my $station = $which[1];
$sqlcmd = 
	"DELETE harvest_raw
	WHERE station='$station'";
		last SWITCH; }
	
	if ($which[0] =~ /^206$/) {
$sqlcmd = 
"UPDATE climdb_raw
SET	climdb_raw.value=harvest_raw.value,
	climdb_raw.flag=harvest_raw.flag,
	climdb_raw.last_update=getdate()
FROM climdb_raw INNER JOIN harvest_raw
	ON climdb_raw.site_code = harvest_raw.site_code
		AND climdb_raw.site_id = harvest_raw.site_id
		AND climdb_raw.res_site_id = harvest_raw.res_site_id
		AND climdb_raw.station = harvest_raw.station
		AND climdb_raw.variable = harvest_raw.variable
		AND climdb_raw.sampledate = harvest_raw.sampledate";
		last SWITCH; }


	if ($which[0] =~ /^207$/) {
$sqlcmd = 
"DELETE climdb_site_variable_dates WHERE res_site_id in 
(SELECT distinct res_site_id FROM harvest_raw)";
		last SWITCH; }
	
	if ($which[0] =~ /^208$/) {
$sqlcmd = 
"INSERT into climdb_raw 
	(res_site_id,site_id,site_code,station,variable,sampledate,value,flag,last_update)
SELECT harvest_raw.res_site_id,harvest_raw.site_id,harvest_raw.site_code,harvest_raw.station,harvest_raw.variable,harvest_raw.sampledate,harvest_raw.value,harvest_raw.flag,getdate()
FROM climdb_raw right outer join harvest_raw
	ON climdb_raw.res_site_id = harvest_raw.res_site_id
	AND climdb_raw.site_id = harvest_raw.site_id
	AND climdb_raw.site_code = harvest_raw.site_code
	AND climdb_raw.station = harvest_raw.station
	AND climdb_raw.variable = harvest_raw.variable
	AND climdb_raw.sampledate = harvest_raw.sampledate
WHERE climdb_raw.site_code is null";
		last SWITCH; }
	
	if ($which[0] =~ /^209$/) {
$sqlcmd = 
"INSERT INTO climdb_site_variable_dates 
 SELECT  res_site_id,
	 site_id,
	 site_code,
	 station,variable, 
     min(sampledate) AS first_seen,
     max(sampledate) AS most_recent,
     max(last_update) AS last_update
 FROM climdb_raw
 WHERE 
res_site_id in (SELECT distinct res_site_id FROM harvest_raw)
 GROUP BY site_code,station,variable,site_id,res_site_id";
		last SWITCH; }
	
	if ($which[0] =~ /^210$/) {
$sqlcmd = 
"DELETE climdb_agg WHERE res_site_id in 
(SELECT distinct res_site_id FROM harvest_raw)";
		last SWITCH; }
	
#/*Get the monthly average of daily values for all variables WHERE an "average"
# is appropriate. Also, count the number of valid days included in the monthly 
# value, AND the number of days estimated in the month.  Additionally, 
# only compute monthly means for currently harvested stations - this is a 
# time saver to prevent the entire aggregate table FROM being recalculated*/
	if ($which[0] =~ /^211$/) {
$sqlcmd = 
"INSERT into climdb_agg SELECT
	 r.res_site_id,r.site_id,
     r.site_code,r.station,r.variable,
     datepart(year,r.sampledate),
	 datepart(month,r.sampledate),
     'MEAN' ,
     convert(varchar,AVG(convert(real,r.VALUE))),
     sum(case when FLAG is NULL or FLAG = 'E' or FLAG = 'T' or FLAG = 'G' then 1
	  else 0 end),
     sum(case when FLAG = 'E' then 1 else 0 end),
	 getdate()
     FROM climdb_raw r, 
       climdb_variables v where
      v.variable = r.variable AND 
      v.aggregate_mean = 'Y' AND 
       (r.flag is null or r.flag = 'E' or r.flag = 'T' or r.flag = 'G') AND
      res_site_id in (SELECT distinct res_site_id FROM harvest_raw)
  group by 
	site_code,res_site_id,site_id,station,r.variable,datepart(year,sampledate),
	datepart(month,sampledate)";
		     
		last SWITCH; }

#*Get the annual average of daily values for all variables WHERE an "average"
#is appropriate. Also, count the number of valid days included in the annual 
#value, AND the number of days estimated in the year.  Additionally, 
#only compute annual means for currently harvested stations - this is a 
#time saver to prevent the entire aggregate table FROM being recalculated*/
	if ($which[0] =~ /^212$/) {
$sqlcmd = 
"INSERT into climdb_agg SELECT 
	 r.res_site_id,r.site_id,
     r.site_code,r.station,r.variable,
     datepart(year,r.sampledate),99,'MEAN' ,
     convert(varchar,AVG(convert(real,r.VALUE))),
     sum(case when FLAG is NULL or FLAG = 'E' or FLAG = 'T' or FLAG = 'G' then 1
	  else 0 end),
     sum(case when FLAG = 'E' then 1 else 0 end),
	 getdate()
     FROM climdb_raw r, 
       climdb_variables v where
      v.variable = r.variable AND 
      v.aggregate_mean = 'Y' AND 
      (r.flag is null or r.flag = 'E' or r.flag = 'T' or r.flag = 'G') AND 
      res_site_id in (SELECT distinct res_site_id FROM harvest_raw)
  group by 
   site_code,res_site_id,site_id,station,r.variable,datepart(year,sampledate)";
		last SWITCH; }
	
#Get the mean monthly average of daily values for all variables WHERE an "average"
#is appropriate. Also, count the number of valid days included in the monthly
#value, AND the number of days estimated in the months over all years. Additionally, 
#only compute monthly means for currently harvested stations - this is a 
#time saver to prevent the entire aggregate table FROM being recalculated
	if ($which[0] =~ /^213$/) {
$sqlcmd = 
"INSERT into climdb_agg SELECT 
	 r.res_site_id,r.site_id,
     r.site_code,r.station,r.variable,
     0,datepart(month,r.sampledate),'MEAN',
     convert(varchar,AVG(convert(real,r.VALUE))),
     sum(case when FLAG is NULL or FLAG = 'E' or FLAG = 'T' or FLAG = 'G' then 1
	  else 0 end),
     sum(case when FLAG = 'E' then 1 else 0 end), 
	 getdate()
     FROM climdb_raw r, 
       climdb_variables v where
      v.variable = r.variable AND 
      v.aggregate_mean = 'Y' AND 
      (r.flag is null or r.flag = 'E' or r.flag = 'T' or r.flag = 'G') AND 
      res_site_id in (SELECT distinct res_site_id FROM harvest_raw)
  group by 
   site_code,res_site_id,site_id,station,r.variable,datepart(month,sampledate)";
		last SWITCH; }

# Get the monthly total of daily values for all variables WHERE a "total" 
# is appropriate. Also, count the number of valid days included in the monthly 
# value, AND the number of days estimated in the month.  Additionally, 
# only compute monthly totals for currently harvested stations -  this is a 
# time saver to prevent the entire aggregate table FROM being recalculated
	if ($which[0] =~ /^214$/) {
$sqlcmd = 
"INSERT INTO climdb_agg SELECT 
	 r.res_site_id,r.site_id,
     r.site_code,r.station,r.variable,
     datepart(year,r.sampledate),
	 datepart(month,r.sampledate),
     'TOTAL',
     convert(varchar,sum(convert(real,r.VALUE))),
     sum(case when FLAG is NULL or FLAG = 'E' or FLAG = 'T' or FLAG = 'G' then 1
	  else 0 end),
     sum(case when FLAG = 'E' then 1 else 0 end), getdate()
     FROM climdb_raw r, 
       climdb_variables v WHERE
      v.variable = r.variable AND 
      v.aggregate_total = 'Y' AND 
       (r.flag is null or r.flag = 'E' or r.flag = 'T' or r.flag = 'G') AND 
      res_site_id in (SELECT distinct res_site_id FROM harvest_raw)
  GROUP BY 
   res_site_id,site_id,site_code,station,r.variable,datepart(year,sampledate),
     datepart(month,sampledate)";
		last SWITCH; }

# Get the monthly minimum of daily values for all variables WHERE a "minimum"
# is appropriate. Also, count the number of valid days included in the monthly 
# value, AND the number of days estimated in the month.  Additionally, 
# only compute monthly minimums for currently harvested stations - this is a 
# time saver to prevent the entire aggregate table FROM being recalculated
	if ($which[0] =~ /^215$/) {
$sqlcmd = 
"INSERT INTO climdb_agg SELECT 
	 r.res_site_id,r.site_id,
     r.site_code,r.station,r.variable,
     datepart(year,r.sampledate),
	 datepart(month,r.sampledate),
     'MIN' ,
     convert(varchar,min(convert(real,r.VALUE))),
     sum(case when FLAG is NULL or FLAG = 'E' or FLAG = 'T' or FLAG = 'G' then 1
	  else 0 end),
     sum(case when FLAG = 'E' then 1 else 0 end) , getdate()
     FROM climdb_raw r, 
       climdb_variables v WHERE
      v.variable = r.variable AND 
      v.aggregate_min = 'Y' AND 
       (r.flag is null or r.flag = 'E' or r.flag = 'T' or r.flag = 'G') AND 
      res_site_id in (SELECT distinct res_site_id FROM harvest_raw)
  GROUP BY 
   res_site_id,site_id,site_code,station,r.variable,datepart(year,sampledate),
     datepart(month,sampledate)";
		last SWITCH; }
	
#/*Get the monthly maximum of daily values for all variables WHERE a "maximum"
# is appropriate. Also, count the number of valid days included in the monthly 
# value, AND the number of days estimated in the month.  Additionally, 
# only compute monthly maximums for currently harvested stations - this is a 
# time saver to prevent the entire aggregate table FROM being recalculated*/
	if ($which[0] =~ /^216$/) {
$sqlcmd = 
"INSERT INTO climdb_agg SELECT 
	 r.res_site_id,r.site_id,
     r.site_code,r.station,r.variable,
     datepart(year,r.sampledate),
	 datepart(month,r.sampledate),
     'MAX' ,
     convert(varchar,max(convert(real,r.VALUE))),
     sum(case when FLAG is NULL or FLAG = 'E' or FLAG = 'T' or FLAG = 'G' then 1
	  else 0 end),
     sum(case when FLAG = 'E' then 1 else 0 end) , getdate()
     FROM climdb_raw r, 
       climdb_variables v WHERE
      v.variable = r.variable AND 
      v.aggregate_max = 'Y' AND 
       (r.flag is null or r.flag = 'E' or r.flag = 'T' or r.flag = 'G') AND 
      res_site_id in (SELECT distinct res_site_id FROM harvest_raw)
  GROUP By 
   res_site_id,site_id,site_code,station,r.variable,datepart(year,sampledate),
     datepart(month,sampledate)";
		last SWITCH; }

#*Get the annual total of daily values for all variables WHERE a "total"
#is appropriate. Also, count the number of valid days included in the annual 
#value, AND the number of days estimated in the year.  Additionally, 
#only compute annual totals for currently harvested stations - this is a 
#time saver to prevent the entire aggregate table FROM being recalculated*/
	if ($which[0] =~ /^217$/) {
$sqlcmd = 
"INSERT INTO climdb_agg SELECT 
	 r.res_site_id,r.site_id,
     r.site_code,r.station,r.variable,
     datepart(year,r.sampledate),99,
     'TOTAL' ,
     convert(varchar,sum(convert(real,r.VALUE))),
     sum(case when FLAG is NULL or FLAG = 'E' or FLAG = 'T' or FLAG = 'G' then 1
	  else 0 end),
     sum(case when FLAG = 'E' then 1 else 0 end),getdate() 
     FROM climdb_raw r, 
       climdb_variables v WHERE
      v.variable = r.variable AND 
      v.aggregate_total = 'Y' AND 
      (r.flag is null or r.flag = 'E' or r.flag = 'T' or r.flag = 'G') AND 
      res_site_id in (SELECT distinct res_site_id FROM harvest_raw)
  GROUP BY 
   res_site_id,site_id,site_code,station,r.variable,datepart(year,sampledate)";
		last SWITCH; }
	
#*Get the annual minimum daily value for all variables WHERE a "minimum"
#is appropriate. Also, count the number of valid days included in the annual 
#value, AND the number of days estimated in the year.  Additionally, 
#only compute annual minimum for currently harvested stations - this is a 
#time saver to prevent the entire aggregate table FROM being recalculated*/
	if ($which[0] =~ /^218$/) {
$sqlcmd = 
"INSERT INTO climdb_agg SELECT 
	 r.res_site_id,r.site_id,
     r.site_code,r.station,r.variable,
     datepart(year,r.sampledate),99, 'MIN' ,
     convert(varchar,min(convert(real,r.VALUE))),
     sum(case when FLAG is NULL or FLAG = 'E' or FLAG = 'T' or FLAG = 'G' then 1
	  else 0 end),
     sum(case when FLAG = 'E' then 1 else 0 end) ,getdate()
     FROM climdb_raw r, 
       climdb_variables v where
      v.variable = r.variable AND 
      v.aggregate_min = 'Y' AND 
      (r.flag is null or r.flag = 'E' or r.flag = 'T' or r.flag = 'G') AND 
      res_site_id in (SELECT distinct res_site_id FROM harvest_raw)
  GROUP BY 
   res_site_id,site_id,site_code,station,r.variable,datepart(year,sampledate)";
		last SWITCH; }

#Get the annual maximum daily value for all variables WHERE a "maximum"
#is appropriate. Also, count the number of valid days included in the annual 
#value, AND the number of days estimated in the year.  Additionally, 
#only compute annual maximum for currently harvested stations - this is a 
#time saver to prevent the entire aggregate table FROM being recalculated*/
	if ($which[0] =~ /^219$/) {
$sqlcmd = 
"INSERT into climdb_agg SELECT 
	 r.res_site_id,r.site_id,
     r.site_code,r.station,r.variable,
     datepart(year,r.sampledate),99, 'MAX' ,
     convert(varchar,max(convert(real,r.VALUE))),
     sum(case when FLAG is NULL or FLAG = 'E' or FLAG = 'T' or FLAG = 'G' then 1
	  else 0 end),
     sum(case when FLAG = 'E' then 1 else 0 end) ,getdate()
     FROM climdb_raw r, 
       climdb_variables v where
      v.variable = r.variable AND 
      v.aggregate_max = 'Y' AND 
      (r.flag is null or r.flag = 'E' or r.flag = 'T' or r.flag = 'G') AND 
      res_site_id in (SELECT distinct res_site_id FROM harvest_raw)
  group by 
   res_site_id,site_id,site_code,station,r.variable,datepart(year,sampledate)";
		last SWITCH; }


#Get the minimum monthly daily value for all variables WHERE an "minimum"
#is appropriate. Also, count the number of valid days included in the monthly
#value, AND the number of days estimated in the months over all years. Additionally, 
#only compute monthly minimums for currently harvested stations - this is a 
#time saver to prevent the entire aggregate table FROM being recalculated*/
	if ($which[0] =~ /^220$/) {
$sqlcmd = 
"INSERT into climdb_agg SELECT 
	 r.res_site_id,r.site_id,
     r.site_code,r.station,r.variable,
     0,datepart(month,r.sampledate),'MIN',
     convert(varchar,min(convert(real,r.VALUE))),
     sum(case when FLAG is NULL or FLAG = 'E' or FLAG = 'T' or FLAG = 'G' then 1
	  else 0 end),
     sum(case when FLAG = 'E' then 1 else 0 end) ,getdate()
     FROM climdb_raw r, 
       climdb_variables v where
      v.variable = r.variable AND 
      v.aggregate_min = 'Y' AND 
      (r.flag is null or r.flag = 'E' or r.flag = 'T' or r.flag = 'G') AND 
      res_site_id in (SELECT distinct res_site_id FROM harvest_raw)
  group by 
   res_site_id,site_id,site_code,station,r.variable,datepart(month,sampledate)";
		last SWITCH; }

# Get the maximum monthly daily value for all variables WHERE an "maximum"
# is appropriate. Also, count the number of valid days included in the monthly
# value, AND the number of days estimated in the months over all years. Additionally, 
# only compute monthly maximums for currently harvested stations - this is a 
# time saver to prevent the entire aggregate table FROM being recalculated

	if ($which[0] =~ /^221$/) {
$sqlcmd = 
"INSERT into climdb_agg SELECT 
	 r.res_site_id,r.site_id,
     r.site_code,r.station,r.variable,
     0,datepart(month,r.sampledate),'MAX' ,
     convert(varchar,max(convert(real,r.VALUE))),
     sum(case when FLAG is NULL or FLAG = 'E' or FLAG = 'T' or FLAG = 'G' then 1
	  else 0 end),
     sum(case when FLAG = 'E' then 1 else 0 end) ,getdate()
     FROM climdb_raw r, 
       climdb_variables v where
      v.variable = r.variable AND 
      v.aggregate_max = 'Y' AND 
      (r.flag is null or r.flag = 'E' or r.flag = 'T' or r.flag = 'G') AND 
      res_site_id in (SELECT distinct res_site_id FROM harvest_raw)
  group by 
   res_site_id,site_id,site_code,station,r.variable,datepart(month,sampledate)";
		last SWITCH; }
		
#Get the monthly total of daily values for all variables WHERE a "total"
#is appropriate. Also, count the number of valid days included in the monthly
#value, AND the number of days estimated in the months over all years. Additionally, 
#only compute month totals for currently harvested stations - this is a 
#time saver to prevent the entire aggregate table FROM being recalculated
	
	if ($which[0] =~ /^222$/) {
$sqlcmd = 
"INSERT INTO climdb_agg SELECT 
	 res_site_id,site_id,
     site_code,station,variable,
     0,month,'TOTAL' ,
     convert(varchar,avg(convert(real,VALUE))),
     sum(num_get),
     sum(num_e),
     getdate()
     FROM climdb_agg WHERE
     aggregate_type = 'TOTAL' AND month > 0 AND month <= 12  
	 AND year > 0 AND 
      res_site_id in (SELECT distinct res_site_id FROM harvest_raw)
  GROUP BY 
   res_site_id,site_id,site_code,station,variable,month";
		last SWITCH; }


# SQL commands for plot.pl

	if ($which[0] =~ /^300dd$/) {
		my @which = @_;
		my ($i,@var_list,@variable);
		my ($site,$station,$variable,$begin,$end,$type,$agg_type);
		shift @which;
		WHICH: while (@which) {
			($site,$station,$variable,$begin,$end,$type,$agg_type) 
				= splice(@which,0,7);
			last WHICH if ($site eq 'daily');
			push @var_list,$variable;
		}
		$sqlcmd .= "\n@@@#CLEAN UP TABLES (temp_union is the union of all temp(n)s) (temp_dates is the list of all dates FROM masterdate) \n";
		$sqlcmd .= "\n@@@ DROP TABLE temp_union\n";
		$sqlcmd .= "@@@ DROP TABLE temp_dates\n";
		for (my $i=0;$i<=$#var_list;$i++) {
			$sqlcmd .= "@@@ DROP TABLE temp$i\n";}
		$sqlcmd .= "\n@@@#MAKE A TEMP TABLE FOR EACH VARIABLE (temp(n))\n"; 
		for (my $i=0;$i<=$#var_list;$i++) {
			$sqlcmd .= "@@@ SELECT site_code, station, sampledate, value, flag\nINTO temp$i\nFROM climdb_raw\nWHERE site_code='$site' and\n\t station='$station' and\n\t variable='$var_list[$i]' and\n\t sampledate>='$begin' and\n\t sampledate<='$end'\n";
		}
		$sqlcmd .= "\n@@@#DO A UNION ON ALL temp(n)s IN ORDER TO HOLD THE MIN AND MAX DATES\n"; 
		$sqlcmd .= "@@@ SELECT min(sampledate) as mindate, max(sampledate) as maxdate into temp_union FROM temp0\n";
		for (my $i=1;$i<=$#var_list;$i++) {
			$sqlcmd .= "UNION SELECT min(sampledate) as mindate, max(sampledate) as maxdate FROM temp$i\n";
		}

		$sqlcmd .= "\n@@@#GET ALL DATES FROM MASTERDATE TABLE\n";
		$sqlcmd .= "@@@ SELECT '$site' as site_code, '$station' as station, sampledate into temp_dates\nFROM masterdate\nWHERE sampledate>=(SELECT min(mindate) FROM temp_union)\n\tAND sampledate<=(SELECT max(maxdate) FROM temp_union)\n";

		$sqlcmd .= "\n@@@#DO THE JOIN ON THE temp_dates AND ALL THE temp(n)s\n";
		$sqlcmd .= "@@@ LAST SELECT temp_dates.sampledate, temp_dates.site_code, temp_dates.station";
		for (my $i=0;$i<=$#var_list;$i++) {
			$sqlcmd .= ",temp$i.value, temp$i.flag";
		}
		$sqlcmd .= "\nFROM temp_dates\n";
		for (my $i=0;$i<=$#var_list;$i++) {
			$sqlcmd .= "FULL OUTER JOIN temp$i\nON temp_dates.site_code= temp$i.site_code AND temp_dates.station= temp$i.station AND temp_dates.sampledate= temp$i.sampledate\n";
		}
		$sqlcmd .= "ORDER BY temp_dates.sampledate\n";
	

		last SWITCH; }
			
	if ($which[0] =~ /^300mm$/) {
		my @which = @_;
		my ($i,@var_list,@variable);
		my ($site,$station,$variable,$begin,$end,$type,$agg_type);
		my ($year_begin,$year_end,$month_end,$month_begin,@agg_type);
		shift @which;
		WHICH: while (@which) {
			($site,$station,$variable,$begin,$end,$type,$agg_type)= 
				splice(@which,0,7);
			$begin =~ s/^(....)(..)//;
			$year_begin = $1;
			$month_begin = $2;
			$end =~ s/^(....)(..)//;
			$year_end = $1;
			$month_end = $2;
			last WHICH if ($site eq 'monthly');
			push @var_list,$variable;
			push @agg_type,$agg_type;
		}
		$sqlcmd .= "\n@@@#CLEAN UP TABLES (temp_union is the union of all temp(n)s) (temp_dates is the list of all dates FROM masterdate) \n";
		$sqlcmd .= "\n@@@ DROP TABLE temp_union\n";
		$sqlcmd .= "@@@ DROP TABLE temp_dates\n";
		for (my $i=0;$i<=$#var_list;$i++) {
			$sqlcmd .= "@@@ DROP TABLE temp$i\n";}
		$sqlcmd .= "\n@@@#MAKE A TEMP TABLE FOR EACH VARIABLE (temp(n))\n"; 
		for (my $i=0;$i<=$#var_list;$i++) {
					$sqlcmd .= "@@@ SELECT site_code, station, year, month, v.variable, value, num_e, num_get, v.decimals\nINTO temp$i\nFROM climdb_agg a, climdb_variables v\nWHERE site_code='$site' and\n\t station='$station' and\n\t a.variable='$var_list[$i]' and\n\t year>='$year_begin' and\n\t year<='$year_end' and\n\t aggregate_type = '$agg_type[$i]' AND \n\t month != 99 AND v.variable = a.variable \n";
		}
		$sqlcmd .= "\n@@@#DO A UNION ON ALL temp(n)s IN ORDER TO HOLD THE MIN AND MAX DATES\n"; 
		$sqlcmd .= "@@@ SELECT min(year) as mindate, max(year) as maxdate into temp_union FROM temp0\n";
		for (my $i=1;$i<=$#var_list;$i++) {
			$sqlcmd .= "UNION SELECT min(year) as mindate, max(year) as maxdate FROM temp$i\n";
		}

		$sqlcmd .= "\n@@@#GET ALL DATES FROM MASTERDATE TABLE\n";
		$sqlcmd .= "@@@ SELECT '$site' as site_code, '$station' as station, DATEPART(year,sampledate) as year, DATEPART(month,sampledate) as month into temp_dates\nFROM masterdate\nWHERE DATEPART(year,sampledate)>=(SELECT min(mindate) FROM temp_union)\n\tAND DATEPART(year,sampledate)<=(SELECT max(maxdate) FROM temp_union)\n";

		$sqlcmd .= "\n@@@#DO THE JOIN ON THE temp_dates AND ALL THE temp(n)s\n";
		$sqlcmd .= "@@@ LAST SELECT DISTINCT temp_dates.year, temp_dates.month, temp_dates.site_code, temp_dates.station";
		for (my $i=0;$i<=$#var_list;$i++) {
			$sqlcmd .= ",temp$i.value, temp$i.num_e, temp$i.num_get, temp$i.decimals";
		}
		$sqlcmd .= "\nFROM temp_dates\n";
		for (my $i=0;$i<=$#var_list;$i++) {
			$sqlcmd .= "FULL OUTER JOIN temp$i\nON temp_dates.site_code= temp$i.site_code AND temp_dates.station= temp$i.station AND temp_dates.year= temp$i.year AND temp_dates.month = temp$i.month\n";
		}
		$sqlcmd .= "ORDER BY temp_dates.year, temp_dates.month\n";

		last SWITCH; }

	if ($which[0] =~ /^300yy$/) {
		my @which = @_;
		my ($i,@var_list,@variable,@agg_list);
		my ($site,$station,$variable,$begin,$end,$type,$agg_type);
		shift @which;
		WHICH: while (@which) {
			($site,$station,$variable,$begin,$end,$type,$agg_type)= 
				splice(@which,0,7);
			$begin =~ s/^(....)//;
			$begin = $1;
			$end =~ s/^(....)//;
			$end = $1;
			last WHICH if ($site eq 'yearly');
			push @var_list,$variable;
			push @agg_list,$agg_type;
		}
		$sqlcmd .= "\n@@@#CLEAN UP TABLES (temp_union is the union of all temp(n)s) (temp_dates is the list of all dates FROM masteryear) \n";
		$sqlcmd .= "\n@@@ DROP TABLE temp_union\n";
		$sqlcmd .= "@@@ DROP TABLE temp_dates\n";
		for (my $i=0;$i<=$#var_list;$i++) {
			$sqlcmd .= "@@@ DROP TABLE temp$i\n";}
		$sqlcmd .= "\n@@@#MAKE A TEMP TABLE FOR EACH VARIABLE (temp(n))\n"; 
		for (my $i=0;$i<=$#var_list;$i++) {
			$sqlcmd .= "@@@ SELECT site_code, station, year, value, num_e, num_get, v.decimals\nINTO temp$i\nFROM climdb_agg a, climdb_variables v\nWHERE site_code='$site' and\n\t station='$station' and\n\t a.variable='$var_list[$i]' and\n\t year>='$begin' and\n\t year<='$end' and\n\t aggregate_type = '$agg_list[$i]' AND \n\t month = 99 AND v.variable = a.variable \n";
		}
		$sqlcmd .= "\n@@@#DO A UNION ON ALL temp(n)s IN ORDER TO HOLD THE MIN AND MAX DATES\n"; 
		$sqlcmd .= "@@@ SELECT min(year) as mindate, max(year) as maxdate into temp_union FROM temp0\n";
		for (my $i=1;$i<=$#var_list;$i++) {
			$sqlcmd .= "UNION SELECT min(year) as mindate, max(year) as maxdate FROM temp$i\n";
		}

		$sqlcmd .= "\n@@@#GET ALL DATES FROM MASTERYEAR TABLE\n";
		$sqlcmd .= "@@@ SELECT '$site' as site_code, '$station' as station, DATEPART(year,sampledate) as year into temp_dates\nFROM masterdate\nWHERE DATEPART(year,sampledate)>=(SELECT min(mindate) FROM temp_union)\n\tAND DATEPART(year,sampledate)<=(SELECT max(maxdate) FROM temp_union)\n";

		$sqlcmd .= "\n@@@#DO THE JOIN ON THE temp_dates AND ALL THE temp(n)s\n";
		$sqlcmd .= "@@@ LAST SELECT DISTINCT temp_dates.year, temp_dates.site_code, temp_dates.station";
		for (my $i=0;$i<=$#var_list;$i++) {
			$sqlcmd .= ",temp$i.value, temp$i.num_e, temp$i.num_get, temp$i.decimals";
		}
		$sqlcmd .= "\nFROM temp_dates\n";
		for (my $i=0;$i<=$#var_list;$i++) {
			$sqlcmd .= "FULL OUTER JOIN temp$i\nON temp_dates.site_code= temp$i.site_code AND temp_dates.station= temp$i.station AND temp_dates.year= temp$i.year\n";
		}
		$sqlcmd .= "ORDER BY temp_dates.year\n";
		

		last SWITCH; }

	if ($which[0] =~ /^300hack$/) {
		my $variable = $which[1];
$sqlcmd = "
SELECT variable_name
FROM climdb_variables
WHERE variable = '$variable'";
		last SWITCH; }

	if ($which[0] =~ /^300ed$/) {
		my $site = $which[1];
		my $station = $which[2];
		my $variable = $which[3];
		my $agg_type = $which[4];
		my $end = $which[5];
		my $begin = $which[6];
		$begin =~ s/^(....)..../$1/;
		$end =~ s/^(....)..../$1/;
$sqlcmd = "
SELECT month, year, value 
INTO tmp
FROM climdb_agg
WHERE site_code = '$site' AND 
	station = '$station' AND 
	variable = '$variable' AND 
	aggregate_type = '$agg_type' AND 
	month != 99 AND 
	year <= $end AND
    year >= $begin	";
		last SWITCH; }

	if ($which[0] =~ /^300ed2$/) {
		my $site = $which[1];
		my $station = $which[2];
		my $variable = $which[3];
		my $end = $which[4];
		my $begin = $which[5];
		my $table = $which[6];
$sqlcmd = "
SELECT sampledate, $table.value 
FROM climdb_raw r, tmp t
WHERE site_code = '$site' AND 
	station = '$station' AND 
	variable = '$variable' AND 
	t.month = datepart(month,sampledate) AND
	t.year = datepart(year,sampledate) AND
	sampledate <= '$end' AND
	sampledate >= '$begin' 
ORDER BY sampledate";
		last SWITCH; }

	if ($which[0] =~ /^300em$/) {
		my $site = $which[1];
		my $station = $which[2];
		my $variable = $which[3];
		my $agg_type = $which[4];
$sqlcmd = "
SELECT year, month, value 
INTO tmp
FROM climdb_agg
WHERE site_code = '$site' AND 
	station = '$station' AND 
	variable = '$variable' AND 
	aggregate_type = '$agg_type' AND 
	month != 99 AND 
	year <= 0 
ORDER BY year, month";
		last SWITCH; }

	if ($which[0] =~ /^300em2$/) {
		my $site = $which[1];
		my $station = $which[2];
		my $variable = $which[3];
		my $agg_type = $which[4];
		my $end = $which[5];
		my $begin = $which[6];
		my $table = $which[7];
		$begin =~ s/^(....)..../$1/;
		$end =~ s/^(....)..../$1/;
$sqlcmd = "
SELECT a.year, a.month, $table.value 
FROM climdb_agg a, tmp t
WHERE site_code = '$site' AND 
	station = '$station' AND 
	variable = '$variable' AND 
	aggregate_type = '$agg_type' AND 
	a.month != 99 AND
	a.month = t.month AND
	a.year <= $end AND
	a.year >= $begin 
ORDER BY a.year, a.month";
		last SWITCH; }

	if ($which[0] =~ /^300ey$/) {
		my $site = $which[1];
		my $station = $which[2];
		my $variable = $which[3];
		my $agg_type = $which[4];
		my $end = $which[5];
		my $begin = $which[6];
		$begin =~ s/^(....)..../$1/;
		$end =~ s/^(....)..../$1/;
$sqlcmd = "
SELECT avg(convert(real,value)) as value 
INTO tmp
FROM climdb_agg
WHERE site_code = '$site' AND 
	station = '$station' AND 
	variable = '$variable' AND 
	aggregate_type = '$agg_type' AND 
	month = 99 AND 
	year <= $end AND
    year >= $begin	";
		last SWITCH; }

	if ($which[0] =~ /^300ey2$/) {
		my $site = $which[1];
		my $station = $which[2];
		my $variable = $which[3];
		my $agg_type = $which[4];
		my $end = $which[5];
		my $begin = $which[6];
		my $table = $which[7];
		$begin =~ s/^(....)..../$1/;
		$end =~ s/^(....)..../$1/;
$sqlcmd = "
SELECT a.year, $table.value 
FROM climdb_agg a, tmp t
WHERE site_code = '$site' AND 
	station = '$station' AND 
	variable = '$variable' AND 
	aggregate_type = '$agg_type' AND 
	a.month = 99 AND
	a.year <= $end AND
	a.year >= $begin 
ORDER BY a.year, a.month";
		last SWITCH; }

if ($which[0] =~ /^300d$/) {
		my $site = $which[1];
		my $station = $which[2];
		my $variable = $which[3];
		my $end = $which[4];
		my $begin = $which[5];
$sqlcmd = "
SELECT sampledate, value, flag 
FROM climdb_raw
WHERE site_code = '$site' AND 
	station = '$station' AND 
	variable = '$variable' AND 
	sampledate <= '$end' AND 
	sampledate >= '$begin'
ORDER BY sampledate";
		last SWITCH; }

	if ($which[0] =~ /^300m/) {
		my $site = $which[1];
		my $station = $which[2];
		my $variable = $which[3];
		my $end = $which[4];
		$end =~ s/(....)..../$1/;
		my $begin = $which[5];
		$begin =~ s/(....)..../$1/;
		my $agg_type = $which[6];
$sqlcmd = "
SELECT  year, month, value, num_e 
FROM climdb_agg
WHERE site_code = '$site' AND 
	station = '$station' AND 
	variable = '$variable' AND 
	aggregate_type = '$agg_type' AND 
	month != 99 AND 
	year <= '$end' AND 
	year >= '$begin'
ORDER BY year,month";
		last SWITCH; }

	if ($which[0] =~ /^300y/) {
		my $site = $which[1];
		my $station = $which[2];
		my $variable = $which[3];
		my $end = $which[4];
		$end =~ s/(....)..../$1/;
		my $begin = $which[5];
		$begin =~ s/(....)..../$1/;
		my $agg_type = $which[6];
$sqlcmd = "
SELECT year, value, num_e 
FROM climdb_agg
WHERE site_code = '$site' AND 
	station = '$station' AND 
	variable = '$variable' AND 
	aggregate_type = '$agg_type' AND 
	month = 99 AND 
	year <= '$end' AND 
	year >= '$begin'
ORDER BY year,month";
		last SWITCH; }


#	if ($which[0] =~ /^300$/) {
#		my $site = $which[1];
#		my $station = $which[2];
#		my $variable = $which[3];
#		my $end = $which[4];
#		my $begin = $which[5];
#$sqlcmd = "
#SELECT sampledate, value, flag
#FROM climdb_raw
#WHERE site_code = '$site' AND 
#	station = '$station' AND 
#	variable = '$variable' AND 
#	sampledate <= '$end' AND 
#	sampledate >= '$begin'
#ORDER BY sampledate";
#		last SWITCH; }
	
	if ($which[0] =~ /^300$/) {
		my $variable = $which[1];
$sqlcmd = "
SELECT aggregate_total, aggregate_mean
FROM climdb_variables
WHERE variable = '$variable'";;
		last SWITCH; }

	
	if ($which[0] =~ /^301/) {
		my $station = $which[1];
		my $variable = $which[2];
		my $site_code = $which[3];
$sqlcmd = "
SELECT first_seen, 
	   most_recent
FROM climdb_site_variable_dates
WHERE station = '$station' AND 
	  variable = '$variable' AND 
	  site_code = '$site_code'";
		last SWITCH; }

	if ($which[0] =~ /^302/) {
		my $site = $which[1];
		my $res_sitetype_id = $which[2];
$sqlcmd = " 
SELECT DISTINCT d.station, r.res_site_name
FROM climdb_site_variable_dates d, 
	research_site r,
	research_site_sitetype t
WHERE d.res_site_id = r.res_site_id AND
	t.res_site_id = r.res_site_id AND
	t.res_sitetype_id = $res_sitetype_id AND
	d.site_code = '$site'";
		last SWITCH; }
	
	if ($which[0] =~ /^303/) {
		my $site = $which[1];
		my $res_sitetype_id = $which[2];
$sqlcmd = "
SELECT DISTINCT d.variable, v.variable_name
FROM climdb_site_variable_dates d,
	research_site r,
	climdb_variables v,
	research_site_sitetype t
WHERE d.res_site_id = r.res_site_id AND
	t.res_site_id = r.res_site_id AND
	v.variable = d.variable AND 
	t.res_sitetype_id = $res_sitetype_id AND
	d.site_code = '$site'";
		last SWITCH; }
	
	if ($which[0] =~ /^304/) {
$sqlcmd = "
SELECT DISTINCT s.site_code, s.site_name 
FROM site s, 
	research_site r,
	climdb_site_variable_dates d
WHERE s.site_id = r.site_id AND 
	r.res_site_id = d.res_site_id AND 
	d.site_id = s.site_id
ORDER by s.site_name";
#SELECT DISTINCT s.site_code, s.site_name 
#FROM site s, 
#	stations t,
#	climdb_site_variable_dates d
#WHERE s.site_code = t.site_code AND 
#	d.site_code = t.site_code AND 
#	d.site_code = s.site_code
#ORDER by s.site_name";
		last SWITCH; }

	if ($which[0] =~ /^305/) {
		my $site = $which[1];
$sqlcmd = "
SELECT site_name, site_name
	FROM site
	WHERE site_code = '$site'";
		last SWITCH; }

	if ($which[0] =~ /^306/) {
		my $session_id = $which[1];
		my $datetime = $which[2];
		my $ip_address = $which[3];
		my $requestor = $which[4];
		my $organization = $which[5];
		my $purpose = $which[6];
$sqlcmd = "
INSERT INTO session
(session_id,ip_address,requestor,organization,purpose)
VALUES
('$session_id','$ip_address','$requestor','$organization','$purpose')";
		last SWITCH; }

	if ($which[0] =~ /^307/) {
		my $session_id = $which[1];
		my $download_id = $which[2];
		my $datetime = $which[3];
		my $ip_address = $which[4];
		my $file_type = $which[5];
$sqlcmd = "
INSERT INTO download 
(session_id,download_id,ip_address,file_type)
VALUES
('$session_id','$download_id','$ip_address','$file_type')";
		last SWITCH; }

# SQL commands for chump.pl
		
	if ($which[0] =~ /^400/) {
		my $site_code = $which[1];
$sqlcmd = "
SELECT distinct r.res_site_id, r.res_site_code
FROM research_site r, site s, research_site_sitetype st
WHERE 	st.res_sitetype_id = 1 AND
	r.res_site_id=st.res_site_id AND
	s.site_id = r.site_id AND 
	s.site_code = '$site_code'";

		last SWITCH; }
	
	if ($which[0] =~ /^401/) {
		my $site_id = $which[1];
$sqlcmd = "
SELECT site_code FROM site WHERE site_id = '$site_id'
";
		last SWITCH; }
	
	if ($which[0] =~ /^402/) {
		my $site_code = $which[1];
$sqlcmd = "
SELECT site_id FROM site WHERE site_code = '$site_code'
";
		last SWITCH; }
	
	if ($which[0] =~ /^403/) {
		my $table_name = $which[1];
		my $id_name = $which[2];
		my $id = $which[3];
$sqlcmd = "
DELETE FROM $table_name
WHERE $id_name = \'$id\'
";
		last SWITCH; }
	
	if ($which[0] =~ /^404/) {
		my $id_name = $which[1];
		my $table_name = $which[2];
$sqlcmd = "
SELECT max($id_name) FROM $table_name
";
		last SWITCH; }
	
	if ($which[0] =~ /^405/) {
		my $site_code = $which[1];
		my $site_name = $which[2];
		my $loc1 = $which[3];
		my $loc2 = $which[4];
		my $latitude_dec = $which[5];
		my $longitude_dec = $which[6];
		my $hydro_data_url = $which[7];
		my $clim_data_url = $which[8];
		my $usgs_data_url = $which[9];
		my $site_url = $which[10];
		my $site_id = $which[11];
$sqlcmd = "
UPDATE site
SET site_code = '$site_code',
	site_name = '$site_name',
	loc1 = '$loc1',
	loc2 = '$loc2',
	latitude_dec = $latitude_dec,
	longitude_dec = $longitude_dec,
	hydro_data_url = '$hydro_data_url',
	clim_data_url = '$clim_data_url',
	usgs_data_url = '$usgs_data_url',
	site_url = '$site_url'
WHERE site_id = '$site_id'
";
		last SWITCH; }
	
	if ($which[0] =~ /^406/) {
		my $site_code = $which[1];
		my $site_name = $which[2];
		my $loc1 = $which[3];
		my $loc2 = $which[4];
		my $latitude_dec = $which[5];
		my $longitude_dec = $which[6];
		my $hydro_data_url = $which[7];
		my $clim_data_url = $which[8];
		my $usgs_data_url = $which[9];
		my $site_url = $which[10];
		my $site_id = $which[11];
$sqlcmd = "
INSERT INTO site
(site_code,site_name,loc1,loc2,latitude_dec,longitude_dec,hydro_data_url,clim_data_url,usgs_data_url,site_url,site_id)
VALUES
('$site_code','$site_name','$loc1','$loc2',$latitude_dec,$longitude_dec,'$hydro_data_url','$clim_data_url','$usgs_data_url','$site_url','$site_id')
";
		last SWITCH; }
	
	if ($which[0] =~ /^407/) {
		my $last_name = $which[1];
		my $first_name = $which[2];
		my $middle_name = $which[3];
		my $address = $which[4];
		my $city = $which[5];
		my $state = $which[6];
		my $postal_code = $which[7];
		my $country = $which[8];
		my $telephone1 = $which[9];
		my $telephone2 = $which[10];
		my $email1 = $which[11];
		my $email2 = $which[12];
		my $fax1 = $which[13];
		my $fax2 = $which[14];
		my $personnel_id = $which[15];
$sqlcmd = "
INSERT INTO personnel
(last_name,first_name,middle_name,address,city,state,postal_code,country,telephone1,telephone2,email1,email2,fax1,fax2,personnel_id)
VALUES
('$last_name','$first_name','$middle_name','$address','$city','$state','$postal_code','$country','$telephone1','$telephone2','$email1','$email2','$fax1','$fax2','$personnel_id')
";
		last SWITCH; }
	
	if ($which[0] =~ /^408/) {
		my $site_id = $which[1];
		my $personnel_id = $which[2];
		my $id = $which[3];
		my $mod_id = $which[4];
$sqlcmd = "
INSERT INTO site_personnel_role
(site_id,personnel_id,personnel_role_id,res_module_id)
VALUES
('$site_id','$personnel_id','$id','$mod_id')
";
		last SWITCH; }
	
	if ($which[0] =~ /^409/) {
		my $last_name = $which[1];
		my $first_name = $which[2];
		my $middle_name = $which[3];
		my $address = $which[4];
		my $city = $which[5];
		my $state = $which[6];
		my $postal_code = $which[7];
		my $country = $which[8];
		my $telephone1 = $which[9];
		my $telephone2 = $which[10];
		my $email1 = $which[11];
		my $email2 = $which[12];
		my $fax1 = $which[13];
		my $fax2 = $which[14];
		my $personnel_id = $which[15];
$sqlcmd = "
UPDATE personnel
SET last_name = '$last_name',
	first_name = '$first_name',
	middle_name = '$middle_name',
	address ='$address', 
	city = '$city',
	state = '$state',
	postal_code = '$postal_code',
	country = '$country',
	telephone1 = '$telephone1',
	telephone2 = '$telephone2',
	email1 = '$email1', 
	email2 = '$email2',
	fax1 = '$fax1',
	fax2 = '$fax2'
WHERE personnel_id = '$personnel_id'
";
		last SWITCH; }
	
	if ($which[0] =~ /^410/) {
		my $personnel_id = $which[1];
$sqlcmd = "
DELETE FROM site_personnel_role
WHERE personnel_id = '$personnel_id'
";
		last SWITCH; }
	
	if ($which[0] =~ /^411/) {
		my $site_id = $which[1];
		my $personnel_id = $which[2];
		my $id = $which[3];
		my $mod_id = $which[4];
$sqlcmd = "
INSERT INTO site_personnel_role
(site_id,personnel_id,personnel_role_id,res_module_id)
VALUES ('$site_id','$personnel_id','$id','$mod_id')
";
		last SWITCH; }
	
	if ($which[0] =~ /^412/) {
		my $site_code = $which[1];
$sqlcmd = "
SELECT DISTINCT site_id FROM site WHERE site_code = '$site_code' 
";
		last SWITCH; }
		
	if ($which[0] =~ /^413/) {
		my $res_site_name = $which[1];
		my $res_site_code = $which[2];
		my $res_site_parent_id = $which[3];
		my $site_id = $which[4];
		my $res_site_id = $which[5];
$sqlcmd = "
INSERT INTO research_site
(res_site_name,res_site_code,res_site_parent_id,site_id,res_site_id)
VALUES
('$res_site_name','$res_site_code',$res_site_parent_id,'$site_id','$res_site_id')
";
		last SWITCH; }
		
	if ($which[0] =~ /^414/) {
		my $res_site_id = $which[1];
		my $res_sitetype_id = $which[2];
$sqlcmd = "
INSERT INTO research_site_sitetype
(res_site_id,res_sitetype_id)
VALUES
('$res_site_id','$res_sitetype_id')
";
		last SWITCH; }
		
	if ($which[0] =~ /^415/) {
		my $res_site_id = $which[1];
		my $res_module_id = $which[2];
$sqlcmd = "
INSERT INTO research_site_module
(res_site_id,res_module_id)
VALUES
('$res_site_id','$res_module_id')
";
		last SWITCH; }
		
	if ($which[0] =~ /^416/) {
		my $site_code = $which[1];
$sqlcmd = "
SELECT DISTINCT site_id FROM site WHERE site_code = '$site_code' 
";
		last SWITCH; }
		
	if ($which[0] =~ /^417/) {
		my $res_site_id = $which[1];
$sqlcmd = "
DELETE FROM research_site_module
WHERE res_site_id = '$res_site_id'
";
		last SWITCH; }
	
	if ($which[0] =~ /^420/) {
		my $res_site_id = $which[1];
		my $res_module_id = $which[2];
$sqlcmd = "
INSERT INTO research_site_module
(res_site_id,res_module_id)
VALUES
('$res_site_id','$res_module_id')
";
		last SWITCH; }
	
	if ($which[0] =~ /^421/) {
		my $res_site_name = $which[1];
		my $res_site_code = $which[2];
		my $res_site_parent_id = $which[3];
		my $site_id = $which[4];
		my $res_site_id = $which[5];
$sqlcmd = "
UPDATE research_site
SET res_site_name = '$res_site_name',
	res_site_code = '$res_site_code',
	res_site_parent_id = $res_site_parent_id,
	site_id = '$site_id'
WHERE
	res_site_id = '$res_site_id'
";
		last SWITCH; }
	
	if ($which[0] =~ /^423/) {
		my $res_site_id = $which[1];
		my $res_module_id = $which[2];
$sqlcmd = "
UPDATE research_site_module
SET res_site_id = '$res_site_id',
	res_module_id = '$res_module_id'
";
		last SWITCH; }
	
	if ($which[0] =~ /^424/) {
		my $site_code = $which[1];
		my $res_sitetype_id = $which[2];
$sqlcmd = "
SELECT DISTINCT r.res_site_id, r.res_site_code
FROM research_site r, site s, research_site_sitetype st
WHERE 	st.res_sitetype_id = $res_sitetype_id AND 
	r.res_site_id=st.res_site_id AND
	s.site_id = r.site_id AND 
	s.site_code = '$site_code'
";
		last SWITCH; }
	
	if ($which[0] =~ /^425/) {
$sqlcmd = "
SELECT DISTINCT site_code, site_name FROM site
";
		last SWITCH; }
	
	if ($which[0] =~ /^426/) {
		my $site_code = $which[1];
		my $res_sitetype_ida = $which[2];
		my $res_sitetype_idb = $which[3];
		my $site_id = $which[4];
$sqlcmd = "
SELECT DISTINCT r.res_site_code, r.res_site_name 
FROM research_site r, research_site_module m, research_site_sitetype st
WHERE r.site_id = '$site_id' AND 
	st.res_sitetype_id >= '$res_sitetype_ida' AND 
	st.res_sitetype_id <= '$res_sitetype_idb' AND 
	r.res_site_id = m.res_site_id AND
	r.res_site_id = st.res_site_id AND
	st.res_sitetype_id > 1
";
		last SWITCH; }
	
	if ($which[0] =~ /^427/) {
$sqlcmd = "
SELECT distinct rtrim(last_name), rtrim(first_name), s.site_code
FROM personnel as p, 
	site_personnel_role as spr,
	site as s
WHERE p.personnel_id = spr.personnel_id and
	s.site_id = spr.site_id
";
#SELECT rtrim(last_name), first_name
#FROM personnel
		last SWITCH; }
	
	if ($which[0] =~ /^428/) {
		my $site_code = $which[1];
		my $site_name = $which[2];
$sqlcmd = "
SELECT site_id,loc1,loc2,latitude_dec,longitude_dec,hydro_data_url,clim_data_url,usgs_data_url,site_url 
FROM site s 
WHERE site_code = '$site_code' AND site_name = '$site_name'
";
		last SWITCH; }
	
	if ($which[0] =~ /^429/) {
		my $res_site_code = $which[1];
		my $res_site_name = $which[2];
		my $r_sitetype = $which[3];
		my $op = '=';
		if ($r_sitetype == 0) {
			$op = '>';
		}
$sqlcmd = "
SELECT r.res_site_id,st.res_sitetype_id,r.res_site_code,r.res_site_parent_id 
FROM research_site r, research_site_module m, research_site_sitetype st
WHERE r.res_site_id = m.res_site_id AND 
	r.res_site_id = st.res_site_id AND 
	r.res_site_code = '$res_site_code' AND 
	r.res_site_name = '$res_site_name' AND
	st.res_sitetype_id $op '$r_sitetype'
";
		last SWITCH; }
		
	if ($which[0] =~ /^430/) {
		my $first_name = $which[1];
		my $last_name = $which[2];
		my $site_id = $which[3];
$sqlcmd = "
SELECT p.personnel_id,middle_name,address,city,state,postal_code,country,telephone1,telephone2,email1,email2,fax1,fax2,r.site_id,r.res_module_id 
FROM personnel p, site_personnel_role r 
WHERE first_name = '$first_name' AND 
	last_name = '$last_name' AND 
	p.personnel_id = r.personnel_id AND
	r.site_id = '$site_id'
";
		last SWITCH; }
	
	if ($which[0] =~ /^431/) {
		my $first_name = $which[1];
		my $last_name = $which[2];
		my $site_id = $which[3];
$sqlcmd = "
SELECT distinct personnel_role_id 
FROM personnel p, site_personnel_role r 
WHERE first_name = '$first_name' AND 
	last_name = '$last_name' AND 
	p.personnel_id = r.personnel_id AND
	r.site_id = '$site_id'
";
		last SWITCH; }
	
	if ($which[0] =~ /^432/) {
		my $first_name = $which[1];
		my $last_name = $which[2];
		my $site_id = $which[3];
$sqlcmd = "
SELECT distinct res_module_id 
FROM personnel p, site_personnel_role r 
WHERE first_name = '$first_name' AND 
	last_name = '$last_name' AND 
	p.personnel_id = r.personnel_id AND
	r.site_id = '$site_id'
";
		last SWITCH; }

	if ($which[0] =~ /^433/) {
$sqlcmd = "
DELETE FROM personnel_mailing_list
";
		last SWITCH; }

	if ($which[0] =~ /^434/) {
$sqlcmd = "
INSERT INTO personnel_mailing_list (mailing_list_id,personnel_id) 
SELECT DISTINCT '1', personnel_id FROM site_personnel_role 
WHERE res_module_id=2 AND (personnel_role_id=3 or personnel_role_id=5)
";
		last SWITCH; }

	if ($which[0] =~ /^435/) {
$sqlcmd = "
INSERT INTO personnel_mailing_list (mailing_list_id,personnel_id) 
SELECT DISTINCT '2', personnel_id FROM site_personnel_role 
WHERE res_module_id=2
";
		last SWITCH; }

	if ($which[0] =~ /^436/) {
$sqlcmd = "
INSERT INTO personnel_mailing_list (mailing_list_id,personnel_id) 
SELECT DISTINCT '3', personnel_id FROM site_personnel_role 
WHERE res_module_id=1 AND (personnel_role_id=3 or personnel_role_id=5)
";
		last SWITCH; }

	if ($which[0] =~ /^437/) {
$sqlcmd = "
INSERT INTO personnel_mailing_list (mailing_list_id,personnel_id) 
SELECT DISTINCT '4', personnel_id FROM site_personnel_role 
WHERE res_module_id=1
";
		last SWITCH; }
	
	if ($which[0] =~ /^438/) {
$sqlcmd = "
SELECT mailing_list_name 
FROM mailing_list
";
		last SWITCH; }

	if ($which[0] =~ /^439/) {
		my $mailing_list_id = $which[1]+1;

$sqlcmd = "
SELECT DISTINCT email1 
FROM personnel p,
	personnel_mailing_list l,
	site_personnel_role spr
WHERE l.mailing_list_id = $mailing_list_id AND
	l.personnel_id = p.personnel_id AND
	l.personnel_id = spr.personnel_id AND
	spr.personnel_role_id != 6
";
		last SWITCH; }		

	if ($which[0] =~ /^440/) {
		my $site_id = $which[1];
$sqlcmd = "
SELECT rsm.res_module_id
FROM research_site_module rsm,
	research_site r, research_site_sitetype st
WHERE r.site_id = $site_id AND
	r.res_site_id = rsm.res_site_id AND
	r.res_site_id = st.res_site_id AND
	st.res_sitetype_id = 1
";
		last SWITCH; }

	if ($which[0] =~ /^441/) {
#		my $res_site_code = $which[1];
#		my $res_site_name = $which[2];
		my $res_site_id = $which[1];
$sqlcmd = "
SELECT res_module_id 
FROM research_site r, research_site_module m
WHERE r.res_site_id = m.res_site_id AND 
	r.res_site_id = '$res_site_id'
";
#r.res_site_code = '$res_site_code' AND 
#	r.res_site_name = '$res_site_name' AND
		last SWITCH; }

	if ($which[0] =~ /^442/) {
		my $site_id = $which[1];
$sqlcmd = "
SELECT r.res_site_id
FROM research_site r, research_site_sitetype st
WHERE r.site_id = '$site_id' AND
	r.res_site_id=st.res_site_id AND
	st.res_sitetype_id = '1'
";
		last SWITCH; }

	if ($which[0] =~ /^443/) {
		my $res_site_id = $which[1];
$sqlcmd = "
DELETE FROM research_site_sitetype
WHERE res_site_id = '$res_site_id'
";
		last SWITCH; }

	if ($which[0] =~ /^501a/) {
		my $temp = $which[1];
$sqlcmd = "
drop table $temp
";
		last SWITCH; }		

	if ($which[0] =~ /^501b/) {
$sqlcmd = "
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
";
		last SWITCH; }		
	
	if ($which[0] =~ /^501c/) {
$sqlcmd = "
	select vd.site_code, count(distinct(res_site_id)) as ms_stns into #metstn  
  from climdb_site_variable_dates vd
  where res_site_id in (select vd.res_site_id from climdb_site_variable_dates vd,research_site_sitetype st
     where vd.res_site_id=st.res_site_id and st.res_sitetype_id=4)
  group by vd.site_code order by vd.site_code
";
		last SWITCH; }		

	if ($which[0] =~ /^501d/) {
$sqlcmd = "
select vd.site_code, count(distinct(res_site_id)) as gs_stns into #gsstn  
  from climdb_site_variable_dates vd
  where res_site_id in (select vd.res_site_id from climdb_site_variable_dates vd,research_site_sitetype st
    where vd.res_site_id=st.res_site_id and st.res_sitetype_id=3)
    group by vd.site_code order by vd.site_code
";
		last SWITCH; }		

	if ($which[0] =~ /^501e/) {
$sqlcmd = "
select #all_sites.site_code,#all_sites.site_name,isnull(#gsstn.gs_stns,0) as gs_stns,isnull(#metstn.ms_stns,0) as ms_stns,
  #all_sites.first_seen,#all_sites.most_recent,#all_sites.last_update
  from #all_sites left join #metstn on #all_sites.site_code=#metstn.site_code
  left join #gsstn on #all_sites.site_code=#gsstn.site_code
";
		last SWITCH; }		

	if ($which[0] =~ /^501f/) {
		my $res_module_id = $which[1];
$sqlcmd = "
select vd.site_code, s.site_name,
  count(distinct(res_site_id)) as ms_stns,
  convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, 
  convert(character(12),max(vd.last_update),110) as last_update
  into #metstn  
  from climdb_site_variable_dates vd, site s
  where res_site_id in (select vd.res_site_id 
from climdb_site_variable_dates vd,research_site_sitetype st
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=4)
  and vd.site_code in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=$res_module_id and rs.res_site_parent_id is null)
  and vd.site_code=s.site_code
    group by vd.site_code,s.site_name order by vd.site_code
";
		last SWITCH; }		

	if ($which[0] =~ /^501g/) {
		my $res_module_id = $which[1];
$sqlcmd = "
select vd.site_code, s.site_name,count(distinct(res_site_id)) as gs_stns,convert(character(12),min(vd.first_seen),110) as first_seen,
  convert(character(12),max(vd.most_recent),110) as most_recent, convert(character(12),max(vd.last_update),110) as last_update
  into #gsstn  
  from climdb_site_variable_dates vd, site s
  where res_site_id in (select vd.res_site_id from climdb_site_variable_dates vd,research_site_sitetype st
  where vd.res_site_id=st.res_site_id and st.res_sitetype_id=3)
  and vd.site_code in (select rs.res_site_code from research_site rs, research_site_module rsm 
    where rs.res_site_id=rsm.res_site_id and rsm.res_module_id=$res_module_id and rs.res_site_parent_id is null)
  and vd.site_code=s.site_code
    group by vd.site_code,s.site_name order by vd.site_code
";
		last SWITCH; }		

	if ($which[0] =~ /^501h/) {
$sqlcmd = "
select ms.site_code, ms.site_name,isnull(ms.ms_stns,0) as ms_stns,isnull(gs.gs_stns,0) as gs_stns,
ms.first_seen,
ms.most_recent,
ms.last_update
  from #metstn ms left join #gsstn gs on gs.site_code=ms.site_code
";
		last SWITCH; }		

	if ($which[0] =~ /^501i/) {
$sqlcmd = "
select gs.site_code, gs.site_name,gs.gs_stns as gs_stns,isnull(ms.ms_stns,0) as met_stns,
gs.first_seen,
gs.most_recent,
gs.last_update
  from #gsstn gs left join #metstn ms on gs.site_code=ms.site_code
";
		last SWITCH; }		

	if ($which[0] =~ /^501j/) {
$sqlcmd = "
select vd.site_code, s.site_name,
  count(distinct(res_site_id)) as gs_stns,
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
";
		last SWITCH; }		


	if ($which[0] =~ /^502/) {
		my $res_module_id = $which[1];
		my $operator = $which[2];
$sqlcmd = "
SELECT vd.site_code,
	rst.res_sitetype_desc,
	rs.res_site_code,
	rs.res_site_name,
	CONVERT(character(12),min(vd.first_seen),110) AS first_seen,
  	CONVERT(character(12),max(vd.most_recent),110) AS most_recent, 
	CONVERT(character(12),max(vd.lASt_update),110) AS last_update
FROM climdb_site_variable_dates vd, 
	research_site rs, 
	research_site_sitetype st,
	research_site_type rst
WHERE vd.variable 
in (	SELECT v.variable 
	FROM climdb_variables v, 
	research_site_module rsm, 
	research_module_descriptor m 
    	WHERE v.descriptor_category_id=m.descriptor_category_id AND 
	rsm.res_module_id $operator $res_module_id)  
and vd.res_site_id 
in (	SELECT rs.res_site_id 
	FROM research_site rs, 
	research_site_module rsm 
	WHERE rs.res_site_id=rsm.res_site_id AND 
	rsm.res_module_id $operator $res_module_id  )
and vd.site_id 
in (	SELECT rs.site_id 
	FROM research_site rs, 
	research_site_module rsm 
    	WHERE rs.res_site_id=rsm.res_site_id AND 
	rsm.res_module_id $operator $res_module_id AND 
	rs.res_site_parent_id is null) AND
vd.res_site_id=rs.res_site_id AND
vd.res_site_id=st.res_site_id AND
rst.res_sitetype_id=st.res_sitetype_id
GROUP BY vd.site_code,
	rst.res_sitetype_desc,
	rs.res_site_code,
	rs.res_site_name,
	st.res_sitetype_id 
ORDER BY vd.site_code,
	st.res_sitetype_id desc,
	rs.res_site_code
";
		last SWITCH; }		
	#(rsm.res_module_id=1 or rsm.res_module_id=2)) 

	if ($which[0] =~ /^503/) {
		my $res_module_id = $which[1];
		my $operator = $which[2];
$sqlcmd = "
SELECT	vd.site_code, 
		vd.station,
		v.variable_name,
		convert(varchar,min(vd.first_seen),110) as begin_date, 
		convert(varchar,max(vd.most_recent),110) as end_date, 
		convert(character(12),max(vd.last_update),110) as last_update
FROM	climdb_site_variable_dates vd,
		climdb_variables v
WHERE	v.variable_name IN 
			(SELECT v.variable_name 
			FROM	climdb_variables v,
					research_site_module rsm	
			WHERE v.variable = vd.variable)
		AND vd.res_site_id IN 
			(SELECT rs.res_site_id 
				FROM	research_site rs,
						research_site_module rsm,
						climdb_site_variable_dates vd 
				WHERE	vd.res_site_id=rs.res_site_id 
						AND rs.res_site_id = rsm.res_site_id 
						AND rsm.res_module_id $operator $res_module_id
			)
GROUP BY vd.site_code,vd.station,v.variable_name
ORDER BY vd.site_code,vd.station,v.variable_name
";
		last SWITCH; }		
	#AND rs.res_site_parent_id is null

	if ($which[0] =~ /^504/) {
		my $res_module_id = $which[1];
$sqlcmd = "
SELECT DISTINCT rs.res_site_code, 
 	rs.res_site_name, 
	'fullname'=
		rtrim(p.first_name)+' '+rtrim(p.middle_name)+' '+rtrim(p.last_name),
	pr.personnel_role_desc, 
 	p.email1, 
	rsd.descriptor_value
FROM site_personnel_role spr, 
	personnel p, 
	personnel_role pr,
	site s,
	research_site rs,
	research_site_descriptor rsd, 
	research_site_module rsm
WHERE p.personnel_id=spr.personnel_id AND
	spr.personnel_role_id=pr.Personnel_role_id AND 
	spr.site_id=s.site_id AND 
	s.site_id=rs.site_id AND 
	rs.res_site_id=rsm.res_site_id AND
	rs.res_site_id=rsd.res_site_id AND
	rsd.descriptor_type_id=233 AND 
	spr.res_module_id=$res_module_id AND 
	rs.res_site_parent_id is null AND
	spr.personnel_role_id!=6
ORDER BY rs.res_site_code, pr.personnel_role_desc desc
";

		last SWITCH; }		

	if ($which[0] =~ /^505a/) {
		my $res_module_id = $which[1];
		my $operator = $which[2];
$sqlcmd = "
SELECT rsd.res_site_id,rs.res_site_code,dt.descriptor_type_id,dct.descriptor_category_id,
  substring(dt.descriptor_type_code,1,PATINDEX('%qc%',dt.descriptor_type_code)-2) as descr,
  rsd.descriptor_value as qcmin into #qcmin
  from research_site_descriptor rsd, descriptor_type dt,research_site rs,descriptor_category_type dct
  where rsd.descriptor_type_id=dt.descriptor_type_id and dt.descriptor_type_code like '%_qc_min%' and
	rsd.res_site_id=rs.res_site_id and dct.descriptor_type_id=dt.descriptor_type_id and
	rsd.res_site_id in (SELECT rs.res_site_id 
		FROM research_site rs,research_site_module rsm,climdb_site_variable_dates vd 
		WHERE	vd.res_site_id=rs.res_site_id 
		AND rs.res_site_id = rsm.res_site_id AND rsm.res_module_id $operator $res_module_id)
";
		last SWITCH; }


	if ($which[0] =~ /^505b/) {
		my $res_module_id = $which[1];
		my $operator = $which[2];
$sqlcmd = "
SELECT rsd.res_site_id,rs.res_site_code,dt.descriptor_type_id,dct.descriptor_category_id,
  substring(dt.descriptor_type_code,1,PATINDEX('%qc%',dt.descriptor_type_code)-2) as descr,
  rsd.descriptor_value as qcmax  into #qcmax
  from research_site_descriptor rsd, descriptor_type dt,research_site rs,descriptor_category_type dct
  where rsd.descriptor_type_id=dt.descriptor_type_id and dt.descriptor_type_code like '%_qc_max%' and
	rsd.res_site_id=rs.res_site_id and dct.descriptor_type_id=dt.descriptor_type_id and
	rsd.res_site_id in (SELECT rs.res_site_id 
		FROM research_site rs,research_site_module rsm,climdb_site_variable_dates vd 
		WHERE	vd.res_site_id=rs.res_site_id 
		AND rs.res_site_id = rsm.res_site_id AND rsm.res_module_id $operator $res_module_id)
";
		last SWITCH; }

	if ($which[0] =~ /^505c/) {
$sqlcmd = "
SELECT mn.res_site_id,mn.res_site_code,mn.descriptor_category_id,mn.descr,
  mn.qcmin as qcmin,mx.qcmax as qcmax into #qc
  from #qcmin mn left join #qcmax mx on mn.res_site_id=mx.res_site_id and 
  mn.res_site_code=mx.res_site_code and mn.descr=mx.descr and 
  mn.descriptor_category_id=mx.descriptor_category_id
";
		last SWITCH; }		
		
	if ($which[0] =~ /^505d/) {
$sqlcmd = "
SELECT	vd.site_code, 
		vd.station,
		v.variable_name,
		convert(varchar,min(vd.first_seen),110) as begin_date, 
		convert(varchar,max(vd.most_recent),110) as end_date, 
		convert(character(12),max(vd.last_update),110) as last_update,
		qc.qcmin, qc.qcmax
	FROM	climdb_site_variable_dates vd,
		climdb_variables v,
		research_site_descriptor rsd,
		#qc qc
	WHERE	v.variable_name IN 
			(SELECT v.variable_name 
			FROM	climdb_variables v,
					research_site_module rsm	
			WHERE v.variable = vd.variable
			)
		AND v.descriptor_category_id=qc.descriptor_category_id
		AND v.variable = vd.variable
		AND qc.res_site_id=vd.res_site_id
GROUP BY vd.site_code,vd.station,v.variable_name,qc.qcmin,qc.qcmax
ORDER BY vd.site_code,vd.station,v.variable_name
";
		last SWITCH; }	
				
	if ($which[0] =~ /^601/) {
		my $variable = $which[1];
$sqlcmd = "
SELECT variable_name FROM climdb_variables WHERE variable='$variable'
";
		last SWITCH; }		
	
	if ($which[0] =~ /^602/) {
		my $site = $which[1];
		my $station = $which[2];
		my $variable = $which[3];
$sqlcmd = "
SELECT DATEADD(day,1,max(sampledate)) FROM climdb..climdb_raw WHERE site_code = '$site' and station = '$station' and variable = '$variable'
";
		last SWITCH; }		

	if ($which[0] =~ /^700/) {
		my $descriptor_category_id = $which[1];
$sqlcmd = "
SELECT	descriptor_type_name, 
		descriptor_type_desc, 
		descriptor_type_unit
FROM	descriptor_type dt, 
		descriptor_category_type dct
WHERE 	dt.descriptor_type_id = dct.descriptor_type_id  AND
		dct.descriptor_category_id = $descriptor_category_id 
ORDER BY type_order
";
		last SWITCH; }		
	
	if ($which[0] =~ /^701/) {
		my $descriptor_category_id = $which[1];
$sqlcmd = "
SELECT 	dc.descriptor_category_desc, dt.descriptor_type_unit
FROM 	descriptor_category dc,
	descriptor_category_type dct,
	descriptor_type dt
WHERE 	dc.descriptor_order > $descriptor_category_id  and
	dc.descriptor_category_id = dct.descriptor_category_id and
	dct.descriptor_type_id = dt.descriptor_type_id and
	dt.descriptor_type_name = 'Minimum QC Threshold'
ORDER BY dc.descriptor_order
";
		last SWITCH; }		

	if ($which[0] =~ /^702/) {
$sqlcmd = "
SELECT DISTINCT dc.descriptor_category_id,
				dc.descriptor_category_desc,
				dc.descriptor_order
FROM			descriptor_category_type dct,
				descriptor_category dc
WHERE			dc.descriptor_order < 8 AND
				dc.descriptor_category_id != 2
ORDER BY		dc.descriptor_order
";
		last SWITCH; }		
	
	
	
	}

print POO " xxx $which[0]\n$sqlcmd\n";
return($sqlcmd);
}
1;






