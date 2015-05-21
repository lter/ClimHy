#! C:/Perl/bin/Perl 
#print "Content-type: text/html\n\n";

## plot.pl
##
## Kyle Kotwica 2-2003
## Takes user request over CGI and plots or presents data

#
# This program consists of 3 pages of html;
# page 1 - Called from web page by plot.pl. This page prompts 
#		the user to choose a site(s).
# page 2 - This page receives the choices submitted above and prompts the
#		user for research station(s).
# page 3 - This page receives the choices submitted above and prompts the user
#		for dates and which side the variable should be scaled on.
# A final page is a GIF image of the data or a data file, if one was requested.

use FindBin qw($Bin);
use lib "$Bin/bin";
open POO, ">>$Bin/log/query.log";

use strict;
use clim_lib;
use sql_cmd;
use DBI;
use CGI;
use File::Temp qw/tempfile tempdir/;
use CGI::Carp qw(fatalsToBrowser);

my ($file_1,$data1_fh);
my ($gif_fh,$gnu_gif);

chdir "$Bin/temp";
unlink <*.gif>;
chdir $Bin;

#read control file 
my %control = &read_control();	
my $gnuexe = $control{gnu_exe};

#connect with database
my $dbh = DBI->connect($control{data_source},$control{data_user},$control{data_password}) || die "Connect failure in plot.pl. It would seem the database has gone away?\n";

my $cgi = new CGI;
my $request_method = $cgi->request_method();

if($request_method eq 'GET'){				#if 'GET' go get first page
	&draw_page1();
}
elsif ($cgi->param('page')+1 == 2) {
	&draw_page2();
}
elsif ($cgi->param('page')+1 == 3) {
	&draw_page3();
}
elsif ($cgi->param('page')+1 == 4) {
	&draw_page4();}

## COUNTER

sub counter {
	my $method = shift;
	my ($count_a,$count_b);
	open COUNTER, "<$Bin/log/counter" or die;
	while (<COUNTER>) {
		($count_a,$count_b) = split /,/,$_;}
	open COUNTER, ">$Bin/log/counter" or die;
	if ($method) {
		$count_b++;
	} else {
		$count_a++;}
	print COUNTER "$count_a,$count_b";
	close COUNTER;
	return ($count_a,$count_b);
}

## UPLOAD_LOG
# This simply logs information on who is using the data from the CLIMHY 
# database. It keeps track of how many perople hit the first page and how 
# many people submit on the last. The information is stored in a file
# (./log/upload.log) and in database tables (session, download)

sub upload_log {
	my $method = shift;
	my @t = localtime;
	my $t = sprintf("%d-%02d-%02d %02d:%02d:%02d:0000",
		$t[5] += 1900,$t[4]+1,$t[3],$t[2],$t[1],$t[0]);
	
	my $purpose = $cgi->param('purpose');
	my $name = $cgi->param('name');
	my $org = $cgi->param('org');
	my $ip = $ENV{'REMOTE_HOST'};
	my ($count,$count_b) = &counter($method);
	open BOOKS, ">>$Bin/log/upload.log" or die;
	if (!$method) {
			# we have a hit on page one
		my $sqlcmd = &get_cmd('306',$count,$t,$ip,$name,$org,$purpose);
		my $rv = &query_DB($sqlcmd,'do',$dbh);
		print BOOKS "\t## $count ##\t $t \t $ip \nName: $name\t\tOrg: $org\n\tPurpose: $purpose\n";
	} elsif ($method) {
			# we have a plot or download
		my $sqlcmd = &get_cmd('307',$count,$count_b,$t,$ip,$method);
		my $rv = &query_DB($sqlcmd,'do',$dbh);
		print BOOKS "\t$count_b\t$ip downloaded a $method file on\n\t\t\t $t\n";
	}
	close BOOKS;
}

## DRAW_PAGE4
# This sub presents the plot 

