#! Perl -w

## Kyle Kotwica 1-2003
## HARVEST ROUTINE FOR CLIMDB


use FindBin qw($Bin);
use lib "$Bin/bin";
open POO, ">$Bin/log/query.log";

use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use CGI;
use DBI;
use ingest;
use clim_lib;
use sql_cmd;
use xdigest;
use FileHandle;
autoflush STDOUT 1;

#read control file 
my %control = &read_control();	

#rename some of the control variables for simplicity
my $data_path = "$Bin/data/";
my $log_path = "$Bin/log/";
my $style;

#catch error message generated during SMTP
&cgi_log();

#connect with database
my $dbh = DBI->connect($control{data_source},$control{data_user},$control{data_password}) || print "Connect failure in $0 \n";

#create CGI object, get $site and $module
my $cgi = new CGI;					
my $module = 4;
if ($cgi->param('module') ) {
	$module = $cgi->param('module');} 
my $site = uc($cgi->param('site'));		


# if no args and no $site then somebody goofed
if (!$ARGV[0] && !$module) { &usage(); }
if ($ARGV[0] eq '-h') { &usage(); }

# if no $site and we aren't running from the command prompt we want page1
if (!$site && ($ARGV[0] ne '-c')){
	$site = 'none';
}

if ($module == 1) { $style = $control{climdb_css}; }
elsif ($module == 2) { $style = $control{hydrodb_css}; }
elsif ($module == 3) { $style = $control{usgsdb_css}; }
elsif ($module == 4) { $style = $control{all_css}; }
else { $style = $control{all_css}; }

print $cgi->header(-nph => 1,-expires=>'now'),
$cgi->start_html(-title=>'ClimDB/HydroDB harvest page',-author=>'kyle.kotwica@comcast.net',-style=>{'src'=>"$style"},);

if (!$module) {
	print "<H1>Oops</H1> <H2>Please select an option</h2> <pre>";
	print &usage;
	print "</pre>";
}


#load URL, name, email data from DB
my ($module_name,%site_list,%url_list,@mail_stuff);

if ($ARGV[0] ne '-c') {
	&load_data();		
	$module_name = &what_module();			# are we climdb or hydrodb ?
}

#to avoid dangerous collisions with other versions of this program running
#coincidentally we open the climdb.log and lock it. If we can't lock it someone
#else must be using it and we must wait.
&start_log();								#log each user

if ($site eq 'none'){
	if ($module != 4) { 
		print "<H1>Oops</H1> <pre>";
		print &usage;
		print "</pre>";
	}
	&draw_page();
	exit(0);
}
else{
# all option is no longer supported
	if ($site eq 'all'){
		exit;
		foreach $site (sort keys (%url_list)){
			my	$sqlcmd = &get_cmd('3',$site,$module);
			@mail_stuff = &query_DB($sqlcmd,'array',$dbh);
			&harvester($site);
			&report();
		}
	}
	elsif ($ARGV[0] eq '-c') {
		shift @ARGV;
		while (@ARGV) {
			($module,$site) = splice(@ARGV,0,2);
			$site = uc($site);
			$module_name = &what_module();
			print CLIMLOG localtime()." $ENV{'REMOTE_HOST'} \t HARVESTING \t $module_name $site\n";
			&load_data();		
			&harvester($site);
			&report();
		}
	}
	else{
		&harvester($site);
		&report();
	}
}

$dbh->disconnect();

####
#### 		END OF MAIN PROGRAM
####

### REPORT
## reports back to the browser the results drawing either an error page
## or the logfile
sub report(){
	open (LOGIT, ">$log_path.log") or die "Can't open $log_path.log: $!\n";
	my $ok=1;
	my ($oops,@sum_up);
#if there is an error file, draw error page 
	if (-e "$log_path$site.err"){
		$ok = &err_page();
	}
#if there isn't say so
	else{
		($ok,$oops,@sum_up) = &ok_page();
	}
#note in master log
	&end_log($ok,$oops,@sum_up);
}

### MAIL_UPDATE
## mail an update to the user

