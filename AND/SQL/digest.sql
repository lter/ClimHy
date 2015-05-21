--Commands to run for the digestion phase of harvest.pl
-- Need to change the res_site_id's
-- 

--	if ($which[0] =~ /^207$/) {
DELETE climdb_site_variable_dates WHERE res_site_id=376 or res_site_id=379
	
--	if ($which[0] =~ /^209$/) {
INSERT INTO climdb_site_variable_dates 
 SELECT  res_site_id,
	 site_id,
	 site_code,
	 station,variable, 
     min(sampledate) AS first_seen,
     max(sampledate) AS most_recent,
     max(last_update) AS last_update
 FROM climdb_raw
 WHERE res_site_id=379
 GROUP BY res_site_id,site_id,site_code,station,variable
	
--	if ($which[0] =~ /^210$/) {
DELETE climdb_agg WHERE res_site_id=376 or res_site_id=379
	
/*Get the monthly average of daily values for all variables WHERE an "average"
# is appropriate. Also, count the number of valid days included in the monthly 
# value, AND the number of days estimated in the month.  Additionally, 
# only compute monthly means for currently harvested stations - this is a 
# time saver to prevent the entire aggregate table FROM being recalculated*/
--	if ($which[0] =~ /^211$/) {
INSERT into climdb_agg SELECT
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
      res_site_id=379
  group by 
	site_code,res_site_id,site_id,station,r.variable,datepart(year,sampledate),
	datepart(month,sampledate)
		     

/*Get the annual average of daily values for all variables WHERE an "average"
#is appropriate. Also, count the number of valid days included in the annual 
#value, AND the number of days estimated in the year.  Additionally, 
#only compute annual means for currently harvested stations - this is a 
#time saver to prevent the entire aggregate table FROM being recalculated*/
--	if ($which[0] =~ /^212$/) {
INSERT into climdb_agg SELECT 
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
      res_site_id=379
  group by 
   site_code,res_site_id,site_id,station,r.variable,datepart(year,sampledate)
	
/*Get the mean monthly average of daily values for all variables WHERE an "average"
#is appropriate. Also, count the number of valid days included in the monthly
#value, AND the number of days estimated in the months over all years. Additionally, 
#only compute monthly means for currently harvested stations - this is a 
#time saver to prevent the entire aggregate table FROM being recalculated*/
--	if ($which[0] =~ /^213$/) {
INSERT into climdb_agg SELECT 
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
      res_site_id=379
  group by 
   site_code,res_site_id,site_id,station,r.variable,datepart(month,sampledate)

/* Get the monthly total of daily values for all variables WHERE a "total" 
# is appropriate. Also, count the number of valid days included in the monthly 
# value, AND the number of days estimated in the month.  Additionally, 
# only compute monthly totals for currently harvested stations -  this is a 
# time saver to prevent the entire aggregate table FROM being recalculated*/
--	if ($which[0] =~ /^214$/) {
INSERT INTO climdb_agg SELECT 
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
      res_site_id=379
  GROUP BY 
   res_site_id,site_id,site_code,station,r.variable,datepart(year,sampledate),
     datepart(month,sampledate)

/* Get the monthly minimum of daily values for all variables WHERE a "minimum"
# is appropriate. Also, count the number of valid days included in the monthly 
# value, AND the number of days estimated in the month.  Additionally, 
# only compute monthly minimums for currently harvested stations - this is a 
# time saver to prevent the entire aggregate table FROM being recalculated*/
--	if ($which[0] =~ /^215$/) {
INSERT INTO climdb_agg SELECT 
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
      res_site_id=379
  GROUP BY 
   res_site_id,site_id,site_code,station,r.variable,datepart(year,sampledate),
     datepart(month,sampledate)
	
/*Get the monthly maximum of daily values for all variables WHERE a "maximum"
# is appropriate. Also, count the number of valid days included in the monthly 
# value, AND the number of days estimated in the month.  Additionally, 
# only compute monthly maximums for currently harvested stations - this is a 
# time saver to prevent the entire aggregate table FROM being recalculated*/
--	if ($which[0] =~ /^216$/) {
INSERT INTO climdb_agg SELECT 
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
      res_site_id=379
  GROUP By 
   res_site_id,site_id,site_code,station,r.variable,datepart(year,sampledate),
     datepart(month,sampledate)

/*Get the annual total of daily values for all variables WHERE a "total"
#is appropriate. Also, count the number of valid days included in the annual 
#value, AND the number of days estimated in the year.  Additionally, 
#only compute annual totals for currently harvested stations - this is a 
#time saver to prevent the entire aggregate table FROM being recalculated*/
--	if ($which[0] =~ /^217$/) {
INSERT INTO climdb_agg SELECT 
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
      res_site_id=379
  GROUP BY 
   res_site_id,site_id,site_code,station,r.variable,datepart(year,sampledate)
	
/*Get the annual minimum daily value for all variables WHERE a "minimum"
#is appropriate. Also, count the number of valid days included in the annual 
#value, AND the number of days estimated in the year.  Additionally, 
#only compute annual minimum for currently harvested stations - this is a 
#time saver to prevent the entire aggregate table FROM being recalculated*/
--	if ($which[0] =~ /^218$/) {
INSERT INTO climdb_agg SELECT 
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
      res_site_id=379
  GROUP BY 
   res_site_id,site_id,site_code,station,r.variable,datepart(year,sampledate)

/*Get the annual maximum daily value for all variables WHERE a "maximum"
#is appropriate. Also, count the number of valid days included in the annual 
#value, AND the number of days estimated in the year.  Additionally, 
#only compute annual maximum for currently harvested stations - this is a 
#time saver to prevent the entire aggregate table FROM being recalculated*/
--	if ($which[0] =~ /^219$/) {
INSERT into climdb_agg SELECT 
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
      res_site_id=379
  group by 
   res_site_id,site_id,site_code,station,r.variable,datepart(year,sampledate)


/*Get the minimum monthly daily value for all variables WHERE an "minimum"
#is appropriate. Also, count the number of valid days included in the monthly
#value, AND the number of days estimated in the months over all years. Additionally, 
#only compute monthly minimums for currently harvested stations - this is a 
#time saver to prevent the entire aggregate table FROM being recalculated*/
--	if ($which[0] =~ /^220$/) {
INSERT into climdb_agg SELECT 
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
      res_site_id=379
  group by 
   res_site_id,site_id,site_code,station,r.variable,datepart(month,sampledate)

/* Get the maximum monthly daily value for all variables WHERE an "maximum"
# is appropriate. Also, count the number of valid days included in the monthly
# value, AND the number of days estimated in the months over all years. Additionally, 
# only compute monthly maximums for currently harvested stations - this is a 
# time saver to prevent the entire aggregate table FROM being recalculated*/
--	if ($which[0] =~ /^221$/) {
INSERT into climdb_agg SELECT 
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
      res_site_id=379
  group by 
   res_site_id,site_id,site_code,station,r.variable,datepart(month,sampledate)
		
/*Get the monthly total of daily values for all variables WHERE a "total"
#is appropriate. Also, count the number of valid days included in the monthly
#value, AND the number of days estimated in the months over all years. Additionally, 
#only compute month totals for currently harvested stations - this is a 
#time saver to prevent the entire aggregate table FROM being recalculated*/
--	if ($which[0] =~ /^222$/) {
INSERT INTO climdb_agg SELECT 
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
      res_site_id=379
  GROUP BY 
   res_site_id,site_id,site_code,station,variable,month

