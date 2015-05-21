#! perl -w

# This package has sets of programs for dealing with personnel, site, and 
# station tables.
# Each of the above sets has filling, updating, inserting, and deleting 
# features.
# The naming convention is fill_X, XDelete, XInsert, and XUpdate, where X
# is eather personnel, site, or station.

use Tk::Dialog;
use Tk::Balloon;
use Net::FTP;
use sql_cmd;

my (%control) = &read_control();

my $verbose;
my $debug;

my ($window,$mainFrame,$bigFrame,$dbh);
my $parent_flag = 0;

my ($res_site_name, $res_site_code, $res_sitetype_id, $res_module_id, $res_site_parent_id, $res_site_id, $last_name, $first_name, $middle_name, $address, $city, $state, $postal_code, $country, $telephone1, $telephone2, $email1, $email2, $fax1, $fax2, $personnel_role_id, $site_code, $site_name, $loc1, $loc2, $latitude_dec, $longitude_dec, $hydro_data_url, $clim_data_url, $usgs_data_url, $site_url, $site_id, $personnel_id, $station, $description);

my ($sitetype_change,$module_change);

sub display{
# This is basically the main for the program for updateing and adding to the
# CLIMDB database. Look to conf.pm for the configuration settings.
# it sets up and fills all of the values depending on the 
# users choices.

	(my $type, $window,$mainFrame,$dbh,$verbose,$debug) = @_;
#clean up the old garbage
	&reset();
	
#set up frames for entries
	$bigFrame = $window->Frame(
							-borderwidth =>1,
							-relief => 'groove');
	my $topFrame = $bigFrame->Frame(
							-relief => 'groove')->pack();
	my $midFrame = $bigFrame->Frame(
							-borderwidth =>5,
							-relief => 'groove')->pack();
	my $bottomFrame = $bigFrame->Frame(
							-borderwidth =>10,
							-relief => 'groove')->pack();

# Update the verbose or debug flags
	if ($type eq 'None'){
		&cancel;
		return(1,$bigFrame);
	}

#deal with top frame
	my $topLabel = $topFrame->Label(-textvariable => \$type,
									-font => 'Arial 24 normal')->pack();

	if ($type =~ /Personnel/) { 
		&fill_personnel($midFrame); 
		if ($type =~ /Update/) {
			&myDialog('Pick a Name');
			&fill_buttons($bottomFrame,'Update',\&personnelUpdate,'Cancel',\&cancel);
		}
		else {
			&fill_buttons($bottomFrame,'Insert',\&personnelInsert,'Reset',\&reset,'Cancel',\&cancel);}
	}
	if ($type =~ /Site/) { 
		&fill_site($midFrame);
		if ($type =~ /Update/) {
			&myDialog('Pick a Site');
			&fill_buttons($bottomFrame,'Update',\&siteUpdate,'Cancel',\&cancel);
		}
		else {
			&fill_buttons($bottomFrame,'Insert',\&siteInsert,'Reset',\&reset,'Cancel',\&cancel);}
	}
	if ($type =~ /Station/) {
		&fill_station($midFrame); 
		if ($type =~ /Update/) {
			&myDialog('First Pick a Site');
			&fill_buttons($bottomFrame,'Update',\&stationUpdate,'Get Parent',\&getParent,'Cancel',\&cancel);}
		else {
			&fill_buttons($bottomFrame,'Insert',\&stationInsert,'Get Parent',\&getParent,'Reset',\&reset,'Cancel',\&cancel);}
	}

#git rid of old frame and replace with new frame
	&go_next($mainFrame,$bigFrame);

	return (1,$bigFrame);
}

sub getParent {
# this gets the parent for the site type
# if the res_sitetype_id == 3 
# (or if its a 5 (or 3,4) treat it as if its a 3) it displays a dialog 
# so as to allow the user to choose

	$res_sitetype_id =~ s/.+,.+/5/;
	if ($res_sitetype_id == 1){
		$res_site_parent_id = 'null';
		&myDialog('Get Parent',1);
	} 
	elsif ($res_sitetype_id == 2 || $res_sitetype_id == 4){
		&myDialog('Get Parent',2);
	}
	elsif ( ($res_sitetype_id == 3) || ($res_sitetype_id == 5) ){
		#$res_sitetype_id = '3,4';
		&myDialog('Get Parent',3);
	}
	$module_change = $res_module_id;
	$sitetype_change = $res_sitetype_id;
}

