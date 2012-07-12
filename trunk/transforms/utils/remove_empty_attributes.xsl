<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet     
    xmlns="http://www.music-encoding.org/ns/mei" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xl="http://www.w3.org/1999/xlink" 
    xmlns:m="http://www.music-encoding.org/ns/mei" 
    xmlns:t="http://www.tei-c.org/ns/1.0" 
    exclude-result-prefixes="m xsl"
    version="1.0">
    
    <xsl:template match="@*|*">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="identifier/@type|@unit|@target|@targettype|@pname|@accid|@mode|@meter.count|@meter.unit|@meter.sym|@notbefore|@notafter|@reg|@n">
        <xsl:if test="normalize-space(.)!=''">
            <xsl:variable name="attrName"><xsl:value-of select="name()"/></xsl:variable>
            <xsl:attribute name="{$attrName}"><xsl:value-of select="."/></xsl:attribute>
        </xsl:if>
    </xsl:template>    
    
</xsl:stylesheet>