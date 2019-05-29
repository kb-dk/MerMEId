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
        
        Please note: Any encoded music - whether in <music> or <incip> – is NOT transformed
        
        Axel Teich Geertinger
        Royal Danish Library, 2019    
        
    -->
    
    <xsl:output indent="yes" encoding="UTF-8"/>
    
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">
        <!--<xsl:processing-instruction name="xml-model">href="https://music-encoding.org/schema/4.0.0/mei-all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
        <xsl:text>
</xsl:text>
        <xsl:processing-instruction name="xml-model">xml-model href="https://music-encoding.org/schema/4.0.0/mei-all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
        <xsl:text>
</xsl:text>-->
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
    
    <xsl:template match="@key.sig.showchange">
        <xsl:attribute name="keysig.showchange" select="."/>
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
                    <xsl:apply-templates select="../m:workDesc/m:work/m:classification/m:classCode" mode="move"/>
                </taxonomy>
            </classDecls>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="m:workDesc/m:work/m:classification/m:classCode"/>
    
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
    
    
    <!-- DELETE ELEMENTS AND ATTRIBUTES -->
    
    <!-- Move contents out of <titleStmt> in work and expression -->
    <xsl:template match="m:work/m:titleStmt | m:expression/m:titleStmt">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <!-- Delete empty <respStmt> elements -->
    <xsl:template match="m:source/m:titleStmt/m:respStmt[not(*)] | m:item/m:titleStmt/m:respStmt[not(*)]"/>
    
    <!-- MEI elements names now correspond to FRBR group 1 entity names; no need to specify the analogy -->
    <xsl:template match="*[name()='work' or name()='expression' or name()='source' or name()='item']/@analog[contains(.,'frbr:')]"/>
    

    <!-- CORRECTIONS -->

    <!-- Cleaning up an old misconception... -->
    <xsl:template match="m:hand/@initial">
        <xsl:attribute name="type">
            <xsl:choose>
                <xsl:when test=".='true'">main</xsl:when>
                <xsl:otherwise>additions</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <!-- Cleaning up errors generated prior to bugfix for issue #132: -->
    <!-- https://github.com/Det-Kongelige-Bibliotek/MerMEId/issues/132 -->
    <!-- (moving <creation> out of <history> in <expression>)  -->
    <xsl:template match="m:expression">
        <xsl:element name="expression" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="m:head | m:identifier | m:title"/>
            <xsl:apply-templates select="m:contributor | m:author | m:arranger | m:composer | m:editor | m:funder"/>
            <xsl:apply-templates select="m:incip | m:tempo | m:key | m:mensuration | m:meter | m:otherChar"/>
            <xsl:apply-templates select="m:creation"/>
            <xsl:if test="m:history/m:creation">
                <creation>
                    <xsl:apply-templates select="m:history/m:creation/@* | m:history/m:creation/node()"/>
                </creation>
            </xsl:if>
            <xsl:apply-templates select="m:history"/>
            <xsl:apply-templates select="m:langUsage | m:perfMedium | m:perfDuration | m:contents | m:context"/>
            <xsl:apply-templates select="m:biblList | m:notesStmt | m:classification"/>
            <xsl:apply-templates select="m:componentList | m:relationList | m:extMeta"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="m:expression/m:history/m:creation"/>     
    
    <!-- Add # to @source IDref if missing -->
    <xsl:template match="@source">
        <xsl:attribute name="source">#<xsl:value-of select="translate(.,'#','')"/></xsl:attribute>
    </xsl:template>
    
    <!-- Move source-specific instrumentations inside main <perfResList> (only one <perfResList> allowed in <perfMedium>)  -->
    <xsl:template match="m:perfMedium/m:perfResList[@source and ../m:perfResList[not(@source)]]">
        <!-- Delete only if there is a general <perfResList> element to move it into -->
    </xsl:template>
    <xsl:template match="m:perfMedium/m:perfResList[not(@source)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | *"/>
            <xsl:copy-of select="//m:perfResList[@source]"/>
        </xsl:copy>
    </xsl:template>
    

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
                    <name>MerMEId</name>
                </respStmt>
                <changeDesc>
                    <p>Transform from MEI 3.0.0 to 4.0.0</p>
                </changeDesc>
            </change>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