sub draw_page4 {

	my ($enhanced,$station,$variable,$site,@labels,$scale);
	my $old_station = 'none';

	my $begin = $cgi->param('begin');
	my $end = $cgi->param('end');
	$begin = &date_num($begin);
	$end = &date_num($end);
	my $count = $cgi->param('count');
	my $method = $cgi->param('method');
	my $agg_period = $cgi->param('agg_period');
	my $style = $cgi->param('style');
	my @parameters = $cgi->param;
	
	&upload_log($method);
	&upload($method);

# for each set of site, station, variable
	for (my $i=0; $i<$count; $i++){
		$scale = 'none';
		foreach my $value (@parameters) {
			if ($value =~ /$i$/) {
				if ($value =~ /^station/) {
					$station = $cgi->param($value);}
				elsif ($value =~ /^site/) {
					$site = $cgi->param($value);}
				elsif ($value =~ /^scale/) {
					$scale = $cgi->param($value);}
				else {$variable = $cgi->param($value); }
			}

		}

# if they want to plot it
		if ( ($method =~ /plot/) && ($scale !~ /none/) ) {
			if ($method =~ /means/) {
				$enhanced = 1;
				if ($agg_period =~ /monthly/) {
					push @labels, 
						("$station".'_'."$variable".' (mean for year)',$scale);
					push @labels, 
						("$station".'_'."$variable".' (mean all years)',$scale);
				} elsif ($agg_period =~ /yearly/) {
					push @labels, 
						("$station".'_'."$variable".' (mean for year)',$scale);
					push @labels, 
						("$station".'_'."$variable".' (mean all years)',$scale);
				} elsif ($agg_period =~ /daily/) {
					push @labels, 
						("$station".'_'."$variable",$scale);
					push @labels, 
						("$station".'_'."$variable".' (mean for year)',$scale);
				}
			} else {
				push @labels, ("$station".'_'."$variable",$scale);
			}
			&print_plot_data($site, $station, $variable, $begin, $end, $agg_period,$enhanced);

# if they want to see it
		} elsif ($method !~ /plot/){
			if ( ($station ne $old_station) && ($i != 0) ) {
				if (@labels) { &print_data($method,@labels); }
				undef(@labels);
			}
			my $agg_type = &what_type($variable);
			push @labels, ($site, $station, $variable, $begin, $end, $agg_period, $agg_type);
		}
		$old_station = $station;
	}

	if ($method =~ /plot/) {
		my ($gif_fh,$gnu_cmd) = &plot_cmds($agg_period,@labels);
		system ($gnuexe,$gnu_cmd);
		close $gif_fh;
		&mk_plot_html($agg_period,$style,@labels);
		print $cgi->redirect("temp/plot_image.htm");
	} else {
		&print_data($method,@labels);
	}
	
}

## MK_PLOT_HTML
# This generates a HTML page to hold the plot_image.gif so the user can 
# download the images.

sub mk_plot_html {
	my ($agg_period,$style,$pretty_names,@labels) = @_;
	my $plot_image = "$Bin/temp/plot_image.htm";
	open(HTML,">$plot_image") || die "oops! no $plot_image";
	$agg_period = ucfirst($agg_period); 
	$gnu_gif =~ s/^.*temp\\//;
	print HTML $cgi->start_html(-title=>'Plot Image',-author=>'kyle.kotwica@comcast.net',-style=>{'src'=>"../$style"},);

	print HTML <<EOF
<TITLE>ClimDB Plot Image</TITLE>
<H1>ClimDB plot Image</H1>
$agg_period data<BR>
<TABLE BORDER=15><TR><TD>
<IMG SRC="$gnu_gif"><BR>
</TD></TR></TABLE>
Right clicking on the image will allow you to download the image to your local drive.<BR> 
</HTML>
EOF
;

	close(HTML);
}


## PRINT_DATA
# this gets the SQL command for the uploaded files. 
# Also Printing it (through exec_query). 
# Also prepares the header information.

sub print_data {
	my ($method,@labels) = @_;
	my ($count,$sqlcmd,$header,$agg_type);
	my $i = 1;
	my $flag = 'Estimates';

	if ($method =~ /html/) {
		my $style = $cgi->param('style');
		print $cgi->start_html(-title=>'Page 4',-author=>'kyle.kotwica@comcast.net',-style=>{'src'=>"$style"}); }

	#if ($method !~ /plot/) {
		$header = "<TABLE BORDER=5>";
		if ($labels[5] =~ /month/) {
			$header .= "<TR><TH>Site</TH><TH>Station</TH><TH>Year</TH><TH>Month</TH>";
		} elsif ($labels[5] =~ /year/) {
			$header .= "<TR><TH>Site</TH><TH>Station</TH><TH>Date</TH>";
			$flag = '# of Estimates';
		} else {
			$header .= "<TR><TH>Site</TH><TH>Station</TH><TH>Date</TH>";
			$flag = 'Flag';
		}
		my @which = @labels;
		WHICH: while (@which) {
			my($site,$station,$variable,$begin,$end,$type,$agg_type)
				= splice(@which,0,7);
			last WHICH if ($site eq $method);
			my $pretty_name = &get_pretty_name($variable);
			$header .= "<TH>$pretty_name</TH><TH>$flag</TH>";
			#$header .= "<TH>$variable</TH><TH>$flag</TH>";
		}
		$header .= "</TR>\n";
	#}
	
	if ($labels[5] =~ /daily/) {
		$sqlcmd = &get_cmd('300dd',@labels);}
	if ($labels[5] =~ /monthly/) {
		$sqlcmd = &get_cmd('300mm',@labels);
	}
	if ($labels[5] =~ /yearly/) {
		$sqlcmd = &get_cmd('300yy',@labels);
	}
	$sqlcmd = &parse_sqlcmd($sqlcmd);
	$count = &exec_query($sqlcmd,$labels[5],$method,$header);
	if ($method =~ /html/) {print "<\/TABLE>";}
}

