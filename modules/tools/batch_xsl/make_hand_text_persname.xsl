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

    <!-- 
    Transformation moving any text in <hand> to a <persName> child element. 

    Axel Teich Geertinger (atge@kb.dk)
    Danish Centre for Music Editing
    Royal Danish Library 
    Copenhagen 2018    
    -->

    <xsl:output 
        method="xml" 
        encoding="UTF-8" 
        indent="yes" 
        xml:space="default"
        omit-xml-declaration="yes" />
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Generate xml:id -->
    <xsl:template name="fill_in_id">
        <xsl:param name="element"/>
        <xsl:variable name="generated_id" select="generate-id()"/>
        <xsl:variable name="no_of_nodes" select="count(//*)"/>
        <xsl:attribute name="xml:id">
            <xsl:value-of select="concat($element,'_',$no_of_nodes,$generated_id)"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="m:hand[text() and not(m:persName)]">
        <!-- move text only if no persName child element exists already -->
        <hand>
            <xsl:apply-templates select="@*|*"/>
            <persName>
                <xsl:call-template name="fill_in_id">
                    <xsl:with-param name="element">persName</xsl:with-param>
                </xsl:call-template>                
                <xsl:value-of select="text()"/>
            </persName>
        </hand>
        
    </xsl:template>
    
    <!-- Add a record of the conversion to revisionDesc if any changes were made -->
    <xsl:template match="m:revisionDesc[count(/*//m:hand[text() and not(m:persName)]) &gt; 0]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <change>
                <xsl:attribute name="isodate"><xsl:value-of select="date:date-time()"/></xsl:attribute>
                <xsl:call-template name="fill_in_id">
                    <xsl:with-param name="element">change</xsl:with-param>
                </xsl:call-template>                
                <respStmt>
                    <resp>MerMEId</resp>
                </respStmt>
                <changeDesc>
                    <p>handList/hand text moved to persName child element</p>
                </changeDesc>
            </change>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>