sub mail_update{
	my ($email,$site,$log_path,$mail_server) = @_;
	use Net::SMTP;
	my $smtp = Net::SMTP->new("$mail_server");

	$smtp->mail("$email");
	$smtp->to("$email");

	$smtp->data();
#	$smtp->datasend("From: CLIMDB/HYDRODB\n");
	$smtp->datasend("From: climhy\@lternet.edu\n");
	$smtp->datasend("To: $email\n");
	$smtp->datasend("Content-Type: text/html\n");
	$smtp->datasend("Subject: The results of the $site data harvest\n\n");
	open (LOGIT, "<$log_path.log") or die "Can't open $log_path.log: $!\n";
	while (<LOGIT>){
		if(!/^Expires|^Date|^Content/){
 			$smtp->datasend($_);}
	}
	$smtp->dataend();
	$smtp->quit;
}

### WHAT_MODULE
### Gets a pretty name for the module

sub what_module(){					# are we climdb or hydrodb ?
	if ($module==1){					
		$module_name = 'ClimDB';}
	elsif ($module==2) {
		$module_name = 'HydroDB';}
	elsif ($module==3) {
		$module_name = 'USGSDB';}
	elsif ($module==4) {
		$module_name = 'ClimHY';}
}

## HARVESTER
## fetches the data and calls climdb.pl

sub harvester(){
	
	my $site=shift;
#if there is an error file get rid of it
	if (-e "$log_path$site.err"){
		unlink "$log_path$site.err";}
	
	open(OUT, ">$data_path$site.in") or die "Cannot open output file $data_path$site.in: $!";
	open(LOG, ">$log_path$site.log") or die "Cannot open logfile $site.log $!";

#DEBUG
#if ($site eq 'AND') {$url_list{AND} = 'bin/webservice/and.pl';}

	print "<H2>Harvesting $site_list{$site} ($site) data from $url_list{$site}</H2>\n";

# if url looks like bin/$site.pl then its a webservice. 
# Trigger client at bin/$site.pl, overide the url and look
# in http://127.0.0.1/climdb/data/$site.ws for the input file.
	if ($url_list{$site} =~ /bin\/webservice\/...\.pl/) {
		print LOG "Web service\n";
		print CLIMLOG "\t\t\tHarvest is using web service\n";
		system("perl $url_list{$site}");
		$url_list{$site} = $control{web}."data/$site.ws";
	}
# fetch the file and put it in one long string
	my $ua = LWP::UserAgent->new;
	my $req = HTTP::Request->new('GET',$url_list{$site});
	my $resp = $ua->request($req);
	my $parstring = $resp->as_string();
	
# split the string into a big array
	$parstring =~ s/\r\n/\n/g; # do real people still use macs?
	$parstring =~ s/\r/\n/g;   # dam bill gates
	my @arr = split /\n/, $parstring;

#check to see if it harvested ok
	my $i = 0;
	if ($arr[$i] =~ m/200/) {
		while ($arr[$i] ne ""){
			print LOG "$arr[$i++]\n";
		}
		$i++;									#start printing output	
		for (my $j = $i; $j <= $#arr; $j++) {	#till the end of @arr
	$arr[$j] =~ s/\r//g;
			if ($arr[$j] =~ /^.+\n$/) {				#just to be safe?
				print OUT $arr[$j];
			} else {
				print OUT "$arr[$j]\n";
			}
		}
	}

#if not log it in error file
	else{
		open (ERR, ">$log_path$site.err") or die "Cannot open error file $site.err: $!";
		print ERR "$parstring";
		print LOG "$parstring";
		close ERR;
		return;
	}
	close OUT;
	close LOG;
	print "The connection to your data is established.<BR>";
	if ($control{ingest} == 1){
		print "Beginning quality assurance procedures. <BR><I>This process may take several moments depending on the size of the file. Please be patient...</I><P>\n";
		&ingest('harvest', $dbh, $site);
	}
	else{
		print "<B>The process is terminating prematurely due to the settings of the configuration file. If this was not expected contact the database administrator.</B><P>";
	}
}

### DRAW_PAGE
## Draw the opening page

