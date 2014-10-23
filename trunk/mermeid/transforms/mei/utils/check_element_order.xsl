<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.music-encoding.org/ns/mei" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xl="http://www.w3.org/1999/xlink" 
    xmlns:m="http://www.music-encoding.org/ns/mei"
    version="1.0"
    exclude-result-prefixes="m xsl xl">

    <!--  
    Occasionally MerMEId misplaces some elements. 
    These are put in the right order with this xsl.
    As of rev. 823, this check is also performed each time MerMEId saves a file.
    
    Oct. 2014
    -->

    <xsl:output indent="yes" 
        xml:space="default" 
        method="xml"
        encoding="UTF-8"
        omit-xml-declaration="yes" />
    
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="m:biblList">
        <xsl:element name="biblList" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="m:head"/>
            <xsl:apply-templates select="m:bibl"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="m:source">
        <xsl:element name="source" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="m:identifier"/>
            <xsl:apply-templates select="m:titleStmt"/>
            <xsl:apply-templates select="m:editionStmt"/>
            <xsl:apply-templates select="m:pubStmt"/>
            <xsl:apply-templates select="m:physDesc"/>
            <xsl:apply-templates select="m:physLoc"/>
            <xsl:apply-templates select="m:seriesStmt"/>
            <xsl:apply-templates select="m:contents"/>
            <xsl:apply-templates select="m:langUsage"/>
            <xsl:apply-templates select="m:notesStmt"/>
            <xsl:apply-templates select="m:classification"/>
            <xsl:apply-templates select="m:itemList"/>
            <xsl:apply-templates select="m:componentGrp"/>
            <xsl:apply-templates select="m:relationList"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="m:work">
        <xsl:element name="work" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="m:identifier"/>
            <xsl:apply-templates select="m:titleStmt"/>
            <xsl:apply-templates select="m:incip"/>
            <xsl:apply-templates select="m:tempo"/>
            <xsl:apply-templates select="m:key"/>
            <xsl:apply-templates select="m:mensuration"/>
            <xsl:apply-templates select="m:meter"/>
            <xsl:apply-templates select="m:otherChar"/>
            <xsl:apply-templates select="m:history"/>
            <xsl:apply-templates select="m:langUsage"/>
            <xsl:apply-templates select="m:perfMedium"/>
            <xsl:apply-templates select="m:audience"/>
            <xsl:apply-templates select="m:contents"/>
            <xsl:apply-templates select="m:context"/>
            <xsl:apply-templates select="m:biblList"/>
            <xsl:apply-templates select="m:notesStmt"/>
            <xsl:apply-templates select="m:classification"/>
            <xsl:apply-templates select="m:expressionList"/>
            <xsl:apply-templates select="m:componentGrp"/>
            <xsl:apply-templates select="m:relationList"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
