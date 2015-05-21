#! perl -w
## sitePDF.pl
##
# Version 2.0
## Kyle Kotwica 1-2004
## Takes the contents of a sites metadata and spits it out in XML to be used
## by a XSLT to convert to fo's for fop. Then calls fop, makes the pdf and 
## redirects the user to the pdf so as to see the metadata in a browser.
#
#		Called from web page by sitePDF.pl.
# 		This page prompts the user to choose a site. 
#		WWW->DB->XML->XSLT->fo->fop->pdf->WWW
# 		A file called LTERmetadata.pdf will be created and the user
# 		will be redirected to it.
#
# NOTE: dealing with non-valid html to xml is a real bitch. If your getting
# illegal characters or other problems this is the most likly culprit
# See the subroutine &escape. Some day I'll fix this (maybe HTML::Entities).
use FindBin qw($Bin);
use lib "$Bin/bin";

open POO, ">$Bin/log/query.log";

use strict;
use clim_lib;
use sql_cmd;
use CGI;
use DBI;
use CGI::Carp qw(fatalsToBrowser);

#print &escape($ARGV[0])."\n";
#exit;

# Global $id for toc entries, all must be unique. We just $i++ each time
my $id = 0;
my $site_id;

#read control file 
my %control = &read_control();	
my $fop = $control{fop};

#connect with database
my $dbh = DBI->connect($control{data_source},$control{data_user},$control{data_password}) || print "Connect failure in $0 \n";

my $cgi = new CGI;
my $request_method = $cgi->request_method();
#$request_method = 'TEST';

#if 'GET' get first page, else make report
if($request_method eq 'GET'){				
	&draw_page1();
} else {
	$site_id = $cgi->param('site_id');
	my $windowsBin = $Bin;
	$windowsBin	=~ s|/|\\|g;
	#$windowsBin	= $control{UNC};
	my $XSL = "$windowsBin\\bin\\LTERmeta2fo.xsl";
	my $XML = "$windowsBin\\temp\\LTERmetadata.xml";
	open XML, ">$XML" or die "Can't open $XML\n$!";

	my $site = &page1();
	my $PDF = "$windowsBin\\temp\\$site.pdf";

# Create page for research area
	my $type = 'Research Area Information';
	&section($type);
# Create pages for met stations
	$type = 'Meteorological Stations';
	&section($type);
# Create pages for ws stations
	$type = 'Watershed';
	&section($type);
# Create pages for gs stations
	$type = 'Gauging Stations';
	&section($type);

	print XML "</BODY></HTML>\n";

close XML;
#`$fop -xsl $XSL -xml $XML -pdf $PDF`;
	$fop =~ /(.*)fop.bat/;
	my $no_batch = ugly_java_crap($1,"-xsl $XSL -xml $XML -pdf $PDF");
	
	$PDF = $control{web}."/temp/$site.pdf"  ;
	print $cgi->redirect("$PDF");

}

#################################
######### END OF MAIN ###########
#################################
# Apparently Bill Gates has decided that batch files won't be supported this
# month. We will have to bypass the normall convention (Apache, IIS5, but not 
# IIS6) of using a batch file to set up fops classpath. This makes for a 
# maintanence nightmere, but thats windows.
 
sub ugly_java_crap {
	my ($FOP,$args) = @_;
	
	my $LIBDIR = $FOP.'lib';
	my $LOCALCLASSPATH = $FOP.'build\fop.jar';
	$LOCALCLASSPATH .= ';'.$LIBDIR.'\xml-apis.jar';
	$LOCALCLASSPATH .= ';'.$LIBDIR.'\xercesImpl-2.2.1.jar';
	$LOCALCLASSPATH .= ';'.$LIBDIR.'\xalan-2.4.1.jar';
	$LOCALCLASSPATH .= ';'.$LIBDIR.'\batik.jar';
	$LOCALCLASSPATH .= ';'.$LIBDIR.'\avalon-framework-cvs-20020806.jar';
	$LOCALCLASSPATH .= ';'.$LIBDIR.'\jimi-1.0.jar';
	$LOCALCLASSPATH .= ';'.$LIBDIR.'\jai_core.jar';
	$LOCALCLASSPATH .= ';'.$LIBDIR.'\jai_codec.jar';

	my $output = "java -cp \"$LOCALCLASSPATH\" org.apache.fop.apps.Fop $args";	
	print POO $output;
	`$output`;
}

