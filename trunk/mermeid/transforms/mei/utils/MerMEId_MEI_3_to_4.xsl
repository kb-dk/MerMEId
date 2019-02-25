<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet     
    xmlns="http://www.music-encoding.org/ns/mei" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:m="http://www.music-encoding.org/ns/mei" 
    xmlns:xl="http://www.w3.org/1999/xlink"
    xmlns:date="http://exslt.org/dates-and-times"
    exclude-result-prefixes="m xl xsl date"
    version="2.0">
    
    <!-- 
    Transform MEI header information created with MerMEId from MEI 3.0.0 to MEI 4.0.0.
    
    Caution: This transform is made specifically for transforming metadata created using 
    MEI 3.0.0-versions of MerMEId. Metadata from other applications or older versions of MerMEId 
    may or may not be successfully transformed with it.
    
    Axel Teich Geertinger
    Royal Danish Library, 2019    
    
    -->
    
    <xsl:output indent="yes" encoding="UTF-8"/>
    
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">
        <xsl:processing-instruction name="xml-model">href="https://music-encoding.org/schema/4.0.0/mei-all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
        <xsl:text>
</xsl:text>
        <xsl:processing-instruction name="xml-model">xml-model href="https://music-encoding.org/schema/4.0.0/mei-all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
        <xsl:text>
</xsl:text>
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="m:mei">
        <xsl:copy>
            <xsl:attribute name="meiversion">4.0.0</xsl:attribute>
            <xsl:apply-templates select="@*[not(local-name()='meiversion')] | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- RENAME ELEMENTS AND ATTRIBUTES -->
    
    <xsl:template match="m:componentGrp">
        <componentList><xsl:apply-templates select="@* | node()"/></componentList>
    </xsl:template>
    
    <xsl:template match="m:workDesc">
        <workList><xsl:apply-templates select="@* | node()"/></workList>
    </xsl:template>
    
    <xsl:template match="m:work/m:titleStmt/m:respStmt | m:expression/m:titleStmt/m:respStmt">
        <contributor><xsl:apply-templates select="@* | node()"/></contributor>
    </xsl:template>

    <xsl:template match="m:revisionDesc/m:change/m:respStmt/m:resp">
        <name><xsl:apply-templates select="@* | node()"/></name>
    </xsl:template>
    
    <xsl:template match="@authority">
        <xsl:attribute name="auth" select="."/>
    </xsl:template>
    
    <xsl:template match="@authURI">
        <xsl:attribute name="auth.uri" select="."/>
    </xsl:template>
    
    <xsl:template match="@classcode">
        <xsl:attribute name="class" select="."/>
    </xsl:template>
    
    <xsl:template match="@xl:title">
        <xsl:if test="not(../@label)">
            <xsl:attribute name="label"><xsl:value-of select="."/></xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!-- Music -->
    <xsl:template match="@barthru">
        <xsl:attribute name="bar.thru" select="."/>
    </xsl:template>
    

    <!-- MOVE ELEMENTS -->     
    
    <!-- Move sources to manifestation list -->
    <xsl:template match="m:sourceDesc"/>
    
    <xsl:template match="m:sourceDesc" mode="move">
        <manifestationList>
            <xsl:apply-templates select="@* | node()"/>
        </manifestationList>
    </xsl:template>
    
    <xsl:template match="m:source">
        <manifestation><xsl:apply-templates select="@* | node()"/></manifestation>
    </xsl:template>
    
    <xsl:template match="m:meiHead">
        <xsl:copy>
            <xsl:apply-templates select="@* | m:altId | m:fileDesc | m:encodingDesc | m:workDesc"/>
            <xsl:apply-templates select="m:fileDesc/m:sourceDesc" mode="move"/>
            <xsl:apply-templates select="m:extMeta | m:revisionDesc"/>
        </xsl:copy>
    </xsl:template>

    <!-- Move source taxonomy  -->
    <xsl:template match="m:encodingDesc">
        <xsl:copy>
            <xsl:apply-templates select="@* | *"/>
            <classDecls>
                <taxonomy xml:id="DcmSourceClassification">
                    <xsl:apply-templates select="../m:workDesc/m:work/m:classification/m:classCode" mode="move"></xsl:apply-templates>
                </taxonomy>
            </classDecls>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="m:classCode"/>
    
    <xsl:template match="m:classCode" mode="move">
        <category>
            <xsl:apply-templates select="@xml:id"/>
        </category>
    </xsl:template>
    
    <!-- Move provenance -->
    <xsl:template match="m:provenance"/>
    
    <xsl:template match="m:item[m:physLoc/m:provenance]">
        <xsl:copy>
            <xsl:apply-templates select="@* | m:head | m:identifier | m:availability | m:physDesc | m:physLoc"/>
            <history>
                <xsl:copy-of select="m:physLoc/m:provenance"/>
            </history>
            <xsl:apply-templates select="m:notesStmt | m:classification | m:componentGrp | m:relationList | m:extMeta"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- DELETE ELEMENTS -->
    
    <xsl:template match="m:work/m:titleStmt | m:expression/m:titleStmt">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <xsl:template match="m:source/m:titleStmt/m:respStmt[not(*)] | m:item/m:titleStmt/m:respStmt[not(*)]"/>

    <!-- MISCELLANEOUS -->

    <xsl:template match="@*|*">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Add a record of the conversion to revisionDesc  -->
    <xsl:template match="m:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <change>
                <xsl:attribute name="isodate"><xsl:value-of select="date:date-time()"/></xsl:attribute>
                <xsl:variable name="generated_id" select="generate-id()"/>
                <xsl:variable name="no_of_nodes" select="count(//*)"/>
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="concat('change_',$no_of_nodes,$generated_id)"/>
                </xsl:attribute>
                <respStmt>
                    <resp>MerMEId</resp>
                </respStmt>
                <changeDesc>
                    <p>Transform from MEI 3.0.0 to 4.0.0</p>
                </changeDesc>
            </change>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
