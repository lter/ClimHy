#! perl 

# Kyle Kotwica
# wambam.pl

=head1 NAME

WAMBAM
Web service Administration Module for B2B Application Model

=head1 DESCRIPTION

WAMBAM is a GUI Tool for the soap_server.pl program. The idea is to take user imput and write the XML configuration file for the automatic generation of webservices.

=head1 USAGE

perl wambam.pl

=head1 TODO


Do the Inline thing at OSU
Need to fill out documentation more.
Need to deal with modules and method names having to be the same.
Add view menu for more info about the services?

=cut

use warnings;
use strict;

use lib './bin';
use XML::Writer;
use XML::Simple;
use IO;
use Tk;
use Tk::widgets qw(Button Label Frame Entry Balloon Dialog);
use Objects;

my ($SOBJ,$MOBJ);

my %SERVICE_HASH = (
	name=> ['What would you like to name your web service?','This is totally arbitrary.'],
	documentation=> ['You may supply some description of this service.','This is optional, but recomended.']
);

my %METHOD_HASH = (
	method => ['The name of the method','This is arbitrary'],
	type => ['What type of method is this?','SQL,PERL,or JAVA'],
	request_names => ['The input variables',"A comma delimited list with a SOAP type in parenthases after each name;\n i.e. a(string),b(int).\n NOTE if no type is supplied or if I don\'t recognize the type I will make it a string.\n Order is important!"],
	response_names => ['The output variables',"A comma delimited list with a SOAP type in parenthases after each name;\n i.e. a(string),b(int). \nNOTE if no type is supplied or if I don\'t recognize the type I will make it a string.\n Order is important"],
	DSN => ['The datasource name',''],
	user => ['User',''],
	password => ['Password',''],
	sqlcmd => ['SQL Command',"Enter the SQL command with a \'?\' as place holders for the request_names;\n i.e. select foo from bar where blarch = ?"],
	module => ['Name of program to include','include the absolute path to the program.'],
	documentation=> ['You may supply some description of this method.','This is optional, but recomended.'],
	class => ['The name of the class','']
);


#&splash();

my $MW = MainWindow->new;
$MW->geometry('900x800+40+40');
#$MW->resizable(0,0);
$MW->title("Web service Administration Module for B2B Application Model");

my $MENU_FRAME = $MW->
	Frame(	-height => 40,
			-width => 500,
			-borderwidth => 2,
			-relief => 'groove')->
	pack(	-side => 'top', 
			-anchor=>'w', 
			-fill=>'x');

my $PROJECT_FRAME;
my $METHOD_FRAME;
	
my $img = $MW->
	Photo(	-file => "bin\\danteBW.gif");
$MW->
	Label(	-image => $img, 
			-width => 200)->
	pack();

$MW->fontCreate('big',  
				-family => 'helvetica',
				-size => 24,
				-weight => 'bold');
my $PROJECT_LABEL = $MW->
	Label(	-text => "There is no present project",
			-width => 250,
			-font => 'big')->
	pack();
	
my $PROJECT_MENU = $MENU_FRAME->
	Menubutton(	-text => 'Project', 
				-tearoff => 0,
				-menuitems => [	['command' => 'New Project',
								-underline => 0,
								-command => [\&new_project,'project'] ],
								['command' => 'Open Project',
								-underline => 0,
								-command => [\&selector, 'project', 'open'] ],
								['command' => 'Edit Properties',
								-underline => 0,
								-command => [\&save_project,'edit'] ],
								['command' => 'Save Project',
								-state => 'disabled',
								-underline => 0,
								-command => [\&save_project,'save'] ],
								['command' => 'Clear Project',
								-state => 'disabled',
								-underline => 0,
								-command => [\&clear_project] ],
								['command' => 'Delete Project',
								-underline => 0,
								-command => [\&selector, 'project', 'delete'] ],
								['command' => 'Exit',
								-underline => 1,
								-command => sub {$MW->exit;}] ])->
	pack(	-side => 'left', 
			-anchor => 'n');
