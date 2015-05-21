select * from masterdate
delete from masterdate

select min(sampledate) from masterdate
select * from climdb_raw where year(sampledate)=1931