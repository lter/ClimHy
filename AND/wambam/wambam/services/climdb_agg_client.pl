#! perl -w

###
### This code (D:/forwww/lter/climdb/wambam/services/climdb_agg_client.pl) has been automagicaly created 
### by D:\forwww\lter\climdb\wambam\soap_server.pl 
### at Fri Apr  2 13:29:47 2004 
### The genuis behind it all is 
### Kyle Kotwica 
### kyle.kotwica@comcast.net

### You may edit it as you see fit, but don't blame me.
### It will get rewriten if the properities file changes or it 
### the user forces a rebuild. It is supplied as a test, or possably
### as a stub to use for a starting point.

### If you like you can point a browser to 
###
### http://www.soapclient.com/soapclient?template=/clientform.html&fn=soapform&SoapTemplate=none&SoapWSDL=http://wwwdata.forestry.oregonstate.edu/climdb/wambam/soap_server.pl?wsdl=climdb_agg
###
### For a more elegent test.
###


#BEGIN {open (STDERR, '>message.log');)
use SOAP::Lite +trace => qw(debug);


if (!$ARGV[0]) {
	print "\nUsage: perl <climdb_agg>_client.pl method [args]\n";
	print "
This web service allows a remote user to access the climdb_agg table from OSU's CLIMHY database. 

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
	#->proxy("http://wwwdata.forestry.oregonstate.edu/climdb/wambam/services/climdb_agg_handler.pl")
	->service("http://wwwdata.forestry.oregonstate.edu/climdb/wambam/soap_server.pl?wsdl=climdb_agg")
	;

$soap->on_fault(sub{print"\n\nOops!!!\n\n";die;});

my $som = $soap->$method(@ARGV);

# deserialize the SOAP message here.
# I suggest you *do not* use the WSDL interface.
# It seems SOAP::Lite does not deal with complex data in a WSDL very well.
# I have not investigated, but it does not seem to return a som object, but a 
# hash reference. This is OK, but odd. Since I'm not really conserned with the
# client end of things and only supply it here as a test of the service, why 
# bother? 
#  
