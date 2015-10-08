<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:h="http://www.w3.org/1999/xhtml"
	       version="1.0">

  <xsl:output method="text"/>
  
  <xsl:template match="/">
    <xsl:for-each select="//h:a[@target='incipit']">
      <xsl:text>GET </xsl:text><xsl:value-of select="@href"/><xsl:text>| convert - -transparent 'rgb(256,256,256)' - > </xsl:text><xsl:value-of 
      select="concat('images/',substring-after(@href,'res/'))"/><xsl:text>
</xsl:text>
    </xsl:for-each>
  </xsl:template>

</xsl:transform>