sub getChoices {
# Usage: 		@ = getChoices($sqlcmd,$cmdType,[$none])
# 	$sqlcmd = A SQL command
#	$cmdType = Either hash or array
# 	$none = Anything (optional). If $none is supplied the value of $none will 
#		be placed in the begining of the returned array. The purpose of this 
#		silly feature is to get a list of like the following;
#	
#	no choice
#	A
# 	B
#	C
#
# $none = 'no choice' and the result of the SQL querry was A,B, and C
	
	my ($sqlcmd,$cmdType,$none) = @_;
	my ($key,@choices);
	if ($cmdType eq 'hash') {
		my %choices = &query_DB($sqlcmd,'hash',$dbh);
		if ($none) {
			push @choices, $none;}
		foreach $key (sort  keys(%choices)){
			push @choices, "$key - $choices{$key}";
		}
	}
	else {
		if ($none) {
			push @choices, $none;}
		@choices = &query_DB($sqlcmd,'array',$dbh); 
	}
	return(@choices);
}

sub fill_site {
# This fills the site frame

	my $siteFrame  = shift;
	if ($site_code) {
		if ($longitude eq 'null') {$longitude = '';}
		if ($latitude eq 'null') {$latitude = '';}
	}
	&label_entry($siteFrame,'Site code - a three-letter code',\$site_code,1);
	&label_entry($siteFrame,'Site name - full name of site',\$site_name ,2 );
	&label_entry($siteFrame,'Module associations',\$res_module_id ,3 );
	&label_entry($siteFrame,'ClimDB data URL - where the climate data resides',\$clim_data_url ,4 );
	&label_entry($siteFrame,'HydroDB data URL - where the hydrologic data resides',\$hydro_data_url ,5 );
	&label_entry($siteFrame,'USGS data URL - where the USGS data resides',\$usgs_data_url ,6 );
	&label_entry($siteFrame,'Site URL - informational web page for site',\$site_url ,7 );
	&label_entry($siteFrame,'Location1 - Beats me?',\$loc1 ,8 );
	&label_entry($siteFrame,'Location2 - Beets meto?',\$loc2 ,9 );
	&label_entry($siteFrame,'Longitudeonal coordinate of site',\$longitude_dec ,10 );
	&label_entry($siteFrame,'Latitudenal coordinate of site',\$latitude_dec ,11 );

}

sub fill_station {
# This fills the station frame
	
	my $stationFrame  = shift;
	my $b = $stationFrame->Balloon();
	my $xLabel;

	$xLabel = &label_entry($stationFrame,'The research site code',\$res_site_code,1 );
	$b->attach($xLabel,
		-balloonmsg => "This should be 10 or less characters",
		-initwait => 1);
	&label_entry($stationFrame,'The name of the research site',\$res_site_name,2);
	&label_entry($stationFrame,'The three letter site code',\$site_code,3 );
	$xLabel = &label_entry($stationFrame,'The site type ID of the research site',\$res_sitetype_id,4 );
	$b->attach($xLabel,
		-balloonmsg => "1 = Research Area\n2 = Watershed\n3 = Gauging Station\n4 = Meteorological Station",
		-initwait => 1);
	$xLabel = &label_entry($stationFrame,'The number representing the module',\$res_module_id,5 );
	$b->attach($xLabel,
		-balloonmsg => "1 = LTER\n2 = USFS\n3 = USGS",
		-initwait => 1);
	$res_site_parent_id = 'null';
	$xLabel = &label_entry($stationFrame,'The parent ID',\$res_site_parent_id,6,'disabled');
	$b->attach($xLabel,
		-balloonmsg => "This field will be filled automaticaly",
		-initwait => 1);
}

