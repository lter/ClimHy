#! perl -w 
#use strict;

# WAMDAM 1.0
# Web service Administration Method for Developimg Associated perl Modules

# This needs to do the following:
# 1) query user for important arg's
#		probably use TK and make wizard.
#       Also using CGI is option, it might be nice to run from commmand prompt as well
#		for now hard wire imputs
# 2) generate WSDL file
# 3) generate web service
#		For now ignore actual guts of service. (empty method)
#		Next version, write code for given SQL query and results. 
#		Still allow for empty method. So tool can be used for more complex WS's
# 4) generate handler code
# 5) generate sample client
#		Would be nice to have a sample web page as well as sample program.
# 6) someday deal with complex data types.
#		First we will allow for editing by hand.
#		Later allow for a complex data type that would work well 
#		with DB results. 
#
#
# Stucture is as follows: (web service name is WS, first method is meth1, second meth2)
# wamdam.pl writes the following files:
#	WS.wsdl
#	WS_client.pl
#	WS_web_client.pl
#	WS_handler.pl
#	WS.pl

#----------------------------------------------------
package WSservice;
#----------------------------------------------------
use KObjectTemplate;
#use strict;
@ISA = qw(KObjectTemplate Exporter);
require Exporter;
attributes qw(wsdl_path name service_path soap_action methods number cgi server);

sub open_wsdl {
	my $self = shift;
	
	my $wsdl_http = $self->server . $self->name . '.wsdl';
	my $wsdl_file = $self->wsdl_path . $self->name . '.wsdl';
	open(WSDL,">$wsdl_file") || die "cant open $wsdl_file";
	return ($wsdl_http);
}

sub mk_types {
	my $self = shift;
	
	my $i=0;
	while ($self->methods->[$i]) {
		if ($self->methods->[$i]->rows > 0) {
			$self->methods->[$i]->write_types($self->name);
		}
		$i++;
	}
}

sub mk_client {
	my $self = shift;
	my $wsdl = shift;

	my $name = $self->name;
	my $client = $self->service_path . 'c_' . $name . '.pl';
	my $proxy = $self->cgi . $name . '.pl';

	my $string;
	for (my $i=0;$i<=$self->number;$i++) {
		my $method = $self->methods->[$i]->method;
		my $req_names = $self->methods->[$i]->request_names;
		$string .= "$method \n";
		for (my $j=0;$j<@$req_names;$j=$j+2) {
			$string .= "\t$$req_names[$j] - $$req_names[$j+1]\n";
		}
	}
	
	open(CLIENT,">$client") || die "cant open $client";
	print CLIENT<<EOF
#! perl -w
use SOAP::Lite;
use SOAP::Lite +trace => qw(debug);
if (!\$ARGV[0]) {
	print "\\nUsage: $name method args\\n";
	print "the available methods are:\n";
	print "\n$string";
	exit();
}
my \$method = shift;

my \$soap =  SOAP::Lite
	->uri('urn:$name')
	->proxy('$proxy')
	#->service("$wsdl")
	;

\$soap->on_fault(sub{print"\\n\\nOops!!!\\n\\n";die;});

my \$som = \$soap->\$method(\@ARGV);

# if you want to use the wsdl the result comes back a a hash not an object
if (ref(\$som) eq 'HASH') {
	print \$\$som{row}{value};
} else {
	my \@list = \$som->valueof("//Envelope/Body/".\$method."Response/complex/row/*");
print \@list
}
EOF
;
close CLIENT;
}


sub mk_handler {
	my $self = shift;

	my $name = $self->name;
	my $handler = $self->service_path . $name . '.pl';
	open(HANDLER,">$handler") || die "cant open $handler";
	print HANDLER<<EOF
#! perl -w
BEGIN {
    package MySerializer;
	\@MySerializer::ISA = 'SOAP::Serializer';
    sub envelope {
	    \$_[2] =~ s/Response\$// if \$_[1] =~ /^(?:method|response)\$/;
    	shift->SUPER::envelope(\@_);
    }
}

use SOAP::Transport::HTTP;

SOAP::Transport::HTTP::CGI
	->dispatch_to("$name")
	#->serializer(MySerializer->new)
	->handle
	;
		
EOF
}

