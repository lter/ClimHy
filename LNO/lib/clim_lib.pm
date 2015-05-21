use strict;
use DBI;


## READ_CONTROL
## Reads climdb.conf file. This file holds special variables that might change
## due to porting, user preferences .... It's an ASCII file delimited with a
## '=' 
 
sub read_control{
	my %control;

# IMPORTANT: The next $control{control} variable has to point to the 
# climdb.conf file. climdb.conf holds all of the changable parameters for 
# the intire FUNDME package. If I can't find this file - your screwed!
# This is the only user editable line in the FUNDME package, all other 
# variables can be changed using CHUMP

# The climdb.conf file needs to be read by all programs in the FUNDME group.
# Some of these files are not on the local machine so we need both absolute 
# (UNC) path names and relative path names to the climbb.conf file.
	$control{control} = '/var/www/climhy/conf/climdb.conf';
#JAMES EDITED
	if (!open (CONTROL,"<$control{control}")) {
		$control{control} = '/conf/climdb.conf';
		if (!open (CONTROL,"<$control{control}")) {
			$control{control} = '/conf/climdb.conf';
			open (CONTROL,"<$control{control}")	or die "Can't open $control{control}: $!Climdb.pl needs an associated control file to recieve instructions from.\n";	}
	}

	while (<CONTROL>){
		if (!/^#/){
			chop;
			(my $name,my $value) = split (/=/,$_);
			$value =~ s/\015//;
			$control{$name} = $value;
		}
	}
	close CONTROL;
	return(%control);

}

# QUERY_DB 
# useses the DBI and an user supplied SQL command to query the database
# when supplied with a second argument 'hash' the function returns a hash
# if 'array' the function returns an array.
# If 'sort' the sqlcmd should select 3 things (key,value, and sort_order)
# sort_order will be appended to the key then the calling code can sort the 
# hash on keys and strip off the sort_order using; 
# 			($crap,$real_key) = split('\.0',$key);
# NOTE: $dbh->connect before calling this code. It would also be nice to 
# disconnect somewhere.

sub query_DB(){
	my ($sqlcmd,$type,$dbh) = @_;
	my ($sth,$key,$value,$sort_order,%hash_it,@eat_it,@get_it);

	if ($type eq 'hash'){
		$sth=$dbh->prepare($sqlcmd) || print "prepare failure: " . $dbh->errstr;
		$sth->execute || print "execute failure: ".$sth->errstr;
		while (($key,$value) = $sth->fetchrow_array){
			$hash_it{$key} = $value;}
		return (%hash_it);
	
	} elsif($type eq 'array') {
		$sth=$dbh->prepare($sqlcmd) || print "prepare failure: " . $dbh->errstr;
		$sth->execute || print "execute failure: ".$sth->errstr;
		while (@get_it = $sth->fetchrow_array){
			push (@eat_it,@get_it);}
		return (@eat_it);
	
	} elsif($type eq 'do') {
		my $rv = $dbh->do($sqlcmd)|| return(-1); 
		return ($rv);

	} elsif ($type eq 'sort') {
		$sth=$dbh->prepare($sqlcmd) || print "prepare failure: " . $dbh->errstr;
		$sth->execute || print "execute failure: ".$sth->errstr;
		while (($key,$value,$sort_order) = $sth->fetchrow_array){
			$key = $sort_order . '.0' . $key;
			$hash_it{$key} = $value;}
		return (%hash_it);
	} elsif ($type eq 'value') {
		$sth=$dbh->prepare($sqlcmd) || print "prepare failure: " . $dbh->errstr;
		$sth->execute || print "execute failure: ".$sth->errstr;
		@get_it = $sth->fetchrow_array;
		return $get_it[0];
	}	
}


## PRINT_HASH
# used for debugging, give me a reference to as many hashs as you got.
sub print_hash() {
	my $href;
	my ($var,$val);
	foreach $href (@_){
		foreach $var (keys(%$href)) {
    			$val = $$href{$var};
   			print "$var=\"$val\"\n";
		}
	}
}


sub print_array(){
	my $col = shift;
	
	while (@_) {
		my @row = splice(@_,0,$col);
		foreach my $thing (@row){
			if (!$thing) {$thing = 'NULL';}
			$thing =~ s/(.*?):00.000$/$1/;
			print "$thing\t";
		}
		print "\n";
	}
}

sub feedback {
	my $prg = shift;
	my $title = shift;

print <<EOF
<P><HR><P>
The ClimDB/HydroDB administrators appreciate your comments and suggestions.
<P><P>
<FORM METHOD="post" ACTION="feedback.pl" ENCTYPE="application/x-www-form-urlencoded">
<INPUT TYPE='hidden' NAME='prg' VALUE='$prg'>
<INPUT TYPE='hidden' NAME='title' VALUE='$title'>
<P><INPUT TYPE=submit VALUE='Feedback?'>
</form>

EOF
;
	
}
1;
