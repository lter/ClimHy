select * from harvest_raw
select distinct res_site_id,site_id,station from harvest_raw

--to run harvest_raw
--sqlagent must be a user on the IIS server
TRUNCATE TABLE harvest_raw

ALTER TABLE harvest_raw 
  DROP CONSTRAINT PK_harvest_raw

BULK INSERT harvest_raw FROM '\\ZIRCOTE\lter\climhy\data\AND.out'
WITH (
DATAFILETYPE = 'char',
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)

BULK INSERT harvest_raw 
  FROM '\\GINKGO\forwww\lter\climhy\data\and.out' 
  WITH ( DATAFILETYPE = 'char', FIELDTERMINATOR = ',', ROWTERMINATOR = '\n' )

select distinct site_code,station,sampledate from harvest_raw
  group by site_code,station,sampledate,variable
  having count(*)>1


ALTER TABLE harvest_raw 
  ADD CONSTRAINT PK_harvest_raw
  PRIMARY KEY (res_site_id,sampledate,variable)


delete harvest_raw where station='LTER1'


--proposed idea
--to find duplicates in harvest_raw
drop PK constraint on harvest_raw
bulk insert
select for duplicates
  if no dups, add PK constaint back and continue
  else
  report 1st 10 duplicates and discontinue digestion
  should not report # of records ingested

