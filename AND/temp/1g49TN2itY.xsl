<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
    <HTML>
      <HEAD>
	<LINK REL="stylesheet" TYPE="text/css" HREF="http://climhy.lternet.edu/./images/expe1011.css"></LINK>
	<TITLE>Contributing ClimDB/HydroDB variables</TITLE>
      </HEAD>
      
      <BODY>
		<!--script src="../bin/jumptop.js">
		</script-->

	     <H1>Contributing ClimDB/HydroDB variables</H1>
	     <A HREF="http://climhy.lternet.edu/">Back to Data Access page</A><P/>
	     <FONT SIZE='-1'><I>Click on the up arrow to sort in ascending order and the down arrow for descending order.</I></FONT>
             <xsl:apply-templates select="info/variables"/>
      </BODY>
    </HTML>
  </xsl:template>
  
  <xsl:template match="variables">
    <TABLE CELLSPACING="10" BORDER="0">
	  <TR>
	  	
<TH WIDTH='100' ALIGN='center'>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=site&amp;order=ascending&amp;type=text">
		<IMG SRC='http://climhy.lternet.edu/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Site<BR/>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=site&amp;order=descending&amp;type=text">
		<IMG SRC='http://climhy.lternet.edu/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='200' ALIGN='center'>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=name&amp;order=ascending&amp;type=text">
		<IMG SRC='http://climhy.lternet.edu/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Name<BR/>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=name&amp;order=descending&amp;type=text">
		<IMG SRC='http://climhy.lternet.edu/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='320' ALIGN='center'>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=variable&amp;order=ascending&amp;type=text">
		<IMG SRC='http://climhy.lternet.edu/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Variable<BR/>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=variable&amp;order=descending&amp;type=text">
		<IMG SRC='http://climhy.lternet.edu/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=begin&amp;order=ascending&amp;type=number">
		<IMG SRC='http://climhy.lternet.edu/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Earliest&#160;Data<BR/>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=begin&amp;order=descending&amp;type=number">
		<IMG SRC='http://climhy.lternet.edu/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=end_date&amp;order=ascending&amp;type=number">
		<IMG SRC='http://climhy.lternet.edu/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Latest&#160;Data<BR/>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=end_date&amp;order=descending&amp;type=number">
		<IMG SRC='http://climhy.lternet.edu/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=last&amp;order=ascending&amp;type=number">
		<IMG SRC='http://climhy.lternet.edu/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Last&#160;Update<BR/>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=last&amp;order=descending&amp;type=number">
		<IMG SRC='http://climhy.lternet.edu/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH>
	  </TR>

      <xsl:apply-templates select="site_item_usgs">
      	<xsl:sort select="code" order="ascending" data-type="text"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="site_item">
      	<xsl:sort select="code" order="ascending" data-type="text"/>
      </xsl:apply-templates>
    </TABLE>
  </xsl:template>

  <xsl:template match="stations">
    <TABLE CELLSPACING="10" BORDER="0">
	  <TR>
	  	
<TH WIDTH='100' ALIGN='center'>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=site&amp;order=ascending&amp;type=text">
		<IMG SRC='http://climhy.lternet.edu/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Site<BR/>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=site&amp;order=descending&amp;type=text">
		<IMG SRC='http://climhy.lternet.edu/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='200' ALIGN='center'>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=name&amp;order=ascending&amp;type=text">
		<IMG SRC='http://climhy.lternet.edu/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Name<BR/>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=name&amp;order=descending&amp;type=text">
		<IMG SRC='http://climhy.lternet.edu/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='320' ALIGN='center'>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=variable&amp;order=ascending&amp;type=text">
		<IMG SRC='http://climhy.lternet.edu/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Variable<BR/>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=variable&amp;order=descending&amp;type=text">
		<IMG SRC='http://climhy.lternet.edu/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=begin&amp;order=ascending&amp;type=number">
		<IMG SRC='http://climhy.lternet.edu/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Earliest&#160;Data<BR/>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=begin&amp;order=descending&amp;type=number">
		<IMG SRC='http://climhy.lternet.edu/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=end_date&amp;order=ascending&amp;type=number">
		<IMG SRC='http://climhy.lternet.edu/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Latest&#160;Data<BR/>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=end_date&amp;order=descending&amp;type=number">
		<IMG SRC='http://climhy.lternet.edu/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=last&amp;order=ascending&amp;type=number">
		<IMG SRC='http://climhy.lternet.edu/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Last&#160;Update<BR/>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=last&amp;order=descending&amp;type=number">
		<IMG SRC='http://climhy.lternet.edu/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH>
	  </TR>

      <xsl:apply-templates select="station_item">
      	<xsl:sort select="code" order="ascending" />
      </xsl:apply-templates>
    </TABLE>
  </xsl:template>

  <xsl:template match="variables">
    <TABLE CELLSPACING="10" BORDER="0">
	  <TR>
		
<TH WIDTH='100' ALIGN='center'>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=site&amp;order=ascending&amp;type=text">
		<IMG SRC='http://climhy.lternet.edu/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Site<BR/>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=site&amp;order=descending&amp;type=text">
		<IMG SRC='http://climhy.lternet.edu/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='200' ALIGN='center'>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=name&amp;order=ascending&amp;type=text">
		<IMG SRC='http://climhy.lternet.edu/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Name<BR/>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=name&amp;order=descending&amp;type=text">
		<IMG SRC='http://climhy.lternet.edu/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='320' ALIGN='center'>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=variable&amp;order=ascending&amp;type=text">
		<IMG SRC='http://climhy.lternet.edu/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Variable<BR/>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=variable&amp;order=descending&amp;type=text">
		<IMG SRC='http://climhy.lternet.edu/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=begin&amp;order=ascending&amp;type=number">
		<IMG SRC='http://climhy.lternet.edu/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Earliest&#160;Data<BR/>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=begin&amp;order=descending&amp;type=number">
		<IMG SRC='http://climhy.lternet.edu/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=end_date&amp;order=ascending&amp;type=number">
		<IMG SRC='http://climhy.lternet.edu/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Latest&#160;Data<BR/>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=end_date&amp;order=descending&amp;type=number">
		<IMG SRC='http://climhy.lternet.edu/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=last&amp;order=ascending&amp;type=number">
		<IMG SRC='http://climhy.lternet.edu/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Last&#160;Update<BR/>
	<A HREF="http://climhy.lternet.edu/products.pl?use=variables&amp;module=0&amp;sort=last&amp;order=descending&amp;type=number">
		<IMG SRC='http://climhy.lternet.edu/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH>
	  </TR>

      <xsl:apply-templates select="variable_item">
      	<xsl:sort select="code" order="ascending"/>
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
