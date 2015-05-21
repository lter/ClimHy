
--	if ($which[0] =~ /^13$/) {
		my $res_site_code = $which[1];
		my $site_id = $which[2];

	SELECT r.res_site_id
	FROM research_site r, research_site_sitetype st
	WHERE r.res_site_code = 'NEVERSINK' AND
		r.res_site_id=st.res_site_id AND
		st.res_sitetype_id>2 AND
		 r.site_id = 24
