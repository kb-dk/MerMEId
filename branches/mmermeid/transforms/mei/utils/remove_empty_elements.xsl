<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.music-encoding.org/ns/mei" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xl="http://www.w3.org/1999/xlink" 
    xmlns:m="http://www.music-encoding.org/ns/mei"
    xmlns:t="http://www.tei-c.org/ns/1.0" 
    xmlns:exsl="http://exslt.org/common"
    xmlns:uuid="java:java.util.UUID" version="2.0"
    exclude-result-prefixes="m xsl">
    
    <xsl:output indent="yes" 
        xml:space="default" 
        method="xml"
        encoding="UTF-8"
        omit-xml-declaration="yes" />
    
    <xsl:strip-space elements="*"/>

    <xsl:template match="m:mei">
        <!-- empty elements are removed stepwise -->
        <xsl:variable name="header">
            <!-- first run -->
            <xsl:apply-templates select="m:meiHead"/>
        </xsl:variable>
        <xsl:variable name="header2">
            <!-- second run -->
            <xsl:apply-templates select="exsl:node-set($header)"/>
        </xsl:variable>
        <mei xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:copy-of select="@*"/>
            <!-- third run -->
            <xsl:apply-templates select="exsl:node-set($header2)"/>
            <xsl:copy-of select="m:music"/>
        </mei>       
    </xsl:template>
    

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
                   <xsl:attribute name="label" select="translate(@type,'_',' ')"/>
                   <xsl:apply-templates select="node()"/>
               </xsl:element>
           </xsl:otherwise>
       </xsl:choose>
    </xsl:template>
    
    <!-- Clean up MEI -->
    
    <xsl:template match="m:date[@*[substring(.,1,1)=' ']]">
        <!-- get rid of leading space in date attributes -->
            <xsl:copy>
                <xsl:for-each select="@*">
                    <xsl:attribute name="{name()}"><xsl:value-of select="normalize-space(.)"/></xsl:attribute>
                </xsl:for-each>
                <xsl:apply-templates select="node()"/>
            </xsl:copy>
    </xsl:template>
    
    <!-- Remove empty elements -->
    <xsl:template match="m:annot[not(* or normalize-space(.))]"/>    
    <xsl:template match="m:availability[not(*)]"/>    
    <xsl:template match="m:availability//*[not(* or normalize-space(.))]"/>    
    <xsl:template match="m:bibl[not(text()) and not(*[name()!='genre' and normalize-space(.)])]"/>    
    <xsl:template match="m:biblList[not(m:bibl)]"/>    
    <xsl:template match="m:biblScope[not(normalize-space(.))]"/>    
    <xsl:template match="m:classification[not(m:classCode or normalize-space(.))]"/>    
    <xsl:template match="m:componentGrp[not(*)]"/>    
    <xsl:template match="m:dimensions[not(* or normalize-space(.))]"/>    
    <xsl:template match="m:extent[not(* or normalize-space(.))]"/>    
    <xsl:template match="m:event[not(normalize-space(.))]"/>    
    <xsl:template match="m:eventList[not(m:event)]"/>
    <xsl:template match="m:hand[not(* or normalize-space(concat(@medium,@resp,.)))]"/>    
    <xsl:template match="m:handList[not(*)]"/>    
    <xsl:template match="m:incip[not(*)]"/>    
    <xsl:template match="m:incip//*[not(* or normalize-space(.))]"/>    
    <xsl:template match="m:key[not(@*[normalize-space(.)] or normalize-space(.))]"/>    
    <xsl:template match="m:meter[not(@*[normalize-space(.)] or normalize-space(.))]"/>    
    <xsl:template match="m:notesStmt[not(m:annot)]"/>    
    <xsl:template match="m:perfMedium//*[not(normalize-space(.) or @*[normalize-space(.)] or name()='head')]"/>    
    <xsl:template match="m:perfMedium[not(*)]"/>    
    <xsl:template match="m:physMedium[not(* or normalize-space(.))]"/>    
    <xsl:template match="m:plateNum[not(* or normalize-space(.))]"/>    
    <xsl:template match="m:provenance[not(* or normalize-space(.))]"/>    
    <xsl:template match="m:ptr[not(@*[normalize-space(.)] or normalize-space(.))]"/>    
    <xsl:template match="m:publisher[not(* or normalize-space(.))]"/>    
    <xsl:template match="m:pubPlace[not(* or normalize-space(.))]"/>    
    <xsl:template match="m:pubStmt[not(* or normalize-space(.))]"/>    
    <xsl:template match="m:tempo[not(@*[normalize-space(.)] or normalize-space(.))]"/>    
    <xsl:template match="m:titlePage[not(* or normalize-space(.))]"/>    
    <xsl:template match="m:titlePage/m:p[not(* or normalize-space(.))]"/>    
    <xsl:template match="m:date[not(node()) and not(@*)]"/>    
    
    <!-- end clean-up -->

</xsl:stylesheet>
