<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
	<!ENTITY aacute "&#225;">
	<!ENTITY copy   "&#169;">
	<!ENTITY nbsp   "&#160;">
  ]>

<xsl:stylesheet 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="1.0">

<xsl:output method="xml" indent="yes"/>
<xsl:template match="HTML">
<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format"
               xmlns:fox="http://xml.apache.org/fop/extensions">

	<fo:layout-master-set>
		<fo:simple-page-master		 master-name="cover"	orphans="3"
					page-width="8.5in"   page-height="11in"		widows="3"
					margin-top="0.5in"   margin-bottom="0.5in"
					margin-left="0.5in"  margin-right="0.5in">
		  <fo:region-start  extent="0.5in"/>
		  <fo:region-before extent="0.5in"/>
		  <fo:region-body   margin="0.5in"/>
		  <fo:region-end    extent="0.5in"/>
		  <fo:region-after  extent="3.5in"/>
		</fo:simple-page-master>
		<fo:simple-page-master		 master-name="body"	orphans="3"
					page-width="8.5in"   page-height="11in"		widows="3"
					margin-top="0.5in"   margin-bottom="0.5in"
					margin-left="0.5in"  margin-right="0.5in">
		  <fo:region-start  extent="0.5in"/>
		  <fo:region-before extent="0.5in"/>
		  <fo:region-body   margin="0.5in"/>
		  <fo:region-end    extent="0.5in"/>
		  <fo:region-after  extent="0.5in"/>
		</fo:simple-page-master>
	</fo:layout-master-set>

<!-- OUTLINE STUFF BEGINS HERE -->	
	<xsl:for-each select= "COVER" >
		<xsl:variable name="bookmark" select="SITE_NAME" />
		<fox:outline internal-destination="COVER">
			<fox:label><xsl:value-of select = "$bookmark"/> </fox:label>
		</fox:outline>
	</xsl:for-each>


	<xsl:for-each select= "BODY/SECTION" >
	  <xsl:variable name="bookmark" select="@TYPE" />
	  <xsl:variable name="id" select="@ID" />
	  <fox:outline internal-destination="{$id}">
	    <fox:label><xsl:value-of select = "$bookmark"/> </fox:label>
			
	    <xsl:for-each select = "STATION">
				<xsl:variable name="bookmark2" select="@NAME" />
				<xsl:variable name="id2" select="@ID" />
				<fox:outline internal-destination="{$id2}">
					<fox:label> <xsl:value-of select = "$bookmark2"/> </fox:label>

					<xsl:for-each select = "DESCRIPTOR_DESC">
						<xsl:variable name="bookmark3" select="@DESC" />
						<xsl:variable name="id3" select="@ID" />
						<fox:outline internal-destination="{$id3}">
							<fox:label> <xsl:value-of select = "$bookmark3"/> </fox:label>
					  </fox:outline>
				  </xsl:for-each>

				</fox:outline>
			</xsl:for-each>

	  </fox:outline>
	</xsl:for-each>

<!-- OUTLINE STUFF ENDS HERE -->	

	<xsl:apply-templates/>

</fo:root>
</xsl:template>

<!-- COVER PAGE -->	

<xsl:template match="HEAD/TITLE">
<fo:page-sequence master-reference="cover">

	<fo:static-content flow-name="xsl-region-after">
		<fo:block text-align="end" font-size="9pt">
			Copyright &copy; 2004 
		</fo:block>
		<fo:block text-align="end" font-size="9pt">
			Dante Da Shepherd 
		</fo:block>
		<fo:block text-align="end">
			<fo:external-graphic src="file:../bin/danteBW.gif"
				width="99px" height="109px"/>
		</fo:block>
		<fo:block text-align="end" font-size="9pt">
			A DanZart Production
		</fo:block>
		<fo:block space-before="16pt" font-size="9pt" text-align="end">
			Created by <xsl:value-of select="/HTML/COVER/CREATE"/>
		</fo:block> 
		<fo:block font-size="9pt" text-align="end">
			on <xsl:value-of select="/HTML/COVER/TIME"/>
		</fo:block>
	</fo:static-content>
	
	<fo:flow flow-name="xsl-region-body">
		<fo:block id="COVER" font-family="Helvetica" font-size="36pt"
							text-align="center" font-weight="bold" > 
			<xsl:value-of select="."/>
		</fo:block>
		<fo:block font-family="Helvetica" font-size="30pt"
							font-weight="bold" text-align="center" space-after="36pt">
			(<xsl:value-of select="/HTML/COVER/SITE_CODE"/>)
		</fo:block>			

		<fo:block text-align="center" space-before="66pt" font-size="24pt">
			<xsl:value-of select="/HTML/COVER/LOC1"/>, 
			<xsl:value-of select="/HTML/COVER/LOC2"/>
		</fo:block>

	</fo:flow>

