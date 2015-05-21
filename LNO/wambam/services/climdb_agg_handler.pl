#!/usr/bin/perl -w
#
###
### This code (/var/www/climhy/wambam/services/climdb_agg_handler.pl) has been automagicly created by /var/www/climhy/wambam/soap_server.pl at 1317837646
### Kyle Kotwica kyle.kotwica@comcast.net
#
### You may edit it as you see fit, but don't blame me.
### It will get rewriten if the properties file changes or it 
### the user forces a rebuild. 
###
#
BEGIN {
    package MySerializer;
	@MySerializer::ISA = 'SOAP::Serializer';
    sub envelope {
	    $_[2] =~ s/Response$// if $_[1] =~ /^(?:method|response)$/;
    	shift->SUPER::envelope(@_);
    }
}
use strict;
use SOAP::Transport::HTTP;
SOAP::Transport::HTTP::CGI
	->dispatch_to("climdb_agg")
	->serializer(MySerializer->new)
	->handle;

package climdb_agg;

sub get_agg_monthly {
	shift;
	my $som;
	my @soms;
	my @result = &query_DB("SELECT site_code, station, variable, aggregate_type, year, month, value FROM climdb_agg WHERE site_code =  ? and station = ? and variable = ? and aggregate_type =  ? and convert(int,year) >= ? and convert(int,year) <= ? ","DBI:ODBC:ALPINE","climdb","adm4cdb*",@_);
	&logger('climdb_agg','get_agg_monthly');

	for (my $i=0;$i<=$#result;$i=$i+7) {
		$som = SOAP::Data->name('row' =>
			\SOAP::Data->value(

				SOAP::Data->name("site_code"=>$result[$i+0])
		   		->type("string"),
				SOAP::Data->name("station"=>$result[$i+1])
		   		->type("string"),
				SOAP::Data->name("variable"=>$result[$i+2])
		   		->type("string"),
				SOAP::Data->name("aggregate_type"=>$result[$i+3])
		   		->type("string"),
				SOAP::Data->name("year"=>$result[$i+4])
		   		->type("string"),
				SOAP::Data->name("month"=>$result[$i+5])
		   		->type("string"),
				SOAP::Data->name("value"=>$result[$i+6])
		   		->type("string"),			)
		);
		push @soms, $som;	
	}

	$som = SOAP::Data->name('get_agg_monthly' =>
		\SOAP::Data->value(@soms));
}

sub get_agg_yearly {
	shift;
	my $som;
	my @soms;
	my @result = &query_DB("SELECT site_code, station, variable, aggregate_type, year, value FROM climdb_agg WHERE site_code = ? and station = ? and variable = ? and aggregate_type = ? and convert(int,year) >= ? and convert(int,year) <= ? and month = 99","DBI:ODBC:ALPINE","climdb","adm4cdb*",@_);
	&logger('climdb_agg','get_agg_yearly');

	for (my $i=0;$i<=$#result;$i=$i+6) {
		$som = SOAP::Data->name('row' =>
			\SOAP::Data->value(

				SOAP::Data->name("site_code"=>$result[$i+0])
		   		->type("string"),
				SOAP::Data->name("station"=>$result[$i+1])
		   		->type("string"),
				SOAP::Data->name("variable"=>$result[$i+2])
		   		->type("string"),
				SOAP::Data->name("aggregate_type"=>$result[$i+3])
		   		->type("string"),
				SOAP::Data->name("year"=>$result[$i+4])
		   		->type("string"),
				SOAP::Data->name("value"=>$result[$i+5])
		   		->type("string"),			)
		);
		push @soms, $som;	
	}

	$som = SOAP::Data->name('get_agg_yearly' =>
		\SOAP::Data->value(@soms));
}

sub agg_over_all {
	shift;
	my $som;
	my @soms;
	my @result = &query_DB("SELECT site_code, station, variable, aggregate_type, year, value FROM climdb_agg WHERE site_code = ? and station = ? and variable = ? and aggregate_type = ? and year = 0","DBI:ODBC:ALPINE","climdb","adm4cdb*",@_);
	&logger('climdb_agg','agg_over_all');

	for (my $i=0;$i<=$#result;$i=$i+6) {
		$som = SOAP::Data->name('row' =>
			\SOAP::Data->value(

				SOAP::Data->name("site_code"=>$result[$i+0])
		   		->type("string"),
				SOAP::Data->name("station"=>$result[$i+1])
		   		->type("string"),
				SOAP::Data->name("variable"=>$result[$i+2])
		   		->type("string"),
				SOAP::Data->name("aggregate_type"=>$result[$i+3])
		   		->type("string"),
				SOAP::Data->name("year"=>$result[$i+4])
		   		->type("string"),
				SOAP::Data->name("value"=>$result[$i+5])
		   		->type("string"),			)
		);
		push @soms, $som;	
	}

	$som = SOAP::Data->name('agg_over_all' =>
		\SOAP::Data->value(@soms));
}

use DBI;
sub query_DB {
	my ($sqlcmd,$DSN,$user,$password, @args) = @_;
	my @eat_it;

	my $dbh =DBI->connect($DSN,$user,$password) || print "Connect failure
";

	my $sth=$dbh->prepare($sqlcmd) || 
			print "prepare failure: " . $dbh->errstr;
	$sth->execute(@args) || print "execute failure: ".$sth->errstr;
	while (my @get_it = $sth->fetchrow_array){
		push (@eat_it,@get_it);}
	return (@eat_it);
}

sub logger {
	my ($service,$method) = @_;

	open LOGGER, ">>/var/www/climhy/wambam//log/log.log" or die;
	print LOGGER localtime()."	service	=>	$service";
	print LOGGER "		method	=>	$method
";
} 
1;