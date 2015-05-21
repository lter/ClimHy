#! perl
use warnings;
use strict;
use FindBin qw($Bin);
use lib "$Bin";
# SQL commands go to query.log
open POO, ">$Bin/query.log" or die "Can't open $Bin/query.log $!";

use CGI;
use DBI;
use Time::JulianDay;
use Math::Trig;
use CGI::Carp qw(fatalsToBrowser);

use glitch_html;
# All HTML is in glitch_html.pm
# If you want to fix spelling and stuff look there

# List all flags here, in order of precedence (Don't use a G flag).
my @FLAGS = qw(M E Q A B S);
@FLAGS = &set_flags(@FLAGS);

# set $DEBUG to 1 for extra output
my $DEBUG = 0;

#Time this 
#use Benchmark;

# DATABASE CONNECTIVITY INFO
my $DBH = &get_it(	'connect',
					'DBI:ODBC:rocky_lter_ltermeta',
					'ltermeta',
					'#dbLterM&ta');
			
# CGI 
my $CGI = new CGI;
my %P = $CGI->Vars;

# if a file is specified in the URL i.e. (...glitch.pl?input=[filename])
# load Vars
&file_input if $P{input};
if ($P{debug}) {$DEBUG = $P{debug};}

# if first page, we know $sub_entity_id, ask user for input
if ($P{sub_entity_id}) {
	&header();	
	&make_form;

# otherwise, get data and glitch it as per users wishes
} else {
	#my $t0 = &time_it();
	my $fetch = &get_glitch_info();
	if ($P{download}) {
		print "Content-type: application/text/comma-separated-values\nContent-Disposition: attachment; filename=\"$P{sub_entity_title}.csv\"\n\n";
	} else {
			&header();
	}
	&pretty_header();
	&do_it($fetch);
	if (!$P{download}) {print "</PRE>";}
	#&time_it($t0);
}
if (!$P{download}) { &footer(); }


####
# END OF MAIN
####

sub file_input {
	if (!open(DATA, $P{input})) {
	   	$P{input} = $Bin . $P{input}; 
		open(DATA, $P{input}) || die "cant open ",$P{input}," : $! \n";
	}
	for(1..8) {
		my @huh = split /=>/,<DATA>;
		chomp($huh[1]);
		$P{$huh[0]} = $huh[1];
	}
}

sub time_it {
	if ($_[0]) {
		my $t0 = shift;
		my $t1 = new Benchmark;
		my $td = timediff($t1,$t0);
		if (!$P{download}) {
			print "<FONT SIZE=-2>The code took ",timestr($td),"</FONT>";}
	} else {
		my $t0 = new Benchmark;
		return($t0);
	}
}

sub fetch_it {
	my $sqlcmd = shift;
	print POO "\n$sqlcmd\n";
	my $sth=$DBH->prepare($sqlcmd) || print "prepare failure: " . $DBH->errstr;
	$sth->execute || print "execute failure: ".$sth->errstr;
	return($sth);
}

sub fetch_row {
	my ($handle) = @_;

	if (!$P{input}) {
		$handle->fetchrow_array 
	} else {
		my @huh = split /\t/,<DATA>;
		if (!$huh[0]) {return -999;}
		my $huh = pop(@huh);
		chomp $huh;
		push @huh, $huh;
		return @huh;
	}
}

