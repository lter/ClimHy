#! perl 

# Kyle Kotwica 12-2003
# Version 1.0
# A dynamic description of CLIMDB/HYDRODB variables
#

use FindBin qw($Bin);
use lib "$Bin/bin";
open POO, ">log/query.log";

use strict;
use CGI;
use DBI;
use clim_lib;
use sql_cmd;
use CGI::Carp qw(fatalsToBrowser);

#read control file 
my %control = &read_control();	

#connect with database
my $dbh = DBI->connect($control{data_source},$control{data_user},$control{data_password}) || die "Connect failure in $0. It would seem the database has gone away?\n";

my $cgi = new CGI;
print $cgi->header(-nph =>1,-expires=>'now'),
$cgi->start_html(-title=>'ClimDB/HydroDB Descriptors',-author=>'kyle.kotwica@comcast.net',-style=>{'src'=>$control{all_css}},),
$cgi->h1("ClimDB/HydroDB Descriptors");

my $sqlcmd = &get_cmd('702');
my @answer = &query_DB($sqlcmd,'array',$dbh);
#TOC
for (my $i=0; $i<=$#answer-3; $i=$i+3) {
	my $label = $answer[$i+1];
	$label =~ s/ /_/g;
	print "<A HREF=#$label>$answer[$i+1]</A><BR>";
}
print "<A HREF=#Measurement_Parameter_Descriptors>Measurement Parameters</A><BR>";

for (my $i=0; $i<=$#answer; $i=$i+3) {
	my $sqlcmd = &get_cmd('700',$answer[$i]);
	my @answer1 = &query_DB($sqlcmd,'array',$dbh);
	&prt_list($answer[$i+1],3,@answer1);
}

 
$sqlcmd = &get_cmd('701',6);
@answer = &query_DB($sqlcmd,'array',$dbh);
&prt_list('Measurement Parameters',2,@answer);

print $cgi->end_html();

### END OF MAIN

sub prt_list {
	my ($title,$how_many,@answer) = @_;

	my $extra_text;
	if ($title =~ /Measurement Parameters/) {
		$extra_text = 'Consult user guide for specific parameter guidelines.';}
	if ($title =~ /Air Temperature/) {
		$title = 'Measurement Parameter Descriptors';}
	my $label = $title;
	$label =~ s/ /_/g;

	print "<A NAME=$label><H2>$title</H2></A>$extra_text\n";
	print "<TABLE WIDTH=619><TR><TD>\n";
	print "<DL>\n";
	if ($how_many == 3) {
		for (my $i=0; $i<=$#answer; $i=$i+3) {
			if ($answer[$i+2]) {$answer[$i+2] = '('.$answer[$i+2].')';}
			if ($title =~ /Descriptors/) {
				$answer[$i+2] = ''; }
			print "<DT><FONT SIZE=+1><B>$answer[$i] </B></FONT>$answer[$i+2]</DT><DD>$answer[$i+1]</DD>\n"; 
		}
	} else {
		for (my $i=0; $i<=$#answer; $i=$i+2) {
			print "<DT><FONT SIZE=+1>$answer[$i]</FONT> ($answer[$i+1])</DT>\n"; 
		}
	}
	print "</DL>\n";
	print "</TD></TR><TABLE>\n";
}



