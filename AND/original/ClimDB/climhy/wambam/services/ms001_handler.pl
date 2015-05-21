#! perl 
#
###
### This code (D:/forwww/lter/climdb/wambam/services/ms001_handler.pl) has been automagicaly created by D:\forwww\lter\climdb\wambam\soap_server.pl at 1103324673
### Kyle Kotwica kyle.kotwica@comcast.net
#
### You may edit it as you see fit, but don't blame me.
### It will get rewriten if the properities file changes or it 
### the user forces a rebuild. 
###
#
BEGIN {
    package MySerializer;
	@MySerializer::ISA = 'SOAP::Serializer';
    sub envelope {
	    $_[2] =~ s/Response$/_response/ if $_[1] =~ /^(?:method|response)$/;
    	shift->SUPER::envelope(@_);
    }
}
use strict;
use SOAP::Transport::HTTP;
SOAP::Transport::HTTP::CGI
	->dispatch_to("ms001")
	->serializer(MySerializer->new)
	->handle;

package ms001;

sub TMAXairpri01 {
	shift;
	my $som;
	my @soms;
	my @result = &query_DB("SELECT date, maxtemp, ft2 FROM fsdbdata..ms00101 WHERE date>= ? and date<=? and probe = 'AIRPRI01'","DBI:ODBC:rocky_lter_ltermeta","ltermeta ","#dbLterM&ta",@_);
	&logger('ms001','TMAXairpri01');

	for (my $i=0;$i<=$#result;$i=$i+3) {
		$som = SOAP::Data->name('row' =>
			\SOAP::Data->value(

				SOAP::Data->name("date"=>$result[$i+0])
		   		->type("string"),
				SOAP::Data->name("tmean"=>$result[$i+1])
		   		->type("string"),
				SOAP::Data->name("flag"=>$result[$i+2])
		   		->type("string"),			)
		);
		push @soms, $som;	
	}

	$som = SOAP::Data->name('data' =>
		\SOAP::Data->value(@soms));
}

sub TMINairpri01 {
	shift;
	my $som;
	my @soms;
	my @result = &query_DB("SELECT date, mintemp, ft3 FROM fsdbdata..ms00101 WHERE date>= ? and date<= ? and probe = 'AIRPRI01'","DBI:ODBC:rocky_lter_ltermeta","ltermeta ","#dbLterM&ta",@_);
	&logger('ms001','TMINairpri01');

	for (my $i=0;$i<=$#result;$i=$i+3) {
		$som = SOAP::Data->name('row' =>
			\SOAP::Data->value(

				SOAP::Data->name("date"=>$result[$i+0])
		   		->type("string"),
				SOAP::Data->name("tmin"=>$result[$i+1])
		   		->type("string"),
				SOAP::Data->name("flag"=>$result[$i+2])
		   		->type("string"),			)
		);
		push @soms, $som;	
	}

	$som = SOAP::Data->name('TMINairpri01' =>
		\SOAP::Data->value(@soms));
}

sub TMEAairpri01 {
	shift;
	my $som;
	my @soms;
	my @result = &query_DB("SELECT date, meantemp, ft1 FROM fsdbdata..ms00101 WHERE date>= ? and date<= ? and probe = 'AIRPRI01'","DBI:ODBC:rocky_lter_ltermeta","ltermeta ","#dbLterM&ta",@_);
	&logger('ms001','TMEAairpri01');

	for (my $i=0;$i<=$#result;$i=$i+3) {
		$som = SOAP::Data->name('row' =>
			\SOAP::Data->value(

				SOAP::Data->name("date"=>$result[$i+0])
		   		->type("string"),
				SOAP::Data->name("tmean"=>$result[$i+1])
		   		->type("string"),
				SOAP::Data->name("flag"=>$result[$i+2])
		   		->type("string"),			)
		);
		push @soms, $som;	
	}

	$som = SOAP::Data->name('TMEAairpri01' =>
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

	open LOGGER, ">>D:/forwww/lter/climdb/wambam//log/log.log" or die;
	print LOGGER localtime()."	service	=>	$service";
	print LOGGER "		method	=>	$method
";
} 
1;
