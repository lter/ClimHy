#! perl -w
# Kyle Kotwica 3-2004
# soap_server.pl
#

=head1 NAME

soap_server  

=head1 DESCRIPTION

Soap_server generates <service>_handler.pl, <service>_client.pl and a WSDL. <service>_handler.pl is the actual web service endpoint. If soap_server.pl gets a hit it dispatchs the request to the handler or returns the virtual WSDL for that service.

I say virtual because it don't exist. I build it on the fly and send it out via CGI. Oh yeah the handler is built on the fly as well. OK heres the part that sucks. Even though the handler is built on the fly this could cause race conditions. So I better leave the handler around, so more than one user can use this. This may or maynot be a problem. I'll look into it more later.

You need to describe the service first in an xml file such as the sample in C</docs/sample.xml>. As of yet I have no schema for this file. Its pretty simple though, I think any monkey could figure it out pretty easly. Have a banana and look at the example.

For your convenience I have added a GUI wizard to write the XML file for you. See wambam.html.

=head1 Usage 

in your browser

 	http://www.erehwon.com/cgi-bin/soap_server.pl?wsdl=<service>
 		returns the WSDL for the service.

in a client (PERL)

	my $soap =  SOAP::Lite
	  ->service("http://www.erehwon.com/cgi-bin/soap_server.pl?wsdl=<service>")

For the mean time, since the handler code is to be left on the server, you may bypass the WSDL and call the service directly.

	my $soap =  SOAP::Lite
		->uri(urn:<service>)
		->proxy("http://erewhon/cgi-bin/<service>_handler.pl")

Or from the command prompt type...

perl -e 'use SOAP::Lite;print SOAP::Lite->proxy("http://services.soap
lite.com/hibye.cgi")->uri("http://www.soaplite.com/Demo")->hi()->result;'

Of course if your using Java... Well if your using Java I'll wait while you type.

Done yet?

Still not done, well try to catch up later.