sub fill_personnel {
# This fills the personnel frame

	my $personnelFrame  = shift;
	my $b = $personnelFrame->Balloon();
	my $xLabel;

	&label_entry($personnelFrame,'Last Name ',\$last_name ,1 );
	&label_entry($personnelFrame,'First Name ',\$first_name ,2 );
	&label_entry($personnelFrame,'Middle Name ',\$middle_name ,3 );
	&label_entry($personnelFrame,'Address ',\$address ,4 );
	&label_entry($personnelFrame,'City ',\$city ,5 );
	&label_entry($personnelFrame,'State ',\$state ,6 );
	&label_entry($personnelFrame,'Postal Code ',\$postal_code ,7 );
	&label_entry($personnelFrame,'Country ',\$country ,8 );
	&label_entry($personnelFrame,'Telephone ',\$telephone1 ,9 );
	&label_entry($personnelFrame,'Second Telephone ',\$telephone2 ,10 );
	&label_entry($personnelFrame,'E-mail ',\$email1 ,11 );
	&label_entry($personnelFrame,'Second E-mail ',\$email2 ,12 );
	&label_entry($personnelFrame,'Fax ',\$fax1 ,13 );
	&label_entry($personnelFrame,'Second Fax ',\$fax2 ,14 );

# res_module_id can be multiple values. We will treat this a a comma delimited list (i.e. 1, 2)
	$xLabel = &label_entry($personnelFrame,'Module Association',\$res_module_id ,15 );
	$b->attach($xLabel,
		-balloonmsg => "1 = LTER\n2 = USFS",
		-initwait => 1);
	
	$xLabel = &label_entry($personnelFrame,'Site Assoication',\$site_code ,16 );
	$b->attach($xLabel,
		-balloonmsg => "Enter the three character site code (i.e. AND)",
		-initwait => 1);
		
# personnel_role_id can be multiple values. We will treat this a a comma delimited list (i.e. 1, 3, 4)
	$xLabel = &label_entry($personnelFrame,'Roll ID',\$personnel_role_id ,17 );
	$b->attach($xLabel,
		-balloonmsg => "Enter a comma deliminated list\n1 = Principal Investigator\n2 = Other Researcher\n3 = Data Set Contact\n4 = Originator\n5 = Metadata Contact\n6 = None\n7 = GIS Contact",
		-initwait => 1);
}

sub getSite_code{
	my $sqlcmd = &get_cmd(401,$site_id);
	($site_code,my $foo) = &query_DB($sqlcmd,'array',$dbh);
}

sub getSite_id {
	if (!$site_code) {$site_code = '';}
	my $sqlcmd = &get_cmd(402,$site_code);
	($site_id,my $foo) = &query_DB($sqlcmd,'array',$dbh);
}

sub cancel{
# This clears the screen

	&go_next($bigFrame,$mainFrame);
}

sub reset{
# This clears all of the values from the globals
($res_site_name, $res_site_code, $res_sitetype_id, $res_module_id, $res_site_code, $site_code, $res_site_parent_id, $res_site_id, $last_name, $first_name, $middle_name, $address, $city, $state, $postal_code, $country, $telephone1, $telephone2, $email1, $email2, $fax1, $fax2, $personnel_role_id, $site_code, $site_name, $loc1, $loc2, $latitude_dec, $longitude_dec, $hydro_data_url, $usgs_data_url, $clim_data_url, $site_url, $site_id, $personnel_id, $station, $description) = '';
}

sub next{
# This displays and executes the SQL commands to update the DB
# wheather it displays and/or executes is dependent on the settings
# of $verbose and or $debug

	my @sqlcmds = @_;
	my $sqlcmd;
	if ($verbose) {
		my $dialog = MainWindow->new();
		$dialog->title('SQL COMMANDS');
		my $frame = $dialog->Frame()->pack();
		my $text = $frame->Text(-height => 50)->pack();
		foreach $sqlcmd (@sqlcmds){
			my $dash = '_' x 80;
			$text->insert('end',"$sqlcmd\n");
			$text->insert('end',"$dash\n");
			if (!$debug) {
				my $rv = $dbh->do($sqlcmd);
				if ($rv) {	
					$text->insert('end',"$rv lines affected\n");}
				else {
					my $error = "ERROR: ".$dbh->errstr;
					$text->insert('end',"$error\n");
					$error = "YOUR COMMAND FAILED\nPlease fix the probelm and try again.\n\n" . $error; 
					&isError($error,'OK');
				}
			$text->insert('end',"$dash\n\n");
			}
		}
		$frame->Button(-text => "Cancel",
					-width => '10',
					-command => sub {$dialog->destroy();})->
						pack();
	}
	else {
		if (!$debug) {
			foreach $sqlcmd (@sqlcmds){
				my $rv = $dbh->do($sqlcmd);
				if (!$rv) {
					my $error = "YOUR COMMAND FAILED\nPlease fix the probelm and try again.\n\nERROR: " .$dbh->errstr; 
					&isError($error,'OK');
				}
			}
		}
	}
	if ($debug) {
		&cancel;
		&isError("The database has not been changed!",'OK'); 
	} else {
		&cancel;
		&isError("The database has been changed!",'OK');
	}
}


