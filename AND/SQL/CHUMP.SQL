--selects either met or gauging stations for a site
SELECT DISTINCT r.res_site_code, r.res_site_name 
FROM research_site r, research_site_module m, research_site_sitetype rss
WHERE r.site_id = 1 AND 
	m.res_module_id = 1 AND 
	r.res_site_id = m.res_site_id AND
	r.res_site_id = rss.res_site_id AND
	rss.res_sitetype_id=4

--	if ($which[0] =~ /^400/) {   ---Gets res_ite_id and site_code
		my $site_code = $which[1];
SELECT distinct r.res_site_id, r.res_site_code
FROM research_site r, site s, research_site_sitetype st
WHERE 	st.res_sitetype_id = 1 AND
	r.res_site_id=st.res_site_id AND
	s.site_id = r.site_id AND 
	s.site_code = 'NEV'


--	if ($which[0] =~ /^401/) {   ---Gets site_code
		my $site_id = $which[1];
SELECT site_code FROM site WHERE site_id = 24
	
--	if ($which[0] =~ /^402/) {
		my $site_code = $which[1];
SELECT site_id FROM site WHERE site_code = 'NEV'
	
--	if ($which[0] =~ /^403/) {
		my $table_name = $which[1];
		my $id_name = $which[2];
		my $id = $which[3];
DELETE FROM $table_name
WHERE $id_name = \'$id\'

--	if ($which[0] =~ /^404/) {
		my $id_name = $which[1];
		my $table_name = $which[2];
SELECT max($id_name) FROM $table_name
	
--	if ($which[0] =~ /^405/) {
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
	
--	if ($which[0] =~ /^406/) {
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
	
--	if ($which[0] =~ /^407/) {
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
	
--	if ($which[0] =~ /^408/) {
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
	
--	if ($which[0] =~ /^409/) {
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
	
--	if ($which[0] =~ /^410/) {
		my $personnel_id = $which[1];
$sqlcmd = "
DELETE FROM site_personnel_role
WHERE personnel_id = '$personnel_id'
";
		last SWITCH; }
	
--	if ($which[0] =~ /^411/) {
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
	
--	if ($which[0] =~ /^412/) {
		my $site_code = $which[1];
$sqlcmd = "
SELECT DISTINCT site_id FROM site WHERE site_code = 'NEV' 
";
		last SWITCH; }
		
--	if ($which[0] =~ /^413/) {
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
		
--	if ($which[0] =~ /^414/) {
		my $res_site_id = $which[1];
		my $res_sitetype_id = $which[2];
$sqlcmd = "
INSERT INTO research_site_sitetype
(res_site_id,res_sitetype_id)
VALUES
('$res_site_id','$res_sitetype_id')
";
		last SWITCH; }
		
--	if ($which[0] =~ /^415/) {
		my $res_site_id = $which[1];
		my $res_module_id = $which[2];
$sqlcmd = "
INSERT INTO research_site_module
(res_site_id,res_module_id)
VALUES
('$res_site_id','$res_module_id')
";
		last SWITCH; }
		
--	if ($which[0] =~ /^416/) {
		my $site_code = $which[1];
$sqlcmd = "
SELECT DISTINCT site_id FROM site WHERE site_code = '$site_code' 
";
		last SWITCH; }
		
--	if ($which[0] =~ /^417/) {
		my $res_site_id = $which[1];
$sqlcmd = "
DELETE FROM research_site_module
WHERE res_site_id = '$res_site_id'
";
		last SWITCH; }
	
--	if ($which[0] =~ /^420/) {
		my $res_site_id = $which[1];
		my $res_module_id = $which[2];
$sqlcmd = "
INSERT INTO research_site_module
(res_site_id,res_module_id)
VALUES
('$res_site_id','$res_module_id')
";
		last SWITCH; }
	
--	if ($which[0] =~ /^421/) {
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
	
--	if ($which[0] =~ /^423/) {
		my $res_site_id = $which[1];
		my $res_module_id = $which[2];
$sqlcmd = "
UPDATE research_site_module
SET res_site_id = '$res_site_id',
	res_module_id = '$res_module_id'
";
		last SWITCH; }
	
--	if ($which[0] =~ /^424/) {
		my $site_code = $which[1];
		my $res_sitetype_id = $which[2];
$sqlcmd = "
SELECT DISTINCT r.res_site_id, r.res_site_code
FROM research_site r, site s, research_site_sitetype st
WHERE 	st.res_sitetype_id = 3 AND 
	r.res_site_id=st.res_site_id AND
	s.site_id = r.site_id AND 
	s.site_code = 'NEV'
";
		last SWITCH; }
	
--	if ($which[0] =~ /^425/) {
$sqlcmd = "
SELECT DISTINCT site_code, site_name FROM site
";
		last SWITCH; }
	
--	if ($which[0] =~ /^426/) {
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
	
--	if ($which[0] =~ /^427/) {
$sqlcmd = "
SELECT rtrim(last_name), first_name
FROM personnel
";
		last SWITCH; }
	
--	if ($which[0] =~ /^428/) {
		my $site_code = $which[1];
		my $site_name = $which[2];
$sqlcmd = "
SELECT site_id,loc1,loc2,latitude_dec,longitude_dec,hydro_data_url,clim_data_url,usgs_data_url,site_url 
FROM site s 
WHERE site_code = '$site_code' AND site_name = '$site_name'
";
		last SWITCH; }
	
--	if ($which[0] =~ /^429/) {
		my $res_site_code = $which[1];
		my $res_site_name = $which[2];
		my $r_sitetype = $which[3];
$sqlcmd = "
SELECT r.res_site_id,st.res_sitetype_id,r.res_site_code,r.res_site_parent_id 
FROM research_site r, research_site_module m, research_site_sitetype st
WHERE r.res_site_id = m.res_site_id AND 
	r.res_site_id = st.res_site_id AND 
	r.res_site_code = '$res_site_code' AND 
	r.res_site_name = '$res_site_name' AND
	st.res_sitetype_id = '$r_sitetype'
";
		last SWITCH; }
		
--	if ($which[0] =~ /^430/) {
		my $first_name = $which[1];
		my $last_name = $which[2];
$sqlcmd = "
SELECT p.personnel_id,middle_name,address,city,state,postal_code,country,telephone1,telephone2,email1,email2,fax1,fax2,r.site_id,r.res_module_id 
FROM personnel p, site_personnel_role r 
WHERE first_name = '$first_name' AND 
	last_name = '$last_name' AND 
	p.personnel_id = r.personnel_id
";
		last SWITCH; }
	
--	if ($which[0] =~ /^431/) {
		my $first_name = $which[1];
		my $last_name = $which[2];
$sqlcmd = "
SELECT distinct personnel_role_id 
FROM personnel p, site_personnel_role r 
WHERE first_name = '$first_name' AND 
	last_name = '$last_name' AND 
	p.personnel_id = r.personnel_id
";
		last SWITCH; }
	
--	if ($which[0] =~ /^432/) {
		my $first_name = $which[1];
		my $last_name = $which[2];
$sqlcmd = "
SELECT distinct res_module_id 
FROM personnel p, site_personnel_role r 
WHERE first_name = '$first_name' AND 
	last_name = '$last_name' AND 
	p.personnel_id = r.personnel_id
";
		last SWITCH; }

--	if ($which[0] =~ /^433/) {
$sqlcmd = "
DELETE FROM personnel_mailing_list
";
		last SWITCH; }

--	if ($which[0] =~ /^434/) {
$sqlcmd = "
INSERT INTO personnel_mailing_list (mailing_list_id,personnel_id) 
SELECT DISTINCT '1', personnel_id FROM site_personnel_role 
WHERE res_module_id=2 AND (personnel_role_id=3 or personnel_role_id=5)
";
		last SWITCH; }

--	if ($which[0] =~ /^435/) {
$sqlcmd = "
INSERT INTO personnel_mailing_list (mailing_list_id,personnel_id) 
SELECT DISTINCT '2', personnel_id FROM site_personnel_role 
WHERE res_module_id=2
";
		last SWITCH; }

--	if ($which[0] =~ /^436/) {
$sqlcmd = "
INSERT INTO personnel_mailing_list (mailing_list_id,personnel_id) 
SELECT DISTINCT '3', personnel_id FROM site_personnel_role 
WHERE res_module_id=1 AND (personnel_role_id=3 or personnel_role_id=5)
";
		last SWITCH; }

--	if ($which[0] =~ /^437/) {
$sqlcmd = "
INSERT INTO personnel_mailing_list (mailing_list_id,personnel_id) 
SELECT DISTINCT '4', personnel_id FROM site_personnel_role 
WHERE res_module_id=1
";
		last SWITCH; }
	
--	if ($which[0] =~ /^438/) {
$sqlcmd = "
SELECT mailing_list_name 
FROM mailing_list
";
		last SWITCH; }

--	if ($which[0] =~ /^439/) {
		my $mailing_list_id = $which[1]+1;

$sqlcmd = "
SELECT email1 
FROM personnel p,
	personnel_mailing_list l
WHERE l.mailing_list_id = $mailing_list_id AND
	l.personnel_id = p.personnel_id
";
		last SWITCH; }		

--	if ($which[0] =~ /^440/) {
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

--	if ($which[0] =~ /^441/) {
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

--	if ($which[0] =~ /^442/) {
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
