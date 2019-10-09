<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0" exclude-result-prefixes="">
    
    <!-- Sort list of elements and attributes alphabetically -->
    
    <xsl:output indent="yes" encoding="UTF-8"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()">
                <xsl:sort select="name()" order="ascending"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[*]">
        <xsl:copy>
            <xsl:apply-templates select="@*">
                <xsl:sort select="name()" order="ascending"/>
            </xsl:apply-templates>      
            <xsl:apply-templates select="*">
                <xsl:sort select="name()" order="ascending"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>