sub draw_page {
	my $key;
	print <<FirstPart
<HTML>
<HEAD>
<TITLE>Update of $module_name</TITLE>
<H2>ClimDB/HydroDB Harvest Page</H2>
The harvesting of data from your site consists of three steps:
<UL><LI> Downloading the data to this ClimDB/HydroDB server
<LI> Preparing the data for insertion into the central database
<LI> Updating the central database</UL>
<P>
<form method=post action="harvest.pl?site">
Please choose your site:
<select name=site>

FirstPart
;
	foreach $key (sort keys (%url_list)){	#for each one
		print "<option value=$key>$key - $site_list{$key}\n";}

	print <<SecondPart
</select>
<P>Please choose the harvest URL option:
<br><font size="-1"><I>These URL options can be editted in the "Update Metadata" link</I></font>
<DL><DD>Option 1<input type=radio name=module value=1 CHECKED> (Original ClimDB URL) - summary log sent to LTER site data and metadata contacts
<DD>Option 2<input type=radio name=module value=2> (Original HydroDB URL) - summary log sent to USFS site data and metadata contacts
<DD>Option 3<input type=radio name=module value=3> (USGS data harvest) - summary log sent to USGS site data and metadata contacts
</DL>
<DL><DD><input type=submit value="Harvest Now"></DL><P>
</form>
If you do not see your site listed above, your data URL is not listed in our database or the correct Harvest URL option is not selected. Please update the metadata with the correct Harvest URL under Research Area information.  If there seems to be another problem, contact the database administrator <A HREF="mailto:$control{email}">$control{email}</A>.
<p>
<h3>Harvest Notes:</h3>
<UL><LI> A diagnostic summary log will be emailed to site data and metadata contacts at the conclusion of this process.  We suggest participants keep their browser open until the end of the harvest process to see a summary of all run diagnostics.  The browser can be closed before the process completes, but certain diagnostics may be lost.
<LI> Sometimes warnings are received indicating failed min-max range checks (Warning 101).  If these extreme ranges are typical for a measurement parameter at a station, the default min and max values can be edited within the metadata on a station basis.
<LI> It is not necessary to harvest data already harvested, unless changes have occurred in the data set.  However, it is ok to do so.
</UL>
SecondPart
;
&feedback("harvest.pl?module=$module","Harvest Page");
print "</BODY></HTML>\n";

}

## ERR_PAGE
##if something went wrong say oops
sub err_page {
	print LOGIT "<H2><font color=red>FATAL ERROR(900):</font></H2> During attempt to download from $site_list{$site}.";
	if (!$url_list{$site}){
		print LOGIT "We have no URL in our database associated with $site_list{$site}<BR>Please update the metadata with the correct Harvest URL under Research Area information or contact $control{email}<P>";}
	else{
		print LOGIT "The URL we have listed is<BR> $url_list{$site}<P>If this URL has changed please update the metadata with the correct Harvest URL under Research Area information or contact $control{email}<P>";
	}

	print LOGIT "The errors returned from your web server follow:<P><HR>";
	open (IN, "$log_path$site.err") || die "Can\'t open $site.err: $!\n";
#'
	while (<IN>) {
		chop;
		print LOGIT "$_<BR>";
	}
	print LOGIT "<HR>";
	close(IN);
	&prn_to_browser();
	return(0);
}