#sub siteDelete{
#	my @cmds;
#	push @cmds, &delete('site','site_id ',$site_id);
#	&next(@cmds);
#	&reset();
#	#&isError("The database has been changed!",'OK');
#}
#
#sub personnelDelete{
#	my @cmds;
#	push @cmds, &delete('site_personnel_role','personnel_id',$personnel_id);
#	#push @cmds, &delete('personnel','personnel_id',$personnel_id);
#	&mailingList('1',@cmds);
#	&reset();
#	#&isError("The database has been changed!",'OK');
#}
#
#sub stationDelete{
#	my @cmds;
#	push @cmds, &delete('research_site','res_site_id',$res_site_id);
#	push @cmds, &delete('research_site_module','res_site_id ',$res_site_id );
#	&next(@cmds);
#	&reset();
#	#&isError("The database has been changed!",'OK');
#}

sub delete {
# give me a list of [table name, id name, and id value] and 
# I will write the delete command
	my ($table_name, $id_name, $id) = @_;
	
	my @cmds;
	my $sqlcmd = &get_cmd(403,$table_name,$id_name,$id);
	return($sqlcmd);
}

sub getID {
# give me a list of [table name, id name, and id value] and 
# I will write the command to get the next highest id number
	my ($table_name, $id_name, $id) = @_;
	
	my $sqlcmd = &get_cmd(404,$id_name,$table_name);
	($id,my $foo) = &query_DB($sqlcmd,'array',$dbh);
	$id = $id + 1;
	return($id);
}

sub siteUpdate{
	my @cmds;
	if (!$latitude_dec) { $latitude_dec = 'null';}
	if (!$longitude_dec) { $longitude_dec = 'null';}
	my $sqlcmd = &get_cmd(405,
$site_code,$site_name,$loc1,$loc2,$latitude_dec,$longitude_dec,$hydro_data_url,$clim_data_url,$usgs_data_url,$site_url,$site_id);
	push @cmds, $sqlcmd;
	
	$sqlcmd = &get_cmd('442',$site_id);
	$res_site_id = &query_DB($sqlcmd,'value',$dbh);

	@cmds = &multi_modules($res_site_id,@cmds);
	&next(@cmds);
}

sub multi_modules {
	my $res_site_id = shift;
	my @cmds = @_;
	my $sqlcmd;
	my @modules;
	
	if ($res_module_id) {
		$res_module_id =~ s/\s//g;
		@modules = split /,/,$res_module_id;
	}
	
	$sqlcmd = &get_cmd('417',$res_site_id);
	push @cmds, $sqlcmd;
	
	if (&checkMods(@modules)) { return(); }
	foreach my $mod_id (@modules) {
		$sqlcmd = &get_cmd('420',$res_site_id,$mod_id);
		push @cmds, $sqlcmd;
	}
	return(@cmds);
}

sub siteInsert {
	my @cmds;
	$site_id = &getID('site','site_id',$site_id);
	$res_site_id = &getID('research_site','res_site_id',$res_site_id);
	&checkNulls
($site_code,$site_name,$loc1,$loc2,$latitude_dec,$longitude_dec,$hydro_data_url,$clim_data_url,$usgs_data_url,$site_url,$site_id);
	if ($latitude_dec eq '') { $latitude_dec = 'null';}
	if ($longitude_dec eq '') { $longitude_dec = 'null';}
				
	my $sqlcmd = &get_cmd(406,
$site_code,$site_name,$loc1,$loc2,$latitude_dec,$longitude_dec,$hydro_data_url,$clim_data_url,$usgs_data_url,$site_url,$site_id);
	push @cmds, $sqlcmd;

#fill research_site 
	$sqlcmd = &get_cmd('413',$site_name,$site_code,'null',$site_id,$res_site_id);
	push @cmds, $sqlcmd;

# fill research_site_module
	@cmds = &multi_modules($res_site_id,@cmds);

#fill research_site_sitetype
	$sqlcmd = &get_cmd('414',$res_site_id,'1');
	push @cmds, $sqlcmd;

	&next(@cmds);
}


sub personnelInsert{
	my (@cmds,@job,@modules);
	
	$personnel_id = &getID('personnel','personnel_id',$personnel_id);
	&checkNulls
($last_name,$first_name,$middle_name,$address,$city,$state,$postal_code,$country,$telephone1,$telephone2,$email1,$email2,$fax1,$fax2);

	my $sqlcmd = &get_cmd(407,
$last_name,$first_name,$middle_name,$address,$city,$state,$postal_code,$country,$telephone1,$telephone2,$email1,$email2,$fax1,$fax2,$personnel_id);
	push @cmds, $sqlcmd;

	&getSite_id();
	if ($personnel_role_id) {
		$personnel_role_id =~ s/\s//g;
		@job = split /,/,$personnel_role_id;
	}
	if ($res_module_id) {
		$res_module_id =~ s/\s//g;
		@modules = split /,/,$res_module_id;
	}
	if (&checkSites($site_id)) { return(); }
	if (&checkMods(@modules)) { return(); }
	if (&checkJobs(@job)) { return(); }
	foreach my $id (@job) {
		foreach my $mod_id (@modules) {
			my $sqlcmd = &get_cmd(408,$site_id,$personnel_id,$id,$mod_id);
			push @cmds, $sqlcmd;
		}
	}
	&mailingList('0',@cmds);
	#&isError("The database has been changed!",'OK');
	#&reset();
}

