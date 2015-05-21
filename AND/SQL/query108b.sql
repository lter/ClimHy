SELECT a.descriptor_type_id, a.descriptor_type_desc,
		a.descriptor_type_name,
		a.descriptor_type_length, b.descriptor_value
	FROM descriptor_type a, research_site_descriptor b, descriptor_category_type c
	WHERE b.res_site_id=157 AND 
		a.descriptor_type_id=b.descriptor_type_id AND
		b.descriptor_type_id=c.descriptor_type_id AND
		a.descriptor_type_id in (SELECT descriptor_type_id
	FROM descriptor_category_type
	WHERE descriptor_category_id=16)
	ORDER by c.type_order

SELECT a.descriptor_type_id, a.descriptor_type_desc,
		a.descriptor_type_name,
		a.descriptor_type_length, b.descriptor_value
	FROM descriptor_type a, research_site_descriptor b, descriptor_category_type c
	WHERE b.res_site_id=157 AND 
		a.descriptor_type_id=b.descriptor_type_id AND
		b.descriptor_type_id=c.descriptor_type_id AND
		a.descriptor_type_id in (SELECT descriptor_type_id
	FROM descriptor_category_type
	WHERE descriptor_category_id=16)
	ORDER by c.type_order

SELECT a.descriptor_type_id, a.descriptor_type_desc,a.descriptor_type_name,
		a.descriptor_type_length, b.descriptor_value
	FROM descriptor_type a, descriptor_category_type c left outer join research_site_descriptor b
	on a.descriptor_type_id=b.descriptor_type_id
	WHERE c.descriptor_category_id=16 AND b.res_site_id=157 AND a.descriptor_type_id=c.descriptor_type_id

SELECT descriptor_type_id FROM descriptor_category_type	WHERE descriptor_category_id=16
  AND descriptor_type_id in (
select a.descriptor_type_id from research_site_descriptor a, descriptor_category_type c 
	where a.res_site_id=157 AND descriptor_category_id=16 AND a.descriptor_type_id=c.descriptor_type_id)

SELECT a.descriptor_type_id FROM descriptor_category_type a
  left outer join on research_site_descriptor b
  on a.descriptor_type_id=b.descriptor_type_id
  join on 
select b.descriptor_type_id from research_site_descriptor b, descriptor_category_type c 
	where b.res_site_id=157 AND c.descriptor_category_id=16 AND b.descriptor_type_id=c.descriptor_type_id)

WHERE c.descriptor_category_id=16