<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.music-encoding.org/ns/mei"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:m="http://www.music-encoding.org/ns/mei"
    xmlns:xl="http://www.w3.org/1999/xlink" 
    version="1.0" 
    exclude-result-prefixes="m xsl xl">

    <!--  
        Move invalid <extent> and <dimensions> @unit values to the elements' content - and other fixes.        
        Sept. 2017
    -->
    
    
    <xsl:output indent="yes" xml:space="default" method="xml" encoding="UTF-8"
        omit-xml-declaration="yes"/>
    
    <!-- Remove empty elements -->
    <xsl:template match="m:castItem[not(//text())]"/>
    <xsl:template match="m:castList[not(*)]"/>    
    <xsl:template match="m:provenance[not(* or //text())]"/>

    <!-- Remove empty attributes -->
    <xsl:template match="@codedval | @rel">
        <xsl:if test="normalize-space(.)">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>
    
    <!-- rename @auth to @authority -->
    <xsl:template match="@auth">
        <xsl:if test="normalize-space(.)">
            <xsl:attribute name="authority"><xsl:value-of select="."/></xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!-- rename @xl_title to @label -->
    <xsl:template match="@xl:title">
        <xsl:if test="normalize-space(.)">
            <xsl:attribute name="label"><xsl:value-of select="."/></xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <!-- highly DCM-specific name changes... -->
    <xsl:template match="m:expan[.='Danish Centre for Music Publication']">
        <xsl:element name="expan">Danish Centre for Music Editing</xsl:element>
    </xsl:template>
    <xsl:template match="m:addrLine[.='The Royal Library']">
        <xsl:element name="addrLine">Royal Danish Library</xsl:element>
    </xsl:template>
    <xsl:template match="m:ptr/@target[.='http://www.kb.dk/dcm']">
        <xsl:attribute name="target">http://www.kb.dk</xsl:attribute>
    </xsl:template>
        
        
    <!-- append non-valid @unit values to the element content and omit the unit attribute -->
    <xsl:template match="m:extent[@unit] | m:dimensions[@unit]">
        <xsl:choose>
            <xsl:when test="@unit 
                and @unit!=''
                and @unit!='byte' 
                and @unit!='char' 
                and @unit!='cm' 
                and @unit!='in' 
                and @unit!='issue' 
                and @unit!='mm' 
                and @unit!='page' 
                and @unit!='pc' 
                and @unit!='pt' 
                and @unit!='px' 
                and @unit!='record' 
                and @unit!='vol' 
                and @unit!='vu'">
                <xsl:element name="{name(.)}">
                    <xsl:apply-templates select="@*[name()!='unit']"/>
                    <xsl:apply-templates select="*|text()"/><xsl:value-of select="concat(' ',@unit)"/></xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{name(.)}">
                    <xsl:apply-templates select="@*|*|text()"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