## DONS_DUMB_NAME
#  Airtemp (mean c) instead of DAILY_AIRTMEP_MEAN_C 

sub get_pretty_name {
	my $name = shift;

	my $sqlcmd = &get_cmd('300hack',$name);
	my $pretty_name = &query_DB($sqlcmd,'value',$dbh);
	my @name = split('_',lc($pretty_name));
	$pretty_name = ucfirst($name[1])." ($name[2] $name[3])";
	
	return ($pretty_name);

}

## PARSE_SQLCMD
# Need to take a bunch of sql commands and run them one at a time. 
# Each command starts with @@@; each comment starts @@@#
# Also need to strip off comments.

sub parse_sqlcmd {
	$_ = shift;
	my @commands = split('@@@',$_);
	foreach my $sqlcmd (@commands) {
		if ($sqlcmd !~ /^#/) {
			if ($sqlcmd =~ /^ LAST/) {
				$sqlcmd =~ s/LAST//;	
				return($sqlcmd);
			} else {
				my $rv = &query_DB($sqlcmd,'do',$dbh);
			}
		}
	}
	
}


## PRINT_PLOT_DATA
# This sub prints the datafile for gnuplot.

sub print_plot_data {
	my ($site,$station,$variable,$begin,$end,$agg_period,$enhanced) = @_;
	my ($sqlcmd,$count);
	my $agg_type = &what_type($variable);

	if ($agg_period =~ /daily/) {
		if ($enhanced) {
			$sqlcmd = &enhanced
				($site,$station,$variable,$agg_type,$end,$begin,$agg_period);
		} else {
			$agg_type = 'DAILY';
			$sqlcmd = &get_cmd('300d',$site,$station,$variable,$end,$begin);
		}
		
	} elsif ($agg_period =~ /monthly/) {
		if ($enhanced) {
			$sqlcmd = &enhanced
				($site,$station,$variable,$agg_type,$end,$begin,$agg_period);
		} else {
			$sqlcmd = &get_cmd
				('300m',$site,$station,$variable,$end,$begin,$agg_type);
		}
	} elsif ($agg_period =~ /yearly/) {
		if ($enhanced) {
			$sqlcmd = &enhanced
				($site,$station,$variable,$agg_type,$end,$begin,$agg_period);
		} else {
			$sqlcmd = &get_cmd('300y',$site,$station,$variable,$end,$begin,$agg_type);
		}
	}
	$count = &exec_query($sqlcmd,$agg_period,'plot');
}

## ENHANCED
# Deal with the sql for plot with means feature

sub enhanced {
	my ($site,$station,$variable,$agg_type,$end,$begin,$agg_period) = @_;
	my ($sqlcmd,$rv);

	if ($agg_period =~ /daily/) {
		$sqlcmd = &get_cmd('501a','tmp');
		$rv = &query_DB($sqlcmd,'do',$dbh);
		$sqlcmd = &get_cmd('300ed',$site,$station,$variable,$agg_type,$end,$begin);
print POO "$sqlcmd\n";
		$rv = &query_DB($sqlcmd,'do',$dbh);
		$sqlcmd = &get_cmd
			('300ed2',$site,$station,$variable,$end,$begin,'r');
print POO "$sqlcmd\n";
		&exec_query($sqlcmd,$agg_period,'plot');
		$sqlcmd = &get_cmd
			('300ed2',$site,$station,$variable,$end,$begin,'t');
print POO "$sqlcmd\n";
	} elsif ($agg_period =~ /monthly/) {
		$sqlcmd = &get_cmd('501a','tmp');
		$rv = &query_DB($sqlcmd,'do',$dbh);
		$sqlcmd = &get_cmd('300em',$site,$station,$variable,$agg_type);
		$rv = &query_DB($sqlcmd,'do',$dbh);
		$sqlcmd = &get_cmd
			('300em2',$site,$station,$variable,$agg_type,$end,$begin,'a');
		&exec_query($sqlcmd,$agg_period,'plot');
		$sqlcmd = &get_cmd
			('300em2',$site,$station,$variable,$agg_type,$end,$begin,'t');
	} elsif ($agg_period =~ /yearly/) {
		$sqlcmd = &get_cmd('501a','tmp');
		$rv = &query_DB($sqlcmd,'do',$dbh);
		$sqlcmd = &get_cmd
			('300ey',$site,$station,$variable,$agg_type,$end,$begin);
		$rv = &query_DB($sqlcmd,'do',$dbh);
		$sqlcmd = &get_cmd
			('300ey2',$site,$station,$variable,$agg_type,$end,$begin,'a');
		&exec_query($sqlcmd,$agg_period,'plot');
		$sqlcmd = &get_cmd
			('300ey2',$site,$station,$variable,$agg_type,$end,$begin,'t');
	}
	return($sqlcmd);
}