sub do_it {
	my ($sth) = @_;					# handle for DBI if not comming from a file

	my @incoming;					# convienence array for incomming data
	my @data;						# holds up to 3 variables
	my @flags;						# the 3 flags that corrispond to @data
	my @old_flags = qw/G G G/;		# the last 3 flags read
	my @left_over = (0,0,0);		# $left_over is the remainder that needs to
									# be carried over to the next ieteration
									# if we pass into another time period
									# TIME:
	my $t;							# data is read from DB at time $t
	my $et = 0;						# $et is the time of the estimate
	my $lt = 0;						# $lt is the last time we computed a value
	my $last_read_time = 0;			# the last time we read data
	my ($date,$jday);				# handle dates
	my $start = 1;					# flag to signal first time

DATA: while( ($t,@incoming) = &fetch_row($sth)) {
		if ($t =~  /-999/) {return;}
		($date,$t) = &date($t);		# split into a date and a time

# @incoming is data/flag pairs; 
# @data will be in one minute values
# @flags will be the flags
		@flags = &break_down(($t-$last_read_time),\@data,@incoming);
		print "READ: $date $t \t $data[0] f=$flags[0] of=$old_flags[0]\n" if $DEBUG;
		&flags(\@flags,\@old_flags);
		
		if ($start) {			# Do this the first time through
			($et,$start,$jday) = &first_time($date,$t);
			next DATA;
		}
		if  ($t == 0) { $t = 1440; }

# as long as we havent crossed over a boundary glitch it
# if this is the first time in a new boundary make sure to add whats left 
# over from the last
		while ($et <= $t) {
			&flags(\@flags,\@old_flags);
			my @est = &compute(($et-$lt),\@data,\@left_over);
			&print_this($jday,$et,\@est,\@old_flags);
			print "\tet=$et t=$t lt=$lt f=$flags[0] of=$old_flags[0] lrt=$last_read_time\n" if $DEBUG;
# if we no longer care about the old data reset old flags
			if ($last_read_time <= $et) {
				@old_flags = ('G','G','G');
# shift this flag into old flag to be safe; only important if theres a leftover
				if ($et < $t) {
					&flags(\@flags,\@old_flags);}
			}
# if last point of the day we don't care about old flags; reset times as well
			if (($et == 1440) && ($t == 1440)) {
				($et,$t,$last_read_time) = (0,0,0);
				@old_flags = ('G','G','G');
			}
			@left_over = (0,0,0);
			$lt = $et;
			$jday += $P{delta}/1440;
			$et += $P{delta};
		}
# seems weve crossed over a boundary, compute how much happened before the
# boundary and store it in $left_over.
		if ($lt != $t) {
			for (my $i = 0;$i <= $#data;$i++) {
				if ($data[$i]) {
					$left_over[$i] += $data[$i]*($t-$lt);}
			}
			$lt = $t;
		}
	$last_read_time = $t;			
	}
}

sub compute {
	my ($t,$data,$left_over) = @_;
	my ($x,$y,$z);
	
	$x = (@$data[0]*$t+@$left_over[0]);
	print "COMPUTE: $x = (@$data[0] * $t)+ @$left_over[0]\n" if $DEBUG;
	if (($P{type} =~ /mean/i) || ($P{type} =~ /wind/i)) {
		$x /= $P{delta};
		if ($P{type} =~ /wind/i) {
			$y = (@$data[1]*$t+@$left_over[1]);
			$y /= $P{delta};
			$z = (@$data[2]*$t+@$left_over[2]);
			$z /= $P{delta};
			($x, $z) = &rebuild_wind($x, $z);
			if (!$y) {$y='0.0';}
			if (!$z) {$z='0.0';}
		}
	}
	return ($x,$y,$z);
}

sub first_time {
	my ($date,$t) = @_;
# we must start at midnight but we cant print anything because we don't know
# the previous time periods info
	if ($t != 0) {return(undef,1,undef);}
# if its midnight; set $et and $jday and go with it
	my $et = $P{delta};
	$date =~ /^(....)-(..)-(..)/;
	my $jday = &julian_day($1, $2, $3);
	return($et,undef,$jday);
}
			
sub convert_flag {
	my $flag = shift;
	
				# M=1, E=2,...., NULL|G=(number of flags)
	if ((!$flag) || ($flag eq 'NULL')) {
		$flag = $#FLAGS;		# if no flag set to G
	} else {
		if ($flag =~ /U/) {$flag = 'Q';}
		for(my $i=1;$i<=$#FLAGS;$i++) {
			$flag =~ s/$FLAGS[$i]/$i/i;}
	}
	return $flag;
}

