<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
    <HTML>
      <HEAD>
	<LINK REL="stylesheet" TYPE="text/css" HREF="http://lterweb.forestry.oregonstate.edu/climhy/./images/sand1101.css"></LINK>
	<TITLE>Contributing LTER sites</TITLE>
      </HEAD>
      
      <BODY>
		<!--script src="../bin/jumptop.js">
		</script-->

	     <H1>Contributing LTER sites</H1>
	     <A HREF="http://www.fsl.orst.edu/climhy">Back to Data Access page</A><P/>
	     <FONT SIZE='-1'><I>Click on the up arrow to sort in ascending order and the down arrow for descending order.</I></FONT>
             <xsl:apply-templates select="info/sites"/>
      </BODY>
    </HTML>
  </xsl:template>
  
  <xsl:template match="sites">
    <TABLE CELLSPACING="10" BORDER="0">
	  <TR>
	  	
<TH WIDTH='100' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=site&amp;order=ascending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Site<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=site&amp;order=descending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='325' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=name&amp;order=ascending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Name<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=name&amp;order=descending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=number&amp;order=ascending&amp;type=number">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/># of Met Stations<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=number&amp;order=descending&amp;type=number">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=number2&amp;order=ascending&amp;type=number">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/># of Hydro Stations<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=number2&amp;order=descending&amp;type=number">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=first&amp;order=ascending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Earliest Met Data<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=first&amp;order=descending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=recent&amp;order=ascending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Latest Met Data<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=recent&amp;order=descending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=last&amp;order=ascending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Last Met Update<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=last&amp;order=descending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
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
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=site&amp;order=ascending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Site<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=site&amp;order=descending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='325' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=name&amp;order=ascending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Name<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=name&amp;order=descending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=number&amp;order=ascending&amp;type=number">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/># of Met Stations<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=number&amp;order=descending&amp;type=number">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=number2&amp;order=ascending&amp;type=number">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/># of Hydro Stations<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=number2&amp;order=descending&amp;type=number">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=first&amp;order=ascending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Earliest Met Data<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=first&amp;order=descending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=recent&amp;order=ascending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Latest Met Data<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=recent&amp;order=descending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=last&amp;order=ascending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Last Met Update<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=last&amp;order=descending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
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
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=site&amp;order=ascending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Site<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=site&amp;order=descending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='325' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=name&amp;order=ascending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Name<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=name&amp;order=descending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=number&amp;order=ascending&amp;type=number">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/># of Met Stations<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=number&amp;order=descending&amp;type=number">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=number2&amp;order=ascending&amp;type=number">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/># of Hydro Stations<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=number2&amp;order=descending&amp;type=number">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=first&amp;order=ascending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Earliest Met Data<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=first&amp;order=descending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=recent&amp;order=ascending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Latest Met Data<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=recent&amp;order=descending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
	</A>
</TH> 
<TH WIDTH='125' ALIGN='center'>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=last&amp;order=ascending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_up.bmp' border='0' ALT='ascending' />
	</A>
	<BR/>Last Met Update<BR/>
	<A HREF="http://lterweb.forestry.oregonstate.edu/climhy/products.pl?use=sites&amp;module=1&amp;sort=last&amp;order=descending&amp;type=text">
		<IMG SRC='http://lterweb.forestry.oregonstate.edu/climhy/images/black_down.bmp' border='0' ALT='descending' />
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
