<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.music-encoding.org/ns/mei" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xl="http://www.w3.org/1999/xlink" 
    xmlns:m="http://www.music-encoding.org/ns/mei"
    version="1.0"
    exclude-result-prefixes="m xsl xl">
    
    <!-- 
        Transforms data created with MerMEId before revision 821 to conform 
        with MerMEId rev. 821+.
        From rev. 821 MerMEId uses @label on identifiers instead of @type      
        to allow the use of string values.    
        
        Oct. 2014
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
    
</xsl:stylesheet>
