#! perl
use warnings;
use strict;

sub form {
	my ($entity_file_name, $sub_entity_title, $sub_entity_desc, $entity_number, $entity_id,$begin,$end) = @_;
	$sub_entity_desc =~ s/\s+$//;
	$sub_entity_title =~ /(......)../;
	my $sitecode = $1;
	$entity_file_name =~ /(.....)../;
	my $stcode = $1;
	$begin =~ s/^(\d+-\d+-\d+).*$/$1/;
	$end =~ s/^(\d+-\d+-\d+).*$/$1/;

print <<EOF;

<script language="JavaScript1.2">
	function validate() {
		var minutes=document.glitch.delta.value
		if((1440%minutes>0) || minutes<=0){
			alert("You must pick a positive integer that is a multiple of 1440.")
			return false
		}
	}
</script>

<H2>$sub_entity_title</H2>
<B>$sub_entity_desc</B><P/>

<FORM	NAME="glitch"
		ONSUBMIT="return validate()"
		METHOD="post"
		ACTION="glitch.pl"
		ENCTYPE="application/x-www-form-urlencoded">

   <INPUT TYPE=hidden NAME=entity_file_name VALUE=$entity_file_name>
   <INPUT TYPE=hidden NAME=sub_entity_title VALUE=$sub_entity_title>
   <INPUT TYPE=hidden NAME=sub_entity_desc VALUE="$sub_entity_desc">
   <INPUT TYPE=hidden NAME=entity_number VALUE="$entity_number">
   <INPUT TYPE=hidden NAME=sitecode VALUE="$sitecode">
   <INPUT TYPE=hidden NAME=entity_id VALUE="$entity_id">


   <dl><dt>Number of Minutes
<INPUT TYPE=text NAME=delta SIZE=3 VALUE='60'><BR/>
<dd><font size='-1'><i>Time interval for aggregation. Choose any positive integer that is divisible into 1440, the number of minutes in one day.</i></font></dl><P/>
<font size='-1'>*The dates that appear in the boxes include the data that are currently available in the database.</font><P/>
  <dl><dt>Begin Date: 
<INPUT TYPE=text NAME=begin SIZE = 10 VALUE='$begin'>
  <dd><font size='-1'><i>Enter the start date for data request (YYYY-MM-DD)</i></font></dl><p>
  <dl><dt>End Date: 
<INPUT TYPE=text NAME=end SIZE = 10 VALUE='$end'>
  <dd><font size='-1'><i>Enter the end date for data request (YYYY-MM-DD)</i></font></dl><p>
<INPUT TYPE=checkbox NAME=download VALUE=1 >
  Would you like to download the data as a comma delimited (.csv) file? (as opposed to viewing it in your browser)<P>

  <INPUT TYPE=submit VALUE='Calculate'>
</FORM>

<P>Welcome to GLITCH.  The GLITCH application has been developed for the convenience of the data user and provides hands-on access to Andrews Forest
meteorological data.  GLITCH provides value-added data sets which are customized for a selected station and sensor and for a selected date range and
output interval.</P>

<P>A note about aggregation…Most of the Andrews meteorological data is collected on an hourly basis.  Air temperature and solar radiation are output
every 15 minutes in recent years (since about 1995) at the benchmark stations.  This application allows for this 15 minute data to be aggregated at an
hourly interval, or for all data to be output at 15 minutes.  Note that this data can also be output at shorter time intervals, e.g., 10 minutes, but
certain assumptions are made when the requested time interval is less than the data collection time interval.  Precipitation is output on a 5 minute
basis, but the sensitivity of some gages in lighter precipitation events is not sufficient, and the data may appear discontinuous at finer aggregation
time intervals during precipitation events.</P>


EOF
;
}