## PAGE1
# Create Title page

sub page1 {

	my $sqlcmd = &get_cmd('150',$site_id);
	my ($site_code,$site_name,$loc1,$loc2,$lat,$long,$url) = 
		&query_DB($sqlcmd,'array',$dbh);
	my $time = localtime();

	print XML <<EOF
<HTML>
  <HEAD>
    <TITLE>$site_name Metadata Report</TITLE>
  </HEAD>
  <COVER>
    <SITE_NAME>$site_name</SITE_NAME> 
    <SITE_CODE>$site_code</SITE_CODE>
    <LOC1>$loc1</LOC1>
    <LOC2>$loc2</LOC2>
    <CREATE>$0 </CREATE>  
    <TIME>$time</TIME>
  </COVER>
  <BODY>
  
EOF
;

return($site_code);

}

## SECTION
# A new section for each res_site_type

sub section{
	my $type = shift;
		
# Make a title page for all $type stations 

	my $res_sitetype_id = &what_sitetype($type);
	my $sqlcmd = &get_cmd('151',$site_id, $res_sitetype_id);
# @stations = (res_site_id,res_site_code,res_site_name,......)
# repeated for each station
	my @stations = &query_DB($sqlcmd,'array',$dbh);
    print XML "  <SECTION TYPE='$type' ID='$id'>\n";
	$id++;
	print XML "    <TYPES>\n";

	for (my $i=0; $i<=$#stations; $i = $i+3) {
		print XML 
"      <RES_SITE_NAME CODE='$stations[$i+1]'>$stations[$i+2]</RES_SITE_NAME>\n";
	}
	print XML "    </TYPES>\n";
	&stations($res_sitetype_id,@stations);
	print XML "  </SECTION>\n";
}

## STATIONS
# Create stations

sub stations {
	my ($res_sitetype_id,@stations) = @_;

	for (my $i=0; $i<=$#stations; $i = $i+3) {
		my $res_site_id = $stations[$i];
# Make a title page for each station
# but first check that they have metadata
		my $sqlcmd = &get_cmd('154',$res_site_id, $res_sitetype_id);
		my $check = &query_DB($sqlcmd,'value',$dbh);
		if ($check > 0 ) {
			print XML "    <STATION NAME='$stations[$i+2]' ID='$id'>\n";
			$id++;
# gather descriptor_categorys for each station
			$sqlcmd = &get_cmd('152',$res_sitetype_id);
			my %descriptors = &query_DB($sqlcmd,'sort',$dbh);
# foreach descriptor_category make a page and outline entrty
			foreach my $key (sort {$a <=> $b} keys(%descriptors)) {
				my ($crap,$descriptor_category_id) = split('\.0',$key);

# before you do this you should check to see if there are any values
# lets get a count
				$sqlcmd = &get_cmd('153',$res_site_id,$descriptor_category_id);
# if you have any make the page
				if( &query_DB($sqlcmd,'value',$dbh) > 0 ) {
					my $descriptor_desc = $descriptors{$key};
					print XML 
	"      <DESCRIPTOR_DESC DESC='$descriptor_desc' ID='$id'>\n";
					$id++;
					&get_values($res_site_id,$descriptor_category_id);
					print XML "      </DESCRIPTOR_DESC>\n";
				}
			}
			if ($check > 0) { print XML "    </STATION>\n" ;}
		}
	}
}

## GET_VALUES
#
sub get_values {
	my ($res_site_id,$descriptor_category_id) = @_;


	my $sqlcmd = &get_cmd('108',$res_site_id,$descriptor_category_id);
	my @info = &query_DB($sqlcmd,'array',$dbh);
	
	for (my $i = 0;$i<$#info;$i=$i+6){
		if (($info[$i+4]) && (length($info[$i+4]) > 0)) {
		   my $value = &escape($info[$i+4]);
#this dumb hack is to help break long URLs
		   if ($value =~ /http/) {$info[$i+3] = 'm'}
		   my $units = '';
		   if ($info[$i+5]) {
			   $info[$i+5] =~ s/</&lt;/g;
			   $info[$i+5] =~ s/>/&gt;/g;
			   $units = "UNITS='$info[$i+5]'"; 
		   }
			print XML 
"        <INFO SIZE='$info[$i+3]' $units TITLE='$info[$i+2]'>
		   $value
		 </INFO>\n";
		}
	}
}