my $METHOD_MENU = $MENU_FRAME->
	Menubutton(	-text => 'Method', 
				-tearoff => 0,
				-menuitems => [	[Cascade => 'New Method',
								-state => 'disabled',
								-tearoff => 0,
								-menuitems => [
									['command' => 'Database Query',
									-underline => 0,
									-command => [\&new_method, 'SQL', 'NEW'] ],
									['command' => 'Perl Module',
									-underline => 0,
									-command => [\&new_method, 'PERL', 'NEW'] ], 
									['command' => 'JAVA Module',
									-underline => 0,
									-command => [\&new_method, 'JAVA', 'NEW'] ] ] ],
								['command' => 'Open Method',
								-underline => 0,
								-state => 'disabled',
								-command => [\&selector, 'method', 'open'] ],
								['command' => 'Clear Method',
								-underline => 0,
								-state => 'disabled',
								-command => [\&clear_method] ],
								['command' => 'Delete Method',
								-underline => 0,
								-state => 'disabled',
								-command => [\&selector,'method','delete']]])->
	pack(	-side => 'left', 
			-anchor => 'n');


MainLoop;

###
### End of Main
###

sub new_method {
	my ($type,$operation) = @_;
	my $text =  
		"The present project is ".$SOBJ->name."\nPlease edit the $type method";
	if ($operation eq 'NEW'){
		$MOBJ = $SOBJ->push_method(MethodObj->new());
	} else {
		$text .= " ".$MOBJ->method;
	}
	$PROJECT_LABEL->configure(
			-text => "$text");	

	$METHOD_FRAME = $MW->
		Frame(	-relief => 'raised',
				-borderwidth => 5)->
		pack( 	-side => 'top');
	my $entry_frame = $METHOD_FRAME->
		Frame(	-relief => 'raised',
				-borderwidth => 5)->
		pack();
	
	my (@entries,@entry_list);
	if ($type eq 'SQL') {
		@entry_list = ('method','DSN','user','password','sqlcmd','request_names','response_names','documentation');
	} elsif ($type eq 'JAVA') {
		@entry_list = ('method','module','class','request_names','response_names','documentation');
	} elsif ($type eq 'PERL') {
		@entry_list = ('method','module','request_names','response_names','documentation');
	}
	@entries = &entries('method',$entry_frame,@entry_list);

	my $buttonFrame = $METHOD_FRAME->
		Frame()->
		pack();
	$buttonFrame->
		Button(	-text => "Make",
				-command => [\&save_method,$type,\@entry_list,\@entries])->
		pack(	-side => 'left');	
	$buttonFrame->
		Button( -text => "Cancel",
				-width => '10',
				-command => \&cancel_method)->
		pack(	-side => 'right');	

	&grey_out('METHOD',0,1,3);
	&grey_out('PROJECT',0,1,2,3,4,5);
	
}

sub new_project {
	my $type = shift;
	$SOBJ = WebServiceObj->new();
	$PROJECT_LABEL->configure(
		-text => "Please fill out the fields below");	

	$PROJECT_FRAME = $MW->
		Frame( -relief => 'raised',
				-borderwidth => 5)->
		pack( -side => 'top');
	my $entry_frame = $PROJECT_FRAME->
		Frame(	-relief => 'raised',
				-borderwidth => 5)->
		pack();
	my $buttonFrame = $PROJECT_FRAME->
		Frame()->
		pack();
	
	&grey_out('PROJECT',0,1,2,3,5);
	
	my @entry_list = ('name','documentation');
	my @entries = &entries('service',$entry_frame,@entry_list);

	$buttonFrame->Button(
			-text => "Submit",
			-width => '10',
			-command => [\&save_project,'submit',\@entry_list,\@entries])->
		pack(	-side => 'left');	
	
	$buttonFrame->Button(
			-text => "Cancel",
			-width => '10',
			-command => \&cancel_project)->
		pack(	-side => 'right');	
}

sub entries {
	my ($type,$entry_frame,@entry_list) = @_;
	my (@entries,$obj,$hash);

	if ($type eq 'service') {
		$obj = $SOBJ;
		$hash = \%SERVICE_HASH;
	} else {
		$obj = $MOBJ;
		$hash = \%METHOD_HASH;
	}

	my $i = 0;
	
	my $b = $entry_frame->Balloon();
	
	foreach my $thing (@entry_list) {
		my $x = &makeEntry($obj,$entry_frame,$thing,$i++,$hash,$b);
		push @entries,$x; 
			
	}
	return @entries;
}

sub fill_obj {
# entries is a list of references (to be values)
# entry_list is a list of attributes (to be keys)
	my ($obj,$entry_list,$entries) = @_;
	my $i = 0;

	foreach my $thing (@$entries) {
		my $what = $thing->get();
		my $huh = @$entry_list[$i++];
		$obj->$huh($what);
	}
}

