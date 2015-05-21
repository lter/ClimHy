#! perl -w
use strict;
use vars qw/@sites $site $ua $req $resp/;

# change the following (space only between sitecodes)
@sites = qw/jrn ntl vcr kbs/;

use HTTP::Request;
use LWP::UserAgent;

$ua = LWP::UserAgent->new;
foreach $site (@sites) {
	print "Attempting to harvest [$site]\n";
	$req = HTTP::Request->new
		('GET',"http://lterweb.forestry.oregonstate.edu/climhy/harvest.pl?site=$site&module=1");
	$resp = $ua->request($req);
	print "DONE\n" if $resp->is_success;
	print "OOPS!\n" if $resp->is_error;
}

