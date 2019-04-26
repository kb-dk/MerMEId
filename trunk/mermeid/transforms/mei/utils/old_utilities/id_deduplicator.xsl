<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.music-encoding.org/ns/mei"  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:m="http://www.music-encoding.org/ns/mei" 
    xmlns:xl="http://www.w3.org/1999/xlink"
    xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:exsl="http://exslt.org/common"
    xmlns:date="http://exslt.org/dates-and-times"
    exclude-result-prefixes="xsl m exsl xl h date"
    version="1.0">

  <xsl:template match="@*|node()">
   <xsl:copy>
     <xsl:apply-templates select="@*|node()"/>
   </xsl:copy>
  </xsl:template>

  <xsl:template match="*[@xml:id=preceding::*/@xml:id]">
    <xsl:variable name="duplicateID" select="@xml:id"/>
    <xsl:element name="{name()}">
      <xsl:apply-templates select="@*"/>
      <!-- Append a number to the ID according to its number of occurrence -->
      <xsl:attribute name="xml:id">
        <xsl:value-of select="concat('id',$duplicateID,'_',count(preceding::*[@xml:id=$duplicateID]))"/>
      </xsl:attribute>
      <!-- To log changes: -->
      <!--<xsl:comment>Duplicate ID (<xsl:value-of select="$duplicateID"/>) changed</xsl:comment>-->
      <xsl:apply-templates select="node()"/>       
    </xsl:element>
  </xsl:template>


</xsl:stylesheet>