sub checkSites {
	my $site_id = shift; 
	my $error_string;
	if (!$site_id) {
		if (!$site_code) { $site_code = '';}
		$error_string = "The site assoication ($site_code) is not in the database\n";}
	if ($error_string) {
		&isError($error_string,'Cancel');
		return(1);
	}
}

sub checkMods {
	my @modules = @_; 
#print @modules;
	my $error_string;
	if (!$modules[0]){
		$error_string = "I will need a module association number, either a 1 (ClimDB), 2 (HydroDB), 3 (USGS). Or a comma deliminated list if more then one.";}
	foreach my $id (@modules) {
		if ($id > 3 || $id < 1){
			$error_string = "I will need a module association number, either a 1 (ClimDB), 2 (HydroDB), 3 (USGS). Or a comma deliminated list if more then one.";}

	}
	if ($error_string) {
		&isError($error_string,'Cancel');
		return(1);
	}
}

sub checkJobs {
	my @job = @_; 
	my $low = 1;
	my $high = 7;
	my $error_string;
	if (!$job[0]) {
		$error_string = "I will need at least one Personnel Roll ID (between $low and $high)";}
	foreach my $id (@job) {
		if ($id > $high || $id < $low){
			$error_string = "Personnel Role Id's need to be between $low and $high";}
	}
	if ($error_string) {
		&isError($error_string,'Cancel');
		return(1);
	}
}

sub isError {
	my $error_string = shift;
	my $text = shift;

	my $nag = $bigFrame->Dialog(-text => "$error_string",-buttons => [$text])->Show();
	return(1);
}

	
sub personnelUpdate{
	my @cmds;

	&checkNulls(
$last_name,$first_name,$middle_name,$address,$city,$state,$postal_code,$country,$telephone1,$telephone2,$email1,$email2,$fax1,$fax2,$personnel_id);
	my $sqlcmd = &get_cmd(409,
$last_name,$first_name,$middle_name,$address,$city,$state,$postal_code,$country,$telephone1,$telephone2,$email1,$email2,$fax1,$fax2,$personnel_id);
	push @cmds, $sqlcmd;
	
	&getSite_id();
#parse personnel_role_id's and res_module_id's  and loop the following
	$personnel_role_id =~ s/\s//g;
	$res_module_id =~ s/\s//g;
	my @job = split /,/,$personnel_role_id;
	my @modules = split /,/,$res_module_id;
	if (&checkSites($site_id)) { return(); }
	if (&checkMods(@modules)) { return(); }
	if (&checkJobs(@job)) { return(); }
	$sqlcmd = &get_cmd(410,$personnel_id);
	push @cmds, $sqlcmd;
	foreach my $id (@job) {
		foreach my $mod_id (@modules) {
			$sqlcmd = &get_cmd(411,$site_id,$personnel_id,$id,$mod_id);
			push @cmds, $sqlcmd;
		}
	}
	&mailingList('0',@cmds);
	#&isError("The database has been changed!",'OK');
}

sub check_parent {
	my ($res_site_parent_id,$res_sitetype_id) = @_;

	if (($res_site_parent_id eq 'null') && ($res_sitetype_id > 1)) {
		&isError("You will need to choose a research site parent id number\nClick on 'get parent'",'Cancel');
		return(1);
	} 
}

sub stationInsert{
	my @cmds;

	my $sqlcmd = &get_cmd(412,$site_code);
	($site_id, my $foo) = &query_DB($sqlcmd,'array',$dbh);

	$res_site_id = &getID('research_site','res_site_id',$res_site_id);

	&checkNulls(
$res_site_name,$res_site_code,$res_sitetype_id,$res_site_parent_id,$site_id,$res_site_id);

# SPECIAL CASE: if user types in 3,4 for res_sitetype_id switch it to a 5
	$res_sitetype_id =~ s/.+,.+/5/;

	return if &check_parent($res_site_parent_id,$res_sitetype_id);
	$sqlcmd = &get_cmd(413,
$res_site_name,$res_site_code,$res_site_parent_id,$site_id,$res_site_id);
	push @cmds, $sqlcmd;
	
	@cmds = &multi_sitetype($res_sitetype_id,@cmds);
	#$sqlcmd = &get_cmd(414,$res_site_id,$res_sitetype_id);
	#push @cmds, $sqlcmd;

	@cmds = &multi_modules($res_site_id,@cmds);

	&next(@cmds);
	$parent_flag = 0;
}

