#! /usr/bin/perl 
BEGIN {unshift (@INC, '/var/www/climhy/bin/webservice', "./bin/webservice" ) }

use master_client;
use strict;

# This is just a glorified configuration file.
# See master_client.pm for documentation.

my $site = $0;
$site =~ s/.*(...)\.pl$/$1/;
my $service = 'ms001';
#my $endpoint = 'http://127.0.0.1/cgi-bin/wambam/services/ms001_handler.pl';
#my $endpoint = 'http://wwwdata.forestry.oregonstate.edu/climdb/wambam/services/ms001_handler.pl';
my $endpoint = 'http://climhy.lternet.edu/wambam/services/ms001_handler.pl';

my @methods = (
	['TMEAairpri01','PRIMET','TMEA'],
	['TMAXairpri01','PRIMET','TMAX'],
	['TMINairpri01','PRIMET','TMIN'],
);

&client($site,$service,$endpoint,@methods);

