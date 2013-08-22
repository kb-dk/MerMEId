<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.music-encoding.org/ns/mei" 
    xmlns:m="http://www.music-encoding.org/ns/mei" 
    xmlns:xl="http://www.w3.org/1999/xlink"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:exsl="http://exslt.org/common"
    exclude-result-prefixes="xsl m t exsl xl h"
    version="2.0">

    <!-- 
    Transformation of MEI metadata from MEI 2012 to MEI 2013.
    Caution: This transform is made specifically for transforming metadata created using 
    the 2012 version of MerMEId. Metadata from other applications may or may not 
    be successfully transformed with it. 

    Axel Teich Geertinger (atge@kb.dk)
    Danish Centre for Music Publication
    The Royal Library 
    Copenhagen 2013    
    -->

    <xsl:output 
        method="xml" 
        encoding="UTF-8" 
        indent="yes" 
        xml:space="default"
        omit-xml-declaration="yes" />
    <xsl:strip-space elements="*"/>
    <xsl:strip-space elements="node"/>
    
    <xsl:template match="@*|*">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="m:mei">
        <mei>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="meiversion">2013</xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </mei>
    </xsl:template>
    
    <xsl:template match="m:rend[@fontstyle='ital']">
        <rend>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="fontstyle">italic</xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </rend>
    </xsl:template>
    
    <xsl:template match="m:creator">
        <author>
            <xsl:apply-templates select="@*|node()"/>
        </author>
    </xsl:template>
    
    <xsl:template match="m:identifier[@auth]">
        <identifier>
            <xsl:apply-templates select="@*[name(.)!='auth']"/>
            <xsl:attribute name="authority"></xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </identifier>
    </xsl:template>

</xsl:stylesheet>
