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
    <xsl:apply-templates />
    <xsl:comment>
      A comment added by the transform
    </xsl:comment>
  </xsl:template>

  <xsl:template match="@xml:id">
    <xsl:if test="string-length(.)">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
    
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:transform>