sub mk_web_service {
	my $self = shift;

	my $name = $self->name;

print HANDLER "package $name;\n";
	my $list;

# foreach method
	for(my $i=0;$i<=$self->number;$i++) {
		my $j = 0;
		my $list;
		my $method_name = $self->methods->[$i]->method;
		my $rows = $self->methods->[$i]->rows;
		my $sqlcmd = $self->methods->[$i]->sqlcmd;
		my $DSN = $self->methods->[$i]->DSN;
		my $user = $self->methods->[$i]->user;
		my $password = $self->methods->[$i]->password;
		my @h_names = @{$self->methods->[$i]->response_names};
		my $repeat = (@h_names/2);

		print HANDLER "\nsub $method_name {\n";
		print HANDLER "\tshift; #get rid off class\n";
# if this is a DB query (i.e. rows = 1) shift off input parameters
		if ($rows > 0) {

print HANDLER<<EOF
	my \@inputs = \@_;
	my \$som;
	my \@soms;
	\@query_result = \&query_DB(\"$sqlcmd\",\'$DSN\',\'$user\',\'$password\', \@inputs);
	\$rows = \@query_result;
	for (my \$i=0;\$i<\$rows;\$i=\$i+$repeat) {
		\$som =
		SOAP::Data->name('row' =>
		  \\SOAP::Data->value(

EOF
;
			while (my($elem_name,$elem_type) = splice @h_names,0,2) {
				print HANDLER "\t\tSOAP::Data->name(\"$elem_name\"=>\$query_result[\$i+$j]),\n";
				$j++;
			}

print HANDLER<<EOF
		  )
		);
		push \@soms, \$som;
	}

	\$som = SOAP::Data->name('complex' =>
		\\SOAP::Data->value(\@soms) );

	return(\$som);
}


EOF
;
		}
		elsif ($rows == 0) {
			@h_names = @{$self->methods->[$i]->response_names};
			while (my($elem_name,$elem_type) = splice @h_names,0,2) {
				print HANDLER "\tmy \$return$j = SOAP::Data->name(\"$elem_name\"=>shift);\n";
				print HANDLER "\tpush \@return, \$return$j;\n";
				$j++;
			}
			print HANDLER "\t\t return(\@return);\n\t}\n\n";
		}
	}
			
print HANDLER <<EOF
use DBI;
sub query_DB {
	my (\$sqlcmd,\$DSN,\$user,\$password, \@args) = \@_;
	my \@eat_it;

	my \$dbh =DBI->connect(\$DSN,\$user,\$password) || print "Connect failure\n";

	my \$sth=\$dbh->prepare(\$sqlcmd) || 
			print "prepare failure: " . \$dbh->errstr;
	\$sth->execute(\@args) || print "execute failure: ".\$sth->errstr;
	while (my \@get_it = \$sth->fetchrow_array){
		push (\@eat_it,\@get_it);}
	return (\@eat_it);
}
EOF
;

close HANDLER;
}

sub mk_binding {
	my $self = shift;
	print WSDL 
'  <binding name="SoapBinding" type="tns:PortType">
    <soap:binding transport="http://schemas.xmlsoap.org/soap/http" style="rpc"/>';

	for(my $i=0;$i<=$self->number;$i++) {
		my $method_name = $self->methods->[$i]->method;
		my $service_name = $self->name;
		my $soapAction = 'urn:'.$service_name.$self->soap_action.$method_name;

print WSDL<<EOF
    <operation name="$method_name">
      <soap:operation soapAction="$soapAction"/>
      <input>
        <soap:body use="literal" namespace="urn:$service_name" encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"/>
      </input>
      <output>
        <soap:body use="literal" namespace="urn:$service_name" encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"/>
      </output>
    </operation>
EOF
	}

print WSDL '  </binding>';
}


