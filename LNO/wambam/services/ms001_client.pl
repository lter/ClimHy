#! perl -w

###
### This code (/var/www/climhy/wambam/services/ms001_client.pl) has been automagicly created 
### by /var/www/climhy/wambam/soap_server.pl 
### at Fri Feb 25 20:06:46 2011 
### The genuis behind it all is 
### Kyle Kotwica 
### kyle.kotwica@comcast.net

### You may edit it as you see fit, but don't blame me.
### It will get rewritten if the properties file changes or if 
### the user forces a rebuild. It is supplied as a test, or possibly
### as a stub to use for a starting point.

### If you like you can point a browser to 
###
### http://www.soapclient.com/soapclient?template=/clientform.html&fn=soapform&SoapTemplate=none&SoapWSDL=http://climhy.lternet.edu/wambam/soap_server.pl?wsdl=ms001
###
### For a more elegant test.
###


#BEGIN {open (STDERR, '>message.log');)
use SOAP::Lite +trace => qw(debug);


if (!$ARGV[0]) {
	print "\nUsage: perl <ms001>_client.pl method [args]\n";
	print "
Test web service for auto harvesting H.J. Andrews data for ClimDB; ala soap.

The available methods are:

TMAXairpri01
	begin - string
	end - string
given a date range, I will return the maxtemp, its flag and the date for each point in the date range. This method uses probe AIRPRI01.

TMINairpri01
	begin - date
	end - string
given a date range, I will return the mintemp, its flag and the date for each point in the date range. This method uses probe AIRPRI01.

TMEAairpri01
	begin - string
	end - string
given a date range, I will return the meantemp, its flag and the date for each point in the date range. This method uses probe AIRPRI01.
";
	exit();
}
my $method = shift;

my $soap =  SOAP::Lite
	#->uri("urn:ms001")
	#->proxy("http://climhy.lternet.edu/wambam/services/ms001_handler.pl")
	->service("http://climhy.lternet.edu/wambam/soap_server.pl?wsdl=ms001")
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