# order of precedence of flags is M,E,Q,A,B,S
sub flags {
	my ($flag_arr,$old_flag_arr) = @_;

	my $size = @$flag_arr;
	for (my $i=0;$i<$size;$i++) {
		(@$old_flag_arr[$i]) = &flag_guts(@$old_flag_arr[$i],@$flag_arr[$i]);
	}
	
}
	
sub flag_guts {
# given 2 flags convert them to a number compare and return the lowest
	my($old_flag,$flag) = @_;
	
	$old_flag = &convert_flag($old_flag); #convert to a number for comparison
	$flag = &convert_flag($flag);
	if ($flag !~ /\d/) { 
		$flag = 1;
	}
	if ($flag <= $old_flag) { return($flag);}
	else { return ($old_flag);}
}

sub reconvert_flags {
	my ($flag,$x) = @_;

	if (!$flag) {$flag = ' ';}
# M=1, E=2,...., NULL|G=(number of flags)
	for(my $i=1;$i<=$#FLAGS;$i++) {
		$flag =~ s/$i/$FLAGS[$i]/i;}
	if ($flag =~ /G/) {$flag = ' ';}
	if ($flag =~ /M/) {$x = 'NULL';}

	return($flag,$x);
}

sub rebuild_wind {
	my ($x,$y) = @_;
	if (!$x) {$x = 0.0;}
	if (!$y) {$y = 0.0;}

	my $dir = rad2deg(atan2($x,$y));
	if ($dir < 0) {$dir += 360;}
	my $spd = sqrt(($x*$x)+($y*$y));
	return($spd,$dir);
}

sub print_this {
	my ($jday,$time,$est,$flag) = @_;
	my ($flag1,$flag2,$flag3,$x,$y,$z);

# for wind; magnitude and direction flags must be linked?
#bug in julian_day?
	my @day_fudge = &inverse_julian_day(int($jday+.0001));
#change the format of time (720) to hhmmss (12:00:00) and deal with midnight
	($time,$day_fudge[2]) = &hhmmss($time,$day_fudge[2]);

	my $string = sprintf"%s,%s,%s,%s,%02d-%02d-%02d, %s,",$P{filename},$P{entity_number},$P{sitecode},$P{sub_entity_title},@day_fudge,$time;
	
	if ($P{type} =~ /wind/i) {
		@$flag[0] = &flag_guts(@$flag[0],@$flag[2]);
		@$flag[2] = @$flag[0];
		($flag2,$y) = &reconvert_flags(@$flag[1],@$est[1]);
		($flag3,$z) = &reconvert_flags(@$flag[2],@$est[2]);
	}
	($flag1,$x) = &reconvert_flags(@$flag[0],@$est[0]);
	
	$string .= &is_null($x,$flag1);
	if ($y) { $string .= "," . &is_null($y,$flag2); }
	if ($z) { $string .= "," . &is_null($z,$flag3); }

	#if ($P{download}) { $string =~ s/\t/,/g; } 
	print "$string\n";
}

sub is_null {
	my ($x,$flag) = @_;
	my $value;
	
	if ($x =~ /NULL/) {
		$value = sprintf"%*s",$P{width},' ';
	} else {
		$value = sprintf"%*.*f",$P{width},$P{percision},$x;
	}
	return(sprintf"%s,%s",$value,$flag);
}

sub hhmmss {
	my ($time,$day) = @_;
	#if ($time == 1440) { $time = 0; }
	my $hhmmss = sprintf("%02d:%02d:00",$time/60,$time%60);
	#if ($hhmmss =~ /24:00:00/) { 
	#	$hhmmss = '00:00:00';
	#	$day += 1; 
		#$jday = int($jday); 
		#	}
	return($hhmmss,$day);
}

sub date {
#1971-10-23 00:00:00.000
	my ($time) = @_;
	$time =~ m/(....-..-..) (..):(..):....../;
	my $minutes = $3 + ($2*60);
		return ($1,$minutes); 
}

