<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dcm="http://www.kb.dk/dcm"
    xmlns:xf="http://www.w3.org/2002/xforms"
    version="2.0">
    
    <xsl:include href="mermeid_configuration.xsl" />
    
    <xsl:template match="@src[contains(., 'editor/images/')]">
        <xsl:attribute name="src">
            <xsl:value-of select="replace(., '.*editor', $xslt.resources-endpoint)"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@src[contains(., 'editor/js/')]">
        <xsl:attribute name="src">
            <xsl:value-of select="replace(., '.*editor/js', concat($xslt.resources-endpoint, '/js'))"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@src[contains(., 'model')]">
        <xsl:attribute name="src">
            <xsl:value-of select="replace(., '.*model', concat($xslt.exist-endpoint-seen-from-orbeon, '/forms/model'))"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@resource[contains(., 'model')]">
        <xsl:attribute name="resource">
            <xsl:value-of select="replace(., '.*model', concat($xslt.exist-endpoint-seen-from-orbeon, '/forms/model'))"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@resource[contains(., 'manual')]">
        <xsl:attribute name="resource">
            <xsl:value-of select="replace(., '.*manual', concat($xslt.resources-endpoint, '/../manual'))"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="xf:instance[@id='parameters']">
        <xsl:copy>
            <xsl:apply-templates select="@* except @src"/>
            <xsl:sequence select="$xforms-parameters"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[contains(., 'editor/images/')]">
        <xsl:value-of select="replace(., '.*editor', $xslt.resources-endpoint)"/>
    </xsl:template>
    
    <xsl:template match="text()[contains(., '/editor/style/')]">
        <xsl:value-of select="replace(., '/editor/style', concat($xslt.resources-endpoint, '/css'))"/>
    </xsl:template>
    
</xsl:stylesheet>