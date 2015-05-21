#! perl 
use strict;
use SOAP::Transport::HTTP;
SOAP::Transport::HTTP::CGI
	->dispatch_to("sample")
	->handle;

package sample;

sub research_site_list {
	shift;
	my $som;
	my @soms;
	my @result = &query_DB("select res_site_name, res_site_code from research_site where site_id = ?","DBI:ODBC:rocky_lter_climdb","climdb","adm4cdb*",@_);

	for (my $i=0;$i<=$#result;$i=$i+2) {
		$som = SOAP::Data->name('row' =>
			\SOAP::Data->value(

				SOAP::Data->name("name"=>$result[$i+0])
		   		->type("string"),
				SOAP::Data->name("code"=>$result[$i+1])
		   		->type("string"),			)
		);
		push @soms, $som;	
	}

	$som = SOAP::Data->name('research_site_list' =>
		\SOAP::Data->value(@soms));
}

sub add_it {
	shift;
	my $som;
	my @soms;
	BEGIN {unshift (@INC, 'D:\\forwww\\lter\\climdb\\wambam\\bin\\' ) };
	use add;
	my @result = &add::add_it(@_);
	&logger('sample','add_it');

	for (my $i=0;$i<=$#result;$i=$i+1) {
		$som = SOAP::Data->name('row' =>
			\SOAP::Data->value(

				SOAP::Data->name("c"=>$result[$i+0])
		   		->type("string"),			)
		);
		push @soms, $som;	
	}

	$som = SOAP::Data->name('add_it' =>
		\SOAP::Data->value(@soms));
}

sub sites {
	shift;
	my $som;
	my @soms;
	my @result = &query_DB("select site_name, loc1, loc2 from site where site_id >= ? and site_id <= ?","DBI:ODBC:rocky_lter_climdb","climdb","adm4cdb*",@_);
	&logger('sample','sites');

	for (my $i=0;$i<=$#result;$i=$i+3) {
		$som = SOAP::Data->name('row' =>
			\SOAP::Data->value(

				SOAP::Data->name("name"=>$result[$i+0])
		   		->type("string"),
				SOAP::Data->name("loc1"=>$result[$i+1])
		   		->type("string"),
				SOAP::Data->name("loc2"=>$result[$i+2])
		   		->type("string"),			)
		);
		push @soms, $som;	
	}

	$som = SOAP::Data->name('sites' =>
		\SOAP::Data->value(@soms));
}

sub empty {
	shift;
	my $som;
	my @soms;
	my @result = &query_DB("select last_name from personnel where personnel_id = 44","DBI:ODBC:rocky_lter_climdb","climdb","adm4cdb*",@_);
	&logger('sample','empty');

	for (my $i=0;$i<=$#result;$i=$i+1) {
		$som = SOAP::Data->name('row' =>
			\SOAP::Data->value(

				SOAP::Data->name("name"=>$result[$i+0])
		   		->type("string"),			)
		);
		push @soms, $som;	
	}

	$som = SOAP::Data->name('empty' =>
		\SOAP::Data->value(@soms));
}

sub personnel_email {
	shift;
	my $som;
	my @soms;
	my @result = &query_DB("select email1 from personnel where personnel_id = ?","DBI:ODBC:rocky_lter_climdb","climdb","adm4cdb*",@_);
	&logger('sample','personnel_email');

	for (my $i=0;$i<=$#result;$i=$i+1) {
		$som = SOAP::Data->name('row' =>
			\SOAP::Data->value(

				SOAP::Data->name("email"=>$result[$i+0])
		   		->type("string"),			)
		);
		push @soms, $som;	
	}

	$som = SOAP::Data->name('personnel_email' =>
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
