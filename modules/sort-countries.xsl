<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:m="http://www.music-encoding.org/ns/mei" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  
  <xsl:template match="/">
    <list xmlns="http://www.music-encoding.org/ns/mei">
      <head>RISM country codes</head>
      <xsl:for-each select="//m:li">
	<xsl:sort data-type="text" select="m:geogName/@codedval"/>
	<li>
	  <xsl:element name="geogName">
	    <xsl:attribute name="codedval">
	      <xsl:value-of select="m:geogName/@codedval"/>
	    </xsl:attribute>
	    <xsl:apply-templates select="m:geogName"/>
	  </xsl:element>
	</li>
      </xsl:for-each>
    </list>
  </xsl:template>

</xsl:transform>