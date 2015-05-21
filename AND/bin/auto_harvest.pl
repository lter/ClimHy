#! perl 
use warnings;
use strict;
#use clim_lib;
#BEGIN {unshift (@INC, 'blah', '\\ginkgo\forwww\lter\climhy\bin' ) }

#read control file 
#my %control = &read_control();	

# add all sites that wish to be auto havested below
# as a comma delimited list e.g.
#my @sites = ('and', 'baz', 'foo', 'bar');
my @sites = ('and');

use LWP::UserAgent;

my $ua = LWP::UserAgent->new;
$ua->agent("auto_harvest/0.1 ");

my ($request, $response);
foreach my $site (@sites) {
	$request = HTTP::Request->new(POST => "http://wwwdata.forestry.oregonstate.edu/climhy/harvest.pl");
#	$request = HTTP::Request->new(POST => "$control{web}/harvest.pl");
	$request->content_type('application/x-www-form-urlecoded');
	$request->content("site=$site");
	$response = $ua->request($request);
}


	