## WHAT_TYPE
# Given the variable check in CLIMDB_VARIABLES in order to determine 
# weather the type should be MEAN or TOTAL

sub what_type {
	my $variable = shift;
	my $agg_type = 'MEAN';

	my $sqlcmd = &get_cmd('300',$variable);
	my $agg_total = &query_DB($sqlcmd,'value',$dbh);
	if ($agg_total eq 'Y') {
		$agg_type = 'TOTAL';
	}
	return($agg_type);
}

## EXEC_QUERY
#
# Here we write the 'raw' data file (file_1) by executing the SQL statement 
# Appending to it if its a plot or writing a new one if otherwise.

sub exec_query {
	my ($sqlcmd,$agg_period,$method,$header) = @_;
	my $count=0;

	if ( (!$file_1) && ($method eq 'plot') ) {
		($data1_fh,$file_1) = tempfile(UNLINK => 1, DIR => "$Bin/temp");
		open($data1_fh,">$file_1") || die "Cant open data file";
	} elsif ($method eq 'plot') {
		open($data1_fh,">>$file_1") || die "Cant open data file";}

	if ($method ne 'plot') {
		if ($method eq 'html') {
			print $header;}
		else {
			$header =~ s/<\/TH><TH>/\t/g;
			$header =~ s/<.*?>//g;
			if ($method =~ /comma/) {
				$header =~ s/\t/,/g;}
			chop $header;
			$header .= "\r\n";
			print "$header";
		}
	}
	
	my $sth = $dbh->prepare($sqlcmd) || die "prepare failure: ". $dbh->errstr;
	$sth->execute || die "execute failure: ".$sth->errstr;
	my $flag = 0;
	while (my $data = $sth->fetchrow_arrayref){
		$flag = 1;
		my $size = @$data;
		my $i;
		$$data[0] =~ s/ 00:00:00.000//;
		$$data[0] =~ s/ 00:00:00//;
		$count++;
# for now set to 3 sig. digits
# Once Suzanne gets her shit together add decimal as $$data[$i+2]
# change for loops, sprintf, and sqlcmd (see 300yy for example of sql)
		if ($method eq 'plot') {
			if ($agg_period =~ /monthly/) {
				print $data1_fh "$$data[1]-$$data[0]\t$$data[2]\t$$data[3]\t$$data[4]\n";
			} else {
				print $data1_fh join("\t",@$data),"\n";
			}
		} else {
			if ($agg_period =~ /monthly/) {
				$_ = "$$data[2]\t$$data[3]\t$$data[0]\t$$data[1]";
				for ($i=4; $i<$size; $i=$i+3) {
					if (defined $$data[$i]) {
						if (!$$data[$i+2]) {$$data[$i+2] = 3;}
						$_ = $_ . sprintf "\t%8.$$data[$i+2]f\t%d",$$data[$i],$$data[$i+1];
					} else {
						$_ = $_ ."\t \t ";
					}
				}
			} elsif ($agg_period =~ /daily/) {
				$_ = "$$data[1]\t$$data[2]\t$$data[0]";
				for ($i=3; $i<$size; $i=$i+2) {
					$_ = $_ . "\t$$data[$i]\t$$data[$i+1]";
				}
			} elsif ($agg_period =~ /yearly/) {
				$_ = "$$data[1]\t$$data[2]\t$$data[0]";
				for ($i=3; $i<$size; $i=$i+3) {
					if (defined $$data[$i]) {
						if (!$$data[$i+2]) {$$data[$i+2] = 3;}
						$_ = $_ . sprintf "\t%8.$$data[$i+2]f\t%d",$$data[$i],$$data[$i+1];
					} else {
						$_ = $_ ."\t \t ";
					}
				}
			}
			if ($method =~ /comma/) {
				s/\t/,/g;}
			if ($method =~ /html/) {
				&make_html();
			}
			print "$_\r\n";
		}
	}
	
	if ($method eq 'plot') {
# if no data set missing to keep legend strait
		if ($flag == 0) {print $data1_fh "1\tM\n";}
		print $data1_fh "\n\n";
		close $data1_fh;
	}
	return($count);
}