# gets the one minute value of a total (total/time_span)
# or breaks down wind into components
sub break_down {
	my ($time_span,$data,$x,$f1,$y,$f2,$z,$f3) = @_;
	#oops, if $time_span is negitive you have a problem !!!
	#its because $time_span = time - last time OR
	#			 $time_span = 0    - last time
	# Which happens at mid night (1440 or 0) depending on fox pro / MSSQL
	# so stupid hack #1498 if $time_span < 0 $time_span = 1440 + $time_span
		
	print "$time_span\n" if $DEBUG;
	if ($time_span <= 0) {$time_span = 1440 + $time_span;}
	if (!$x) {$x = 0.0;}
	if ($P{type} =~ /total/i) {
		if (($time_span) && ($x)) {
			$x /= ($time_span);
		}
	} elsif ($P{type} =~ /wind/i) {
		if (!$z) {$z = 0.0;}
		if (!$y) {$y = 0.0;}
		if (($x<0)||($z<0)) {($f1,$f3) = ('M','M');}
		if ($y<0) {$f2 = 'M';}

		my $temp_x = $x;
		$x = $x * cos(deg2rad(90-$z));
		$z = $temp_x * sin(deg2rad(90-$z));
	}
	@$data = ($x,$y,$z);
	return($f1,$f2,$f3);
}


sub pretty_header {

	my $time = localtime();
	my ($p,$br,$f1,$f2,$b1,$b2,$more);
	if (!$P{download}) {
		$p = '<P/>';
		$br = '<BR/>';
		$f1 = '<FONT SIZE=-1>';
		$f2 = '</FONT><PRE>';
		$b1 = '<B>';
		$b2 = '</B>';
	}
	if ($P{type} =~ /wind/i) {
		$more = ",$P{v2},$P{f2},$P{v3},$P{f3}"; 
	}

	print <<EOF
Download for $P{sub_entity_desc} $br $b1 ($P{sub_entity_title}) $b2 $p
beginning at $P{begin} and ending at $P{end} $br
glitched to $P{delta} minute intervals $p
$f1 generated at $time $f2\n
Stcode,Format,Sitecode,Probe,Date,Time,$P{v1},$P{f1}$more
EOF
;
}

sub get_glitch_info {
	my $sqlcmd = 
"SELECT *  FROM fsdbdata..ms001_p where code = '$P{sub_entity_title}'";
	($P{filename},undef,undef,$P{type},$P{att_type},$P{v1},$P{f1},
		undef,$P{v2},$P{f2},undef,$P{v3},$P{f3}) = &get_it($sqlcmd);
	$P{att_type} =~ /numeric\((\d),(\d)\)/;
	$P{width} = $1;
	$P{percision} = $2;
$P{percision} = 5 if $DEBUG;
	$P{filename} =~ s/\s+$//;

	$sqlcmd = 
"SELECT DISTINCT sitecode 
FROM	fsdbdata..$P{entity_file_name}
WHERE	probe = '$P{sub_entity_title}'";
	($P{sitecode}) = &get_it($sqlcmd);
	
	my $select = "SELECT date_time, $P{v1}, $P{f1}";
	if ($P{sub_entity_title} =~ /^WND/i) {
		$P{type} = 'wind';
		$select .= ", $P{v2}, $P{f2}, $P{v3}, $P{f3}"; 
	}

	$sqlcmd = "
$select
FROM fsdbdata..$P{entity_file_name} 
WHERE	date_time <= '$P{end}' AND 
	date_time >= '$P{begin}' AND 
	probe = '$P{sub_entity_title}' 
ORDER BY date_time";
&fetch_it($sqlcmd);	
}

sub make_form{
	my $sqlcmd = 
"SELECT e.entity_file_name, 
	se.sub_entity_title,
se.sub_entity_desc,
	e.entity_number,
	e.entity_id
FROM entity e, sub_entity se
WHERE se.entity_id = e.entity_id
  AND se.sub_entity_id = $P{sub_entity_id}";
	my @data = &get_it($sqlcmd);

my $probe = lc($data[1]);
	$sqlcmd = 
"SELECT (min(date_time)), (max(date_time)) 
FROM fsdbdata..$data[0]
WHERE probe='$probe'
";
	push @data,&get_it($sqlcmd);
	&form(@data);
}

