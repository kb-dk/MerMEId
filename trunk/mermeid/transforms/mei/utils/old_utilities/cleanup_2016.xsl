<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.music-encoding.org/ns/mei"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:m="http://www.music-encoding.org/ns/mei"
    xmlns:xl="http://www.w3.org/1999/xlink" 
    version="1.0" 
    exclude-result-prefixes="m xsl xl">

    <!-- 
        
        After migrating from YUI RTE to TinyMCE for text editing, 
        <rend> elements with no recognizable attributes spanning entire text blocks have caused their content to 
        fall outside the containing parent element. For instance:
        
        <annot>
            <p><rend>Some content</rend><p>
        </annot>
        
        may have become
        
        <annot>
            <rend>Some content</rend>
            <p></p>
        </annot>
        
        This transform puts the contents back in place.
        It also checks for duplicate @xml:id values.
        
        DCM, March 2016
        
    -->
    
    
    <xsl:output indent="yes" xml:space="default" method="xml" encoding="UTF-8"
        omit-xml-declaration="yes"/>

    <xsl:key name="ids" match="*[@xml:id]" use="@xml:id"/> 
    
    <xsl:strip-space elements="*"/>

    <xsl:template match="/m:mei">
        <xsl:copy>
            <xsl:apply-templates select="@*|*"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="m:titlePage[(*[not(local-name(.)='p')] or text()) and count(m:p[not(* or text())])=1]
        | m:annot[(*[not(local-name(.)='p')] or text()) and m:p[not(* or text())]]">
        <!-- elements containing mixed content and an empty <p>: 
        put mixed content back into the <p> element -->
        <xsl:element name="{local-name(.)}" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="@*"/>
            <p>
                <xsl:apply-templates select="m:p/@*"/>
                <xsl:apply-templates select="text() | *[name()!='p']"/>
            </p>
        </xsl:element>
    </xsl:template>
    
    
    <!-- Remove <rend> elements without any rendition information or empty -->
    <xsl:template match="m:rend">
        <xsl:choose>
            <xsl:when test="count(@*[local-name(.)!='xml:id'])>0 and (* or text())">
                <!-- contains relevant attributes and content; just copy it -->
                <xsl:element name="rend" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates select="node()"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <!-- no qualifying attributes or no content; omit <rend> -->
                <xsl:apply-templates select="node()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Change duplicate IDs -->
    <xsl:template match="*[@xml:id and count(key('ids', @xml:id)) &gt; 1]">
        <xsl:variable name="duplicateID" select="@xml:id"/>        
        <xsl:element name="{name()}">
            <xsl:apply-templates select="@*"/>
            <!-- Append a number to the ID according to its number of occurrence -->
            <xsl:variable name="newval">
                <xsl:choose>
                    <xsl:when test="substring(@xml:id,1,1)='_'">
                        <!-- add element name if xml:id seems to be something like '_13' -->
                        <xsl:value-of select="concat(name(),@xml:id)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@xml:id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:attribute name="xml:id">
                <xsl:value-of select="concat($newval,'_',count(preceding::*[@xml:id=$duplicateID]))"/>
            </xsl:attribute>
            <!-- To log changes: -->
            <!--<xsl:comment>Duplicate ID (<xsl:value-of select="$duplicateID"/>) changed</xsl:comment>-->
            <xsl:apply-templates select="node()"/>        
        </xsl:element>
    </xsl:template>    


    <!-- Add a record of the conversion to revisionDesc -->
    <xsl:template match="m:revisionDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <change>
                <xsl:attribute name="isodate"><xsl:value-of 
                    select="format-date(current-date(),'[Y]-[M02]-[D02]')"/></xsl:attribute>
                <xsl:attribute name="resp">MerMEId</xsl:attribute>
                <xsl:variable name="generated_id" select="generate-id()"/>
                <xsl:variable name="no_of_nodes" select="count(//*)"/>
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="concat('change_',$no_of_nodes,$generated_id)"/>
                </xsl:attribute>
                <changeDesc>
                    <p>Batch transformation putting misplaced text back in place</p>
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