## DRAW_PAGE3
# This sub takes a list stations, variables, a page number, and a count of 
# how many variables we are talking about. 
# It passes on a page number, count, begin and end dates, as well as the 
# side to scale on.
sub draw_page3 {

	my ($i,@station,@variable,@master,$skip_yes,$skip_no);
	my $count = $cgi->param('count');

#do HTML
	my $style = $cgi->param('style');
	print $cgi->header(-expires=>'now'),
	$cgi->start_html(-title=>'Page 3',-author=>'kyle.kotwica@comcast.net',-style=>{'src'=>"$style"},),
	$cgi->h2("ClimDB/HydroDB Data Retrieval Program; page 3"),
	$cgi->start_form(-method=>'post',-action=>'plot.pl');
	print "Selecting either left or right for each variable below specifies to which side of the graph that variable is scaled when plotting data.  If skip is selected, the variable will not be displayed. Skip only has an effect when plotting.<BR>";
	print "<TABLE BORDER=5><TR><TH WIDTH=40>Site</TH><TH WIDTH=140>Station</TH><TH WIDTH=60>Variable</TH><TH WIDTH=150>Begin Date</TH><TH WIDTH=150>End Date</TH><TH WIDTH=30>Left</TH><TH WIDTH=30>Right</TH><TH WIDTH=30>Skip</TH></TR>";
	
	my $j=0;
#for each site ($i counts the site)
	for($i=0; $i<$count; $i++) {
		@station = $cgi->param('station'.$i);
		@variable= $cgi->param('variable'.$i);
#for each station in that site ($j counts the station)
		foreach my $site_station (@station) {
			my $site = substr($site_station,0,3);
			my $station = substr($site_station,3);
#for each variable for that station in that site
			foreach my $variable (@variable) {
				my $pretty_name = &get_pretty_name($variable);
				my $sqlcmd = &get_cmd('301',$station,$variable,$site);
				(my @a) = &query_DB($sqlcmd,'array',$dbh);
				$a[0] =~ s/..:..:..\....//;
				$a[1] =~ s/..:..:..\....//;
				if ($a[0]) {
					$skip_no = "CHECKED='true'";
					$skip_yes = '';
				} else {
					$skip_yes = "CHECKED='true'";
					$skip_no = '';
				}

				print <<END
<INPUT TYPE='hidden' NAME='site$j' VALUE='$site'>
<INPUT TYPE='hidden' NAME='station$j' VALUE='$station'>
<INPUT TYPE='hidden' NAME='$variable$j' VALUE='$variable'>
<TR><TD ALIGN=CENTER>$site</TD><TD ALIGN=CENTER>$station</TD>
	<TD ALIGN=CENTER>$pretty_name</TD><TD ALIGN=CENTER>$a[0]</TD>
	<TD ALIGN=CENTER>$a[1]</TD>
	<TD><INPUT TYPE='radio' $skip_no NAME='scale$j' VALUE='left$j'></TD>
	<TD><INPUT TYPE='radio' NAME='scale$j' VALUE='right$j'></TD>
	<TD><INPUT TYPE='radio' $skip_yes NAME='scale$j' VALUE='none'></TD></TR>
END
;
				push @master, @a;
				$j++;
			}
		}
	}
	print "\n</TABLE>";

	my ($begin,$end) = &get_begin(@master);
		if ($begin == 0) 
			{ print "<FONT COLOR='red'>Warning there is no inclusive date range</FONT><BR>You may still plot the data but there will be a gap on the plot<BR>";}
	my $begin_str = &date_str($begin);
	my $end_str = &date_str($end);
	
	print <<ENDD
<TABLE><TR>
	<TD WIDTH=260></TD>
	<TD>You may select begin and end dates by editing the fields below.</TD>
</TR><TR>
	<TD></TD>
	<TD>Please use YYYY-MM-DD as the date format.</TD>
</TR></TABLE>
<TABLE><TR>
	<TD WIDTH=260></TD>
	<TD>Begin Date</TD>
	<TD>End Date</TD>
</TR><TR>
	<TD></TD>
	<TD WIDTH=150><INPUT TYPE='text' NAME='begin' VALUE=$begin_str></TD>
	<TD WIDTH=150><INPUT TYPE='text' NAME='end' VALUE=$end_str></TD>
</TR></TABLE>
<P>
<TABLE><TR>
	<TD WIDTH=400>
<P>Select your preferred aggregation type:<P>
<INPUT TYPE='radio' NAME='agg_period' VALUE='daily' CHECKED='1'>Daily<BR>
<INPUT TYPE='radio' NAME='agg_period' VALUE='monthly'>Monthly<BR>
<INPUT TYPE='radio' NAME='agg_period' VALUE='yearly'>Yearly<BR>
<BR>
	</TD>
	<TD WIDTH = 400>
<P>Select your preferred method of retrieval:<P>
<INPUT TYPE='radio' NAME='method' VALUE='plot' CHECKED='1'>Plot<BR>
<INPUT TYPE='radio' NAME='method' VALUE='means_plot'>Plot with means<BR>
<INPUT TYPE='radio' NAME='method' VALUE='html'>HTML<BR>
<INPUT TYPE='radio' NAME='method' VALUE='tab'>Tab delimited<BR>
<INPUT TYPE='radio' NAME='method' VALUE='comma'>Comma delimited<BR>
	</TD>
</TR></TABLE>
<BR>
	
<INPUT TYPE='hidden' NAME='count' VALUE=$j>
<INPUT TYPE='hidden' NAME='page' VALUE='3'>
<INPUT TYPE='hidden' NAME='style' VALUE='$style'>
<P><INPUT TYPE=submit VALUE=submit ></form>
ENDD
;
	print $cgi->end_html;

}