sub save_method {
	my ($type,$entry_list,$entries) = @_;

	&fill_obj($MOBJ,$entry_list,$entries);

	$MOBJ->type($type);
	&write_xml;
	&clear_method;
	my $text = $SOBJ->name." has been succesfully saved and is live.\n The following methods are available\n";
	for(my $i=0;$i<$SOBJ->census;$i++) {
		my $mobj = $SOBJ->methods->[$i];
		$text .= $mobj->method()."\n";
	}
	$PROJECT_LABEL->configure(
		-text => $text);	
}

sub save_project {
	my ($type,$entry_list,$entries) = @_;
	
	if ($type eq 'submit') {
		&fill_obj($SOBJ,$entry_list,$entries);
		if ($SOBJ->old_name($SOBJ->name)) {
			$PROJECT_LABEL->configure(
				-text => "There already is a project named ".$SOBJ->name);	
			return();
		}

		&grey_out('METHOD',2);
		$PROJECT_LABEL->configure(
			-text => "The present project is ".$SOBJ->name);	
	} else { 
		$PROJECT_LABEL->configure(
			-text => $SOBJ->name." has been succesfully saved and is live.");	
		#TODO show data about service i.e. methods or WSDL
	}
	&grey_out('PROJECT',3);
	&write_xml();
	if ($PROJECT_FRAME) {$PROJECT_FRAME->packForget;}
}

sub write_xml {
	my $file = "services/" . $SOBJ->name() . ".xml";
	my $output = new IO::File(">$file");
	my $writer = XML::Writer->new(
			OUTPUT => $output, 
			DATA_MODE => 1, 
			DATA_INDENT => 1);

	$writer->startTag("service",
                    "name" => $SOBJ->name);
	$writer->startTag("documentation");
	$writer->characters($SOBJ->documentation);
	$writer->endTag("documentation");
# methods writing  starts here
	for(my $i=0;$i<$SOBJ->census;$i++) {
		my $X = $SOBJ->methods->[$i];
		$writer->startTag("method","name" => $X->method, "type" => $X->type);
		if ($X->type eq 'SQL') {
			my @elements =('DSN','password','user','sqlcmd','documentation');
			&write_elements($writer,$X,@elements);
		} elsif ($X->type eq 'JAVA') {
			&write_elements($writer,$X,'class','documentation');
			&write_module($writer,$X->module);
		} elsif ($X->type eq 'PERL') {
			&write_elements($writer,$X,'documentation');
			&write_module($writer,$X->module);
		}
		$writer->endTag("method");
	}
	$writer->endTag("service");
	$writer->end();
	$output->close();
}

sub write_module {
	my ($writer,$module) = @_;
	my $path;
	return if (!$module);

	$module =~ s/\\/\//g;
	if ($module =~ /\//) {
		$module =~ s/(.*\/)(.*)/$2/;
		$path = $1;
	} else {
		$path = './';
	}
	
	$writer->startTag('module',"path" => $path);
	$writer->characters($module);
	$writer->endTag('module');
}

sub write_elements {
	my ($writer,$X,@elements) = @_;
	foreach my $thing (@elements) {
		$writer->startTag($thing);
		$writer->characters($X->$thing);
		$writer->endTag("$thing");
	}
	@elements =('request_names', 'response_names');
	foreach my $thing (@elements) {
		my @list = &parse_thing($X->$thing);
		for(my $i=0; $i<=$#list; $i=$i+2) {
			$writer->startTag("$thing","type" => $list[$i+1]);
			$writer->characters($list[$i]);
			$writer->endTag("$thing");
		}
	}
}

sub parse_thing {
# $thing looks like name1(type1),name2(type2)
# returns a list (name1,type1,name2,type2
# if user did not supply type assume string
	my $thing = shift;
	my (@result,@list);
	if ($thing) {
		$thing =~ s/ //g;
		$thing =~ s/\(/=>/g;
		$thing =~ s/\)//g;
		@list = split /,/,$thing;
	}
	foreach my $foo (@list) {
		my ($name,$type) = split /=>/,$foo;
		if (!$type) { $type = 'string';}
		if ($type && $type !~ /int|string|date/){
			$type = 'string';
		}
		push @result,$name,$type;
	}
	return(@result);
}