sub header {
	print <<EOF;
Content-Type: text/html; charset=ISO-8859-1


<HTML><HEAD>

<STYLE TYPE="text/css">
 <!--
 BODY {font-family: arial, helvetica, sans-serif; margin: 0pt; background-color: #D0D0BF}
 TD {font-family: arial, helvetica, sans-serif}
 UL {font-family: arial, helvetica, sans-serif}
 A {font-family: arial, helvetica, sans-serif; color: #006600; }
 a:visited {font-family: arial, helvetica, sans-serif; color: #009933; }
 a:hover {font-family: arial, helvetica, sans-serif; color: #cc6600; text-decoration: none }
 CENTER {font-family: arial, helvetica, sans-serif}
 LI { list-style-type: square;}
 td.navside a:link {  color: #CCCC99; text-decoration: none; font-weight : bold}
 td.navside a:visited {  color: #CCCC99; text-decoration: none;font-weight : bold}
 td.navside a:hover {  color: #FFCB50; text-decoration: underline;font-weight : bold}
 td.navtop a:link {  color: #CCCC99; text-decoration: none;}
 td.navtop a:visited {  color: #CCCC99; text-decoration: none;}
 td.navtop a:hover {  color: #FFCB50; text-decoration: underline;}
 -->
</STYLE>


</HEAD>
<BODY TOPMARGIN="0" LEFTMARGIN="5" MARGINWIDTH="0" MARGINHEIGHT="0" BGCOLOR="#FFFFFF" TEXT="#000000" LINK="#cc6600" VLINK="#009933" ALINK="#009933">

<blockquote>
	<p>
	<FONT SIZE=5>
	<FONT SIZE=30 COLOR='red'>G</FONT>eneral <FONT SIZE=30 COLOR='red'>L</FONT>inear <FONT SIZE=30 COLOR='red'>I</FONT>ntegrator for <FONT SIZE=30 COLOR='red'>T</FONT>ime <FONT SIZE=30 COLOR='red'>CH</FONT>anging
	</FONT>
	<HR>Version 3.0<HR>

EOF
;
}

sub footer {

print <<EOF

	<TABLE WIDTH="100%" BGCOLOR="#D0D0BF" CELLSPACING="0" CELLPADDING="2" BORDER="0">
	 <TR>
	  <TD align="center">
	
	<a href="http://www.fs.fed.us/r6/willamette/" target="_blank">
	<IMG SRC="http://www.fsl.orst.edu/lter/ImageLibrary/navigation/fs_shielsm.gif" WIDTH="55" HEIGHT="60" ALT="US Forest Service" BORDER="0"></a>
	
	</TD>
	<TD align="center">
	
	<a href="http://www.fsl.orst.edu/" target="_blank">
	<IMG SRC="http://www.fsl.orst.edu/lter/ImageLibrary/navigation/logo_osusm.gif" WIDTH="60" HEIGHT="60" ALT="Oregon State University" BORDER="0"></a>
	
	</TD>
	<TD align="center">
	<a href="http://lternet.edu/" target="_blank">
	
	<IMG SRC="http://www.fsl.orst.edu/lter/ImageLibrary/navigation/lterlogo_blue01sm.gif" WIDTH="51" HEIGHT="60" ALT="LTER network site" BORDER="0"></a>
	
	</TD>
	</TR>

			
	</TABLE>

		<br>
		
	<CENTER>
	<B>
	<font size="-1">
	
	<a href="http://www.fsl.orst.edu/lter/index.cfm?topnav=1" target="_blank">Home</a>
	&nbsp;&nbsp;&nbsp;
	<a href="#">Top of Page</a>
	&nbsp;&nbsp;&nbsp;
	<a href="http://www.fsl.orst.edu/lter/sitemap.cfm" target="_blank">Web-site Map</a>
	&nbsp;&nbsp;&nbsp;
	<a href="http://www.fsl.orst.edu/lter/contact.cfm" target="_blank">Contacts</a>
	&nbsp;&nbsp;&nbsp;
		<a href="http://www.fsl.orst.edu/lter/about/facility/map.cfm?topnav=25" target="_blank">Addresses</a>
	&nbsp;&nbsp;&nbsp;
	<a href="http://www.fsl.orst.edu/lter/disclaim.cfm" target="_blank">Disclaimers</a>
	&nbsp;&nbsp;&nbsp;
	<a href="http://www.fsl.orst.edu/lter/credits.cfm" target="_blank">Credits</a>
	
	</font>
	</B>
<hr>
<center><font size="-2"><B>Last Modified:</B><I> 
27 Feb 2006 </i></font></center>
<p>
<center>Copyright 2002. Andrews Experimental Forest LTER. All rights reserved. 
</center>

</BODY></HTML>

EOF
;
}

1;
