#! perl -w

BEGIN {unshift (@INC, '\\\GINKGO\lter\climdb\bin', '.\bin' ) }

# To connect client to harvest; put client in bin/ and change data_URL to 
# bin/[clientName].pl
# NOTE! harvest expects the following naming convention: [site_code].pl

# This uses the xxx.pm client library
use xxx;
#use SOAP::Lite +trace => qw(debug);

my %variable_hash = (
	TMAX => 'getVCRDailyMaxAirTemp' ,
#	TMIN => 'getVCRDailyMinAirTemp',
#	TMEA => 'getVCRDailyMeanAirTemp',
#	PREC => 'getVCRDailyTotPrecip',
#	RWSP => 'getVCRDailyMeanWindsp' ,
#	RWDI => 'getVCRDailyMeanWinddir',
#	RH   => 'getVCRDailyMeanRH',
#	PREC => 'getVCRDailyTotPrecip',
);

my %station_hash = (
	HOGI => { %variable_hash },
#	OYSM => { %variable_hash },
#	PHCK => { %variable_hash },
);

&client	(	'vcr',
			'urn:vgx-LTERClimDBHarvester',
			'http://192.31.21.60:8080/vxe/listener-soap.pperl',
			%station_hash
);


