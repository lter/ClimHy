#!/usr/bin/perl -w

use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);


## FEEDBACK.PL 
##
## Kyle Kotwica 12-2003 
# All purpose feedback form 
# This was ment to supply feedback to the CLIMDB/HYDRODB database admin person.
# Sends email to the email address set in climdb.conf and also logs in file
# called log/feedback.log
#
# It can be called from any of the CLIMDB/HYDRODB perl programs with;
# &feedback([program],[title]);
# 
# Or from a static HTML page with the following form;
#		<FORM METHOD="post" ACTION="bin/feedback.pl">
#		<INPUT TYPE='hidden' NAME='prg' VALUE='[program]'>
#		<INPUT TYPE='hidden' NAME='title' VALUE='[title]'>
#		<P><INPUT TYPE=submit VALUE='Feedback?'>
#		</form>
# where [title] is a tag represtenting the title of the source page/prg 
# i.e. climhy.htm or harvest.pl and
# [program] is a tag representing the source page/prg
# for example;
# &feedback('/plot.pl?module=1','Data, Plots, and Downloads')
#
# modifed code to make the from be a valid email address to satisfy strict mail server
# requirements for this part of an smtp package. - jwb - 7Feb2013
#
use FindBin qw($Bin);
use lib "$Bin/lib";

use CGI;
use clim_lib;

#read control file 
my %control = &read_control();	

my $cgi = new CGI;

my $prg = $cgi->param('prg');
my $comment = $cgi->param('comment');
my $from = $cgi->param('from');
my $org = $cgi->param('org');
my $add = $cgi->param('add');
my $name = $cgi->param('name');
my $title = $cgi->param('title');
my $style = './'.$control{all_css};

if ($comment) {
	my $web = $control{web};
	&mail_comment
		($control{email},$prg,$control{mail_server},$comment,$name,$org,$add);
#	print $cgi->header(-nph => 1,-expires=>'now'),
	print $cgi->header(-expires=>'now'),
#JAMES EDITED
	$cgi->start_html(	
				-title=>'ClimDB/HydroDB feedback page; Thank you',
				-author=>'kyle.kotwica@comcast.net',
				-style=>{'src'=>$style},);
	print <<EOF
<H1>Thank You</H1>
Your feedback is appreciated.<BR>
Would you like to go back to the refering program <A HREF="$web$prg">$title</A>?

EOF
;

} else {
	print $cgi->header(-expires=>'now'),
#	print $cgi->header(-nph => 1,-expires=>'now'),
#JAMES EDITED
	$cgi->start_html(-title=>'ClimDB/HydroDB feedback page',-author=>'kyle.kotwica@comcast.net',-style=>{'src'=>$style},);
	
	print <<EOF
<H1>Feedback</H1>
<H2>Feedback, Comments, Suggestions?</H2>
<H3>(re: $title)</H3>
Thank you for your comments and suggestions.<P>

<FORM METHOD='post' ACTION='feedback.pl'>
<P>Name: <BR>
<INPUT TYPE='text' SIZE='30' NAME='name'></textarea>
<P>Organization:<BR>
<INPUT TYPE='text' SIZE ='30' NAME='org'></textarea>
<P>Email Address:<BR> 
<INPUT TYPE='text' SIZE ='50' NAME='from'></textarea><br>
<font size="-1"><i>A valid email address is required.</i></font>
<P>Comment<BR>
<TEXTAREA COLS='80' ROWS='15' NAME='comment'>Re: $title\r\n</textarea> 
<P><INPUT TYPE=submit VALUE='Submit'>
<INPUT TYPE='hidden' NAME='prg' VALUE='$prg'>
<INPUT TYPE='hidden' NAME='title' VALUE='$title'>
</FORM>	

EOF
;
$cgi->end_html();

}

### MAIL_COMMENT
## mail an comment to the DB admin

sub mail_comment{
	my ($email,$prg,$mail_server,$comment,$name,$org,$add) = @_;
	if ($org) { $org = 'of ' . $org; }
	if ($add) { $add = '(email: ' . $from . ')'; }

	use Net::SMTP;
	my $smtp = Net::SMTP->new("$mail_server",
							Hello => "$mail_server",
							Debug => 0) || die "no $mail_server\n";

	$smtp->mail("$email");
	$smtp->to("$email");

	$smtp->data();
	$smtp->datasend("From: $from\n");
	$smtp->datasend("To: $email\n");
	$smtp->datasend("Content-Type: text/plain\n");
	$smtp->datasend("Subject: Feedback for CLIMDB/HYDRODB (re: $prg)\n\n");
	
	my $file = "$Bin/log/feedback.log";
	open (FEEDBACK, ">>$file") or die "Can't open $file : $!\n";
	
 	$smtp->datasend("$name $org $from says;\n");
 	$smtp->datasend($comment);
	print FEEDBACK "\n## Comment from $name $org $from \n## ".localtime()."\n## about $prg\n\n";
	$comment =~ s/\r//g;
	print FEEDBACK "$comment\n";
	$smtp->dataend();
	$smtp->quit;
}
