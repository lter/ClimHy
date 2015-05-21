#! perl -w

# IMPORTANT !!!
# CHUMP, CLIMDB, PLOT, SITEDB --- THE WHOLE FUNDME PROJECT MUST ALL BE ABLE TO
# ACCESS climdb.conf! climdb.conf should be in CLIMDB/
# &read_control is in clim_lib and holds the location of climdb.conf in the 
# variable $control{control}

my (%control) = &read_control();
my $conf;

my %pretty_control = (
	password => 'The password needed for editing metadata',
#	harvest_dir => 'The location of harvest.pl',
#	working_dir => 'The path of the FUNDME modules',
#	data_dir => 'The directory where the data files should be written',
#	log_dir => 'The directory where the log files should be written',
	web => 'The URL of the root FUNDME directory',
#	web_harvest => 'The URL of the harvest page',
	data_source => 'The data source for the database',
	data_password => 'The password for the data base',
	verbose => 'The number of errors to log before causing a fatal error',
	warning => 'The number of warnings to log before causing a fatal error',
	email => 'The email address of the database administrator',
	email2 => 'Second email address for database contact',
	UNC => 'UNC path for the root climdb directory',
	mail_server => 'Mail server',
	mail => 'Should the feedback emails be sent?   1=yes, 0=no  ', 
	ingest => 'Should the ingestion step be executed?  1=yes, 0=no', 
	digest => 'Should the digestion step be executed?  1=yes, 0=no',
	data_user => 'The data user for the database',
	fop => 'The location of the fop batch/sh file',
	gnu_exe => 'The location of the Gnuplot executable',
	ftp_server => 'FTP server',
	ftp_password => 'FTP password',
	ftp_user => 'FTP user name',
	ftp_location => 'Location to put mailing list',
	climdb_css => 'Style sheet for LTER web pages',
	hydrodb_css => 'Style sheet for USFS web pages',
	usgsdb_css => 'Style sheet for USGS web pages',
	all_css => 'Style sheet for combined web pages'
);
		
sub config{
	if (!Exists $conf){
		$conf = MainWindow->new;
		$conf->title("Climdb Configuration Utility");

		my $checkFrame = $conf->Frame(
			-relief => 'flat',
			-borderwidth => 5)->
				pack();
		my $entryFrame = $conf->Frame(
			-relief => 'raised',
			-borderwidth => 5)->
				pack();
		my $buttonFrame = $conf->Frame()->
				pack();

		
		$checkFrame->Checkbutton(
			-text => "$pretty_control{mail}",
			-width => 50,
			-variable => \$control{mail})->
				grid(-row => 0, -column => 2);
		$checkFrame->Checkbutton(
			-text=> "$pretty_control{ingest}",
			-width=> 50, 
			-variable => \$control{ingest})->
				grid(-row => 1, -column => 2);
		$checkFrame->Checkbutton
			(-text=> "$pretty_control{digest}", 
			-width=> 50, 
			-variable => \$control{digest})->
				grid(-row => 2, -column => 2);

		&makeLabel($entryFrame,"\nDatabase configuration",50,3,2);
#		&makeEntry($entryFrame,"server",4);
		&makeEntry($entryFrame,"data_source",5);
		&makeEntry($entryFrame,"data_user",6);
		&makeEntry($entryFrame,"data_password",7);
#		&makeLabel($entryFrame,"\nFile System",50,8,2);
#		&makeEntry($entryFrame,"harvest_dir",9);
#		&makeEntry($entryFrame,"working_dir",10);
#		&makeEntry($entryFrame,"data_dir",11);
#		&makeEntry($entryFrame,"log_dir",12);
		&makeLabel($entryFrame,"\nSystem Commands",50,12,2);
		&makeEntry($entryFrame,"fop",13);
		&makeEntry($entryFrame,"gnu_exe",14);
		&makeEntry($entryFrame,"UNC",15);
		&makeLabel($entryFrame,"\nE-mail & FTP Settings",50,16,2);
		&makeEntry($entryFrame,"mail_server",17);
		&makeEntry($entryFrame,"email",18);
		&makeEntry($entryFrame,"email2",19);
		&makeEntry($entryFrame,"ftp_server",20);
		&makeEntry($entryFrame,"ftp_password",21);
		&makeEntry($entryFrame,"ftp_user",22);
		&makeEntry($entryFrame,"ftp_location",23);
		&makeLabel($entryFrame,"\nWWW",50,24,2);
		&makeEntry($entryFrame,"web",25);
		#&makeEntry($entryFrame,"web_harvest",26);
		&makeEntry($entryFrame,"password",27);
		&makeEntry($entryFrame,"climdb_css",28);
		&makeEntry($entryFrame,"hydrodb_css",29);
		&makeEntry($entryFrame,"usgsdb_css",30);
		&makeEntry($entryFrame,"all_css",31);
		&makeEntry($entryFrame,"verbose",32);
		&makeEntry($entryFrame,"warning",33);
		&makeLabel($entryFrame,"\n",50,34,2);

	#	$buttonFrame->Label(
	#		-text => "\n")->
	#			grid(-row => 1);
		$buttonFrame->Button(
			-text => "Save",
			-command => \&saveIt)->
				grid(-row => 2, -column => 1);
		$buttonFrame->Label(
			-text => "", 
			-width => 10)->
				grid(-row => 2, -column => 2);
		$buttonFrame->Button(
			-text => "Cancel",
			-command => sub {$conf->withdraw})->
				grid(-row => 2, -column => 5);
	}
	else {
		$conf->deiconify();
		$conf->raise();
	}
}

sub makeEntry {
	my ($entryFrame,$text,$row) = @_;

	&makeLabel($entryFrame,$text,50,$row,1);
	$entryFrame->Label(
		-text => $pretty_control{$text},
		-width => 50)->
			grid(-row => $row, -column => 1);
	$entryFrame->Entry(
		-width => 40, 
		-textvariable => \$control{$text})->
			grid(-row => $row, -column => 2);

}

sub makeLabel {
	my ($entryFrame,$text,$width,$row,$column) = @_;

	$entryFrame->Label(
		-text => $text,
		-width => $width)->
			grid(-row => $row, -column => $column);
}

sub saveIt{
	close CONTROL;
	$control{control} = "bin\\climdb.conf";
	if (-e $control{control}) {
		open (CONTROL,">$control{control}") or die "Can't open $control{control}: $!\nClimdb.pl needs an associated control file to receive instructions from xx.\n";
	} else {
		$control{control} = "climdb.conf";
		open (CONTROL,">$control{control}") or die "Can't open $control{control}: $!\nClimdb.pl needs an associated control file to receive instructions from xx.\n";
	}	

	my ($var,$val);
	foreach $var (keys %control ) {
		$val = $control{$var};
		print CONTROL "$var=$val\n";
	}
	close CONTROL;
	$conf->withdraw;
}

1;

