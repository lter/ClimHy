#! /usr/bin/perl -w
use strict;

package last_harvest;

sub last_harvest {
	my ($site,$station,$variable) = @_;
	my $sqlcmd;
	
	use DBI;
	my $dbh =DBI->connect("DBI:ODBC:ALPINE","climdb","adm4cdb*") or die  "Connect failure";
	
	if (length($variable) > 4) {
		$sqlcmd = "SELECT variable FROM climdb_variables WHERE variable_name = '$variable'";
		$variable = $dbh->selectrow_array($sqlcmd);	
	}		

	$sqlcmd = "SELECT DATEADD(day,1,max(sampledate)) FROM climdb_raw WHERE site_code = '$site' and station = '$station' and variable = '$variable'";
	my ($date) = $dbh->selectrow_array($sqlcmd);
	$date =~ s/^(.*)\s..:..:......$/$1/;
	return $date;
	
}

1;
