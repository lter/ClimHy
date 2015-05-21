#! perl -w
#
#This is the main webservice client for LTER web services.
#This wont work very well! It only works if your webservice is adherent to 
#the convenetion set by 'some' of the San Diego serivices.
#You'll still need to write the station_hash and the variable_hash 

#my %variable_hash = (
#	TMAX => 'getVCRDailyMaxAirTemp'
#my %station_hash = (
#	HOGI => {%variable_hash}
#in the [whatever].pl client

#Then call this code.
#
# To connect client to harvest; put client in bin/ and change data_URL to 
# bin/[clientName].pl
# NOTE! harvest expects the following naming convention: [site_code].pl

BEGIN {unshift (@INC, '\\\GINKGO\lter\climdb\bin', '.\bin' ) }

use Getopt::Std;
use strict;
use clim_lib;
use sql_cmd;
use SOAP::Lite;
#use SOAP::Lite +trace => qw(debug);

my $dbh;

sub client {
	my ($site,$uri,$proxy,%station_hash) = @_;
	$site = uc($site);
#read control file 
	my %control = &read_control();
	
#connect with database
	$dbh = DBI->connect($control{data_source},$control{data_user},$control{data_password}) || print "Connect failure in xxx.pm \n";
	
	my $break = '<BR>';
	my $para = '<P>';
	my $tab = '-------->';
	my $som;

	our ($opt_c,$opt_b,$opt_e);
	&getopts('cb:e:');  
	my $start = $opt_b;
	my $end = $opt_e;
	
	if ($opt_c) {	
		open OUT, ">../data/$site.ws" or die;
		$break = "\n";
		$para = "\n";
		$tab = "\t";
	} else {
		open OUT, ">./data/$site.ws" or die;
	}	
	
	my $soap = SOAP::Lite                             
		->uri($uri)
		->on_action(sub{sprintf '%s-%s',@_})
		->proxy($proxy);
	
	print "$break Harvest is using web service interface" if (!$opt_c);
	foreach my $station (keys %station_hash) {
		print "$para Accessing ".&station_fix($station);
		foreach my $variable (keys %{ $station_hash{$station} }) {
			if (!$opt_b) {
				$start = &start($site,&statioin_fix($station),$variable);}
			if (!$opt_e) {
				$end = &today;}
			print "$break \t Retrieving $variable --------- $start -> $end";
			my $message_name = $station_hash{$station}{$variable};
	
			if ($site eq 'NTL'){
				$som = $soap->$message_name(
					SOAP::Data->name(start_date => $start),
					SOAP::Data->name(end_date => $end)
				);
			} else {
				$som = $soap->$message_name(
					SOAP::Data->name(station => $station),
					SOAP::Data->name(start_date => $start),
					SOAP::Data->name(end_date => $end)
				);
			}
				
			my @list = $som->valueof("//Envelope/Body/$message_name"."Response/climdb/row/*");
			my $count = @list / 3;
			my $long_name = &get_long_name($variable);
	
			print OUT "!LTER_Site,Station,Date,$long_name,".'flag_'."$long_name\n";	
			if ($opt_c) 
				{print "\n!LTER_Site,Station,Date,$long_name,".'flag_'."$long_name";}	
			for (my $i = 0; $i<$count; $i++) {
				my ($date,$value,$flag) = splice(@list,0,3);
				print OUT "$site,".&station_fix($station).",".&date_fix($date).",$value,$flag\n" if ($date ne '--');
				if ($opt_c) 
					{print "\n$site,".&station_fix($station).",".&date_fix($date).",$value,$flag" if ($date ne '--');}
			}
		}
	}
	$dbh->disconnect;
	print "$break Triggering the harvester now: $break" if !($opt_c);
}

sub today {
	my @today = localtime(time);
	$today[5] += 1900;
	$today[4] += 1;
	my $end_date = "$today[5]-$today[4]-$today[3]";
	return('20010102');
}

sub date_fix {
	$_ = shift;
	s/-//g;
	s/ ..:..:..\....//;
	chomp;
	return($_);
}

sub get_long_name {
	my $variable = shift;

	my $sqlcmd = &get_cmd('601',$variable);
	return(&query_DB($sqlcmd,'value',$dbh));
}

sub start {
	my ($site,$station,$variable) = @_;
	
	my $sqlcmd = &get_cmd('602',$site,$station,$variable);
	my $start = &query_DB($sqlcmd,'value',$dbh);

	#return(&date_fix($start));
	return('20010101');
}

sub AUTOLOAD {
	return(shift);
}

1;
