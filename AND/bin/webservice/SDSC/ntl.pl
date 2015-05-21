#! perl -w

BEGIN {unshift (@INC, '\\\GINKGO\lter\climdb\bin', '.\bin' ) }

# To connect client to harvest; put client in bin/ and change data_URL to 
# bin/[clientName].pl
# NOTE! harvest expects the following naming convention: [site_code].pl

# This uses the xxx.pm client library
use xxx;
#use SOAP::Lite +trace => qw(debug);

my %variable_hash = (
	TMAX => 'getNTLDailyMaxAirTemp' ,
#	TMIN => 'getNTLDailyMinAirTemp',
#	TMEA => 'getNTLDailyMeanAirTemp',
#	PREC => 'getNTLDailyTotPrecip',
);

my %station_hash = (
	AIRPORTWOO => { %variable_hash }, 
);

&client	(	'ntl',
			'urn:vgx-LTERClimDBHarvester',
			'http://192.31.21.60:8080/vxe/listener-soap.pperl',
			%station_hash
);
