#! perl -w
use FindBin qw($Bin);
use lib "$Bin/bin";
$|++;

open (POO,">$Bin/log/query.log");

# Kyle Kotwica 11-2003
# Version 1.0
# A collection of dynamic WWW pages disiminating various products from the 
# CLIMDB database
#
# The sorting should really be done client side but its just to much of a 
# pain to deal with different browsers.

use strict;
use CGI;
use DBI;
use clim_lib;
use sql_cmd;
use File::Temp qw/tempfile tempdir/;
use CGI::Carp qw(fatalsToBrowser);

#read control file 
my %control = &read_control();	
my ($xml,$xsl);
my ($XML_fh,$XSL_fh);

#connect with database
my $dbh = DBI->connect($control{data_source},$control{data_user},$control{data_password}) || print "Connect failure in $0 \n";

#create CGI object
my $cgi = new CGI;

my $use = $cgi->param('use');
my $module = $cgi->param('module');
my $sort = $cgi->param('sort');
my $order = $cgi->param('order');
my $data_type = $cgi->param('type');
if ($data_type eq '') {$data_type = 'text';}
if ($order eq '') {$order = 'ascending';}

if ($use eq 'sites') { #501
	&sites();
} elsif ($use eq 'stations') { #502
	&stations();
} elsif ($use eq 'variables') { #503
	&variables();
} elsif ($use eq 'people'){ #504
	&people();
} elsif ($use eq 'qc'){ #505 
	&qc();
} 

$dbh->disconnect;
close $XSL_fh if $XSL_fh;
close $XML_fh if $XML_fh;
# people is good old fashoned cgi so dont bother redirecting
if ($use ne 'people') {
	print $cgi->redirect("$xml",-nph=>1); }

	
sub mk_temp {
	unlink <$Bin\\temp\\*.xml>; 
	unlink <$Bin\\temp\\*.xsl>; 
	($XML_fh,$xml) = tempfile(SUFFIX => '.xml', DIR => 'temp', UNLINK => 0);
	open($XML_fh,">$xml") || die "Cant open xml file";
	($XSL_fh,$xsl) = tempfile(SUFFIX => '.xsl', DIR => 'temp', UNLINK => 0);
	open($XSL_fh,">$xsl") || die "Cant open xsl file";
	$xsl =~ s/\\/\//;
	$xml =~ s/\\/\//;
}


sub stations {
	&mk_temp();	

	my ($style,$name) = &style_sheet();
	&mk_xsl($sort,$use,$style,$name);
	my $operator = '=';
	if ($module == 0) {
		   $operator = '>'; }	

	my $sqlcmd = &get_cmd('502',"$module","$operator");
	my $sth = $dbh->prepare("$sqlcmd");
	$sth->execute || print "execute failure: ".$sth->errstr;
	print $XML_fh <<EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="$control{web}$xsl"?>

<info xmlns:HTML="http://www.w3.org/Profiles/XHTML-transitional">
  <stations>
EOF
;
	while (my $huh = $sth->fetchrow_arrayref ) {
		$$huh[4] = &dates($$huh[4]);
		$$huh[5] = &dates($$huh[5]);
		$$huh[6] = &dates($$huh[6]);
		print $XML_fh <<EOF
	<station_item>
		<code>$$huh[0]</code>
		<type>$$huh[1]</type>
		<station>$$huh[2]</station>
		<name>$$huh[3]</name>
		<first>$$huh[4]</first>
		<recent>$$huh[5]</recent>
		<last>$$huh[6]</last>
	</station_item>
EOF
;
	} 
	print $XML_fh "  </stations>\n</info>\n";
}

# style_sheet
# sets the style sheet depending on modules
# 
sub style_sheet {
	my $module = $cgi->param('module');
	my ($style,$fancy_name); 

	if ($module == 1) { 
		$style = $control{climdb_css};
		$fancy_name = 'LTER';
	} elsif ($module == 2) { 
		$style = $control{hydrodb_css};
		$fancy_name = 'USFS';
	} elsif ($module == 3) { 
		$style = $control{usgsdb_css};
		$fancy_name = 'USGS';
	} elsif ($module == 0) {
		$style = $control{all_css};
		$fancy_name = 'ClimDB/HydroDB';
	}
	
	return ($style,$fancy_name);
}

