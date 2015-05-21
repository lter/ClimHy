#!/usr/bin/perl
## sitedb.pl
##
# Version 2.0
## Kyle Kotwica 3-2003
## Takes user data over CGI and updates data base
#
# This program consists of 4 pages of html;
# page 1 - Called from web page by sitedb.pl?use=[report|update].
# 		This page prompts 
#		the user to choose a site and a variable category. 
# page 2 - This page receives the choices submitted above and prompts the
#		user for research site.
# page 3 - This page takes the data collected so far and displays the present
# 		content of the database for the selected variables. The user is then
#		allowed to update the contents of the database.
# page 4 - Calling this page executes the update and displays some feedback.

use FindBin qw($Bin);
use lib "$Bin/lib";

open POO, ">log/query.log";

use strict;
use clim_lib;
use sql_cmd;
#use CGI qw(-nph);
use CGI;
use DBI;
use CGI::Carp qw(fatalsToBrowser);

#read control file 
my %control = &read_control();	

#connect with database
my $dbh = DBI->connect($control{data_source},$control{data_user},$control{data_password}) || print "Connect failure in $0 \n";

my $cgi = new CGI;
#print $cgi->header(-nph => 1, -expires=>'now');
#print $cgi->header(-expires=>'now');
#JAMES EDITED
my $request_method = $cgi->request_method();
my ($sqlcmd,$page);

my ($use,$res_sitetype_id,$style );
my ($descriptor_category_id,$site_id,%site_id_list);
my ($res_site_id,$site_name,$descriptor_category_desc,$res_site_name,$descriptor_type_id);	
my %update_hash;

$style = $control{all_css};
	
#if 'GET' get first page
if($request_method eq 'GET'){				

	$use = $cgi->param('use');
	if ($use =~ /Confirmation/) { 
		print $cgi->start_html(-title=>'Cheater!',-author=>'kyle.kotwica@comcast.net',-style=>{'src'=>"$style"});
		print "<FONT COLOR=red><H1>You are not authorized to view this page</H1></FONT>";
		print "If you think this is in error please contact the database administrator <A HREF='mailto:$control{email}'>$control{email}.</A><P>";
		exit();
	}
#	print $cgi->header(-nph => 1,-expires=>'now');
	print $cgi->header(-expires=>'now');
#JAMES EDITED
	&draw_page1();
} else {	
	$page = ($cgi->param('page') + 1);
	if ($page == 1) {
		$use = $cgi->param('use');
		my $password = $cgi->param('password');
		print $cgi->header(-expires=>'now');
#JAMES EDITED
#		print $cgi->header(-nph => 1,-expires=>'now');
		&draw_page1();
	}
	
	if ($page == 2){
		# get site, desc_cat_id, and module
		$site_id = $cgi->param('site');
		$descriptor_category_id = $cgi->param('desc_cat_id');
		$use = $cgi->param('use');
		my $password = $cgi->param('password');
		if ( (!$password) && ($use =~ /Report|Confirmation/) ) { 
			$password = $control{password}; 
			if ($use =~ /Confirmation/) {
				$use = 'Update'; }
		}
		&encrypt($password);
		
		$sqlcmd = &get_cmd('103',$descriptor_category_id);
		my @res_sitetype_id = &query_DB($sqlcmd,'array',$dbh);
		$sqlcmd = &get_cmd('104',$site_id,@res_sitetype_id);
		%site_id_list = &query_DB($sqlcmd,'hash',$dbh);
		&draw_page2();
	}
	if ($page == 3){
		print $cgi->header();
#JAMES EDITED
#		print $cgi->header(-nph => 1);
		&prepare_page3();
		&draw_page3();
	}
	if ($page == 4){
		#  get all parameters sent and put them in a hash
		%update_hash = $cgi->Vars;
		&draw_page4();
	}
}

## PREPARE_PAGE3
## get everything ready for the html do it here so I can use it for page 4
sub prepare_page3 {
	# get res_site_id, descriptor_category_id, and site_id
	$res_site_id = $cgi->param('site');
	$descriptor_category_desc = $cgi->param('descriptor_category_desc');
	$site_name = $cgi->param('site_name');
	$descriptor_category_id = $cgi->param('descriptor_category_id');
	$site_id = $cgi->param('site_id');
	$use = $cgi->param('use');
	#$password = $cgi->param('password');
	$sqlcmd = &get_cmd('105',$descriptor_category_id);
	$descriptor_category_desc = &query_DB($sqlcmd,'value',$dbh);
	#get number of res_site_id's
	$sqlcmd = &get_cmd('106a',$descriptor_category_id);
	$descriptor_type_id = &query_DB($sqlcmd,'value',$dbh);
	$sqlcmd = &get_cmd('106b',$res_site_id,$descriptor_type_id);
	my $count = &query_DB($sqlcmd,'value',$dbh);
	$sqlcmd = &get_cmd('106c',$res_site_id);
	$res_site_name = &query_DB($sqlcmd,'value',$dbh);
	#if none
	if ($count == 0){
		$sqlcmd = &get_cmd('107',$res_site_id,$site_id,$descriptor_category_id);
		&query_DB($sqlcmd,'do',$dbh);
	}
}

