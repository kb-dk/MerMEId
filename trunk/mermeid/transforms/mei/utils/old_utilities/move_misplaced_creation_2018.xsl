<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.music-encoding.org/ns/mei"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:m="http://www.music-encoding.org/ns/mei"
    xmlns:exsl="http://exslt.org/common" xmlns:dyn="http://exslt.org/dynamic" version="2.0"
    exclude-result-prefixes="m xsl" extension-element-prefixes="dyn exsl">

    <xsl:output indent="yes" xml:space="default" method="xml" encoding="UTF-8"
        omit-xml-declaration="yes"/>

    <xsl:strip-space elements="*"/>
    
    <!--    
            A transformation moving <creation> out of <history>. 
            With MEI 3.0.0, <creation> and <history> are siblings, not child and parent. MerMEId implemented this change at <work> level but failed to do so 
            at <expression> level. This transformation cleans up data and should be run when installing the corresponding bug fix for MerMEId (committed August 23, 2018). 
    --> 
    
    <xsl:template match="m:work | m:expression">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="m:history">
                    <xsl:apply-templates select="m:history/preceding-sibling::m:*[not(local-name() = 'creation')]"/>
                    <!-- comment out any existing <creation> element with content before copying in the one from <history> -->
                    <xsl:apply-templates select="m:creation[following-sibling::m:history/m:creation][.//text() or m:date[normalize-space(@*[not(name()='xml:id')])]]" mode="comment_out"/>
                    <!-- else just keep it -->
                    <xsl:apply-templates select="m:creation[not(following-sibling::m:history/m:creation)]"/>
                    <xsl:apply-templates select="m:history/m:creation"/>
                    <xsl:apply-templates select="m:history"/>
                    <xsl:apply-templates select="m:history/following-sibling::m:*"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="m:history">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="m:*[not(local-name() = 'creation')]"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*" mode="comment_out">
                    <xsl:text disable-output-escaping="yes">
                    &lt;!--</xsl:text><xsl:apply-templates select="." /><xsl:text disable-output-escaping="yes">--&gt;
                    </xsl:text>
    </xsl:template>
        
   
    <!-- Add a record of the conversion to revisionDesc -->
    <xsl:template match="m:revisionDesc[//m:history/m:creation]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <change>
                <xsl:attribute name="isodate">
                    <xsl:value-of select="format-date(current-date(), '[Y]-[M02]-[D02]')"/>
                </xsl:attribute>
                <xsl:variable name="generated_id" select="generate-id()"/>
                <xsl:variable name="no_of_nodes" select="count(//*)"/>
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="concat('change_',$no_of_nodes,$generated_id)"/>
                </xsl:attribute>
                <respStmt>
                    <resp>MerMEId</resp>
                </respStmt>
                <changeDesc>
                    <p>Moved creation elements misplaced in history elements up one level</p>
                </changeDesc>
            </change>
        </xsl:copy>
    </xsl:template>
   
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
