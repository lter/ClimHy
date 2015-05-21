use strict;
use clim_lib;
use sql_cmd;
use FindBin qw($Bin);

# Kyle Kotwica 1-2003
# DIGESTING ROUTINE FOR HARVEST.
my (@args,$args);

my %control = &read_control();

sub SQL_report{
	my ($command,$rv,$dbh) = @_;
	
	if($rv == -1){
		print SQLLOG "ERROR: SQL command $command.\n";
		print "<H2>Error encountered while populating central database.</H2>\n";
		print SQLLOG $dbh->errstr;
		return(1);
	}
	else{
		print SQLLOG "Command $command $rv lines\n";
		return(0);
	}
}

sub dupe_report {
	my @dupes = @_;
	my $dupes = @dupes;
	$dupes = $dupes/3;


	if ($dupes[2]) {
		print SQLLOG "ERROR: You have $dupes duplicated records!\n";
		#print "<H2>Error encountered while populating central database.</H2>\n";
		print SQLLOG "You have $dupes duplicated records.\n";
		#print "<FONT COLOR=red>No updates have been made to the central database!</FONT><br>";
		for (my $i=0;$i<=$#dupes;$i=$i+3) {
			$dupes[$i+2] =~ s/..:..:..\....//;
			print SQLLOG "Duplicate at $dupes[$i],$dupes[$i+1],$dupes[$i+2]\n";
		}
		return(1);
	}
	return(0);
}

sub digest{
	@args = @_;
# if we are called from the cmd line we should disconnect from the database 
# when we are done. If we are called from harvest.pl then we shouldn't
	my $cmd_prompt = 'no';
	if ($args[0] ne 'harvest'){
		$cmd_prompt = 'yes';}
	else{
		$args = shift;}	

	my $dbh = shift;

	my $ok = 1;
	my $sqllog = "$Bin\\log\\sql.log";
	#unlink ($sqllog);
	my ($sqlcmd,$rv,$result);

	while ($args = shift) {	
		$args = uc($args);
		if ($cmd_prompt eq 'yes'){
			open (SQLLOG,">>$sqllog") or die "Can't open $sqllog: $!\n";
			print "\n\nRunning digestion routines on $args\n";
			print SQLLOG "\nRunning digestion routines on $args\n";
		}else{
			open (SQLLOG,">$sqllog") or die "Can't open -> $sqllog: $!\n";
			print SQLLOG "\nRunning digestion routines on $args\n";
		}
	
		for (my $i=201; $i<=222; $i++){
			my $j = 222 - $i;
			if ($j > 0) {print "$j...";}
			else {print "Done<B>\n";}
			if ($i == 203){
# Get SQL command
				my $file = $control{UNC}."\\data\\$args".".out";
				$sqlcmd = &get_cmd($i,$file);
			} else {
				$sqlcmd = &get_cmd($i);}
# Execute SQL command
			if ($i == 204) {
				my @dupes = &query_DB($sqlcmd,'array',$dbh);
				$rv = 1;
				if(&dupe_report(@dupes)==1) {
					$ok = 0;
					$sqlcmd = &get_cmd('201');
					&query_DB($sqlcmd,'do',$dbh);
					$sqlcmd = &get_cmd('205');
					&query_DB($sqlcmd,'do',$dbh);
				}	
			} else {
				$rv = &query_DB($sqlcmd,'do',$dbh); }
# stupid hack to deal with fatals on last digestion run
# really should fix this
			if ($i == 201) {$rv = 1;}
			if ($i == 202) {$rv = 1;}
			if ($i == 205) {$rv = 1;}
			if(&SQL_report($i,$rv,$dbh)==1){
				$ok = 0; }
# If you goofed, quit!
			if ($ok == 0) {last;}
		}
		
		if ($ok) {
			$result = 'Finished';
		} else {
			$result = 'Failed';
		}
		print SQLLOG "\n$result digestion on $args\n";
	}	
	if ($cmd_prompt eq 'yes'){
		$dbh->disconnect();} 
	close SQLLOG;
return($ok);
}	

1; 
