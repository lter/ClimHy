-- into #qcmin 
select rsd.res_site_id,rs.res_site_code,dt.descriptor_type_id,dct.descriptor_category_id,
  substring(dt.descriptor_type_code,1,PATINDEX('%qc%',dt.descriptor_type_code)-2) as descr,
  rsd.descriptor_value as qcmin into #qcmin
  from research_site_descriptor rsd, descriptor_type dt,research_site rs,descriptor_category_type dct
  where rsd.descriptor_type_id=dt.descriptor_type_id and dt.descriptor_type_code like '%_qc_min%' and
	rsd.res_site_id=rs.res_site_id and dct.descriptor_type_id=dt.descriptor_type_id and
	rsd.res_site_id in (SELECT rs.res_site_id 
		FROM research_site rs,research_site_module rsm,climdb_site_variable_dates vd 
		WHERE	vd.res_site_id=rs.res_site_id 
		AND rs.res_site_id = rsm.res_site_id AND rsm.res_module_id=3)

select * from #qcmin
drop table #qcmin

-- into #qcmax 
select rsd.res_site_id,rs.res_site_code,dt.descriptor_type_id,dct.descriptor_category_id,
  substring(dt.descriptor_type_code,1,PATINDEX('%qc%',dt.descriptor_type_code)-2) as descr,
  rsd.descriptor_value as qcmax  into #qcmax
  from research_site_descriptor rsd, descriptor_type dt,research_site rs,descriptor_category_type dct
  where rsd.descriptor_type_id=dt.descriptor_type_id and dt.descriptor_type_code like '%_qc_max%' and
	rsd.res_site_id=rs.res_site_id and dct.descriptor_type_id=dt.descriptor_type_id and
	rsd.res_site_id in (SELECT rs.res_site_id 
		FROM research_site rs,research_site_module rsm,climdb_site_variable_dates vd 
		WHERE	vd.res_site_id=rs.res_site_id 
		AND rs.res_site_id = rsm.res_site_id AND rsm.res_module_id=3)

select * from #qcmax
drop table #qcmax

--join qcmin and qcmax
select mn.res_site_id,mn.res_site_code,mn.descriptor_category_id,mn.descr,
  mn.qcmin as qcmin,mx.qcmax as qcmax into #qc
  from #qcmin mn left join #qcmax mx on mn.res_site_id=mx.res_site_id and 
  mn.res_site_code=mx.res_site_code and mn.descr=mx.descr and 
  mn.descriptor_category_id=mx.descriptor_category_id

select * from #qc
drop table #qc

--NEW sqlcmd = 503
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
			WHERE v.variable = vd.variable)
		AND v.descriptor_category_id=qc.descriptor_category_id
		AND v.variable = vd.variable
		AND qc.res_site_id=vd.res_site_id
GROUP BY vd.site_code,vd.station,v.variable_name,qc.qcmin,qc.qcmax
ORDER BY vd.site_code,vd.station,v.variable_name




--Find QC_min and QC_max from research_site_descriptor
select * from descriptor_category
select * from climdb_variables

--get the qc descriptor_type_codes
select b.descriptor_category_id,b.descriptor_category_desc,a.descriptor_type_id,
       a.descriptor_type_code,a.descriptor_type_unit
 from descriptor_type a, descriptor_category b, descriptor_category_type c
  where a.descriptor_type_id=c.descriptor_type_id and
	b.descriptor_category_id=c.descriptor_category_id and
	a.descriptor_type_code like '%_qc_m%'
  order by a.descriptor_type_code

 xxx 15
SELECT r.descriptor_value, t.descriptor_type_code
FROM research_site_descriptor r,
descriptor_type t,
descriptor_category_type c
WHERE r.descriptor_type_id = t.descriptor_type_id AND 
t.descriptor_type_id = c.descriptor_type_id AND
t.descriptor_type_code like '%qc_max' AND 
c.descriptor_category_id = '21' AND 
r.res_site_id = '655'

--test sqlcmd = 503
SELECT	vd.res_site_id,vd.site_code, 
		vd.station,
		v.variable_name,
		convert(varchar,min(vd.first_seen),110) as begin_date, 
		convert(varchar,max(vd.most_recent),110) as end_date, 
		convert(character(12),max(vd.last_update),110) as last_update,
		qc.qcmin, qc.qcmax
--		ltrim(rtrim(qc.qc_min), ltrim(rtrim(qc.qc_max)
	FROM	climdb_site_variable_dates vd,
		climdb_variables v,
		research_site_descriptor rsd,
		#qc qc
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
						AND rsm.res_module_id=3)
		AND v.descriptor_category_id=qc.descriptor_category_id
		AND v.variable = vd.variable
		AND qc.res_site_id=vd.res_site_id
GROUP BY vd.res_site_id,vd.site_code,vd.station,v.variable_name,qc.qcmin,qc.qcmax
order by vd.res_site_id
ORDER BY vd.site_code,vd.station,v.variable_name

--sqlcmd = 503
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
						AND rsm.res_module_id =3
			)
GROUP BY vd.site_code,vd.station,v.variable_name
ORDER BY vd.site_code,vd.station,v.variable_name

SELECT v.variable_name 
			FROM	climdb_variables v,
					research_site_module rsm	
			WHERE v.variable = vd.variable