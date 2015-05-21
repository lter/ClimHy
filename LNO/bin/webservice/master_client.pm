#! /usr/bin/perl -w
use strict;
use warnings;
BEGIN {unshift (@INC, '/var/www/climhy/lib', "./bin" ) }


use SOAP::Lite;
use DBI;
use sql_cmd;
use clim_lib;
my $query_log = './log/query.log';
if (!open POO, ">$query_log") {
	$query_log = '../../log/query_log';
	(open POO, ">$query_log") or die "Can't open $query_log $!";
}
#use SOAP::Lite +trace => qw(debug);

my $dbh;

sub client {
	my ($site,$uri,$proxy,@methods) = @_;
	$site = uc($site);
#read control file 
	my %control = &read_control();
	
#connect with database
	$dbh = DBI->connect($control{data_source},$control{data_user},$control{data_password}) || print "Connect failure in master.pm \n";
	
# for harvest.pl
	my $break = "<BR>\n";
	my $para = "<P>\n";
	my $hr = "<HR>\n";
	my $tab = '-------->';
	#my $break = "\n";
	#my $para = "\n\n";


	my $out = $control{UNC} . "/data/$site.ws";
	open OUT, ">$out" or die "Cant open $out $!";

# connect to the web serivice	
	my $soap = SOAP::Lite                             
		->uri($uri)
		->proxy($proxy);
	
	print "$break Harvest is using web service interface";
	foreach my $set (@methods) {
		my $method = $$set[0];
		my $station = $$set[1];
		my $variable = $$set[2];
		print "$para Accessing ".$method;
		
		my $start = &start($site,$station,$variable);
		my $end = &today;
		$start = sprintf("%4s-%02s-%02s",split /-/,$start);
		$end = sprintf("%4s-%02s-%02s",split /-/,$end);
		print "$break Retrieving ($station) $variable --------- from $start to $end";
	
		my $som = $soap->$method($start,$end);
				
		my @list = $som->valueof("//Envelope/Body/$method"."Response/$method/row/*");
		my $count = @list / 3;

		my $long_name = &get_long_name($variable);
	
		print OUT "!LTER_Site,Station,Date,$long_name,".'flag_'."$long_name\n";	
		#print "\n!LTER_Site,Station,Date,$long_name,".'flag_'."$long_name";	
		for (my $i = 0; $i<$count; $i++) {
			my ($date,$value,$flag) = splice(@list,0,3);
			if (!$flag) { $flag = 'G';}
			print OUT "$site,$station,".&date_fix($date).",$value,$flag\n" if ($date ne '--');
			#print "\n$site,$station,".&date_fix($date).",$value,$flag" if ($date ne '--');
		}
	}
	$dbh->disconnect;
	print "$break Triggering the harvester now: $para $hr";
}

sub today {
	my @today = localtime(time);
	$today[5] += 1900;
	$today[4] += 1;
	my $end_date = "$today[5]-$today[4]-$today[3]";
	#return('20010102');
}

sub date_fix {
	$_ = shift;
	s/-//g;
	s/ ..:..:..\....//;
	chomp;
	return($_);
}

sub get_long_name {
	my $variable = shift;

	my $sqlcmd = &get_cmd('601',$variable);
	return(&query_DB($sqlcmd,'value',$dbh));
}

sub start {
	my ($site,$station,$variable) = @_;
	
	my $sqlcmd = &get_cmd('602',$site,$station,$variable);
	my $start = &query_DB($sqlcmd,'value',$dbh);
	if ($start) {
# FOR TESTING
		return('2003-02-12');
		return(&date_fix($start));
	}
# If this is the first time I've harvested you there will be no start time.
# I'll ask for data from the begining of time or 1901-01-01 wichever is later
	return('1901-01-01');
}

sub AUTOLOAD {
	return(shift);
}

1;


=head1 NAME

B<master_client.pm>  and  B<???.pl>

=head1 DESCRIPTION