</fo:page-sequence>
</xsl:template>

<!-- STATIC CONTENT FOR BODY -->	

<xsl:template match="BODY">
  <fo:page-sequence master-reference="body" initial-page-number="2">

		<fo:static-content flow-name="xsl-region-before">
			<fo:block font-family="Helvetica" font-size="10pt"
								text-align="left">
				<xsl:value-of select="/HTML/HEAD/TITLE"/>
			</fo:block>
		</fo:static-content>

		<fo:static-content flow-name="xsl-region-after">
			<fo:block font-family="Helvetica" font-size="9pt"
								space-before="9pt" space-after="9pt"
								text-align-last="justify" end-indent="0pt" 
								last-line-end-indent="-0pt" text-align="justify" >
				<fo:inline text-align="left" font-size="9pt">
					Created on <xsl:value-of select="/HTML/COVER/TIME"/>
				</fo:inline>
				<fo:inline keep-together.within-line="always">
					<fo:leader leader-pattern="space" leader-pattern-width="3pt" 
										leader-alignment="reference-area"
										keep-with-next.within-line="always"/>
					Page <fo:page-number />
				</fo:inline>
			</fo:block>
		</fo:static-content>

		<fo:flow flow-name="xsl-region-body">
				<xsl:apply-templates/>
		</fo:flow>

	</fo:page-sequence>
</xsl:template>

