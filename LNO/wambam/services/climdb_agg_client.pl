#!/usr/bin/perl -w

###
### This code (/var/www/climhy/wambam/services/climdb_agg_client.pl) has been automagicly created 
### by /var/www/climhy/wambam/soap_server.pl 
### at Wed Oct  5 12:00:46 2011 
### The genuis behind it all is 
### Kyle Kotwica 
### kyle.kotwica@comcast.net

### You may edit it as you see fit, but don't blame me.
### It will get rewritten if the properties file changes or if 
### the user forces a rebuild. It is supplied as a test, or possibly
### as a stub to use for a starting point.

### If you like you can point a browser to 
###
### http://www.soapclient.com/soapclient?template=/clientform.html&fn=soapform&SoapTemplate=none&SoapWSDL=http://ramble.lternet.edu/wambam/soap_server.pl?wsdl=climdb_agg
###
### For a more elegant test.
###


#BEGIN {open (STDERR, '>message.log');)
use SOAP::Lite +trace => qw(debug);


if (!$ARGV[0]) {
	print "\nUsage: perl <climdb_agg>_client.pl method [args]\n";
	print "
This web service allows a remote user to access the climdb_agg table from the CLIMHY database. See xxx for more documentation.

The available methods are:

get_agg_monthly
	site_code - string
	station - string
	variable - string
	aggregate_type - string
	begin - string
	end - string
Gets the aggregated data from climdb_raw for a given range of years. Begin and end are years e.g. 1990

get_agg_yearly
	site_code - string
	station - string
	variable - string
	aggregate_type - string
	begin - string
	end - string
This returns the yearly value of the aggregated varaible over a given range of years. Begin and end are years e.g. 1990

agg_over_all
	site_code - string
	station - string
	variable - string
	aggregate_type - string
This returns the monthly value of the aggregated varaible over the entire period of record.
";
	exit();
}
my $method = shift;

my $soap =  SOAP::Lite
	#->uri("urn:climdb_agg")
	#->proxy("http://ramble.lternet.edu/wambam/services/climdb_agg_handler.pl")
	->service("http://ramble.lternet.edu/wambam/soap_server.pl?wsdl=climdb_agg")
	;

$soap->on_fault(sub{print"\n\nOops!!!\n\n";die;});

my $som = $soap->$method(@ARGV);

# deserialize the SOAP message here.
# I suggest you *do not* use the WSDL interface.
# It seems SOAP::Lite does not deal with complex data in a WSDL very well.
# I have not investigated, but it does not seem to return a som object, but a 
# hash reference. This is OK, but odd. Since I'm not really concerned with the
# client end of things and only supply it here as a test of the service, why 
# bother? 
#  
