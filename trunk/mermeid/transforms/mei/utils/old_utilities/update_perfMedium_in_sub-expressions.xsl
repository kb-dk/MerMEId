<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.music-encoding.org/ns/mei" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xl="http://www.w3.org/1999/xlink" xmlns:m="http://www.music-encoding.org/ns/mei"
    xmlns:t="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="m xsl" xmlns:uuid="java:java.util.UUID" version="2.0">
    
    <!--    Changes reference to ancestor element's instrumentation (using @n as pointer) 
            into an independent COPY of the referenced element 
            to enable editing of instrumentation at sub-level.
            Use to transform data created with MerMEId versions earlier than 646.
            
            Axel Geertinger (atge@kb.dk), November 2013
    -->

    <xsl:template match="@*|*">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="m:perfMedium/*//*[@n=//m:perfMedium//*/@xml:id]">
        <xsl:variable name="id" select="@n"/>
        <xsl:variable name="copy" select="."/>
        <xsl:variable name="origin" select="//m:perfMedium//*[@xml:id=$id]"/>
        <xsl:element name="{local-name()}">
            <xsl:for-each select="$origin/@*">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:attribute name="n" select="$id"/>
            <xsl:attribute name="xml:id">
                <xsl:value-of select="concat(local-name(),'_',generate-id(.))"/>
                <xsl:number level="any" count="//node()"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="local-name()='instrVoiceGrp' or local-name()='castList'">
                    <xsl:apply-templates select="$origin/m:head"/>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="$origin/node()[local-name()!='roleDesc'] | $origin/text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