sub clear_method {
	&grey_out('METHOD',2);
	&grey_out('PROJECT',0,1,5);
	$METHOD_FRAME->packForget;
	undef($MOBJ);
}

sub clear_project {
	&grey_out('PROJECT',3,4);
	&grey_out('METHOD',0,1,2,3);
	#$PROJECT_LABEL->packForget;
	if($PROJECT_FRAME) { $PROJECT_FRAME->packForget; }
	$PROJECT_LABEL->configure(-text => "There is no present project");
	undef($SOBJ);
		#($service_path,$cgi,$server,$wsdl_path,$soap_action) = undef;
		#if ($METHOD_FRAME) { $METHOD_FRAME->packForget; }
}

sub makeEntry {
	my ($obj,$entry_frame,$key,$row,$hash,$ballon) = @_;
	#if ( !$obj->$key() ) {$obj->$key(' ');}
	
	my $label = $entry_frame->
		Label(	-text => $$hash{$key}[0],
				-width => 50)->
		grid(	-row => $row, 
				-column => 1);
	$ballon->
		attach(	$label,
				-balloonmsg => $$hash{$key}[1], 
				-initwait => 1);
	my $x = $entry_frame->
		Entry(	-width => 40,
				-textvariable => \$obj->$key())->
		grid(	-row => $row, 
				-column => 2);
	return($x)
}

sub cancel_project {
	$PROJECT_FRAME->packForget;
	&grey_out('PROJECT',3,4);
}

sub cancel_method {
	$METHOD_FRAME->packForget;
	$PROJECT_LABEL->configure(
		-text => "The present project is ".$SOBJ->name);	
	&grey_out('METHOD',2);
	&grey_out('SERVICE');
	undef($MOBJ);
}

sub grey_out {
	my ($type,@index) = @_;
	my ($size,$menu);

	if ($type eq 'METHOD') {
		$size = 6;
		$menu = $METHOD_MENU;
	} else {
		$size = 6;
		$menu = $PROJECT_MENU;
	}

	for (my $i=0;$i<=$size;$i++) {
		$menu->entryconfigure($i,-state => 'active');
		}
	
	for (my $i=0;$i<=$#index;$i++) {
		$menu->entryconfigure($index[$i],-state => 'disable');
	}
}

sub selector {
	my ($type,$operation) = @_;
	my @things;

	my $title = 'Method Selector';
	if ($type eq 'project') {
		if (!$SOBJ) {$SOBJ = WebServiceObj->new();}
		@things = $SOBJ->ls();
		$title = 'Project Selector';
	} else {
		for(my $i=0;$i<$SOBJ->census();$i++) {
			push @things,$SOBJ->methods->[$i]->method
		}
	}

	my $dialog = MainWindow->new();
	$dialog->title($title);
	$dialog->resizable(0,0);
	$dialog->grabGlobal();
	my $dialogLB = $dialog->Scrolled("Listbox", 
									-width => 42,
									-selectmode => 'single',
									-scrollbars => 'oe')->
										pack(-side => 'left');
	$dialogLB->insert('end',@things);

	my $buttonFrame = $dialog->Frame()->pack();
	if ($operation eq 'open') {
		$buttonFrame->Button(-text => "Open",
				-width => '10',
				-command => [\&open,$type,$dialog,$dialogLB,@things])->
					pack();
	} else {
		$buttonFrame->Button(-text => "Delete",
				-width => '10',
				-command => [\&delete,$type,$dialog,$dialogLB,@things])->
					pack();
	}
	$buttonFrame->Button(-text => "Cancel",
				-width => '10',
				-command => sub {$dialog->withdraw;$dialog->grabRelease;})->
					pack();
}

sub update_project {
	my $name = shift;
	my $properties = XMLin("services/$name.xml", forcearray => 1);
	$SOBJ = WebServiceObj->new();
	$SOBJ->name($properties->{name});
	if (ref($properties->{documentation}[0]) ne "HASH") {
		$SOBJ->documentation($properties->{documentation}[0]); }
	
	my $ref = $properties->{method};
	foreach my $method ( keys( %{$ref} ) ){
		my $mref = $ref->{$method};
		$MOBJ = $SOBJ->push_method(MethodObj->new());
		$MOBJ->method($method);
		$MOBJ->type($mref->{type});
		if ($MOBJ->type =~ /SQL/) {
			&fill_it('DSN',$mref);
			&fill_it('user',$mref);
			&fill_it('password',$mref);
			&fill_it('sqlcmd',$mref);
		} elsif ($MOBJ->type =~ /PERL/) {
			&fill_mod($mref);
		} elsif ($MOBJ->type =~ /JAVA/) {
			&fill_mod($mref);
			&fill_it('class',$mref);
		}
		&fill_it('documentation',$mref);
		&messages('request_names',$mref);
		&messages('response_names',$mref);
	}
}