# OK_PAGE
## if we did it, brag
sub ok_page {
	my $oops = 0;
	my $ok = 1; 
	my @sum_up;
	open (LOG, "<$log_path$site.log") or die "Cant open log/$site.log: $!\n";
	
#This is ugly but I didnt originally intend on making the log file go to the web
#'
	my $print_next_line = 0;
	print LOGIT "<H1>Harvest summary for $site_list{$site}</H1><H4>From $url_list{$site}</H4>";
	print LOGIT "<H4>To <a href=' http://climhy.lternet.edu'>http://climhy.lternet.edu</a></H4>";
	while (<LOG>){
		if ($print_next_line == 1){
			print LOGIT "$_<P>";
			$print_next_line = 0;
		}
		if (/^\t\t/) {print LOGIT "$_<BR>";}
#get summary numbers for climdb.log
		if (/^\t\t\d/) {
			push (@sum_up,$_); }
		if (/^\t\tFatal/) {
			$ok = 0; }
		
		if (/^Date: /) {
			s/Date: //;
			print LOGIT "Harvest initiated on $_<BR>";
		}
		if (/^Web service/) {
			print LOGIT "Using Web Service Methodology<BR>";}
		if (/^Last-Mod/) {
			s/Last-Modified//;
			print LOGIT "The data file was last modified on $_<BR><P>";
		}
		if (/^Ended with /) {print LOGIT "<H3>$_</H3>";}
		if (/^Started with /) {print LOGIT "<H3>$_</H3>";}
		if (/^Finished with /) {print LOGIT "<H3>$_</H3>";}
		if (/^Summary/) {print LOGIT "<H3>$_</H3>";}
		if (/^\tON/) {print LOGIT "<H3>$_</H3>";}
		if (/^\tDURING/) {print LOGIT "<H3>$_</H3>";}
		if (/^FATAL/) {
			s/FATAL ERROR/<FONT COLOR=RED>FATAL ERROR<\/FONT>/;
			print LOGIT "$_<BR>";
			$print_next_line = 1;
			$oops = 1;
		}
		if (/^WARNING/) {
			s/WARNING/<FONT COLOR=RED>WARNING<\/FONT>/;
			print LOGIT "$_<BR>";
			$print_next_line = 1;
		}
		if (/^ERROR/) {
			s/ERROR/<FONT COLOR=RED>ERROR<\/FONT>/;
			print LOGIT "$_<BR>";
			$print_next_line = 1;
		}
	}

	print LOGIT ("<P>\n\nWould you like to see the <A HREF=$control{web}data/$site.in>harvested data</A> from $site_list{$site}?<BR>\n");
	if ($control{ingest} == 1) {

# query data base for modification times ? 
		print LOGIT ("\n\nWould you like to see the <A HREF=$control{web}data/$site.out>prepared data</A> from $site_list{$site}?<BR>\n");}
	my $lower_name = $module_name;
	$lower_name =~ tr/[A-Z]/[a-z]/;
	print LOGIT ("\n\nWould you like to return to the <A HREF=http://climhy.lternet.edu/harvest/harvest.htm>CLIMDB/HYDRODB participant web page</A>?<BR>\n");
	
# if you had fatal errors apologize
	if (($ok == 0) || ($oops)){

		print "<H1> <FONT COLOR='red'> Fatal error while updating the central database.</H1> <H2>Please either correct the data file and re-harvest or contact the database administrator.</H2></FONT>";
		print LOGIT ("<H1> <FONT COLOR='red'> Fatal error while updating the central database.</H1> <H2>Please either correct the data file and re-harvest or contact the database administrator.</H2></FONT>");
		}

	if ($sum_up[1] || $control{ingest} == 0) {
		print "<H2>Process complete.</H2>";}
	if ($control{mail} == 1) {
		print "A summary log file will be e-mailed to the following:<BR><UL>";
		for (my $i=0; $i<=$#mail_stuff; $i=$i+3){
			print "<LI>$mail_stuff[$i+1] $mail_stuff[$i+2] at $mail_stuff[$i]</LI>";
		}
		print "<LI>ClimDB/HydroDB administrator at $control{email}</LI></UL><HR> <P>";
	}
	else{
		print "No e-mail is being sent due to the settings of the configuration file. If you didn't expect this contact the database administrator<BR>";
	}
	print "<HR>";

	&prn_to_browser();
	return ($ok,$oops,@sum_up);
}

### PRN_TO_BROWSER
## This prints the contents of .log to the browser
#
sub prn_to_browser{
	open (LOGIT, "<$log_path.log") or die "Can't open $log_path.log: $!\n";
	while (<LOGIT>){
		print $_;}
	print "<P>The database administrator may be contacted at <A HREF='mailto:$control{email}'>$control{email}.</A>.";
	
	close (LOGIT);
	if ($control{mail} == 1) {
		if (@mail_stuff){
			for (my $i=0; $i<=$#mail_stuff; $i=$i+3){
				&mail_update($mail_stuff[$i],$site,$log_path,$control{mail_server});
			}
		}
		if ($control{email})  {
			&mail_update($control{email},$site,$log_path,$control{mail_server});
		}
		if ($control{email2}) {
			&mail_update($control{email2},$site,$log_path,$control{mail_server});
		}
	}
}

#
### LOAD_DATA
### loads data from data base
sub load_data{
	my ($data_url,$sqlcmd);
	
	if ($module == 1){
		$data_url = '230';}
	elsif ($module == 2){
		$data_url = '231';}
	elsif ($module == 3){
		$data_url = '232';}
	elsif ($module == 4){
		$data_url = '230';}

	$sqlcmd = &get_cmd('1',$data_url);
	%url_list = &query_DB($sqlcmd,'hash',$dbh);

	$sqlcmd = &get_cmd('2',$data_url,$module);
	%site_list = &query_DB($sqlcmd,'hash',$dbh);

	$sqlcmd = &get_cmd('3',$site,$module);
	@mail_stuff = &query_DB($sqlcmd,'array',$dbh);
}


												
### cgi_log 