sub stationUpdate{
	my (@cmds,$sqlcmd);

	$sqlcmd = &get_cmd(416,$site_code);
	($site_id, my $foo) = &query_DB($sqlcmd,'array',$dbh);
	
	@cmds = &multi_modules($res_site_id,@cmds);
	
	$sqlcmd = &get_cmd(443,$res_site_id);
	push @cmds, $sqlcmd;

# SPECIAL CASE: if user types in 3,4 for res_sitetype_id switch it to a 5
	$res_sitetype_id =~ s/.+,.+/5/;
	@cmds = &multi_sitetype($res_sitetype_id,@cmds);

	#if ($res_sitetype_id != $sitetype_change) { 
	#	&isError("You will need to select a research site parent id number(click on 'get parent')",'Cancel');
	#	return();
	#}
	return if &check_parent($res_site_parent_id,$res_sitetype_id);

	$sqlcmd = &get_cmd(421,$res_site_name,$res_site_code,$res_site_parent_id,$site_id,$res_site_id);
	push @cmds, $sqlcmd;

	&next(@cmds);
	$parent_flag = 0;
}

sub multi_sitetype {
	my $res_sitetype_id = shift;
	my @cmds = @_;
	if ($res_sitetype_id == 5) { 
		$sqlcmd = &get_cmd(414,$res_site_id,3);
		push @cmds, $sqlcmd;
		$sqlcmd = &get_cmd(414,$res_site_id,4);
		$main::res_sitetype_id = '3,4';
		#&fill_station($midFrame);
	} else {
		$sqlcmd = &get_cmd(414,$res_site_id,$res_sitetype_id);
	}
	push @cmds, $sqlcmd;
	return(@cmds);
}

sub label_entry{
	my ($frame,$words,$pointer,$i,$state) = @_;
	if (!$state) {$state = 'normal';}
	
	my $xLabel = $frame->Label(
			-text => "$words",
			-width => 50)->
		grid(-row => $i, -column => 1);
	my $xEntry = $frame->Entry(
			-width => 40, 
			-state => $state,
			-textvariable => $pointer)->
		grid(-row => $i, -column => 2);
	return($xLabel);
}

sub go_next {
	my ($last, $next) = @_;
	
	$last->packForget();
	$next->pack(-side =>'top', -anchor=>'center', -expand=>1);
}

sub fill_buttons {
# give button the frame and a list of button name - button subroutine references

	my ($buttonFrame,@buttons) = @_;
	for (my $i = 0; $i < $#buttons; $i=$i+2) {
		$buttonFrame->Button(-text => $buttons[$i],
				-width => '10',
				-command => $buttons[$i+1])->
			grid(-column => $i, -row => 1);
	}
}

