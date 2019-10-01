<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.music-encoding.org/ns/mei" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xl="http://www.w3.org/1999/xlink" 
		xmlns:m="http://www.music-encoding.org/ns/mei"
		xmlns:t="http://www.tei-c.org/ns/1.0" 
		exclude-result-prefixes="m xsl" 
		xmlns:uuid="java:java.util.UUID" 
		version="1.0">

  <xsl:template match="@*|*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