sub get_it {
	my ($sqlcmd) = shift;
	
	if ($sqlcmd eq 'connect') {
		$DBH = DBI->connect(@_) ||die"Connect failure in $0 ".$DBI::errstr."\n";
		return($DBH);
	}
	print POO "\n$sqlcmd\n";	
	my @answer;
	my $sth=$DBH->prepare($sqlcmd) || print "prepare failure: " . $DBH->errstr;
	$sth->execute || print "execute failure: ".$sth->errstr;
	while (my @get_it = $sth->fetchrow_array){
		push (@answer,@get_it);}
	return(@answer);
}

sub set_flags {
	push @_, 'G';
	unshift @_, 'X';
	return @_;
}

__END__

=head1 NAME

Glitch - General Linear Integrator for Time CHanging

=head1 DESCRIPTION

Use for manipulating time series data. Can be used to either sum up over time intervals or extrapolate down to a smaller time interval. The selected time interval must be a positive integer that has a multiple that is equal to 1440. That is all 'glitched' output must have a value printed at midnight.

This version of glitch takes a sub_entity_id as a parameter (through URL).   Looks up the necessary values from tables; entity, sub_entity, and MS001xx.  The user interface prompts the user for a begin time, end time, and a time frame to 'glitch' to. Also uses javascript to verify that the number of minutes selected by the user is valid. Directly downloading the 'glitched' data to a comma delimited '.csv' file is also provided for. There is also a provision for using data files as opposed to getting the data from a RDMS. This is mostly for debugging. See L</DEBUGGING>.

We fill in missing times. The assumption is that the raw data is the value since the previous data point. There are three routines, means,totals, and wind. L</METHODS>

Flags can be set to order of precedence. See L</NOTES TO MAINTAINER>. The flag with the highest precedence will carry through to the final output. 

There (was) a 'Deglitcher' debugging program. It has used early in the development process and is no longer functional. The remnants of this code can be found in directory /old.

=head1 METHODS

This program breaks the data down to 1 minute chunks, multiplies the chunk by how many minutes in each bin, adds each full or partial bin, then divides by the glitch period.

For example: if the user asks for 15 min data, and the database has;

 00:00 3
 00:13 4
 00:25 5
 00:27 1
 00:45 3

The first bin is from 0 to 15 minutes, the second 15 to 30, lastly 30 to 45.

The first estimate is at 15 minutes, that is 4 minutes of 13 and 2 minutes of 5;

 (4*13) + (5*2) / 15 = 4.13 @ 15

Then, from 15 to 30 we have 10 minutes of 5, 2 minutes of 1, and 3 minutes of 3, or;

 (10*5) + (2*1) + (3*3) / 15 = 4.06 @ 30

Finally

 (15*3) + (0) / 15 = 3 @ 45

For totals the only difference is we divide the value by the time first, so;

 ((4/13) * 13) + ((5/12) * 2) = 4.83 @ 15
 The 12 in the equation is 25 - 13 the total amount of time of the 5 value.

=head2 WIND

Wind consists of 3 variables, meanwind, windmag, and winddir. Wind is treated as a L</MEAN> See L</METHODS>. Windmag is treated as a typical mean value, however direction and speed are broken into vectors. These vectors are then glitched, treating each vector as a mean. These 'glitched' vectors are then recombined into a 'glitched' speed and magnitude.