sub people {
	my $use = shift;
	my $last_site = '';
	my $ml_name;

	my $sqlcmd = &get_cmd('504',$module);
	my $sth = $dbh->prepare("$sqlcmd");
	$sth->execute || print "execute failure: ".$sth->errstr;
	my ($style,$name) = &style_sheet();
	my $lc_name = lc($name);

	print $cgi->header(-expires=>'now'),
	$cgi->start_html(-title=>"$name Contacts",-author=>'kyle.kotwica@comcast.net',-style=>{'src'=>"$style"},);
	print "<H1>Participating $name Contacts</H1>";

	if ($lc_name =~ 'usfs'||'lter') {
		if ($lc_name eq 'lter') {
			$ml_name = 'climdb';
		} elsif ($lc_name eq 'usfs') {
			$ml_name = 'hydrodb';
		}
	}
	
	print "<P>The following lists sites and contact persons for the $name database:</P><UL>";

#	print "<B>Participating $name Sites</B><P>The following lists sites and contact persons for the $name database:</P>\n<UL>\n";
	while (my $huh = $sth->fetchrow_arrayref ) {
		if ($$huh[0] ne $last_site) {
			if ($last_site) {
				print "</UL><BR>\n"; }
			if (($$huh[5]) && ($$huh[5] !~ /^    /)) {
				print "\t<LI>$$huh[0] - <A HREF=$$huh[5]><B>$$huh[1]</B></A>\n\t\t<UL>\n";
			} else {
				print "\t<LI>$$huh[0] - <B>$$huh[1]</B>\n\t\t<UL>\n"; }
		}
		if ($$huh[4]) {
			print "\t\t\t<LI><A HREF=\"mailto:$$huh[4]\">$$huh[2]</A> - $$huh[3]</LI>\n";}
		$last_site = $$huh[0];
	} 
	print "</UL>\n";
}
sub qc {
	&mk_temp();	
	
	my ($style,$name) = &style_sheet();
	&mk_xsl($sort,$use,$style,$name);
	my $operator = '=';
	if ($module == 0) {
		   $operator = '>'; }	
	
#drop tables
	my $sqlcmd = &get_cmd('501a','#qcmin');
	&query_DB($sqlcmd,'do',$dbh);
	$sqlcmd = &get_cmd('501a','#qcmax');
	&query_DB($sqlcmd,'do',$dbh);
	$sqlcmd = &get_cmd('501a','#qc');
	&query_DB($sqlcmd,'do',$dbh);
	
# make #qc
	$sqlcmd = &get_cmd('505a',$module,$operator);
	&query_DB($sqlcmd,'do',$dbh);
	$sqlcmd = &get_cmd('505b',$module,$operator);	
	&query_DB($sqlcmd,'do',$dbh);
	$sqlcmd = &get_cmd('505c');	
	&query_DB($sqlcmd,'do',$dbh);
	$sqlcmd = &get_cmd('505d');	
	
	my $sth = $dbh->prepare("$sqlcmd");
	$sth->execute || print "execute failure: ".$sth->errstr;
	print $XML_fh <<EOF
<?xml version="1.0"?>

<info xmlns:HTML="http://www.w3.org/Profiles/XHTML-transitional">
  <variables>
EOF
;
	while (my $huh = $sth->fetchrow_arrayref ) {
		$$huh[3] = &dates($$huh[3]);
		$$huh[4] = &dates($$huh[4]);
		$$huh[5] = &dates($$huh[5]);
		print $XML_fh <<EOF
	<variable_item>
		<code>$$huh[0]</code>
		<name>$$huh[1]</name>
		<variable>$$huh[2]</variable>
		<begin>$$huh[3]</begin>
		<end_date>$$huh[4]</end_date>
		<last>$$huh[5]</last>
		<qcmin>$$huh[6]</qcmin>
		<qcmax>$$huh[7]</qcmax>
	</variable_item>
EOF
;
	} 
	print $XML_fh "  </variables>\n</info>\n";
}