## DRAW_PAGE4
## update the Database and display results via page3

sub draw_page4{

	print $cgi->header();
#	print $cgi->header(-nph => 1);
#JAMES EDITED
	print $cgi->start_html(-title=>'Page 4',-author=>'kyle.kotwica@comcast.net',-style=>{'src'=>"$style"});
	my $password = $cgi->cookie('password');
	if (crypt($control{password},$password) ne $password) {
			print "<FONT COLOR=red><H1>You are not authorized to view this page</H1></FONT>";
			print "If you think this is in error please contact the database administrator <A HREF='mailto:$control{email}'>$control{email}.</A><P>";
			exit();
	}
	print "<H1> You have successfully updated the CLIMDB/HYDRODB database</H1><P>";
	$res_site_id = $cgi->param('site');
	foreach my $id (keys %update_hash){
		#if (($id =~ /\d/) && ($update_hash{$id}) ){
		if ($id =~ /\d/) {
			$update_hash{$id} =~ s/'/"/g;
			$sqlcmd = &get_cmd('109',$update_hash{$id},$res_site_id,$id);
			&query_DB($sqlcmd,'do',$dbh);
			$sqlcmd = &get_cmd('110',$descriptor_category_id);
			my %name_hash = &query_DB($sqlcmd,'hash',$dbh);
		}
	}
	&prepare_page3();
	$use = "Confirmation";
	&draw_page3();

}


## DRAW_PAGE3
## Draw and receive the final set of input boxes

sub draw_page3{
	my $units;
	
	$sqlcmd = &get_cmd('108',$res_site_id,$descriptor_category_id);
	my @info = &query_DB($sqlcmd,'array',$dbh);
	
	print  $cgi->start_html(-title=>'Page 3',-author=>'kyle.kotwica@comcast.net',-style=>{'src'=>"$style"});
	if ($use eq 'Confirmation') {
		print $cgi->start_form(-method=>'post',-action=>'siteDB.pl');
		print "\n".$cgi->hidden('use','Confirmation');
		print ("\n\nWould you like to continue editing the metadata for the $site_name"."?<BR>\n");
		print "\n<P><input type=submit value='Continue Updating'></form>";
		print ("\n\nWould you like to return to the <A HREF='http://climhy.lternet.edu/harvest.html'>participant page</A>?<BR><HR>\n"); 

	} elsif ($use eq 'Update') {
		print ("\n\nWould you like to return to the <A HREF='http://climhy.lternet.edu/harvest.html'>participant page</A>?<BR><HR>\n"); 
	} elsif ($use eq 'Report') {
		print ("\n\nWould you like to return to the <A HREF='http://climhy.lternet.edu/'>data access page</A>?<BR><HR>\n"); }
	print $cgi->h1("$use of CLIMDB/HYDRODB metadata");
	print "<H2>$site_name </H2><H3><BR>$descriptor_category_desc: $res_site_name</H3>";


	if ($use eq 'Update') {
		print $cgi->start_form(-method=>'post',-action=>'siteDB.pl');
		print "\n<INPUT TYPE='hidden' NAME='page' VALUE='3'>";
		print "\n".$cgi->hidden('site',"$res_site_id");
		print "\n".$cgi->hidden('site_name',"$site_name");
		print "\n".$cgi->hidden('descriptor_category_desc',"$descriptor_category_desc");
		print "\n".$cgi->hidden('descriptor_category_id',"$descriptor_category_id");
		print "<HR>Please insert the values:<BR><TABLE WIDTH=800>\n";
		for (my $i = 0;$i<$#info;$i=$i+6){
			my $size = &box_size($info[$i+3]);
			$units = '';
			if ($info[$i+5]) {$units = "($info[$i+5])";}
			print "<TR><TD><FONT COLOR='#996600'><B>$info[$i+2]</B> $units</FONT></TD></TR>";
			print "<TR><TD><FONT SIZE=-1>$info[$i+1]</FONT></TD></TR>";
			if ($size == 0) {
				print "\n<TR><TD><FONT SIZE=-2>(Please limit your entry to 4,000 characters)</FONT></TD></TR>\n<TR><TD><textarea name=$info[$i] cols='80' rows='6' wrap='virtual'>$info[$i+4]</textarea></TD></TR>\n\n";}
			else{
				print "\n<TR><TD><input type=text size=$size name=$info[$i] value='$info[$i+4]'><BR><BR></TD></TR>\n\n";}
		}

		print "\n</TABLE><P><input type=submit value=submit></form>";
	} else {
		print "<TABLE WIDTH=800 BORDER=1>\n";
		for (my $i = 0;$i<$#info;$i=$i+6){
			my $size = &box_size($info[$i+2]);
			$units = '';
			if ($info[$i+5]) { $units = "($info[$i+5])" };
			print "<TR><TD ALIGN='center'><B>$info[$i+2]</B> $units<BR><FONT SIZE=-2>$info[$i+1]</FONT></TD></TR>\n";
			print "<TR><TD BGCOLOR=black ><FONT COLOR=white>$info[$i+4]</FONT></TD></TR>\n";
		}
		print "</TABLE>\n";
	}
	print$cgi->end_html;
}