<!-- FOR EACH SECTION (i.e. watershed or met station -->	

<xsl:template match="SECTION">
	<xsl:variable name="id" select="@ID" />
		<fo:block id="{$id}" font-size="20pt" font-family="sans-serif"
								font-weight="bold" color="green" text-align="center"
								space-before="9pt" space-after="9pt" break-before="page">
			<xsl:value-of select="@TYPE"/>
		</fo:block>
	<xsl:apply-templates/>
</xsl:template>

<!-- FOR EACH TYPE (research station) for section cover page-->	

<xsl:template match="TYPES">
	<xsl:for-each select= "RES_SITE_NAME" >
		<fo:block text-align-last="justify" end-indent="0pt" 
							last-line-end-indent="-0pt" font-size="14pt" 
							font-family="sans-serif" color="black"
							space-before="2pt" space-after="2pt">
			<fo:inline keep-with-next.within-line="always" font-weight="bold">
				<xsl:value-of select="."/>
			</fo:inline>
			<fo:inline keep-together.within-line="always">
				<fo:leader leader-pattern="dots" leader-pattern-width="3pt" 
									leader-alignment="reference-area"
									keep-with-next.within-line="always"/>
				<xsl:value-of select="./@CODE"/>
			</fo:inline>
		</fo:block>	
	</xsl:for-each>
	<fo:block break-after="page" />
</xsl:template>

<!-- FOR EACH STATION OF THAT TYPE (i.e. PRIMET)-->	

<xsl:template match="STATION">
  <xsl:variable name="id" select="@ID" />
  <fo:block id="{$id}" font-size="24pt" font-family="sans-serif"
				border-top-color="blue" border-top-width="2px"
				border-right-color="blue"  border-right-width="2px"
				border-left-color="blue"  border-left-width="2px"
				border-bottom-color="blue"    border-bottom-width="2px"
				font-weight="bold" color="blue" text-align="center"
				border-style="dashed"
				space-before="26pt" space-after="6pt">
		<xsl:value-of select="@NAME"/>
  </fo:block>
  <xsl:apply-templates/>
</xsl:template>

<!-- FOR EACH DESCRIPTOR HEADING (i.e. air temperature)-->	

<xsl:template match="DESCRIPTOR_DESC">
  <xsl:variable name="id" select="@ID" />
  <fo:block id="{$id}" font-size="14pt" font-family="sans-serif"
					font-weight="bold" color="red" text-indent=".3in"
					text-decoration="underline"		
					space-before="18pt" space-after="6pt">
		<xsl:value-of select="@DESC"/>
  </fo:block>
  <xsl:apply-templates/>
</xsl:template>

<!-- FOR EACH DESCRIPTOR VALUE/TITLE (i.e. begin date / july 7th)-->
<!-- NOTE DIFFERENT FORMAT DEPENDING ON INFO'S SIZE ATTRIBUTE -->

<xsl:template match="INFO">
	<xsl:choose>

		<xsl:when test="@SIZE='s'">
			<fo:block text-align-last="justify" end-indent="0pt" 
								last-line-end-indent="-0pt" font-size="12pt" 
								font-family="sans-serif" color="black"
								space-before="2pt" space-after="2pt">
				<fo:inline keep-with-next.within-line="always" font-weight="bold">
					<xsl:value-of select="@TITLE"/>
        </fo:inline>
				<fo:inline keep-with-next.within-line="always" >
					<xsl:if test="@UNITS">
						(<xsl:value-of select="@UNITS"/>)
					</xsl:if>	
        </fo:inline>
				<fo:inline keep-together.within-line="always">
					<fo:leader leader-pattern="dots" leader-pattern-width="3pt" 
										leader-alignment="reference-area"
										keep-with-next.within-line="always"/>
					<xsl:apply-templates/>
				</fo:inline>
			</fo:block>	
		</xsl:when>
		<xsl:otherwise>
			<fo:block font-size="12pt" font-family="sans-serif"
					color="black" text-align="left" font-weight="bold"
					space-before="2pt" space-after="2pt" orphans="3" widows="3">
				<xsl:value-of select="@TITLE"/>
			</fo:block>
			<fo:block font-size="12pt" font-family="sans-serif"
								color="black" text-align="justify" text-align-last="start" 
								language="en" country="US"
								hyphenate="true" start-indent="0.3in"
                hyphenation-push-character-count="3"
                hyphenation-remain-character-count="3"  
								space-before="2pt" space-after="2pt">
				<xsl:apply-templates/>
			</fo:block>
		</xsl:otherwise>

	</xsl:choose>
</xsl:template>

<xsl:template match="TITLE">
	<fo:block font-size="12pt" font-family="sans-serif"
						color="black" text-align="justify" text-align-last="start" 
						language="en" country="US"
						hyphenate="true" orphans="3" widows="3"
						hyphenation-push-character-count="3"
						hyphenation-remain-character-count="3"  
			space-before="2pt" space-after="2pt">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<!-- ALL THE BULLSHIT FOR BEING ABLE TO ADD 'SOME' HTML SUPPORT -->
<!-- THE REST OF THIS STYLESHEET IS A WORK IN PROGRESS -->

<xsl:template match="p">
	<fo:block
		text-indent="1em"
		font-family="sans-serif" font-size="12pt"
		space-before.minimum="2pt"
		space-before.maximum="6pt"
		space-before.optimum="4pt"
		space-after.minimum="2pt"
		space-after.maximum="6pt"
		space-after.optimum="4pt">
	<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="b">
	<fo:inline font-weight="bold"><xsl:apply-templates/></fo:inline>
</xsl:template>

<xsl:template match="i">
	<fo:inline font-style="italic"><xsl:apply-templates/></fo:inline>
</xsl:template>

<xsl:template match="u">
	<fo:inline text-decoration="underline"><xsl:apply-templates/></fo:inline>
</xsl:template>

<xsl:template match="ol">
	<fo:list-block 
	  space-before="0.25em" space-after="0.25em">
		<xsl:apply-templates/>
	</fo:list-block>
</xsl:template>

<xsl:template match="ol/li">
	<fo:list-item>
		<fo:list-item-label end-indent="label-end()">
			<fo:block>
				<xsl:number/>.
			</fo:block>
		</fo:list-item-label>
		<fo:list-item-body start-indent="body-start()">
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</fo:list-item-body>
	</fo:list-item>
</xsl:template>

<xsl:template match="ul">
	<fo:list-block
	  space-before="0.25em" space-after="0.25em">
		<xsl:apply-templates/>
	</fo:list-block>
</xsl:template>

<xsl:template match="ul/li">
	<fo:list-item>
		<fo:list-item-label end-indent="label-end()">
			<fo:block>
				<fo:inline font-family="Symbol">&#x2022;</fo:inline>
			</fo:block>
		</fo:list-item-label>
		<fo:list-item-body start-indent="body-start()">
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</fo:list-item-body>
	</fo:list-item>
</xsl:template>

<xsl:template match="dl">
	<fo:block space-before="0.25em" space-after="0.25em">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="dt">
	<fo:block><xsl:apply-templates/></fo:block>
</xsl:template>

<xsl:template match="dd">
	<fo:block start-indent="2em">
	<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<!-- when table-and-caption is supported, that will be the
   wrapper for this template 
<xsl:template match="table">
	<xsl:apply-templates/>
</xsl:template>
-->
<!--
	find the width= attribute of all the <th> and <td>
	elements in the first <tr> of this table. They are
	in pixels, so divide by 72 to get inches
-->
<xsl:template match="table">
 <fo:table table-layout="fixed">
	<xsl:for-each select="tr[1]/th|tr[1]/td">
		<fo:table-column>
		<xsl:attribute name="column-width"><xsl:value-of
				select="floor(@width div 72)"/>in</xsl:attribute>
		</fo:table-column>
	</xsl:for-each>

<fo:table-body>
	<xsl:apply-templates />
</fo:table-body>

</fo:table>
</xsl:template>

<!-- this one's easy; <tr> corresponds to <fo:table-row> -->
<xsl:template match="tr">
<fo:table-row> <xsl:apply-templates/> </fo:table-row>
</xsl:template>

<!--
	Handle table header cells. They should be bold
	and centered by default. Look back at the containing
	<table> tag to see if a border width was specified.
-->
<xsl:template match="th">
<fo:table-cell font-weight="bold" text-align="center">
	<xsl:if test="ancestor::table[1]/@border &gt; 0">
		<xsl:attribute name="border-style">solid</xsl:attribute>
		<xsl:attribute name="border-width">1pt</xsl:attribute>
	</xsl:if>
	<fo:block>
	<xsl:apply-templates/>
	</fo:block>
</fo:table-cell>
</xsl:template>

<!--
	Handle table data cells.  Look back at the containing
	<table> tag to see if a border width was specified.
-->
<xsl:template match="td">
<fo:table-cell>
	<xsl:if test="ancestor::table/@border &gt; 0">
		<xsl:attribute name="border-style">solid</xsl:attribute>
		<xsl:attribute name="border-width">1pt</xsl:attribute>
	</xsl:if>
	<fo:block>
	<!-- set alignment to match that of <td> tag -->
	<xsl:choose>
	<xsl:when test="@align='left'">
		<xsl:attribute name="text-align">start</xsl:attribute>
	</xsl:when>
	<xsl:when test="@align='center'">
		<xsl:attribute name="text-align">center</xsl:attribute>
	</xsl:when>
	<xsl:when test="@align='right'">
		<xsl:attribute name="text-align">end</xsl:attribute>
	</xsl:when>
	</xsl:choose>
	<xsl:apply-templates/>
	</fo:block>
</fo:table-cell>
</xsl:template>

<xsl:template match="br">
<fo:block><xsl:text></xsl:text></fo:block>
<fo:block text-indent="0.0in">
	<xsl:apply-templates/>
</fo:block>
</xsl:template>

<xsl:template match="TAB">
	<fo:inline>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<xsl:apply-templates/></fo:inline>
</xsl:template>

</xsl:stylesheet>