## ESCAPE
# Since XML is so picky about this stuff we better be real carefull about what
# gets through. Right now this is a catch all routine for any forbiden 
# characters that need to be escaped. When I see a pattern I'll deal with this
# a little more gracefully (I hope)
# NOTE the HTML is a problem I'll add supported tags as needed. However I'll
# need to deal with non-valid HTML (i.e. <P> with no </P>) This Routine is 
# going to be a bitch. Also if someone feeds me something like &amp; I'll
# be changing it to &&amp;amp;
# Oh one more thing. Really long URL's need to be split. I guess I'll just
# insert a space if its really long

sub escape {
	my $thing = shift;
	$thing =~ s/\r//g;
# deal with <p> and <br> tags
	$thing =~ s/<\/?(p|br)\/?>/<$1\/>/ig;
	$thing =~ s/\n/ /g;
	$thing =~ s/\n//g;
	$thing =~ s/<(p|br)\/><(p|br)\/>/<$1\/>/g;
# hmm I need to escape some non printables ,why are they in here????
	$thing =~ s/\xf3//g;
	$thing =~ s/\xa3//g;
# need list of valid entities
	$thing =~ s/&/&amp;/g; # &
	$thing =~ s/\xb0/&#176;/g; #degree symbol
	$thing =~ s/\x96/-/g; #dash symbol
	$thing =~ s/\xb2/&#178;/g; #superscript 2
	$thing =~ s/\xb3/&#179;/g; #superscript 3 
	$thing =~ s/\x93/&#8220;/g; #`` right
	$thing =~ s/\x94/&#8221;/g; #'' left
	$thing =~ s/\x92/&#8217;/g; #right quoatation mark '

#this is for URL's I've put a 0 width space after each /  
#this SUCKS! according to fop I can set my own hypenation pattern
# but I cant. This hack works but if the URL is in a size=l field
# the justification is going to spread all the spaces. So this hack
# leads to another. if it has a http in it I'll change its size to 'm'
# at least until I can figure out hyphenation
	#$thing =~ s/\//\/&#x200B;/g;

# find html tags
	my $supported_tags = 
		'BR|P|I|B|U|TABLE.*?|UL|OL|DL|LI|DT|DD|TD|TH|TH[^a-z].*?|TR';

	while ($thing =~ /(.*?)<(\/?($supported_tags)\/?)>(.*)/i)  {
# if supported html escape it so we dont change the < and >
		$thing = $1.'%%'.lc($2).'%%'.$4; 
	}

# escape < or > if not html
	$thing =~ s/</&lt;/g;
	$thing =~ s/>/&gt;/g;
	$thing =~ s/%%(.*?)%%/<$1>/g;
# pull out embeded BR tags that came about because of \n in tables and such
	while ($thing =~ /<(TABLE|OL|UL|DL).*?>.*?<br\/>.*?<\/\1>/i) {
		$thing =~ s/(<$1.*?>.*?)<br\/>(.*?<\/$1>)/$1$2/ig;
	}
	$thing =~ s/        /<TAB\/>/g;
	return($thing);
}

## WHAT_SITETYPE
# given a title return a res_sitetype_id

sub what_sitetype {
	my $type = shift;
	if ($type =~ /^Meteorological Stations/) {
		return(4);
	} elsif ($type =~ /^Watershed/) {
		return(2);
	} elsif ($type =~ /^Gauging Stations/) {
		return(3);
	} elsif ($type =~ /^Research/) {
		return(1);
	}
}

## DRAW_PAGE1
# allows the user to select a site for the PDF report.

