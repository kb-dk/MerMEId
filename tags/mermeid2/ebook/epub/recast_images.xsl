<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:h="http://www.w3.org/1999/xhtml"
	       xmlns="http://www.w3.org/1999/xhtml"
	       version="1.0">
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="h:img[contains(@src,'incipits')]">
    <xsl:element name="img">
      <xsl:copy-of select="@*"/>
      <xsl:if test="contains(@src,'res/')">
	<xsl:attribute name="width">100%</xsl:attribute>
	<xsl:attribute name="src">
	  <xsl:value-of select="concat('images/',substring-after(@src,'res/'))"/>
	</xsl:attribute>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@style[contains(.,'display')]">
    
  </xsl:template>

</xsl:transform>