Master_client it the backend for ???.pl. ???.pl is basically a configuration file for master_client.pm. What else do you need to know? OK, I'll talk slowly.

=head1 CLIENT

???.pl can be thought of as the webservice client for a webservice designed to be used in the automatic harvest of climdb/hydrodb data. Lets call it and.pl, 'and' is the the 3 letter site code for the H.J. Andrews LTER site. B<NOTE> a L</SERVICE> has to use this convention in order to be used in the web service harvest system (e.g. vcr.pl or ntl.pl). Also it must adhere to the conventions described L</SERVICE>.

and.pl my be run from the shell if you like e.g.
 perl and.pl

The idea however was to change the data url in the site table in climdb to;
 bin/webservices/and.pl and put put and.pl in $CLIMDB_HOME/bin/webservices/

If this is done, when a harvest is initiated, the web service client will be fired and will request all data after the last sample date (in climdb_raw), up to today, from the webservice.

The client (and.pl) looks like this;

 #! perl 
 BEGIN {unshift (@INC, 'C:\climdb\bin', ".\\bin" ) }

 use master;
 use strict;
 
 # This is just a glorified configuration file.
 # See master_client.pm for documentation.
 
 my $site = $0;
 $site =~ s/\.pl$//;
 my $service = 'ms001';
 my $endpoint = 'http://127.0.0.1/cgi-bin/wambam/services/ms001_handler.pl';
 
 my @methods = (
 	['TMEAairpri01','PRIMET','TMEA'],
 	['TMAXairpri01','PRIMET','TMAX'],
 	['TMINairpri01','PRIMET','TMIN'],
 );

 &client($site,$service,$endpoint,@methods);

You need to edit the $service, $endpoint, and @methods variables.

=over

=item SERVICE - 

$service is the name of the webservice.

=item ENDPOINT - 

$endpoint is the URL of the webservice.

=item METHODS - 

@methods is a list of lists consisting of method_name, station, variable. The variable must be a climdb/hydrodb recongnized variable.

=back

The program then calls the master_clilent module that does all of the work.

=head1 SERVICE

Remember this is all for using webservices to populate the climdb database? Of course this could all be done easier if we left all of the webservices out of it, but what the hell its still pretty cool. In order to do this we must adhere to some conventions so new client code does not have to be written for each new service that comes on line. So I picked some conventions, of course 'there is more then one way to do things'. Any convention would do. But, I have spoken. Your web service must adhere to the following conventions;

=head2 CONVENTIONS

=over

=item REQUEST - Must take a request consisting of two dates.

 <message name="whatever_response">
  <part name="whatever_response" type="xsd1:whatever_response" /> 
 </message>

 <message name="whatever_request">
  <part name="begin" type="xsd:date" /> 
  <part name="end" type="xsd:date" /> 
 </message>

For now begin must be first. This can be fixed.

=item RESPONSE - Must return a sequence of records consisting of date,value,flag

 <complexType name="whatever_response">
   <sequence>
     <element name="row">
       <complexType>
         <sequence>
           <element name="date" type="xsd:date" /> 
           <element name="tmean" type="xsd:xx" /> 
           <element name="flag" type="xsd:xx" /> 
         </sequence>
       </complexType>
    </element>
  </sequence>
 </complexType>

=back

You may name the service or methods any thing that you like, and I don't care about the fundemental soap data type. In other words tmean may be called x and may be a string or an int. I<Ain't Perl grand> The dates should probably be soap dates, for convienence. They could be strings but they still need to be YYYY-MM-DD. 

I guess I should write a schema, huh?

What you don't know how to serialize the data into the structure shown above?

I just happen to have 500 lines of code that are perfectly portable and will solve all of youre problems. Whats it worth to you?

=head1 AUTHOR

Kyle Kotwica E<lt>Kyle.kotwica@comcast.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Kyle Kotwica

Mine, all mine! leave it alone or I'll threaten you and stuff like that.

=cut