sub draw_page1{
	my $style = $control{all_css};
	print $cgi->header(-nph => 1, -expires=>'now');
#	print $cgi->header(-expires=>'now');
#JAMES EDITED
	my $sqlcmd = &get_cmd('101');
	my %site_list = &query_DB($sqlcmd,'sort',$dbh);

#do HTML
	print $cgi->start_html(-title=>'PDF request form',-author=>'kyle.kotwica@comcast.net',-style=>{'src'=>"$style"},),
	$cgi->h2("PDF report for CLIMDB/HYDRODB metadata"),
	$cgi->start_form(-method=>'post',-action=>'sitePDF.pl');

	
	print "\n<HR><P>Please choose your site:<BR>\n";
	print "<select name=site_id>\n";
	foreach my $key (sort keys(%site_list)) {
#strip off the sort_order	
		my ($crap,$real_key) = split('\.0',$key);
		print "<option value=$real_key>$site_list{$key}\n";
	}
	print "</SELECT><P><INPUT TYPE=submit VALUE=submit></FORM>\n";
	&feedback('sitePDF.pl','PDF Metadata Report');
	print$cgi->end_html;
}


__END__

=head1 NAME

sitePDF.pl - Generates PDF reports of the ClimDB/HydroDB Metadata

Version 1.0 Beta

=head1 SYNOPSIS

http://www.yourserver.net/sitePDF.pl

=head1 DESCRIPTION

After prompting the user for a site from a drop down list a complete PDF document gleaned from the metadata in the ClimDB/HydroDB database is created. The PDF document is called xxx.PDF, where xxx is the site code of the selected site. The browser is redirected to the newly created PDF document, and hopefully the end user has a PDF Reader plug in installed and enabled. 

The general format of the document is a tree structure following the pattern;
 
 site name (cover page)
   met stations	(lists met stations)
     station1 (start of station1's metadata)
	   descriptor type 1 (first descriptor type/value for station1)
	   descriptor type 2
	   ...
	   ...
	   descriptor type (n)
     station2
	   descriptor type 1
	   descriptor type 2
	   ...
	   ...
	 station(n)
   watershed
     station1
	   descriptor type 1
	   descriptor type 2
	   ...
	   ...
	   descriptor type (n)
     station2
	   descriptor type 1
	   descriptor type 2
	   ...
	   ...
	 station(n)
   gauging station
     ... 
	   ...
	   (etc)

=head2 Methodology

A series of SQL queries are made. A log of all queries are kept in ./log/query.log. The results are embedded in a XML file ./temp/LTERmetadata.xml. The XML is transformed into formating objects by the XSLT file ./bin/LTERmeta2fo.xsl. Apache's FOP is then called upon to render the PDF file ./temp/xxx.PDF. The browser is then redirected to the newly generated PDF document.
	   
=head2 HTML

HTML presents a serious problem. Since the XSLT and the FOP both insist upon well formed and valid XML. Yet the contents of the database may have snippits of HTML in it. These snippits are no doubt not well formed, most of the time.

For example most HTML uses tags such as <P>. To be well formed all <P>'s must have a corresponding </P> tag. To furthur compplicate maters, some of the database entries may not be HTML at all. If the user entered the the data with newlines to format paragraphs FOP will ignore them, since whitespace is ignored.

To further complicate maters, some of the database entries may not be HTML at all. If the user entered the the data with newlines to format paragraphs FOP will ignore them, since whitespace is ignored.

The following conventions have been followed;
all <P>,</P>,<P/>		are converted to <P/>
all <br>,</br>,<br/>	are converted to <br/>
all &					are converted to &amp;
eight spaces			are converted to eight spaces
all < and > that 
are not in a supported
set of HTML tags		are converted to &lt; and &gt;

Supported HTML is as follows (case is not important);
<P>,<BR>,<B>,<I>,<U> NOTE <p> and <br> need not be balenced.

These tags are also supported to some extenet, but their use is not recomended;
<TABLE><TR><TH><TD>
<OL><LI>
<UL><LI>
<DL><DT><DD>

These are not supported because in all but the trivial cases they will fail. The failure of these tags means the program fails in a particularly nasty way (it does nothing). See BUGS.

The table and th tags can have a width attribute (in pixals).
<TBODY>, <THEADER> and <TFOOTER> are not supported.

=head1 BUGS

HTML should not be supported unless it is going to be demanded. I don't know what to do with \n's,<BR>'s,and <P>'s. I suggest all \n should be tossed. 

URL's pose another problem. FOP should hyphenate on /'s put it doesn't. FOP should allow me to add my own hyphanation file, put it doesn't.  

=head1 AUTHOR

Kyle Kotwica E<lt>Kyle.kotwica@comcast.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Kyle Kotwica

Mine, all mine! leave it alone or I'll threaten you and stuff like that.

=cut