sub sites {
	&mk_temp();	
	
	my ($style,$name) = &style_sheet();
	&mk_xsl($sort,$use,$style,$name);
#drop tables
	my $sqlcmd = &get_cmd('501a','#metstn');
	&query_DB($sqlcmd,'do',$dbh);
	$sqlcmd = &get_cmd('501a','#gsstn');
	&query_DB($sqlcmd,'do',$dbh);
	$sqlcmd = &get_cmd('501a','#all_sites');

	if ($module == 0) {
# make #all_sites
		$sqlcmd = &get_cmd('501b');
		&query_DB($sqlcmd,'do',$dbh);
# make #metstn
		$sqlcmd = &get_cmd('501c');
		&query_DB($sqlcmd,'do',$dbh);
# make #gsstn
		$sqlcmd = &get_cmd('501d');
		&query_DB($sqlcmd,'do',$dbh);
# get command for 3 way join
		$sqlcmd = &get_cmd('501e');
	} elsif ($module ==1) {
# make #metstn
		$sqlcmd = &get_cmd('501f',$module);
		&query_DB($sqlcmd,'do',$dbh);
# make #gsstn
		$sqlcmd = &get_cmd('501g',$module);
		&query_DB($sqlcmd,'do',$dbh);
		$sqlcmd = &get_cmd('501h');
	} elsif ($module ==2) {
# make #metstn
		$sqlcmd = &get_cmd('501f',$module);
		&query_DB($sqlcmd,'do',$dbh);
# make #gsstn
		$sqlcmd = &get_cmd('501g',$module);
		&query_DB($sqlcmd,'do',$dbh);
		$sqlcmd = &get_cmd('501i');
	} elsif ($module ==3) {
# for USGS
		$sqlcmd = &get_cmd('501j');
	}
	my $sth = $dbh->prepare("$sqlcmd");
	$sth->execute || print "execute failure: ".$sth->errstr;
	print $XML_fh <<EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="$control{web}$xsl"?>

<info xmlns:HTML="http://www.w3.org/Profiles/XHTML-transitional">
  <sites>
EOF
;
	if ($module == 3) {
		while (my $huh = $sth->fetchrow_arrayref ) {
			$$huh[4] = &dates($$huh[4]);
			$$huh[5] = &dates($$huh[5]);
			$$huh[6] = &dates($$huh[6]);
			print $XML_fh <<EOF
	<site_item_usgs>
		<code>$$huh[0]</code>
		<name>$$huh[1]</name>
		<number>$$huh[2]</number>
		<first>$$huh[4]</first>
		<recent>$$huh[5]</recent>
		<last>$$huh[6]</last>
	</site_item_usgs>
EOF
;
		}
	} else {
		while (my $huh = $sth->fetchrow_arrayref ) {
			$$huh[4] = &dates($$huh[4]);
			$$huh[5] = &dates($$huh[5]);
			$$huh[6] = &dates($$huh[6]);
			print $XML_fh <<EOF
		<site_item>
			<code>$$huh[0]</code>
			<name>$$huh[1]</name>
			<number>$$huh[2]</number>
			<number2>$$huh[3]</number2>
			<first>$$huh[4]</first>
			<recent>$$huh[5]</recent>
			<last>$$huh[6]</last>
		</site_item>
EOF
;
		}
	} 
	print $XML_fh "  </sites>\n</info>\n";
}


sub variables {
	&mk_temp();	
	
	my ($style,$name) = &style_sheet();
	&mk_xsl($sort,$use,$style,$name);
	my $operator = '=';
	if ($module == 0) {
		   $operator = '>'; }	
	
	my $sqlcmd = &get_cmd('503',$module,$operator);
	my $sth = $dbh->prepare("$sqlcmd");
	$sth->execute || print "execute failure: ".$sth->errstr;
	print $XML_fh <<EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="$control{web}$xsl"?>

<info xmlns:HTML="http://www.w3.org/Profiles/XHTML-transitional">
  <variables>
EOF
;
	while (my $huh = $sth->fetchrow_arrayref ) {
		$$huh[3] = &dates($$huh[3]);
		$$huh[4] = &dates($$huh[4]);
		$$huh[5] = &dates($$huh[5]);
		print $XML_fh <<EOF
	<variable_item>
		<code>$$huh[0]</code>
		<name>$$huh[1]</name>
		<variable>$$huh[2]</variable>
		<begin>$$huh[3]</begin>
		<end_date>$$huh[4]</end_date>
		<last>$$huh[5]</last>
	</variable_item>
EOF
;
	} 
	print $XML_fh "  </variables>\n</info>\n";
}