## DATE_STR

sub date_str {
	my $date = shift;
	my $year = substr($date,0,4);
	my $month = substr($date,4,2);
	my $day = substr($date,6,2);
	return ($year . '-' . $month . '-' . $day);
}

## DATE_NUM

sub date_num {
	my $date = shift;
	my ($year,$month,$day) = split '[-/ ,:]',$date;
	if ($year < 20) {$year = $year + 2000;}
	if (($year > 20) && ($year < 100)) {$year = $year + 1900;}
		
	if (length($month) == 1) {$month = '0'.$month;}
	if (length($day) == 1) {$day = '0'.$day;}
	$_ = join '',$year,$month,$day;
	return($_);
}

## GET_BEGIN

sub get_begin {
	my @master = @_;
	my $old_begin = 0;
	my $old_end = 99999999;
	my ($new_begin,$new_end);
	
	for (my $i = 0; $i<$#master; $i=$i+2){
		$master[$i] =~ s/-//g;
		$master[$i+1] =~ s/-//g;
		$new_begin = $master[$i];
		$new_end = $master[$i+1];
			
		if ($new_begin != 0) {
			$old_begin = max($old_begin,$new_begin);
			$old_end = min($old_end,$new_end);
		}
	}
	if ($old_begin > $old_end){
#bring up dialog warning there is no inclusive date range
		return (0,0)
	}
	return ($old_begin,$old_end);
}

##MIN 

sub min {
	my ($a,$b) = @_;

	if ($a < $b) {
		return $a}
	else {
		return $b}
}

## MAX

sub max {
	my ($a,$b) = @_;

	if ($a > $b) {
		return $a}
	else {
		return $b}
}

## DRAW_PAGE2
# This sub takes a page number and a site list as params and passes on the 
# stations and variables the user requested as well as a page number.
sub station_hash {
	my ($site,$type) = @_;
	my (%station_list,@station_list);
		
	my $sqlcmd = &get_cmd('302',$site,$type);	
	@station_list = &query_DB($sqlcmd,'array',$dbh);
	for (my $i=0; $i<=$#station_list; $i=$i+2) {
		$station_list[$i] = $site.$station_list[$i];
	}
	%station_list = @station_list;
	return (%station_list);
}

sub clim_or_hy_select {
	my ($station_list,$variable_list,$station,$variable) = @_;

	print "<TR><TD><SELECT MULTIPLE SIZE=4 NAME='$station' >\n"; 
	foreach my $key (sort keys(%$station_list)) {
		print "<OPTION VALUE=$key>$$station_list{$key}\n";}
	print "</SELECT></TD>";
		
	print "<TD><SELECT MULTIPLE SIZE=4 NAME='$variable' >\n";
	foreach my $key (sort keys(%$variable_list)) {
		#my $variable = $$variable_list{$key};
		#$variable =~ s/DAILY_//;
		#print "<OPTION VALUE=$variable>($key) - $$variable_list{$key}\n";}
		print "<OPTION VALUE=$key>($key) - $$variable_list{$key}\n";}
	print "</SELECT></TD></TR><TR><TD><HR></TD><TD><HR></TD></TR>";
}