sub cgi_log(){
	use CGI::Carp qw(carpout);
	open(CGILOG, ">$log_path"."cgi.log") or
		die("Unable to open $log_path"."cgi.log: $!\n");
	carpout(*CGILOG);
}

### START_LOG
## this logs all users and keeps conflicts with other users at bay by locking 
## the climdb.log file

sub start_log(){
	my ($method,$t);
	open(CLIMLOG, ">>$log_path"."climdb.log") or die
		("Unable to open $log_path"."climdb.log: $!\n");

	if (flock(CLIMLOG,2|4)){
		if ($ENV{'REQUEST_METHOD'} eq 'GET'){
			$method = 'GET';}
		else{
			$method = 'HARVESTING';}
		$t = localtime;
		if (!$module_name) {$module_name = "AUTOMATIC"; }
		print CLIMLOG "$t $ENV{'REMOTE_HOST'} \t $method \t $module_name $site\n";
		}
	else{
		$t = localtime;
		print "<BR>The harvester is busy. Please try again in 5 minutes.<BR>";

		print CLIMLOG "$t $ENV{'REMOTE_HOST'} \t FAILED LOCK\n";
		exit();
	}
}

### END_LOG
## this logs the result status of the process

sub end_log(){
	my ($ok,$oops,@sum_up) = @_;
	my @results;
	if ((!$ok) || ($oops)){					# if you had fatal errors 
		 push (@results,"FATAL ERROR"); 				# warn
	}
	else{
# check for successful completion of ingestion
		if ($sum_up[1]) {
			$results[0] = "Ingestion successful.\n";
		} elsif ($control{ingest} == 0) {
			$results[0] = "Ingestion turned off by CHUMP.\n";
		} else {
			$results[0] = "Incomplete.\n";
			print "<font color=RED><H1>INCOMPLETE</H1>\nSomething went tragically wrong. Please contact the database administrator at <A HREF='mailto:$control{email}'>$control{email}.</A>..<P></font>";
		}
		push (@results,@sum_up);
# check for successful completion of digestion
		if ($control{digest} == 0) {
			push (@results,"Digestion turned off by CHUMP.\n\n");
		} elsif (!$ok) {
			push (@results,"Digestion Failed.\n\n");
		} else {
			push (@results,"Digestion complete.\n\n");}

	}
	my $t = localtime();
	print CLIMLOG "$t $ENV{'REMOTE_HOST'} \t FINISHED \t $module_name $site \n @results\n"
}


## USAGE
# print usage if called from the command prompt incorrectly
sub usage {
print <<USAGE

$0 

CLIMDB/HYDRODB automatic data harvester.
Author Kyle Kotwica
Version 3.0
12-2003

When called from the web this script allows you to select a site, 
harvest, ingest and digest the data from that site.  

This script was designed to be called from the WWW in one of the following ways:
 
$0?module=4
    Draws opening page prompting for the site to harvest and prompting the 
    user to select the res_module_id number. 

$0?module=[1|2|3]&site=[site_id]
    Harvests the data for that site and data url option (module).

Alternatively it may be run from the command prompt in the following way:
    $0 -c module site_id
        where the module and site_id may be repeated for as many sites as 
        desired. In this case module may be 1,2,3, or 4, representing the 
        data url option as before (4 defaults to 1). This option will print 
        HTML to stdout. It is suggested that the output get piped to a file.
        For exmple, run this command as a cron job for autoharvests;
             $0 -c 1 and 2 gce > foo


$0 -h
    prints this message whether from the command prompt.

You may also run the ingestion and digestion step separately, if the data 
is already harvested, by running ingest.pl and digest.pl. This does not 
require a working web server. (not recomended, unless you're Kyle or God) 


Copyright 2003, kyle Kotwica. All rights reserved. It's mine Dammit, all mine!
Don't touch it or I'll get really mad, and threaten you and stuff like that.


USAGE
;
exit();
}