sub dates {
	my $date = shift;

	$date =~ s/(..)-(..)-(....)/$3-$1-$2/;
	return($date);
}

sub table_header {
	my ($width,$what,$label,$type) = @_;
my $head = "
<TH WIDTH=\'$width\' ALIGN='center'>
	<A HREF=\"$control{web}products.pl?use=$use&amp;module=$module&amp;sort=$what&amp;order=ascending&amp;type=$type\">
		<IMG SRC=\'$control{web}images/black_up.bmp\' border='0' ALT='ascending' />
	</A>
	<BR/>$label<BR/>
	<A HREF=\"$control{web}products.pl?use=$use&amp;module=$module&amp;sort=$what&amp;order=descending&amp;type=$type\">
		<IMG SRC=\'$control{web}images/black_down.bmp\' border='0' ALT='descending' />
	</A>
</TH>";
return $head;
}

sub variable_headers {
	my @head;
	push(@head,&table_header('100','site','Site','text'));
	push(@head,&table_header('200','name','Name','text'));
	push(@head,&table_header('320','variable','Variable','text'));
	push(@head,&table_header('125','begin','Earliest&#160;Data','number'));
	push(@head,&table_header('125','end_date','Latest&#160;Data','number'));
	push(@head,&table_header('125','last','Last&#160;Update','number'));
	
	return @head;
}

sub station_headers {
	my @head;
	push(@head,&table_header('100','site','Site','text'));
	push(@head,&table_header('225','type','Type','text'));
	push(@head,&table_header('125','station','Station','text'));
	push(@head,&table_header('325','name','Name','text'));
	push(@head,&table_header('125','first','Earliest&#160;Data','number'));
	push(@head,&table_header('125','recent','Latest&#160;Data','number'));
	push(@head,&table_header('125','last','Last&#160;Update','number'));
	
	return @head;
}

sub site_headers{
	my @head;
	push(@head,&table_header('100','site','Site','text'));
	push(@head,&table_header('325','name','Name','text'));
	if ($module == 1) {
		push(@head,&table_header('125','number','# of Met Stations','number'));
		push(@head,&table_header('125','number2','# of Hydro Stations','number'));
		push(@head,&table_header('125','first','Earliest Met Data','text'));
		push(@head,&table_header('125','recent','Latest Met Data','text'));
		push(@head,&table_header('125','last','Last Met Update','text'));
	} elsif ($module == 2) {
		push(@head,&table_header('125','number','# of Hydro Stations','number'));
		push(@head,&table_header('125','number2','# of Met Stations','number'));
		push(@head,&table_header('125','first','Earliest&#160;Hydro Data','text'));
		push(@head,&table_header('125','recent','Latest&#160;Hydro Data','text'));
		push(@head,&table_header('125','last','Last&#160;Hydro Update','text'));
	} elsif ($module == 3) {
		push(@head,&table_header('125','number','# of USGS Stations','number'));
		push(@head,&table_header('125','first','Earliest&#160;Data','text'));
		push(@head,&table_header('125','recent','Latest&#160;Data','text'));
		push(@head,&table_header('125','last','Last&#160;Update','text'));
	} elsif ($module == 0) {
		push(@head,&table_header('125','number','# of Hydro Stations','number'));
		push(@head,&table_header('125','number2','# of Met Stations','number'));
		push(@head,&table_header('125','first','Earliest&#160;Data','text'));
		push(@head,&table_header('125','recent','Latest&#160;Data','text'));
		push(@head,&table_header('125','last','Last&#160;Update','text'));
	}
	return @head;
}