sub myDialog {

# this dialog is used to prompt the user for options
# it is called when we need to:
#	1) find the parent while adding a new station
#	2) find the site while updating site
#	3) find the person while updating personnel
# 	4) It is called twice while updating a station
# 		a) first to get the site
#		b) then the station

	my ($title,$sitetype) = @_;
	my ($sqlcmd,@choices);
	my $dialog = MainWindow->new();
	$dialog->title($title);
	$dialog->resizable(0,0);
	$dialog->grabGlobal();
	my $dialogLB = $dialog->Scrolled("Listbox", 
									-width => 42,
									-selectmode => 'single',
									-scrollbars => 'e')->
										pack(-side => 'left');
		
	if ($title =~ /Parent/) {
		if ($sitetype == 2) {
			$sqlcmd = &get_cmd(424,$site_code,'1');
		} elsif ($sitetype == 3) {
			$sqlcmd = &get_cmd(424,$site_code,'2');
		} else {
			$sqlcmd = &get_cmd(424,$site_code,'5');
		}
	}

# If we are updating the stations we will need the res_sitetype_id 
	if ($title =~ /First/){
		$r_sitetype = 0;
		$dialog->Radiobutton(-text => 'All',
							 -value => 0,
							 -variable => \$r_sitetype)->
								pack();
		$dialog->Radiobutton(-text => 'Watersheds',
							 -value => 2,
							 -variable => \$r_sitetype)->
								pack();
		$dialog->Radiobutton(-text => 'Gauging Stations',
							 -value => 3,
							 -variable => \$r_sitetype)->
								pack();	
		$dialog->Radiobutton(-text => 'Met Stations',
							 -value => 4,
							 -variable => \$r_sitetype)->
								pack();	
	}

# Site
	if ($title =~ /Site/){
		$sqlcmd = &get_cmd(425);
	}

# Station
	if ($title =~ /Station/){
		my $dummy = $r_sitetype;
		if ($r_sitetype == 0) {
			$dummy = 4;}
		$sqlcmd = &get_cmd(426,$site_code,$r_sitetype,$dummy,$site_id);
	}

# Personnel
	if ($title =~ /Name/){
		$sqlcmd = &get_cmd(427);
	   	my @list = &query_DB($sqlcmd,'array',$dbh); 
		my $listsize = $#list / 3;
		for (my $i=0;$i<$listsize;) {
			my ($last,$first,$site) = splice @list,0,3;
			$choices[$i++] = "$last, $first ($site)";
		}
	} else {
		@choices = &getChoices($sqlcmd,'hash');
	}
	if (!$choices[0]) {$choices[0] = 'null';}
	$dialogLB->insert('end',@choices);
	$dialogLB->selectionSet(0);
	
	my $buttonFrame = $dialog->Frame()->pack();
	$buttonFrame->Button(-text => "Submit",
				-width => '10',
				-command => [ \&getAnswer, $title, $dialogLB, $dialog, @choices])->
					pack();
	$buttonFrame->Button(-text => "Cancel",
				-width => '10',
				-command => sub {$dialog->withdraw;$dialog->grabRelease;})->
					pack();
}

sub getAnswer {

# this sub gets the thing selected by myDialog
# then querys the data base to fill in the blanks
# it is called when we need to:
#	1) find the parent while adding a new station
#	2) find the site while updating site
#	3) find the person while updating personnel
# 	4) It is called twice while updating a station
# 		a) first to get the site
#		b) then the station

	my($title, $dialogLB, $dialog, @choices) = @_;
my ($huh) = $dialogLB->curselection; 
print $huh;
#my $what = $choices[${$dialogLB->curselection}]; 
my $what = $choices[$huh]; 
	my $sqlcmd;
	$dialog->withdraw;
	$dialog->grabRelease;
	
	if ($title =~ /Parent/){
		($res_site_parent_id,my $foo) = split /- /,$what,2;
		$parent_flag = 1;
	}
	
	if ($title =~ /Site/){
		($site_code,$site_name) = split /- /,$what,2;
		$sqlcmd = &get_cmd(428,$site_code,$site_name);
		($site_id,$loc1,$loc2,$latitude_dec,$longitude_dec,$hydro_data_url,$clim_data_url,$usgs_data_url,$site_url) = &query_DB($sqlcmd,'array',$dbh);
		
		$sqlcmd = &get_cmd(440,$site_id);
		@modules = &query_DB($sqlcmd,'array',$dbh);
		$res_module_id = join ', ', @modules;
		if ($title =~ /First/){
			&myDialog('Pick a Station');
		}
	}
	
	if ($title =~ /Station/){ ($res_site_code,$res_site_name) = split /- /,$what,2;
		$sqlcmd = &get_cmd(429,$res_site_code,$res_site_name,$r_sitetype);
#		my $more = undef;
#		($res_site_id,$res_sitetype_id,$res_site_code,$res_site_parent_id,$more) = &query_DB($sqlcmd,'array',$dbh);
#		if ($more) {$res_sitetype_id = '3,4';}
		my @answer = &query_DB($sqlcmd,'array',$dbh);
		($res_site_id,$res_sitetype_id,$res_site_code,$res_site_parent_id) =				splice(@answer,0,4);
		while (@answer) {
			my ($w,$x,$y,$z) = splice(@answer,0,4);
			if ($x != $res_sitetype_id) {
				$res_sitetype_id .= ",$x";
			}
		}

		$sqlcmd = &get_cmd(441,$res_site_id);
		@modules = &query_DB($sqlcmd,'array',$dbh);
		$res_module_id = join ', ', @modules;
  
		$sitetype_change = $res_sitetype_id;
		$module_change = $res_module_id;
	}
	
	if ($title =~ /Name/){

		my ($huh) = $dialogLB->curselection; 
		#$what = $choices[$dialogLB->curselection];
		$what = $choices[$huh];
		($last_name,$first_name) = split /, /,$what,2;
		$first_name =~ s/(.*) \((...)\)/$1/;
		$site_code = $2;
		&getSite_id();
		$sqlcmd = &get_cmd(430,$first_name,$last_name,$site_id);
		($personnel_id,$middle_name,$address,$city,$state,$postal_code,$country,$telephone1,$telephone2,$email1,$email2,$fax1,$fax2,$site_id,$res_module_id) = &query_DB($sqlcmd,'array',$dbh);

		$sqlcmd = &get_cmd(431,$first_name,$last_name,$site_id);
		@job = &query_DB($sqlcmd,'array',$dbh);
		$personnel_role_id = join ', ', @job;

		$sqlcmd = &get_cmd(432,$first_name,$last_name,$site_id);
		@modules = &query_DB($sqlcmd,'array',$dbh);
		$res_module_id = join ', ', @modules;

		&getSite_code();
	}
}