sub draw_page2 {
	if (&upload_log() == 0 ) { return; }
	print $cgi->header(-expires=>'now');
	my @sites = $cgi->param('site');
	my (@station_list,%stations,%variables,%station_list,%variable_list);
	my $i = 0;

#do HTML
	my $style = $cgi->param('style');
	print $cgi->start_html(-title=>'Page 2',-author=>'kyle.kotwica@comcast.net',-style=>{'src'=>"$style"},);
	print $cgi->h2("Data Retrieval Program; page 2"),
	$cgi->start_form(-method=>'post',-action=>'plot.pl');
	print "<TABLE><TR><TD>Select a Station</TD><TD>Select a variable</TD></TR>\n";
	print "<TR><TD><HR></TD><TD><HR></TD></TR>";
# for all of the sites in @sites
	foreach my $site (@sites) {
# for both hydro and clim stations
# get all of the stations for that site and fill %station_list
		my %hydro_stations = &station_hash($site,'3');
		my %clim_stations = &station_hash($site,'4');

# get all of the variables for that site and fill %variable_list
		my $sqlcmd = &get_cmd('303',$site,'3');
		my %hydro_variables = &query_DB($sqlcmd,'hash',$dbh);
		$sqlcmd = &get_cmd('303',$site,'4');
		my %clim_variables = &query_DB($sqlcmd,'hash',$dbh);
	
# Do the HTML for this site	
		$sqlcmd = &get_cmd('305',$site);
		my ($site_name,$site_name) = &query_DB($sqlcmd,'array',$dbh);
		print "<TR><TD><B>$site_name</B></TD></TR>";
		
		if (%clim_stations) {
			print "<TR><TD><B>Meteorological Stations</B></TD></TR>";
			&clim_or_hy_select(\%clim_stations,\%clim_variables,'station'.$i,'variable'.$i);
			$i++;
		}
		if (%hydro_stations) {
			print "<TR><TD><B>Gauging Stations</B></TD></TR>";
			&clim_or_hy_select(\%hydro_stations,\%hydro_variables,'station'.$i,'variable'.$i);
			$i++;
		}
# Go on to next site
	}
 	print "</TABLE>";
	print $cgi->hidden('count',$i);
	print "\n<INPUT TYPE='hidden' NAME='page' VALUE='2'>";
	print "\n<INPUT TYPE='hidden' NAME='style' VALUE='$style'>";
	print '<P><INPUT TYPE=submit VALUE=submit ></form>';
	print$cgi->end_html;
}

#
# style_sheet
# sets the style sheet depending on modules
# 
sub style_sheet {
	my $module = $cgi->param('module');
	my $style; 
	
	if ($module == 1) { $style = $control{climdb_css};
	} elsif ($module == 2) { $style = $control{hydrodb_css}; 
	} else { $style = $control{all_css};}
	return $style;
}

# 
# DRAW_PAGE1
## This sub draws the start up page. Its duty is to get the site(s)
## It passes back a page number and a site list.

sub draw_page1{
	my ($name,$org,$purpose);
	
	my $sqlcmd = &get_cmd('304');
	my %site_list = &query_DB($sqlcmd,'hash',$dbh);
# if %site_list is NULL catch it !!!

#do HTML
	my $style = &style_sheet;
	print $cgi->header(-expires=>'now'),
	$cgi->start_html(-title=>'Page 1',-author=>'kyle.kotwica@comcast.net',-style=>{'src'=>"$style"},),
	$cgi->h2("ClimDB/HydroDB Data Retrieval Program; page 1"),
	$cgi->start_form(-method=>'post',-action=>'plot.pl');

	print "\n<INPUT TYPE='hidden' NAME='page' VALUE='1'>";

	print "\nPlease choose your site(s):<BR>\n";
	print "\n<FONT SIZE=-1><I>Use control key to select multiple sites.</I></FONT><BR>\n";
	print "<SELECT MULTIPLE name=site SIZE=6>\n";
	foreach my $key (sort keys(%site_list)) {
		print "<OPTION VALUE=$key>$site_list{$key}\n";}

print <<PAGE1

</SELECT><P>
<BR>
For our records, we would appreciate the following information:
<BR><TABLE><TR>
<TD>Name:</TD><TD><INPUT TYPE='text' NAME='name' VALUE=$name> </TD></TR>
<TD>Organization:</TD><TD><INPUT TYPE='text' NAME='org' VALUE=$org> </TD></TR>
<TD>Purpose for this download:</TD></TR>
</TABLE>
<TEXTAREA COLS='80' ROWS='3' NAME='purpose'>$purpose</textarea> 
<P><INPUT TYPE=submit VALUE=submit>
<INPUT TYPE='hidden' NAME='style' VALUE='$style'>
</FORM>	


PAGE1
;
&feedback('plot.pl','Data, Plots, and Downloads');
print $cgi->end_html;
}

