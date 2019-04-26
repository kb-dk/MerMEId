<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.music-encoding.org/ns/mei" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xl="http://www.w3.org/1999/xlink" 
    xmlns:m="http://www.music-encoding.org/ns/mei"
    version="1.0"
    exclude-result-prefixes="m xsl xl">
    
    <!-- 
        Transforms data created with MerMEId before revision 821 to conform 
        with MerMEId rev. 843+.
        From rev. 821 MerMEId uses @label on identifiers instead of @type      
        to allow the use of string values.
        From rev. 843 MerMEId uses content class values conforming to MARC Form Category Term List
        (http://www.loc.gov/standards/valuelist/marccategory.html)
        
        Nov. 2014
    -->
    
    <xsl:output indent="yes" 
        xml:space="default" 
        method="xml"
        encoding="UTF-8"
        omit-xml-declaration="yes" />
    
    <xsl:strip-space elements="*"/>

    <xsl:template match="@*|*">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- move identifier/@type values to @label, except for the @type="file_collection" -->
    <xsl:template match="m:identifier[@type and @type!='' and not(@type='file_collection')]">        
       <xsl:choose>
           <xsl:when test="@label and @label!=''">
               <!-- element already has a label; do nothing -->
               <xsl:element name="identifier" namespace="http://www.music-encoding.org/ns/mei">
                   <xsl:apply-templates/>
               </xsl:element>
           </xsl:when>
           <xsl:otherwise>
               <!-- else rename @type to @label and replace underscores with spaces -->
               <xsl:element name="identifier" namespace="http://www.music-encoding.org/ns/mei">
                   <xsl:apply-templates select="@*[name()!='type']"/>
                   <xsl:attribute name="label"><xsl:value-of select="translate(@type,'_',' ')"/></xsl:attribute>
                   <xsl:apply-templates select="node()"/>
               </xsl:element>
           </xsl:otherwise>
       </xsl:choose>
    </xsl:template>

    <!-- Make DcmContentClass values conform to MARC Form Category Term List -->
    
    <!-- change form classification value from "music" to "notated music" except with recordings -->
    <xsl:template match="m:term[@classcode='DcmContentClass' and .='music']">
        <xsl:element name="term" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="../m:term[@classcode='DcmPresentationClass']='recording'">
                    <xsl:text>sound recording</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>notated music</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <!-- change presentation (production mode/carrier) from "recording" to "audio storage medium"  -->
    <xsl:template match="m:term[@classcode='DcmPresentationClass'][.='recording']">
        <xsl:element name="term" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="@*"/>
            <xsl:text>audio storage medium</xsl:text>
        </xsl:element>
    </xsl:template>
    

    <!-- Add a record of the conversion to revisionDesc -->
    <xsl:template match="m:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:element name="change" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="isodate"><xsl:value-of 
                    select="format-date(current-date(),'[Y]-[M02]-[D02]')"/></xsl:attribute>
                <xsl:attribute name="resp">MerMEId</xsl:attribute>
                <xsl:variable name="generated_id" select="generate-id()"/>
                <xsl:variable name="no_of_nodes" select="count(//*)"/>
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="concat('change_',$no_of_nodes,$generated_id)"/>
                </xsl:attribute>
                <xsl:element name="changeDesc" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">Batch transformation moving identifier/@type data to @label</xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>