sub checkNulls{

# This silly little hack just deals with the -w switch when the user leaves
# fields blank when adding a new site,station, or person.

	foreach my $thing (@_){
		if (!$thing){$thing = '';}
	}
}

## MAILINGLIST
# this needs to delete personnel_mailing_list and rebuild it any time the 
# personnel table is changed. Furthermore it must select the email addresses
# for each mailing_list_id and save them to a files which will then be ftp'd
# to a remote server. All the nessisary FTP settings are in 
# the climdb.conf file, editable with CHUMP.

sub mailingList {
	my $del;
	($del,@cmds) = @_;
	my ($sqlcmd,$name);
	
	for (433..437) {
		$sqlcmd = &get_cmd($_);
		push @cmds, $sqlcmd;
		#$rv = &query_DB($sqlcmd,'do',$dbh);
	}
	if ($del) {
		push @cmds, &delete('personnel','personnel_id',$personnel_id);}
	&next(@cmds);
	
	$sqlcmd = &get_cmd(438);
	my @file_list = &query_DB($sqlcmd,'array',$dbh);
	for (my $i=0;$i<4;$i++) {
		$sqlcmd = &get_cmd(439,$i);
		my @name_list = &query_DB($sqlcmd,'array',$dbh);
		open (FILE, ">mailing_lists\\$file_list[$i]") or die "Can't open mailing_lists\\$file_list[$i]: $!\n";
		foreach $name (@name_list) {
			if ($name) {print FILE "$name\n";}}
		close FILE;
	}
	my $message = $bigFrame->Dialog(
		-text => "Would you like to update the mailing list at $control{ftp_server}", 
		-title => "FTP'ing to $control{ftp_server}",
		-default_button => 'Yes',
		-buttons => [qw/Yes No/] )->Show();
	if ($message eq 'Yes') {
		my @answer = &ftp(@file_list);
		&time_dialog(@answer);
	}
}

## TIME_DIALOG
# print the last update time of last file ftp'd

sub time_dialog {
	my $time = shift;
	my @file_list = splice(@_,0,4);
	my $file_list = join ', ',@file_list;

	if ($file_list) {	
		#my @time = localtime($time);
	
		#if ($time[1] < 10) {$time[1] = '0'.$time[1];}
		#if ($time[2] > 12) { $time[2] = ($time[2] - 12); }
#		my $local = $time[2].':'.$time[1] .' on '. ($time[4]+1) ."/". $time[3];
		
		#&isError("The latest version of the files [$file_list] at $control{ftp_server} are dated $local ",'OK');
		&isError("The latest version of the files [$file_list] have been sent to $control{ftp_server}.",'OK');
	} else {
		&isError("Error: $! ",'Cancel');
	}
}

## FTP

sub ftp {
	my @files = @_;
	my $reply;
	my $ftp = (Net::FTP->new($control{ftp_server}, Debug => 0) ); 
	if (!$ftp) {
		&isError("Can not connect at $control{ftp_server}",'Cancel');
	} else {
		if (!$ftp->login($control{ftp_user},$control{ftp_password}) ) {
			&isError("Can not login at $control{ftp_server}",'Cancel'); }
			
		if ($ftp->cwd($control{ftp_location}) ) {
		
			foreach my $file (@files) {
				$file = 'mailing_lists\\'.$file;
				push @remote, ($ftp->put($file) or
					&isError("Problem transfering $file",'Cancel') );
				$reply = $ftp->mdtm($file);
			}
		}
	}
	$ftp->quit;
	return($reply,@remote);
}

1;