sub messages {
	my ($x_names,$mref) = @_;
	my $string;
	if ($mref->{$x_names}) {
		my @names = (@{$mref->{$x_names}});
		foreach my $name (@names) {
			$string .= $name->{content}."(".$name->{type}."),";
		}
		$string =~ s/,$//;
		$MOBJ->$x_names($string);
	}
}

sub fill_mod {
	my ($mref) = @_;
	if (ref($mref->{module}) ne "HASH") {
		my $path=$mref->{module}[0]->{path}; 
		my $module = $mref->{module}[0]->{content}; 
		$module = $path.$module;
		$MOBJ->module($module);
	}
}

sub fill_it {
	my ($x,$mref) = @_;
	if (ref($mref->{$x}[0]) ne "HASH") {
		$MOBJ->$x($mref->{$x}[0]); 
	}
}

sub delete {
	my ($type,$dialog,$dialogLB,@things) = @_;
	my $name = $things[$dialogLB->curselection];	
	if (!$name) {
		$dialog->withdraw;
		$dialog->grabRelease;
		return; 
	}

	#double check
	if ($type eq 'project') {
		&grey_out('METHOD',0,1,2,3);
		&grey_out('PROJECT');
		unlink("services/$name.xml");
		undef($SOBJ);
		$PROJECT_LABEL->configure(	-text => "You have deleted the project $name" );
	} elsif ($type eq 'method') {
		$SOBJ->methods([$SOBJ->prune($name)]);
		&write_xml();
		&grey_out('PROJECT');
		$PROJECT_LABEL->configure(	-text => "You have deleted $name from ".$SOBJ->name."\n" );
	}
	$dialog->withdraw;
	$dialog->grabRelease;
}

sub open {
	my ($type,$dialog,$dialogLB,@things) = @_;
	my $name = $things[$dialogLB->curselection];	
	if (!$name) {
		$dialog->withdraw;
		$dialog->grabRelease;
		return; 
	}

	if ($type eq 'project') {
		&grey_out('METHOD',2);
		&grey_out('PROJECT',3);
		$PROJECT_LABEL->configure(	-text => "The present project is $name" );
		&update_project($name);
	} elsif ($type eq 'method') {
		$MOBJ = $SOBJ->get_ref($name);
		&new_method($MOBJ->type,'EDIT');
	}
	$dialog->withdraw;
	$dialog->grabRelease;
}

sub splash{
	my $dialog = MainWindow->new();
	$dialog->title('Pay Me');
	$dialog->resizable(0,0);
	my $img = $dialog->Photo(-file => "bin\\danteBW.gif");
	my $frame = $dialog->Frame(-background => 'green')->pack();
	my $text = $frame->Text(-borderwidth => 14,
				-relief =>'groove',
				-font => 'Bard 12 normal',
				-background => 'yellow',
				-padx => 50,
				-pady => 50,
				-height => 23,
				-width => 80,)
		->pack(-fill => 'x');
	$frame->Button(-text => 'OK',
					-relief => 'sunken',
					-image => $img,
					-borderwidth => '4',
					-background => 'grey',
					-command => sub {$dialog->destroy();})
		->pack();
		
	$text->tagConfigure('bold',-font =>"{Courier New} 22 {bold}");
	$text->insert('end', 
"\t\tWAMBAM (version 1.0)
Web service Administration Module for B2B Application Model",'bold');
	$text->insert('end',
"\n\nCopyright 2004 Kyle Kotwica
All Rights reserved.\n
WAMBAM and SOAP_SERVER are works of art.\n
This program is what you could call threatware. I didn't get paid for it. So I threaten you that I'll keep on     whining about it untill I get my just rewards.\n
If you get tired of seeing pictures of my dog all over you could pay me, some money and I'll get rid of them\n\n");
	$text->insert('end',
"Warning: This computer program is protected by copyright law and international treaties,
not to mention Dante and Mozart. Unauthorized reproduction or distribution of this program,
or any portion of it, may result in having Dante bite you in the ass.");
}

