<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns="http://www.music-encoding.org/ns/mei" 
	       xmlns:m="http://www.music-encoding.org/ns/mei" 
	       xmlns:xl="http://www.w3.org/1999/xlink"
	       xmlns:xlink="http://www.w3.org/1999/xlink"
	       exclude-result-prefixes="xl xlink xsl m"
	       version="1.0">

  <xsl:output method="xml"
	      encoding="UTF-8"
	      omit-xml-declaration="yes" />

  <xsl:template match="/">
    <mei>
      <xsl:apply-templates />
    </mei>
  </xsl:template>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:transform>