sub get_title_label {

    my @labels = @_;
    my (@title_labels,@label_list);
    my ($old_thing,$thing);
    
    foreach $thing (@labels) {
		if (($thing !~ /left/) && ($thing !~ /right/) ) {
			$thing =~ s/.*_(.*?)\s.*/$1/;	
			$thing =~ s/.*_(.*)/$1/;	
			push @label_list, &get_pretty_name($thing);	
		}
    }
    foreach $thing (sort @label_list) {
		if ($thing ne $old_thing) {
			push @title_labels, $thing; }
		$old_thing = $thing;
    }
    return (@title_labels);
}

sub plot_cmds {
# This sub sets the plot commands for gnuplot.
# The idea is it gets a list like (x,right,y,left,z,right,q,skip)
# This means x gets plotted on the right side, y on the left, z on the right,
# q gets ignored.

	my ($agg_period,@labels) = @_;
	my ($left_label,$right_label,$side,$old_label);

	my @title_labels = &get_title_label(@labels);

	($gif_fh,$gnu_gif) = tempfile(SUFFIX => '.gif', DIR => "$Bin/temp");
	open($gif_fh,">$gnu_gif") || die "oops! no $gnu_gif";

	my ($cmd_fh,$gnu_cmd) = tempfile(UNLINK => 1, DIR => "$Bin/temp");
	open($cmd_fh,">$gnu_cmd") || die "Cannot open the plot command file";

	print $cmd_fh <<GNU;
set terminal gif small size 640,480
set output '$gnu_gif'
set data style linespoints
set xlabel 'Date'
set xdata time
set grid
set missing 'M'
set timefmt '%Y-%m-%d'
set title '@title_labels'
show title
GNU
	if ($agg_period =~ /monthly/ ) {
		print $cmd_fh "set timefmt '%m-%Y'\n";
		print $cmd_fh "set format x '%m-%Y'\n";
	}
	if ($agg_period =~ /yearly/ ) {
		print $cmd_fh "set format x '%Y'\n";}
	if (@labels > 2) {
		print $cmd_fh "set ytics border nomirror\n";
		print $cmd_fh "set y2tics border nomirror\n";
		for (my $i=0; $i<$#labels; $i=$i+2) {
			$title_labels[$i] = &get_pretty_name($labels[$i]);
			$labels[$i] =~ /^(.*?)\s.*?$/;
			if (($1 ne $old_label) || (!$old_label) ) {
				if ($labels[$i+1] =~ /right/){
					$right_label = $right_label . ' ' . $labels[$i];
					}
				if ($labels[$i+1] =~ /left/){
					$left_label = $left_label . ' ' . $labels[$i];}
			}
			$old_label = $1;
		}
		if ($left_label) {
			$left_label =~ s/\(.*?\)//g;
			print $cmd_fh "set ylabel '$left_label'\n";
		}
		if ($right_label) {
			$right_label =~ s/\(.*?\)//g;
			print $cmd_fh "set y2label '$right_label'\n";
		}
		print $cmd_fh "plot ";
		my $j = 0;
		for (my $i=0; $i<$#labels; $i=$i+2) {
			if ($labels[$i+1] =~ /right/){
				$side = '2';}
			elsif ($labels[$i+1] =~ /left/){
				$side = '1';}
			if ($j > 0) {print $cmd_fh ' , ';}
			#print $cmd_fh "'$file_1' index $j using 1:2 axes x1y$side title '$labels[$i]' ";
			print $cmd_fh "'$file_1' index $j using ".'1:(valid(2)?$2:1/0)'." axes x1y$side title '$labels[$i]' ";
			$j++;
		}
	}
	elsif (@labels == 2) {
		print $cmd_fh "set ylabel '$labels[0]'\n";
		#print $cmd_fh "plot '$file_1' index 0 using 1:2 axes x1y1 title '$labels[0]'";
		print $cmd_fh "plot '$file_1' index 0 using ".'1:(valid(2)?$2:1/0)'." axes x1y1 title '$labels[0]'";
	}

	return($gif_fh,$gnu_cmd);
}


## UPLOAD
#

sub upload {
	my $method = shift;
		if ($method =~ /comma/) {
			print "Content-type: application/text/comma-separated-values\nContent-Disposition: file; filename=\"data.csv\"\n\n";
		}
		if ($method =~ /tab/) {
			print "Content-type: application/text/tab-separated-values\nContent-Disposition: file; filename=\"data.dat\"\n\n";
		}
		if ($method =~ /html/) {
			print "Content-type: text/html\n\n";
		}
}

## MAKE_HMTL
#
# Transform the tab delimited file to a formatted HTML version.

sub make_html {
	s/\t/<\/TD><TD>/g;
	s/^/<TR><TD>/;
	s/$/<\/TD><\/TR>/;
}
