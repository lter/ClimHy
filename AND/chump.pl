#!c:\Perl\bin\perl.exe -w
open POO, ">log/query.log";

# NOTE TO MAINTAINER: In theory you should only have to change the 
# $control{control} variable in CLIMDB\clim_lib to run
# this elsewhere. But in theory you would think I could spell better.
use FindBin qw($Bin);
use lib "$Bin/bin";

use strict;
use Tk;
use Tk::Balloon;
use clim_lib;
use conf;
use display;

# IMPORTANT !!!
# CHUMP, CLIMDB, PLOT, SITEDB --- THE WHOLE FUNDME PROJECT MUST ALL BE ABLE TO
# ACCESS climdb.conf! climdb.conf should be in CLIMDB/
# &read_control is in clim_lib and holds the location of climdb.conf in the 
# variable $control{control}
my (%control) = &read_control();

# That was you final warning


my $dbh = DBI->connect($control{data_source},$control{data_user},$control{data_password}) || print "connect failure: \n";

my $verbose = 0;
my $debug = 0; 
my $on = 0;
my ($menuFrame,$mainFrame,$xFrame);
my  $mw = MainWindow->new;
$mw->geometry("700x600+40+40");
$mw->resizable(0,0);
$mw->title("ClimDB HydroDB Utility Management Program (CHUMP)");

$menuFrame = $mw->Frame(-height => '40',
						-width => 500,
						-borderwidth => 2,
						-relief =>'groove')->
	pack(-side => 'top', -anchor=>'w', -fill=>'x');
$mainFrame = $mw->Frame(-height => '400',-width => 500)->
	pack(-side => 'top', -anchor=>'center', -expand =>1);
	my $img = $mainFrame->Photo(-file => "images\\chump.gif");
	$mainFrame->Label(-image => $img, -width => 500)->pack();

$menuFrame->Menubutton(-text => 'File', 
				-tearoff => 0,
				-menuitems => [['command' => 'Configure Climdb',
							-underline => 0,
							-command => \&config ],
#							['command' => 'Schedule Autoharvest',
#							-underline => 0,
#							-command => \&schedule ], 
							['command' => 'Exit',
							-underline => 1,
							#-command => sub {$mw->destroy();}]])->
							-command => sub {$mw->exit;}]])->
	pack(-side => 'left', -anchor => 'n');
#you'll want to disconnect from the data base if someone exits

$menuFrame->Menubutton(-text => 'Add', 
				-tearoff => 0,
				-menuitems => [['command' => 'Add Site',
							-underline => 5,
							-command => [ \&manage , 'Add a Site'] ],
							['command' => 'Add Station',
							-underline => 5,
							-command => [ \&manage , 'Add a Station'] ],
							['command' => 'Add Personnel',
							-underline => 4,
							-command => [ \&manage , 'Add Personnel'] ]])->
	pack(-side => 'left', -anchor => 'n');
		 
$menuFrame->Menubutton(-text => 'Update', 
			-tearoff => 0,
			-menuitems => [['command' => 'Site Data',
							-underline => 5,
							-command => [ \&manage , 'Update a Site'] ],
							['command' => 'Station Data',
							-underline => 5,
							-command => [ \&manage , 'Update a Station'] ],
							['command' => 'Personnel Data',
							-underline => 4,
							-command => [ \&manage , 'Update Personnel']] ])->
	pack(-side => 'left', -anchor => 'n');

my $menuB = $menuFrame->Menubutton(-text => 'Options', -tearoff => 0)->
	pack(-side => 'left', -anchor => 'n');
$menuB->checkbutton(-label => 'Verbose',
					-command =>  [\&manage, 'None'],
					-variable => \$verbose,
					-underline => 0);
$menuB->checkbutton(-label => 'Debug',
					-command =>  [\&manage, 'None'],
					-variable => \$debug,
					-underline => 0);

my $bg_color;
$menuB = $menuFrame->Menubutton(-text => 'Colors')->pack(-side => 'left',
													  -anchor => 'n');
foreach (qw/red yellow green blue grey/) {
	$menuB->radiobutton(-label => $_,
						-command => sub {$mw->configure(-background => $bg_color);},
						-variable => \$bg_color,
						-value => $_);
}

$menuFrame->Menubutton(-text => 'Help', 
			-tearoff => 0,
			-menuitems => [['command' => 'About',
							-underline => 0,
							-command => \&about]])->
	pack(-side => 'right');
		 
MainLoop;

$dbh->disconnect();

###
### End of Main
###

sub manage{
	my ($type) = @_;
	if ($on == 1){
		$xFrame->packForget();}
	($on,$xFrame) = &display($type,$mw,$mainFrame,$dbh,$verbose,$debug);
}

my ($time,$date,$climdb,$hydrodb);

sub fill_schedule {
	my $id;
	system('at>at');
	open AT, "<at";
	while (<AT>) {
		if (/harvest/) {
#deal with multiple harvests in at (shouldn't ever happen but need to warn if does)
			my @list = split;
			$id = $list[0];
			$time = $list[3] . $list[4];
			$date = $list[2];
			my $dummy = splice(@list,0,8);
			while (@list) {
				my ($mod,$site) = splice(@list,0,2);
				if ($mod == 1) {
					$climdb = $climdb .' '. $site; }
				else {
					$hydrodb = $hydrodb .' '. $site; }
			}		
		}	
	}
	close AT;
	unlink 'at';
	return($id);
}