Also the following parameters may be passed via cgi parameters to soap_server.pl

		rebuild=1	(forces a rebuild of the <service>_handler.pl 
					code whether or not <service>.xml changed. 
		debug=1		(sends debuging/trace info to log file 'log/debug.log')
		debug=2		(sends data structure info to log file 'log/debug.log')
		debug=3		(Screw the browser mode. This sends the appropriate header
					 info so as to send the output to the browser whether or
					 not its deemed acceptiable XML. Acts as if debug l is set)

=head1 API

SQL commands, perl subroutines and Java programs all can be used to generate the request payload for the wambam services. 

=head2 SQL

This program was written to allow any fool to spit out the output of his databases as web services, easily. It does this by automatically writing a perl subroutine that handles the DBI to your database. The part of the XML file that describes the method 'site' is below

	<method name = "site" type = "SQL">
		<request_names type="int">site_id_low</request_names>
		<request_names type="int">site_id_high</request_names>
		<response_names type="string">site_name</response_names>
		<DSN>DBI:ODBC:climdb</DSN>
		<password>noneofyourbiz</password>
		<user>me</user>
		<sqlcmd>select site_name from site where site_id &gt;= ? and site_id &lt;= ?</sqlcmd>
	</method>

=head2 Perl

Instead of using my DBI module you may write your own. Simply tell the XML file where your module is and it will stick it where it belongs. Of course if you don't know PERL (you fool) you may use any language of your choice (well not FORTRAN. Lets not be silly.) see L</"Inline">. 

	<method name = "add_it" type = "PERL">
		<request_names type="int">first</request_names>
		<request_names type="int">second</request_names>
		<response_names type="string">result</response_names>
		<module path = "/bin">add</module>
		<documentation>This is an example of using a perl module</documentation>
	</method>

=head2 Inline

This uses the Perl module Inline. This module allows us to use other languges inside of our perl code. For example, if you have a Java class that you would like to offer up as a web service simply tell the properties file where the java code is. The first time the class is called a small performence hit is encurred, the complied class is then saved and future calls are pre-compiled. Other languages can be added easily, for now only Java is included. The API for the other languages would be identical to the example below, i.e. type = "C" module = getSite.c. This is not supported but is easy to add at this point.

	<method name = "getSite" type = "JAVA">
		<request_names type="int">site_id</request_names>
		<response_names type="string">site_name</response_names>
		<module path = "../bin/">getSite.java</module>
		<class>Sites</class>
		<documentation>This is an example of the Inline module</documentation>
	</method>

It is important to note, your service might send a soap data type of string to a Java method that is expecting an integer, and nothing will break. Repeat after B<me JAVA bad, Perl good>.

=head1 Directory structure
		
directory structure (directory wambam is cgi enabled)
	wambam
		soap_server.pl (this file)
		wambam.pl (GUI tool for writing <service>.xml)
		services
			<service>.xml (properties)
			<service>_handler.pl	(handler)
			<service>_client.pl		(client)
		bin (included files)
			_Inline (Inline magic goes here, /_Inline must exist if Inline is 
					be used. The contents may be deleted at any time, a 
					performence hit will be incured the first time and it will
					be rebuilt.)
				build
				lib
		docs (documentation/examples)
		log 
			debug.log
			log.log

=head1 TODO

=over 

=item 1. Offer something other then complex data type for request/reply?

=item 2. Fix client (dont use wsdl, use proxy. This will be ugly it we let the user define there own data types.)

=item 3. Schema for <service>.xml

=back

=head1 BUGS

=head2 year as varchar??

OK this is weird. If you use a placeholder in your queery refering to the field called 'year' there seems to be a problem. The work around is simple, see &year_hack. &year_hack simply switches 'year = ?' to 'convert(int,year) = ?'. This should fix the problem but I don't really understand the issue. I'm sure it will rear its ugly head again. This hack is not really exceptable because it is not portable since 'convert is a MS_SQL function. I should at least warn the user with a dialog or something that this substitution is happening.

=cut

use strict;
use CGI;
use XML::Simple;
use Data::Dumper;
use CGI::Carp qw(fatalsToBrowser);
use SOAP::Transport::HTTP;

my $CGI = new CGI;

# set $DEBUG here or send debug=0|1|2|3 as parameter to turn on debuging
my $DEBUG = 1;
if ($CGI->param('debug')) {$DEBUG = $CGI->param('debug');}
if ($DEBUG == 3) { 
	print $CGI->header;
	print $CGI->start_html(	-title=>'Screw The browser',
							-author=>'kyle.kotwica@comcast.net');
	$DEBUG = 1;
}
# set $REBUILD to true here or send rebuild=1 as parameter to rebuild 
# client and server.
my $REBUILD = 0;
if ($CGI->param('rebuild')) {$REBUILD = $CGI->param('rebuild');}


my $SERVICE = $CGI->param('wsdl');

my $PATH = $0;							#C:\cgi-bin\wambam\soap_server.pl
$PATH =~ s/\\/\//g;						#C:/cgi-bin/wambam/soap_server.pl
$PATH =~ s/(.*)soap_server.pl/$1/;		#C:/cgi-bin/wambam/
my $SERVICE_DIR = $PATH . 'services/';  #C:/cgi-bin/wambam/services/ 
my $PROPERTIES = $SERVICE_DIR . $SERVICE . '.xml';

my $URL = $CGI->url();					#http://127.0.0.1/wambam/soap_server.pl
my $WSDL = $URL . '?wsdl='. $SERVICE;
my $PORT = $URL;	
$PORT =~ s/(.*)soap_server.pl/$1services\//;
$PORT = $PORT.$SERVICE."_handler.pl";
						#http://127.0.0.1/wambam/services/<service>_handler.pl

if ($DEBUG) {
	open POO, ">$PATH/log/debug.log" ||
			&log_it('FATAL',"Can't open $PATH/log/debug.log: $!");
}

if ($DEBUG) { &debug_paths(); }

if (-e $PROPERTIES) {
	&log_it ("INFO","File called \'$PROPERTIES\' has been located");
	print $CGI->header(-type => "text/xml");
	
	# we have the configuration file, read it into memory.
	my $properties = XMLin($PROPERTIES, forcearray => 1);

	# Dump the contents of properities into debug.log
	if ($DEBUG == 2) { &debug_data_structure($properties); }

	&make_wsdl($properties);
	&make_handler($properties);
	&make_client($properties);
} elsif ($SERVICE) {
	&log_it ("NOT","I can't find a file called $PROPERTIES");
}else {
	&log_it ("NONE","User is a dummy, I'll give him some usage info");
}

####
#### END OF MAIN
####

sub usage {
	my $type = shift;
	my ($service,@services);

	print $CGI->header;
	print $CGI->start_html(	-title=>'SOAP_SERVER ERROR',
							-author=>'kyle.kotwica@comcast.net');
	if ($type =~ /NOT/) {
		print "<H1>I can't seem to find the service called $SERVICE</H1>";
	} elsif ($type =~ /NONE/) {
		print <<EOF
<H1>Welcome to WAMBAM</H1>
<FONT SIZE=+2><FONT COLOR=red SIZE=+5>W</FONT>eb Service <FONT COLOR=red SIZE=+5>A</FONT>dministration <FONT COLOR=red SIZE=+5>M</FONT>odule for <FONT COLOR=red SIZE=+5>B</FONT>2B <FONT COLOR=red SIZE=+5>A</FONT>pplication <FONT COLOR=red SIZE=+5>M</FONT>ethods</FONT>

	<HR>These are the services I offer:</HR>
<TABLE><TR><TH WIDTH=100>WSDL</TH><TH WIDTH=100>Sample client</TH><TH ALIGN=center>Documentation</TH></TR>
EOF
;
	}

	opendir (DIR, $SERVICE_DIR) || 
			&log_it('FATAL',"Can't opendir $SERVICE_DIR: $!");
	@services = grep {/.*xml$/ && -f "$SERVICE_DIR/$_"} readdir(DIR);
	
	foreach $service (@services) {
		my $file = $SERVICE_DIR . $service;
		#open (FILE, "<$file") || 
		#		&log_it('FATAL',"Can't open $file: $!");
		my $properties = XMLin($file, forcearray => 1);
		my $wsdl = $URL."?wsdl=$service";
		$wsdl =~ s/.xml$//;
		$service =~ s/.xml$//;
		print <<EOF
<TR><TD>
	<A HREF=$wsdl>$service</A>
</TD><TD>
<A HREF='http://www.soapclient.com/soapclient?template=/clientform.html&fn=soapform&SoapTemplate=none&SoapWSDL=$wsdl'>test me</A>
</TD><TD>
EOF
;
#<A HREF='http://www.soapclient.com/soapTest.html?SoapWSDL=$wsdl'>test me</A>
		if ($properties->{documentation}[0]) {
			print "$properties->{documentation}[0]\n";}
		print "</TD></TR>\n";
	}
	
	print "</TABLE><HR>";
	print $CGI->end_html;
}

sub log_it {
	my ($type,$string) = @_;
	print POO "[$type] $string\n";
	if ($type =~ /NO/) {
		&usage($type);
		exit;
	}
	if ($type !~ /INFO/) {
		&browser_error($string);
		exit;
	}
}

sub should_I {
	my $file = shift;
# I should check modification times of $SERVICE.xml and $SERVICE_handler.pl
# so as not to remake the handler needlessly. Could cause problems with 
# multiple users. Might as well do it for $SERVICE_client.pl as well.
	if ($REBUILD) {
		&log_it("INFO", "User asked to rebuild \'$file\':\n\t recreating");
		return(1);
	}
	if (!-e $file) {
		&log_it ("INFO", "Creating \'$file\'");}
	elsif ((stat($PROPERTIES))[9] > (stat($file))[9]) {
		&log_it ("INFO", "\'$file\' is out of date:\n\t recreating");}
	else { 
		&log_it ("INFO", "\'$file\' is up to date:\n\t skipping");
		return(0); 
	}
	1;
}

sub make_client {
	my $properties = shift;
	my $string;

	my $client = $SERVICE_DIR.$SERVICE."_client.pl";
	if (!&should_I($client)) {return;}
	open(CLIENT,">$client") || 
			&log_it('FATAL',"Can't open $client");

#USAGE INFO
	if ($properties->{documentation}[0]){
		$string = $properties->{documentation}[0]."\n\n";
	}
	$string .= "The available methods are:\n";
	my @methods = keys (%{$properties->{method}});
	foreach my $method (@methods) {
		$string.="\n$method\n";
		my $ref = $properties->{method}->{$method};
		my @requests;
	   	if ($ref->{request_names}) {
			@requests = (@{$ref->{request_names}}); }
		foreach my $request (@requests) {
			my $content = $request->{content};
			my $type = $request->{type};
			$string .= "\t$content - $type\n";
		}
		$string .= $ref->{documentation}[0]."\n";
	}
	my $localtime = localtime();
	
	print CLIENT<<EOF
#! perl -w

###
### This code ($client) has been automagicly created 
### by $0 
### at $localtime 
### The genuis behind it all is 
### Kyle Kotwica 
### kyle.kotwica\@comcast.net

### You may edit it as you see fit, but don't blame me.
### It will get rewritten if the properties file changes or if 
### the user forces a rebuild. It is supplied as a test, or possibly
### as a stub to use for a starting point.

### If you like you can point a browser to 
###
### http://www.soapclient.com/soapclient?template=/clientform.html&fn=soapform&SoapTemplate=none&SoapWSDL=$WSDL
###
### For a more elegant test.
###

EOF
;

	if ($DEBUG) {
		print CLIENT<<EOF

#BEGIN {open (STDERR, '>message.log');)
use SOAP::Lite +trace => qw(debug);

EOF
;
	} else {
		print CLIENT "use SOAP::Lite;";
	}
	print CLIENT<<EOF

if (!\$ARGV[0]) {
	print "\\nUsage: perl <$SERVICE>_client.pl method [args]\\n";
	print "\n$string";
	exit();
}
my \$method = shift;

my \$soap =  SOAP::Lite
	#->uri("urn:$SERVICE")
	#->proxy("$PORT")
	->service("$WSDL")
	;

\$soap->on_fault(sub{print"\\n\\nOops!!!\\n\\n";die;});

my \$som = \$soap->\$method(\@ARGV);

# deserialize the SOAP message here.
# I suggest you *do not* use the WSDL interface.
# It seems SOAP::Lite does not deal with complex data in a WSDL very well.
# I have not investigated, but it does not seem to return a som object, but a 
# hash reference. This is OK, but odd. Since I'm not really concerned with the
# client end of things and only supply it here as a test of the service, why 
# bother? 
#  
EOF
;
close CLIENT;
}

sub make_handler {
	my $properties = shift;

# if there is no need to make handler don't
	my $handler = $SERVICE_DIR.$SERVICE."_handler.pl";
	if (!&should_I($handler)) {
		return;}
	open(HANDLER,">$handler") || 
				&log_it('FATAL',"Can't open $handler : $!");
	
	print HANDLER <<EOF;
#! perl 
#
###
### This code ($handler) has been automagicly created by $0 at $^T
### Kyle Kotwica kyle.kotwica\@comcast.net
#
### You may edit it as you see fit, but don't blame me.
### It will get rewriten if the properties file changes or it 
### the user forces a rebuild. 
###
#
BEGIN {
    package MySerializer;
	\@MySerializer::ISA = 'SOAP::Serializer';
    sub envelope {
	    \$_[2] =~ s/Response\$// if \$_[1] =~ /^(?:method|response)\$/;
    	shift->SUPER::envelope(\@_);
    }
}
use strict;
use SOAP::Transport::HTTP;
SOAP::Transport::HTTP::CGI
	->dispatch_to("$SERVICE")
	->serializer(MySerializer->new)
	->handle;

package $SERVICE;

EOF
	foreach my $method ( keys( %{$properties->{method}} ) ){
		my @response_arr = @{$properties->{method}->{$method}->{response_names}};
		my $type = $properties->{method}->{$method}->{type};
		&mk_handler_method($type,$properties,$method,@response_arr); 
	}

	&mk_query_DB(); 
	&mk_logger();
	print HANDLER "1;";
}

sub mk_logger {

	print HANDLER <<EOF;

sub logger {
	my (\$service,\$method) = \@_;

	open LOGGER, ">>$PATH/log/log.log" or die;
	print LOGGER localtime()."\tservice\t=>\t\$service";
	print LOGGER "\t\tmethod\t=>\t\$method\n";
} 
EOF
;
}

sub mk_query_DB {

	print HANDLER <<EOF;
use DBI;
sub query_DB {
	my (\$sqlcmd,\$DSN,\$user,\$password, \@args) = \@_;
	my \@eat_it;

	my \$dbh =DBI->connect(\$DSN,\$user,\$password) || print "Connect failure
";

	my \$sth=\$dbh->prepare(\$sqlcmd) || 
			print "prepare failure: " . \$dbh->errstr;
	\$sth->execute(\@args) || print "execute failure: ".\$sth->errstr;
	while (my \@get_it = \$sth->fetchrow_array){
		push (\@eat_it,\@get_it);}
	return (\@eat_it);
}
EOF
}

sub year_hack {
	my $sqlcmd = shift;

	if ($$sqlcmd =~ /year\s+..\s+\?/i) {
		$$sqlcmd =~ s/year(\s+..\s+\?)/convert(int,year)$1/ig; 
	}
	#return($sqlcmd);
}

sub mk_handler_method {
	my ($type,$properties,$method,@response_arr) = @_;
	my $size = $#response_arr + 1;
	my ($sqlcmd,$DSN,$user,$password);
	my ($string,$module,$path,$class);

		if ($type =~ /SQL/) {
			$sqlcmd = $properties->{method}->{$method}->{sqlcmd}[0];
			&year_hack(\$sqlcmd);
			$DSN = $properties->{method}->{$method}->{DSN}[0];
			$user = $properties->{method}->{$method}->{user}[0];
			$password = $properties->{method}->{$method}->{password}[0];
			$string = "my \@result = &query_DB(\"$sqlcmd\",\"$DSN\",\"$user\",\"$password\",\@_);";
		} elsif ($type =~ /PERL/) {
			$module = $properties->{method}->{$method}->{module}[0]->{content};
			$module =~ s/\.pm//;
			$path = $properties->{method}->{$method}->{module}[0]->{path};
			$string = "BEGIN {unshift (\@INC, '$path' ) };\n\t";
			$string .= "use $module;\n\t";
			$string .= "my \@result = &".$module.'::'.$method.'(@_);';
		} elsif ($type =~ /JAVA/) {
			$module = $properties->{method}->{$method}->{module}[0]->{content};
			$path = $properties->{method}->{$method}->{module}[0]->{path};
			$class = $properties->{method}->{$method}->{class}[0];
			$class = $SERVICE .'::'. $class;
			$string = <<EOF
my \$java;
BEGIN {
	open JAVA, "<$path$module" || sub {print "[ERROR} Cant find $path$module for the inline java\n";die;};
	while (<JAVA>) {
		\$java.= \$_;}
END
}

use Inline Java => \$java,
			DIRECTORY => '$PATH/bin/_Inline';

my \$thing = new $class();
my \@result = \$thing->$method(\@_);

EOF
;
		}
	
	print HANDLER <<EOF;
sub $method {
	shift;
	my \$som;
	my \@soms;
	$string
	&logger('$SERVICE','$method');

	for (my \$i=0;\$i<=\$#result;\$i=\$i+$size) {
		\$som = SOAP::Data->name('row' =>
			\\SOAP::Data->value(
EOF

	#for each field in the response
		my $k = 0;
		while (my $response_ref = shift(@response_arr) ) { 
			my $name = $response_ref->{content};
			my $type = $response_ref->{type};
			print HANDLER "
				SOAP::Data->name(\"$response_ref->{content}\"=>\$result[\$i+$k])
		   		->type(\"$response_ref->{type}\"),";
			$k++;
		}

	print HANDLER <<EOF;
			)
		);
		push \@soms, \$som;	
	}

	\$som = SOAP::Data->name('$method' =>
		\\SOAP::Data->value(\@soms));
}

EOF
}

sub make_wsdl {
	my $properties = shift;

	&start_definitions();
	my $all_method_ref = $properties->{method};
	
	&start_types();
	&loop($all_method_ref,\&mk_response);
	&end_types;
	&loop($all_method_ref,\&mk_messages);
	&mk_port($all_method_ref);
	&mk_binding($all_method_ref);

	&end_definitions($properties->{documentation}[0]);

}

sub loop {
	my ($ref,$code_ref) = @_;
	foreach my $method ( keys( %{$ref} ) ){
		&$code_ref($method,$ref);
	}
}
	
sub mk_binding {
	my $method_ref = shift;

	print  
'  <binding name="SoapBinding" type="tns:PortType">
    <soap:binding transport="http://schemas.xmlsoap.org/soap/http" style="rpc"/>';
	&loop($method_ref,\&mk_binding_operation);
	print  '  </binding>';
}

sub mk_binding_operation {
	my ($method,$ref) = @_;

	print <<EOF
    <operation name="$method">
      <soap:operation soapAction=""/>
      <input>
        <soap:body use="encoded" namespace="urn:$SERVICE" encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"/>
      </input>
      <output>
        <soap:body use="encoded" namespace="urn:$SERVICE" encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"/>
      </output>
    </operation>
EOF
}

sub mk_port {
	my $method_ref = shift;
	
	print  '<portType name="PortType">';
	foreach my $method ( keys( %{$method_ref} ) ){
		my $response = $method.'_response'; 
		my $request = $method.'_request';
		my $documentation = $method_ref->{$method}->{documentation}[0];
		my $doc = '';
		if($documentation) {$doc = $documentation;}
		print <<EOF
	<operation name="$method">
		<documentation>$doc</documentation>
		<input message="tns:$request"/>
		<output message="tns:$response"/>
	</operation>
EOF
	}
	print  '</portType>';
}

sub mk_messages {
	my ($method,$ref) = @_;
	my $method_ref = $ref->{$method};
	my $response = $method.'_response'; 
	my $request = $method.'_request';

	print  <<EOF;
<message name=\"$response\">	
	<part name=\"$response\" type=\"xsd1:$response\"/>
</message>
<message name=\"$request\">	
EOF

	if ($method_ref->{request_names}) {
		my @requests = (@{$method_ref->{request_names}});
		foreach my $request (@requests) {
			print	"<part name=\"".$request->{content}.
					"\" type=\"xsd:".$request->{type}."\"/>"; 
		}
	}

	print  "</message>";
}
	
sub browser_error {
	my $error = shift;
	print $CGI->header;
	print $CGI->start_html(	-title=>'SOAP_SERVER ERROR',
							-author=>'kyle.kotwica@comcast.net');
	print "<P>$error<HR>Dont bother me. I dont care!</HR></P>";
	print $CGI->end_html;
}

sub start_definitions {
	
	print  <<EOF;
<?xml version="1.0"?>
<definitions xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
	xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" 
	xmlns="http://schemas.xmlsoap.org/wsdl/" 
	xmlns:xsd1="urn:$SERVICE" 
	xmlns:tns="$WSDL"
	name="$SERVICE" 
	targetNamespace="$WSDL">
EOF

}

sub start_types {
	my $response = shift;

	print  <<EOF;
<types>
  <xsd:schema targetNamespace="urn:$SERVICE" xmlns="http://www.w3.org/2001/XMLSchema" >
EOF
}

sub end_types {
	print  <<EOF
  </xsd:schema>
</types>
EOF
}

sub end_definitions {
	my $documentation = shift;
	my $doc = '';
	if($documentation) {$doc = $documentation;}

	print  <<EOF
  <service name="$SERVICE">
	<documentation>$doc</documentation>
    <port name="Port" binding="tns:SoapBinding">
      <soap:address location="$PORT"/>
    </port>
  </service>
</definitions>
EOF
}

sub mk_response {
	my ($method,$ref) = @_;
	my $method_ref = $ref->{$method};
	return if(!$method_ref->{response_names});
	my $response = $method.'_response'; 
	
	print <<EOF
    <xsd:complexType name="$response">
      <xsd:sequence>
         <xsd:element name="row">
           <xsd:complexType>
             <xsd:sequence>
EOF
;
	my @responses = (@{$method_ref->{response_names}});
	foreach my $response (@responses) {
		print	"<xsd:element name=\"".$response->{content}.
				"\" type=\"xsd:".$response->{type}."\"/>"; 
	}
	print <<EOF
             </xsd:sequence>
           </xsd:complexType>
         </xsd:element>
      </xsd:sequence>
    </xsd:complexType>
EOF
;
}

sub debug_paths {

	my $localtime = localtime();
	print POO <<EOF 
$localtime
$0

DEBUGGING INFO

---------------------------------------------------------
[INFO] The following paths have been set as global values:

PATH        ->\t$PATH
SERVICE     ->\t$SERVICE
SERVICE_DIR ->\t$SERVICE_DIR
URL         ->\t$URL
WSDL        ->\t$WSDL
PROPERTIES  ->\t$PROPERTIES
PORT		->\t$PORT
---------------------------------------------------------


EOF
;
}

sub debug_data_structure {
	my $properties = shift;
	print POO "\n\n---------------------------------------------------------\n";
	print POO Dumper($properties);

		print POO "\n\n---------------------------------------------------------\n";
		print POO "Dump of $PROPERTIES follows:\n\n";
		print POO "SERVICE NAME = ".$properties->{name}."\n";
		print POO "SERVICE INFO = ".$properties->{documentation}[0]."\n";
		my @methods = keys (%{$properties->{method}});
		foreach my $method (@methods) {
			print POO "\n\tMETHOD = $method";
			my $ref = $properties->{method}->{$method};
			my $type = $ref->{type};
			print POO "\tTYPE = $type\n";
			if ($type =~ /SQL/) {
				print POO "\t\tPASSWORD = $ref->{password}[0]\n";
				print POO "\t\tUSER = $ref->{user}[0]\n";
				print POO "\t\tDSN = $ref->{DSN}[0]\n";
				print POO "\t\tQUERY = $ref->{sqlcmd}[0]\n";
			} elsif ($type =~ /PERL/) {
				print POO "\t\tMODULE = $ref->{module}[0]->{content}\n";
				print POO "\t\tPATH = $ref->{module}[0]->{path}\n";
			} elsif ($type =~ /JAVA/) {
				print POO "\t\tCLASS = $ref->{module}[0]->{content}\n";
				print POO "\t\tPATH = $ref->{module}[0]->{path}\n";
			}
			print POO "\t\tDOCUMENTATION = $ref->{documentation}[0]\n";

	
			print POO "\t\tRESPONSES\n";
			my @responses = (@{$ref->{response_names}});
			foreach my $response (@responses) {
				print POO "\t\t\t".$response->{content}." (";
				print POO $response->{type}.")\n";
			}
	
			print POO "\t\tREQUESTS\n";
			if ($ref->{request_names}) {
				my @requests = (@{$ref->{request_names}});
				foreach my $request (@requests) {
					print POO "\t\t\t".$request->{content}." (";
					print POO $request->{type}.")\n";
				}
			}
		}
	
		print POO "\n---------------------------------------------------------\n\n\n";
	}
1;
