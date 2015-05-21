#! /usr/bin/perl -w

###
### This code (D:/forwww/lter/climdb/wambam/services/sample_client.pl) has been automagicaly created 
### by D:\forwww\lter\climdb\wambam\soap_server.pl 
### at Thu Jul 22 13:31:11 2004 
### The genuis behind it all is 
### Kyle Kotwica 
### kyle.kotwica@comcast.net

### You may edit it as you see fit, but don't blame me.
### It will get rewriten if the properities file changes or it 
### the user forces a rebuild. It is supplied as a test, or possably
### as a stub to use for a starting point.

### If you like you can point a browser to 
###
### http://www.soapclient.com/soapclient?template=/clientform.html&fn=soapform&SoapTemplate=none&SoapWSDL=http://wwwdata.forestry.oregonstate.edu/climdb/wambam/soap_server.pl?wsdl=sample
###
### For a more elegent test.
###


#BEGIN {open (STDERR, '>message.log');)
use SOAP::Lite +trace => qw(debug);


if (!$ARGV[0]) {
	print "\nUsage: perl <sample>_client.pl method [args]\n";
	print "
This is a sample web service built by wambam. It is for demonstration.

The available methods are:

research_site_list
	id - int
This demonstrates a array of responses to a SQL query. Give me an site id and I'll return a list of all res_site_codes and res_sites_names corresponding to that id.

add_it
	a - string
	b - string
This demonstrates the Perl API. This web service simply adds two numbers and returns the result. The heavy lifting is done by a perl module called add.pm. the subroutine add_it takes two argumetns adds them and returns the result. If I know where it is I'll do the rest.

sites
	low - int
	high - int
Give me to site ids (high, low) and I'll return the site_name,loc1 and ,loc2 for each site in the range between high and low.

empty
This simply returns the name of the person with the personnel id of 44

personnel_email
	id - int
This demonstrates a simple SQL query. supply an id number and I'll return the corresponding email address.
";
	exit();
}
my $method = shift;

my $soap =  SOAP::Lite
	#->uri("urn:sample")
	#->proxy("http://wwwdata.forestry.oregonstate.edu/climdb/wambam/services/sample_handler.pl")
#	->service("http://data.forestry.oregonstate.edu/climdb/wambam/soap_server.pl?wsdl=sample")
	->service("http://climhy.lternet.edu/wambam/soap_server.pl?wsdl=sample")
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