## BOX_SIZE
# given either a 's','m', or 'l' return '25','80', or a 6 line text box.

sub box_size(){
	my $size_class = shift;
	my $size;

	if ($size_class eq 's') {$size = 25;}
	if ($size_class eq 'm') {$size = 80;}
	if ($size_class eq 'l') {$size = 0;}
	return $size;
}

## DRAW_PAGE2
#Given a variable grouping and a station prompts the user for a research site

sub draw_page2{
	$sqlcmd = &get_cmd('102b',$site_id);
	$site_name = &query_DB($sqlcmd,'value',$dbh);
	$sqlcmd = &get_cmd('102c',$descriptor_category_id);
	$descriptor_category_desc = &query_DB($sqlcmd,'value',$dbh);
	if ($use =~ /Confirmation/) {
		$use = 'Update'; }

#do HTML
	print $cgi->start_html(-title=>'Page 2',-author=>'kyle.kotwica@comcast.net',-style=>{'src'=>"$style"}),
	$cgi->h2("$use of CLIMDB/HYDRODB metadata"),
	$cgi->start_form(-method=>'post',-action=>'siteDB.pl');

	print "<INPUT TYPE='hidden' NAME='page' VALUE='2'>\n";
	print "<H3>$site_name <BR>$descriptor_category_desc</H3>";
	print "Please choose your research site:<BR>\n";
	print "<select name=site>\n";
	foreach my $key (sort {$a <=> $b} keys (%site_id_list)) {
		print "<option value=$key>$site_id_list{$key}\n";}

	print "</select>";
	print "\n".$cgi->hidden('descriptor_category_id',"$descriptor_category_id");
	print "\n".$cgi->hidden('site_id',"$site_id");
	print "\n".$cgi->hidden('descriptor_category_desc',"$descriptor_category_desc");
	print "\n".$cgi->hidden('site_name',"$site_name");
	print "\n<INPUT TYPE='hidden' NAME='use' VALUE='$use'>";
	print "\n<P><input type=submit value=submit></form>";
	print$cgi->end_html;
}

## DRAW_PAGE1
# takes the module and two sql commands to determine the available sites
# and variable groups for the given module

sub draw_page1{

	$sqlcmd = &get_cmd('101');
	my %site_list = &query_DB($sqlcmd,'sort',$dbh);
	$sqlcmd = &get_cmd('102a');
	my %desc_list = &query_DB($sqlcmd,'sort',$dbh);
	if ($use eq 'Confirmation') {
		$use = 'Continue updating'; }

#do HTML
	print $cgi->start_html(-title=>'Page 1',-author=>'kyle.kotwica@comcast.net',-style=>{'src'=>"$style"},),
	$cgi->h2("$use of CLIMDB/HYDRODB metadata"),
	$cgi->start_form(-method=>'post',-action=>'siteDB.pl');

	print $cgi->hidden('page','1');
	if ($use eq 'Update') {
		print "\n<BR>A password is required to make changes to the CLIMDB/HYDRODB metadata.<P>Please enter a password:<BR>";
		print $cgi->password_field(-name=>'password', -size=>30);
	}
	
	print "\n<HR><P>Please choose your site:<BR>\n";
	print "<select name=site>\n";
	foreach my $key (sort keys(%site_list)) {
#strip off the sort_order	
		my ($crap,$real_key) = split('\.0',$key);
		print "<option value=$real_key>$site_list{$key}\n";}

	print "</select><P>Please choose your category:<BR>\n";
	print "<select name=desc_cat_id>\n";
#sort numerically on sort_order
	foreach my $key (sort {$a <=> $b} keys(%desc_list)) {
#strip off the sort_order	
		my ($crap,$real_key) = split('\.0',$key);
		print "<option value=$real_key>$desc_list{$key}\n";
	}
	print "\n</select>";
	print "\n".$cgi->hidden('use',$use);
	print "<P><input type=submit value=submit></form>";
	&feedback("siteDB.pl?use=$use","$use of CLIMDB/HYDRODB Metadata");
	print $cgi->end_html;
}

sub encrypt {
	my $password = shift;
	my $huh = crypt($control{password},join '', ('.', '/', 0..9, 'A'..'Z', 'a'..'z')[rand 64, rand 64]);
	my $new_password = crypt($password, $huh);
	my $cookie = $cgi->cookie(-name=>'password',-value=>"$new_password");
	print $cgi->header(-cookie=>"$cookie");
	if (crypt($control{password},$new_password) ne $new_password) {
		$new_password = 'cheater';
	
		print $cgi->start_html(-title=>'Cheater!',-author=>'kyle.kotwica@comcast.net',-style=>{'src'=>"$style"});
		print "<FONT COLOR=red><H1>You are not authorized to view this page</H1></FONT>";
		print "If you think this is in error please contact the database administrator <A HREF='mailto:$control{email}'>$control{email}.</A><P>";
		exit();
	}
}

