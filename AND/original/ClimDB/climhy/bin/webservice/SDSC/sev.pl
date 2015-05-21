#! perl -w

BEGIN {unshift (@INC, '\\\GINKGO\lter\climdb\bin', '.\bin' ) }

# To connect client to harvest; put client in bin/ and change data_URL to 
# bin/[clientName].pl
# NOTE! harvest expects the following naming convention: [site_code].pl

# This uses the xxx.pm client library
use xxx;
#use SOAP::Lite +trace => qw(debug);

my %variable_hash = (
	TMAX => 'getSEVDailyMaxAirTemp' ,
#	TMIN => 'getSEVDailyMinAirTemp',
#	TMEA => 'getSEVDailyMeanAirTemp',
#	PREC => 'getSEVDailyTotPrecip' ,
#	SMAX => 'getSEVDailyMaxSoilTemp',
#	SMIN => 'getSEVDailyMinSoilTemp',
#	SMEA => 'getSEVDailyMeanSoilTemp',
#	VAP  => 'getSEVDailyMeanVapPressure',
##	WSP  => 'getSEVDailyMeanWindSpeed',
#	GRAD => 'getSEVDailyTotSolarRad',
);

my %station_hash = (
	'01' => { %variable_hash },
#	'40' => { %variable_hash },
#	'41' => { %variable_hash },
#	'42' => { %variable_hash },
#	'43' => { %variable_hash },
#	'44' => { %variable_hash },
#	'45' => { %variable_hash },
#	'48' => { %variable_hash },
#	'49' => { %variable_hash },
#	'50' => { %variable_hash },
);

&client	(	'sev',
			'urn:vgx-LTERClimDBHarvester',
			'http://192.31.21.60:8080/vxe/listener-soap.pperl',
			%station_hash
);

sub station_fix {
	my $number = shift;
	if ($number eq '01') { return('FIELDSTN'); }
	if ($number eq '40') { return('DEEPWELL'); }
	if ($number eq '41') { return('SOUTHGATE'); }
	if ($number eq '42') { return('MONTOSO'); }
	if ($number eq '43') { return('REDTANK'); }
	if ($number eq '44') { return('RIOSALADO'); }
	if ($number eq '45') { return('BRONCOWELL'); }
	if ($number eq '48') { return('SAVANNA'); }
	if ($number eq '49') { return('FIVEPOINTS'); }
	if ($number eq '50') { return('BLUEGRAMA'); }
}
