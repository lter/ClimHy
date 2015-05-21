 xxx 1
SELECT distinct s.site_code, rsd.descriptor_value 
FROM site s,
research_site_descriptor rsd,
research_site r
WHERE s.site_id = r.site_id 
AND r.res_site_id = rsd.res_site_id 
AND rsd.descriptor_type_id = 232
 xxx 2
SELECT distinct s.site_code, s.site_name 
FROM site s,
research_site_module m,
research_site r
WHERE s.site_id = r.site_id 
AND r.res_site_id = m.res_site_id 
 xxx 3
SELECT p.email1, p.first_name, p.last_name 
FROM personnel p,
site_personnel_role r,
site s
WHERE p.email1 != 'null' AND s.site_id = r.site_id
AND r.personnel_id = p.personnel_id AND s.site_code = 'CWT' 
AND r.personnel_role_id = '3' AND r.res_module_id = '3'
 xxx 11
SELECT variable_name, variable 
	FROM climdb_variables
 xxx 12
SELECT site_id, site_name,	site_code
	FROM site
	WHERE site_code = 'CWT'
 xxx 13
SELECT r.res_site_id, st.res_sitetype_id, r.res_site_code, r.site_id
	FROM research_site r, research_site_sitetype st
	WHERE 	r.res_site_id=st.res_site_id AND
		st.res_sitetype_id=3 AND
		r.site_id = '7'
 xxx 14
SELECT variable, QC_MIN, QC_MAX, descriptor_category_id 
FROM climdb_variables
 xxx 15
SELECT r.res_site_id,r.descriptor_value, t.descriptor_type_code
FROM research_site_descriptor r,
descriptor_type t,
descriptor_category_type c
WHERE r.descriptor_type_id = t.descriptor_type_id AND 
t.descriptor_type_id = c.descriptor_type_id AND
t.descriptor_type_code like '%q_qc_m%' AND 
r.site_id = '7'

select * from research_site_descriptor r,descriptor_type t 
  where r.descriptor_type_id=t.descriptor_type_id and
  t.descriptor_type_code like '%q_qc_m%' and r.descriptor_value>'100000'

select * from descriptor_category_type where descriptor_category_id = '6'