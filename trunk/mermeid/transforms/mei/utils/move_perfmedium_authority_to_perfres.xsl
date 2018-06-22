<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.music-encoding.org/ns/mei"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:m="http://www.music-encoding.org/ns/mei"
    xmlns:exsl="http://exslt.org/common" xmlns:dyn="http://exslt.org/dynamic" version="2.0"
    exclude-result-prefixes="m xsl" extension-element-prefixes="dyn exsl">

    <xsl:output indent="yes" xml:space="default" method="xml" encoding="UTF-8"
        omit-xml-declaration="yes"/>

    <xsl:strip-space elements="*"/>
    
    <!--    
            A transformation moving @authority, @authURI and @analog values from <perfMedium> container elements
            to <perfResList> and <perfRes> child elements if they do have a @codedvalue.
            This allows the co-existence of different instrument code schemes such as MARC and UNIMARC.
    --> 
    
    <xsl:template match="m:perfMedium[@authority!='' or @analog!='' or @authURI!='']">
        <perfMedium>
            <!-- remove @authority, @authURI and @analog from <perfMedium> -->
            <xsl:apply-templates select="@*[not(name()='authority' or name()='authURI' or name()='analog')]"/>
            <xsl:apply-templates select="node()"/>
        </perfMedium>        
    </xsl:template>

    <xsl:template match="m:perfResList[@codedval and ancestor::m:perfMedium[@authority!='' or @analog!='' or @authURI!='']] 
        | m:perfRes[@codedval and ancestor::m:perfMedium[@authority!='' or @analog!='' or @authURI!='']]">
        <xsl:variable name="authority">
            <xsl:choose>
                <!-- "marcmusperf" is normalized to "MARC" -->
                <xsl:when test="ancestor::m:perfMedium/@authority='marcmusperf'">MARC</xsl:when>
                <xsl:otherwise><xsl:value-of select="ancestor::m:perfMedium/@authority"/></xsl:otherwise>
            </xsl:choose>            
        </xsl:variable>
        <xsl:variable name="authURI" select="ancestor::m:perfMedium/@authURI"/>
        <xsl:variable name="analog" select="ancestor::m:perfMedium/@analog"/>
        <xsl:element name="{name()}">
            <xsl:apply-templates select="@*[not(name()='authority' or name()='authURI' or name()='analog')]"/>
            <!-- copy @authority, @authURI and @analog from <perfMedium> unless they exist already -->
            <xsl:choose>
                <xsl:when test="not(normalize-space(@authority)) and $authority!=''">
                    <xsl:attribute name="authority"><xsl:value-of select="$authority"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise><xsl:apply-templates select="@authority"/></xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="not(normalize-space(@authURI)) and $authURI!=''">
                    <xsl:attribute name="authURI"><xsl:value-of select="$authURI"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise><xsl:apply-templates select="@authURI"/></xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="not(normalize-space(@analog)) and $analog!=''">
                    <xsl:attribute name="analog"><xsl:value-of select="$analog"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise><xsl:apply-templates select="@analog"/></xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
   
    <!-- Add a record of the conversion to revisionDesc -->
    <xsl:template match="m:revisionDesc[//m:perfMedium[@authority!='' or @analog!='' or @authURI!='']]">
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
                    <p>Moved authority information from perfMedium to perfRes elements</p>
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