sub mk_xsl {
	my ($sort,$use,$style,$name) = @_;
#	my $lower_name = lc($name);
	my @head;
	if ($use eq 'sites') {
		@head = &site_headers();
	} elsif ($use eq 'stations') {
		@head = &station_headers();
	} elsif ($use eq 'variables') {
		@head = &variable_headers();
	}

print $XSL_fh <<EOF
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
    <HTML>
      <HEAD>
	<LINK REL="stylesheet" TYPE="text/css" HREF="$control{web}$style"></LINK>
	<TITLE>Contributing $name $use</TITLE>
      </HEAD>
      
      <BODY>
		<!--script src="../bin/jumptop.js">
		</script-->

	     <H1>Contributing $name $use</H1>
	     <A HREF="http://www.fsl.orst.edu/climhy">Back to Data Access page</A><P/>
	     <FONT SIZE='-1'><I>Click on the up arrow to sort in ascending order and the down arrow for descending order.</I></FONT>
             <xsl:apply-templates select="info/$use"/>
      </BODY>
    </HTML>
  </xsl:template>
  
  <xsl:template match="$use">
    <TABLE CELLSPACING="10" BORDER="0">
	  <TR>
	  	@head
	  </TR>

      <xsl:apply-templates select="site_item_usgs">
      	<xsl:sort select="$sort" order="$order" data-type="$data_type"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="site_item">
      	<xsl:sort select="$sort" order="$order" data-type="$data_type"/>
      </xsl:apply-templates>
    </TABLE>
  </xsl:template>

  <xsl:template match="stations">
    <TABLE CELLSPACING="10" BORDER="0">
	  <TR>
	  	@head
	  </TR>

      <xsl:apply-templates select="station_item">
      	<xsl:sort select="$sort" order="$order" />
      </xsl:apply-templates>
    </TABLE>
  </xsl:template>

  <xsl:template match="variables">
    <TABLE CELLSPACING="10" BORDER="0">
	  <TR>
		@head
	  </TR>

      <xsl:apply-templates select="variable_item">
      	<xsl:sort select="$sort" order="$order"/>
      </xsl:apply-templates>
    </TABLE>
  </xsl:template>

  <xsl:template match="site_item_usgs">
    <TR>
      <TD ALIGN='center'><B><xsl:value-of select="code"/></B></TD>
      <TD ALIGN='left'><xsl:value-of select="name"/></TD>
      <TD ALIGN='center'><xsl:value-of select="number"/></TD>
      <TD ALIGN='center'><xsl:value-of select="first"/></TD>
      <TD ALIGN='center'><xsl:value-of select="recent"/></TD>
      <TD ALIGN='center'><xsl:value-of select="last"/></TD>
    </TR>
  </xsl:template>

  <xsl:template match="site_item">
    <TR>
      <TD ALIGN='center'><B><xsl:value-of select="code"/></B></TD>
      <TD ALIGN='left'><xsl:value-of select="name"/></TD>
      <TD ALIGN='center'><xsl:value-of select="number"/></TD>
      <TD ALIGN='center'><xsl:value-of select="number2"/></TD>
      <TD ALIGN='center'><xsl:value-of select="first"/></TD>
      <TD ALIGN='center'><xsl:value-of select="recent"/></TD>
      <TD ALIGN='center'><xsl:value-of select="last"/></TD>
    </TR>
  </xsl:template>

  <xsl:template match="station_item">
    <TR>
      <TD ALIGN='center'><B><xsl:value-of select="code"/></B></TD>
      <TD ALIGN='center'><xsl:value-of select="type"/></TD>
      <TD ALIGN='center'><xsl:value-of select="station"/></TD>
      <TD ALIGN='left'><xsl:value-of select="name"/></TD>
      <TD ALIGN='center'><xsl:value-of select="first"/></TD>
      <TD ALIGN='center'><xsl:value-of select="recent"/></TD>
      <TD ALIGN='center'><xsl:value-of select="last"/></TD>
    </TR>
  </xsl:template>

  <xsl:template match="variable_item">
    <TR>
      <TD ALIGN='center'><B><xsl:value-of select="code"/></B></TD>
      <TD ALIGN='center'><xsl:value-of select="name"/></TD>
      <TD ALIGN='center'><xsl:value-of select="variable"/></TD>
      <TD ALIGN='center'><xsl:value-of select="begin"/></TD>
      <TD ALIGN='center'><xsl:value-of select="end_date"/></TD>
      <TD ALIGN='center'><xsl:value-of select="last"/></TD>
    </TR>
  </xsl:template>
  
</xsl:stylesheet>
EOF
;

}
