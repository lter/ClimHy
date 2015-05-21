#!/usr/bin/perl -w
#
###
### This code (/var/www/climhy/wambam/services/climdb_raw_handler.pl) has been automagicly created by /var/www/climhy/wambam/soap_server.pl at 1317836908
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
	->dispatch_to("climdb_raw")
	->serializer(MySerializer->new)
	->handle;

package climdb_raw;

sub get_day {
	shift;
	my $som;
	my @soms;
	my @result = &query_DB("select variable, value, flag from climdb_raw where res_site_id = ? and sampledate = ?","DBI:ODBC:ALPINE","climdb","adm4cdb*",@_);
	&logger('climdb_raw','get_day');

	for (my $i=0;$i<=$#result;$i=$i+3) {
		$som = SOAP::Data->name('row' =>
			\SOAP::Data->value(

				SOAP::Data->name("variable"=>$result[$i+0])
		   		->type("string"),
				SOAP::Data->name("value"=>$result[$i+1])
		   		->type("string"),
				SOAP::Data->name("flag"=>$result[$i+2])
		   		->type("string"),			)
		);
		push @soms, $som;	
	}

	$som = SOAP::Data->name('get_day' =>
		\SOAP::Data->value(@soms));
}

sub last_harvest {
	shift;
	my $som;
	my @soms;
	BEGIN {unshift (@INC, '/var/www/climhy/wambam/bin/' ) };
	use last_harvest;
	my @result = &last_harvest::last_harvest(@_);
	&logger('climdb_raw','last_harvest');

	for (my $i=0;$i<=$#result;$i=$i+1) {
		$som = SOAP::Data->name('row' =>
			\SOAP::Data->value(

				SOAP::Data->name("date"=>$result[$i+0])
		   		->type("string"),			)
		);
		push @soms, $som;	
	}

	$som = SOAP::Data->name('last_harvest' =>
		\SOAP::Data->value(@soms));
}

sub get_variable {
	shift;
	my $som;
	my @soms;
	my @result = &query_DB("SELECT variable,value,flag,sampledate from climdb_raw where site_code = ? and station = ? and variable = ? and sampledate>= ? and sampledate <=  ?","DBI:ODBC:ALPINE","climdb","adm4cdb*",@_);
	&logger('climdb_raw','get_variable');

	for (my $i=0;$i<=$#result;$i=$i+4) {
		$som = SOAP::Data->name('row' =>
			\SOAP::Data->value(

				SOAP::Data->name("variable"=>$result[$i+0])
		   		->type("string"),
				SOAP::Data->name("value"=>$result[$i+1])
		   		->type("string"),
				SOAP::Data->name("flag"=>$result[$i+2])
		   		->type("string"),
				SOAP::Data->name("date"=>$result[$i+3])
		   		->type("date"),			)
		);
		push @soms, $som;	
	}

	$som = SOAP::Data->name('get_variable' =>
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