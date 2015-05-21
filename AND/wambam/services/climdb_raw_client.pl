#! perl -w

###
### This code (D:/forwww/lter/climhy/wambam/services/climdb_raw_client.pl) has been automagicaly created 
### by D:\forwww\lter\climhy\wambam\soap_server.pl 
### at Thu Feb 10 17:19:08 2005 
### The genuis behind it all is 
### Kyle Kotwica 
### kyle.kotwica@comcast.net

### You may edit it as you see fit, but don't blame me.
### It will get rewriten if the properities file changes or it 
### the user forces a rebuild. It is supplied as a test, or possably
### as a stub to use for a starting point.

### If you like you can point a browser to 
###
### http://www.soapclient.com/soapclient?template=/clientform.html&fn=soapform&SoapTemplate=none&SoapWSDL=http://wwwdata.forestry.oregonstate.edu:80/climhy/wambam/soap_server.pl?wsdl=climdb_raw
###
### For a more elegent test.
###


#BEGIN {open (STDERR, '>message.log');)
use SOAP::Lite +trace => qw(debug);


if (!$ARGV[0]) {
	print "\nUsage: perl <climdb_raw>_client.pl method [args]\n";
	print "
This service allows the user to access the the climdb_raw table in the ClimDB database. See xxx for more documentation.

The available methods are:

get_day
	res_site_id - int
	date - date
This method returns all the data for a given research site id on a given day. Date is YYYY-MM-DD. An example request would be; res_site_id = 47 date = 2000-01-01. An example response would be TMAX,12,G,TMIN,10,G,TMEA,....

last_harvest
	site - string
	station - string
	variable - string
Given a site(AND) , a station (PRIMET), and a ClimDB long name (DAILY_AIRTEMP_MAX_C) , or short name (TMAX) , I will return the date of the last harvest of that varialbe.

get_variable
	site_code - string
	station - string
	variable - string
	date - date
	date1 - date
This method returns the value for a variable between a given date range. Date is YYYY-MM-DD. i.e. given AND,PRIMET,TMAX,2000-01-01,2000-01-03. The response would consist the variable name(TMAX), its value and flag, and the date for the three values on the 1st through the third of January 2000.
";
	exit();
}
my $method = shift;

my $soap =  SOAP::Lite
	#->uri("urn:climdb_raw")
	#->proxy("http://wwwdata.forestry.oregonstate.edu:80/climhy/wambam/services/climdb_raw_handler.pl")
	->service("http://wwwdata.forestry.oregonstate.edu:80/climhy/wambam/soap_server.pl?wsdl=climdb_raw")
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