sub mk_port {
	my $self = shift;
	
print WSDL '  <portType name="PortType">';

	for(my $i=0;$i<=$self->number;$i++) {
	my $method_name = $self->methods->[$i]->method;
	my $request = $self->methods->[$i]->request;
	my $response = $self->methods->[$i]->response;
print WSDL<<EOF
    <operation name="$method_name">
      <input message="tns:$request"/>
      <output message="tns:$response"/>
    </operation>
EOF
	}

print WSDL '  </portType>';
}

sub mk_messages {
	my ($self) = shift;

	for(my $i=0;$i<=$self->number;$i++) {
		&message_part($self,$i,'request');
		&message_part($self,$i,'response');
	}
}

sub message_part {
	my ($self,$i,$type) = @_;
	my $message_name;
	my $type_names = $type .'_names';	
	
	$message_name = $self->methods->[$i]->$type;
	my @h_names = @{$self->methods->[$i]->$type_names};
	print WSDL "<message name=\"$message_name\">\n";
	if ($type eq 'response') {
		#if complex 
		if ($self->methods->[$i]->rows > 0) {
			print WSDL "\t<part name=\"complex\" type=\"xsd1:$message_name\"/>\n";
		} else {
			while (my($name,$type) = splice @h_names,0,2) {
				print WSDL "\t<part name=\"$name\" type=\"xsd:$type\"/>\n";}
		}
	} else {
		while (my($name,$type) = splice @h_names,0,2) {
			print WSDL "\t<part name=\"$name\" type=\"xsd:$type\"/>\n";}
	}
	print WSDL "</message>\n";
}

sub mk_service {
	my $self = shift;
	my $name = $self->name;
	my $location = $self->service_path;
	my $cgi = $self->cgi;

print WSDL<<EOF;
  <service name="$name">
    <port name="Port" binding="tns:SoapBinding">
      <soap:address location="$cgi$name.pl"/>
    </port>
  </service>
</definitions>
EOF
;
}

sub mk_definitions {
	my ($self,$wsdl) = @_;
	my $name = $self->name;

print WSDL <<EOF;
<?xml version="1.0"?>
<definitions xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
	xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" 
	xmlns="http://schemas.xmlsoap.org/wsdl/" 
	xmlns:xsd1="urn:$name" 
	xmlns:tns="$wsdl"
	name="$name" 
	targetNamespace="$wsdl">
EOF
}

#----------------------------------------------------
package WSmethod;
#----------------------------------------------------
use KObjectTemplate;
#use strict;
require Exporter;
@ISA = qw(KObjectTemplate Exporter);
attributes qw(method request response request_names response_names rows sqlcmd DSN user password database name);
# The idea here is the web service obj. has an attribute that points
# to an unkown amount of method obj.'s. 
# The method obj. has two attributes (request_names and response_names)
# @request_names = (variable type variable type,... )

sub fill_names {
	my ($self,$a_vars,$msg_type) = @_;
#	my ($self,$a_vars,$a_types,$msg_type) = @_;
	my (%names,@names); 

	foreach my $variable (@$a_vars) {
		$variable =~ s/\W//;
		#my $type = shift @$a_types;
		#$type =~ s/\W//;
		push @names, ($variable,'string');
		#push @names, ($variable,$type);
	}
	$self->set_attributes($msg_type,\@names);
}

sub write_types {
	my $self = shift;
	my $service_name = shift;
	
	my $response = $self->response;
	my @schema_names = @{$self->response_names};
#my ($name,$type) = splice @schema_names,0,2;
print WSservice::WSDL <<EOF;
<types>
  <schema xmlns="http://www.w3.org/2001/XMLSchema" 
       targetNamespace="urn:$service_name">
    <complexType name="$response">
      <sequence>
         <element name="row">
           <complexType>
             <sequence>
EOF

	while (my ($name,$type) = splice @schema_names,0,2) {
		print WSservice::WSDL "\n<element name=\"$name\" type=\"xsd:$type\"/>"; }

print WSservice::WSDL <<EOF2;

             </sequence>
           </complexType>
         </element>
      </sequence>
    </complexType>
  </schema>
</types>
EOF2
	
}
1;