sub schedule {
	my $sched;
	if (!Exists $sched){
		my $id = &fill_schedule();
		$sched = MainWindow->new();
		$sched->title('Schedule Autoharvest');
		$sched->resizable(0,0);
	
		my $entryFrame = $sched->Frame(
			-relief => 'raised',
			-borderwidth => 5)->
				pack();
		my $buttonFrame = $sched->Frame()->
				pack();
				
		my $xLabel = &label_entry($entryFrame,"Day of the month",\$date,2);
		my $b = $entryFrame->Balloon();
		$b->attach($xLabel,
			-balloonmsg => "Entering a 1 would cause the harvest to run\nautomatically on the first day of each month",
			-initwait => 1);

		$xLabel = &label_entry($entryFrame,"Time",\$time,3);
		$b = $entryFrame->Balloon();
		$b->attach($xLabel,
			-balloonmsg => "24 hour time or specify am/pm \n(e.g. 14:00 or 2:12pm)",
			-initwait => 1);
		
		$xLabel = &label_entry($entryFrame,
				"List of sites for climDB",\$climdb,4);
		$b = $entryFrame->Balloon();
		$b->attach($xLabel,
			-balloonmsg => "Use three letter site code\n(e.g. AND SGS NTL)",
			-initwait => 1);
		
		$xLabel = &label_entry($entryFrame,
				"List of sites for hydroDB",\$hydrodb,5);
		$b = $entryFrame->Balloon();
		$b->attach($xLabel,
			-balloonmsg => "Use three letter site code\n(e.g. AND SGS NTL)",
			-initwait => 1);
		
		$buttonFrame->Button(-text => 'Schedule',
						-relief => 'sunken',
						-width => '10',
						-borderwidth => '4',
						-background => 'green',
						-command => [\&runAT, $sched])
				->pack();
		$buttonFrame->Button(-text => 'Remove',
						-relief => 'sunken',
						-width => '10',
						-borderwidth => '4',
						-background => 'red',
						-command => [\&deleteAT, $sched, $id]) 
				->pack();
		$buttonFrame->Button(-text => 'Exit',
						-relief => 'sunken',
						-width => '10',
						-borderwidth => '4',
						-background => 'grey',
						-command => sub {$sched->destroy();})
				->pack();
	}
	else {
		$sched->deiconify();
		$sched->raise();
	}
}

sub runAT {
	my $sched = shift;
	my ($hydro,$clim);
	$time =~ s/ //;
	if ($climdb) {
		my @climdb = split(' ', $climdb);
		$clim = ' 1 ' . join (' 1 ',@climdb);}
	if ($hydrodb) {
		my @hydrodb = split(' ', $hydrodb);
		$hydro = ' 2 ' . join (' 2 ',@hydrodb);}
	if (!$hydro) {$hydro = '';}
	if (!$clim) {$clim = '';}
	open ATBAT, '>.\temp\at.bat' or die;
	#print ATBAT "H:\ndir \\\\GINKGO\\lter\\climdb\\temp\\>\\\\GINKGO\\lter\\climdb\\temp\\test1.out\nC:\n";
	print ATBAT "H:\nH:\\climhy\\harvest.pl -c $clim $hydro\nC:\n";
	system("AT $time /next:$date \\\\GINKGO\\lter\\climhy\\temp\\at.bat");
	#system("AT $time cmd /c \\\\GINKGO\\lter\\climdb\\temp\\at.bat^>\\\\GINKGO\\lter\\climdb\\temp\\test.out");
	$sched->destroy();
}

sub deleteAT {
	my $sched = shift;
	my $id = shift;
	print "AT $id /delete /yes\n";
	system("AT $id /delete /yes");
	($time,$date,$climdb,$hydrodb ) = '';
	$sched->destroy();
}

sub makeEntry2 {
	my ($entryFrame,$text,$variable,$row) = @_;

	&makeLabel($entryFrame,$text,50,$row,1);
	$entryFrame->Label(
		-text => $text,
		-width => 50)->
			grid(-row => $row, -column => 1);
	$entryFrame->Entry(
		-width => 40, 
		-textvariable => $variable)->
			grid(-row => $row, -column => 2);

}

sub about{
	my $dialog = MainWindow->new();
	$dialog->title('About CHUMP');
	$dialog->resizable(0,0);
	my $img = $dialog->Photo(-file => "images\\danteBW.gif");
	my $frame = $dialog->Frame(-background => 'green')->pack();
	my $text = $frame->Text(-borderwidth => 14,
				-relief =>'groove',
				-font => 'Bard 12 normal',
				-background => 'yellow',
				-padx => 50,
				-pady => 50,
				-height => 13,
				-width => 80,)->pack(-fill => 'x');
	$frame->Button(-text => 'OK',
					-relief => 'sunken',
					-image => $img,
					-borderwidth => '4',
					-background => 'green',
					-command => sub {$dialog->destroy();})->pack();
	$text->tagConfigure('bold',-font =>"{Courier New} 22 {bold}");
	$text->insert('end', 
"\tFUNDME CHUMP (version 1.0)
Climdb Hydrodb Utility Management Package",'bold');
	$text->insert('end',
"\n\nCopyright 2002 Kyle Kotwica
All Rights reserved.\n
CHUMP is a utility designed to be used with FUNDME program.\n
Warning: This computer program is protected by copyright law and international treaties,
not to mention Dante and Mozart. Unauthorized reproduction or distribution of this program,
or any portion of it, may result in having Dante bite you in the ass.");
}
