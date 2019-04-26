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
    Transformation of MEI metadata from MerMEId revision <948 to MerMEId 3
    (revision 948+).  Caution: This transform is made specifically for
    transforming metadata created using the MerMEId versions between 821 and
    948. Metadata from other applications or versions may or may not be
    successfully transformed with it.

    Axel Teich Geertinger (atge@kb.dk)
    Danish Centre for Music Editing
    The Royal Library 
    Copenhagen 2015    
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
    
    <xsl:template match="m:incipCode">
        <!-- moving code name in incipCode from @analog to @form -->
        <xsl:element name="incipCode" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:if test="string-length(@analog) &gt; 0">
                <xsl:attribute name="form"><xsl:value-of select="@analog"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*[name()!='analog']"/>
            <xsl:apply-templates select="*"/>
        </xsl:element>
    </xsl:template>
    

    <!-- check element order -->
    <xsl:template match="m:expression">
        <xsl:element name="expression" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="*[name()!='classification' and name()!='componentGrp' and name()!='relationList']"/>
            <xsl:apply-templates select="m:classification"/>
            <xsl:apply-templates select="m:componentGrp"/>
            <xsl:apply-templates select="m:relationList"/>
        </xsl:element>
    </xsl:template>
    
    <!-- remove empty elements -->
    <xsl:template match="m:incipCode[not(text())]"/>
    <xsl:template match="m:projectDesc[not(*)]"/>
    <xsl:template match="m:titlePage[not(*)]"/>
    
    <!-- add required elements that may have been deleted -->
    <xsl:template match="m:seriesStmt[not(m:title)]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <title/>
            <xsl:apply-templates select="*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- To support the new Rich Text Editor (tinyMCE) the contents of these elements need to be wrapped in <p> elements -->
    <xsl:template match="
        m:annot[@type='private_notes'] |
        m:annot[@type='general_description'] |
        m:expression/m:notesStmt/m:annot |
        m:annot[@type='source_description'] |
        m:titlePage |
        m:bibl/m:annot">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="m:p or m:list">
                    <!-- already wrapped -->
                    <xsl:apply-templates select="node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <p><xsl:apply-templates select="node()"/></p>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

  

    
    <!-- Add a record of the conversion to revisionDesc -->
    <xsl:template match="m:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <change>
                <xsl:attribute name="isodate"><xsl:value-of 
                    select="concat(date:year(),'-0',date:month-in-year(),'-0',date:day-in-month())"/></xsl:attribute>
                <xsl:attribute name="resp">MerMEId</xsl:attribute>
                <xsl:variable name="generated_id" select="generate-id()"/>
                <xsl:variable name="no_of_nodes" select="count(//*)"/>
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="concat('change_',$no_of_nodes,$generated_id)"/>
                </xsl:attribute>
                <changeDesc>
                    <p>Batch transformation migrating metadata to MerMEId rev. 948+</p>
                </changeDesc>
            </change>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>