In this program, if the magnitude is 0, direction will be 0. The opposite is not true, however. Also, the flags for speed and direction are linked. That is, the more severe of the two flags is assigned to both. (i.e. if speed is 'M' and direction is 'G'; both will be set to 'M'. This is because the two values are used in the vector arithmetic.

If speed or direction are negative, both are set to missing ('M'). If windmag is negative, it is set to missing. 

To break down to vectors;
 
		$x = $speed * cos(deg2rad(90-$direction));
		$y = $speed * sin(deg2rad(90-$direction)); 

To recombine;

		$direction = rad2deg(atan2($x,$y));
		if ($direction < 0) {$direction = 360 + $direction;}
		$speed = sqrt(($x*$x)+($y*$y));

=head2 MEAN

Means are the sum of weighted averages of the constituent values. See L</METHODS>.

=head2 TOTAL

Totals are the sums of the estimated one minute values over the constituent intervals. See L</METHODS>. 

=head1 DEBUGGING

A testing harness is included in the directory /t. From the command prompt run test.pl. It will run a series of tests, displaying the success/failure of each test. The testing program uses the UNIX diff utility. If you run this in Windows the testing program will still work, but the results will only show if the test passed or failed.

If you would like to run your own tests, or run the program on data from a file instead of from the DB, do the following. First, make a file holding the data, following this format.

 entity_file_name=>MS00114
 sub_entity_desc=>'blah blah blah'
 sub_entity_title=>wndpri01
 entity_number=>14
 entity_id=>980
 begin=>2000-11-04
 end=>2000-11-05
 delta=>90
 2000-11-04 00:00:00.000	.5	NULL	.5	NULL	90.0	NULL
 2000-11-04 01:00:00.000	.5	NULL	.5	Q	90.0	NULL
 2000-11-04 02:00:00.000	.5	NULL	.5	NULL	90.0	NULL
 2000-11-04 03:00:00.000	.5	NULL	.5	NULL	270.0	NULL

Set the values on the first 8 lines to correspond to the variable in question. The data should be tab delimited, NULL values can either be the string 'NULL' or 'really' null. The format is identical to what you would find if you cut and paste from 'MS Query Analyzer'. Of course if using means or totals the last 4 fields should not exist. See the samples in t/.

To run on a test file (say test.txt) simply point your browser to 

C<http://glitch_home/glitch.pl?input=test.txt&debug=1> 

The debug flag is optional set to 0 or leave off if not desired (recommended).

=head1 NOTES TO MAINTAINER

All (most) of the HTML is in glitch_html.pm; in this directory. It consists of three functions; the input form, the header and the footer. The header and footer are designed to match the coldfusion pages. The data is output in the print_this subroutine as a sprintf formatted string. The format (width, precision) is set in MS001_p.

Set @FLAGS in the order of precedence. The first flag in the list has precedence. Don't use a G or an X flag in this list. Any flag not in the list that is found in the data will be set to the first flag in the list. 

=head1 BUGS, ISSUES 

Snow Lysimeter has a 'U' flag. 

NOTE: Fox pro and perl don't agree on how to round up numbers. Go figure! What is 1.5 any way? 1 or 2? In a previous version of this program (version 2.0) I had a hack in place to mimic the behavior of foxpros rounding scheme. See that program for more info. I undid this hack because it was stupid. If this is important I need to look into how perl rounds and if there is a way to change the rules.

One restriction this program puts on the output is it needs to read a 0 hour value before it starts. If the first data point in the DB is at 6:00 I won't start until the next day at 0:00. This could almost certainly be worked around, but I'm tired.

Weird things are happening in wind. Some times there is speed with a direction of 0 or direction with a speed of 0. This isn't a problem with the raw data, but it is when I try to rebuild it using vectors. This program will not agree with the foxpro output in some cases. If meanwind is 0, I return zeros for speed and direction.

Also the deglitcher reports at least one case (19940119 wndpri01_hr.txt) where the foxpro output reports a negative wind, this 'sucks', sort of speak. This fault is apparently in the foxpro. 

Of course I'm unclear as to weather I should be using meanwind or windmag, I am using meanwind and winddir.

=head1 AUTHOR

Kyle Kotwica E<lt>Kyle.kotwica@comcast.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Kyle Kotwica

Mine, all mine! leave it alone or I'll threaten you and stuff like that.

=cut

