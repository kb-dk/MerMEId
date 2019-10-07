<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2">
    
    <xsl:param name="resources-endpoint" select="'http://localhost:8080/exist/apps/mermeid/resources'"/>
    <xsl:param name="forms-endpoint" select="'http://172.17.0.2:8080/exist/apps/mermeid/forms'"/>
    
    <xsl:template match="@src[contains(., 'editor/images/')]">
        <xsl:attribute name="src">
            <xsl:value-of select="replace(., '.*editor', $resources-endpoint)"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@src[contains(., 'editor/js/')]">
        <xsl:attribute name="src">
            <xsl:value-of select="replace(., '.*editor/js', concat($resources-endpoint, '/js'))"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@src[contains(., 'model')]">
        <xsl:attribute name="src">
            <xsl:value-of select="replace(., '.*model', concat($forms-endpoint, '/mei/model'))"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@resource[contains(., 'model')]">
        <xsl:attribute name="resource">
            <xsl:value-of select="replace(., '.*model', concat($forms-endpoint, '/mei/model'))"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@src[contains(., 'properties.xml')]">
        <xsl:attribute name="src">
            <xsl:value-of select="concat($forms-endpoint, '/../properties.xml')"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="text()[contains(., 'editor/images/')]">
        <xsl:value-of select="replace(., '.*editor', $resources-endpoint)"/>
    </xsl:template>
    
    <xsl:template match="text()[contains(., '/editor/style/')]">
        <xsl:value-of select="replace(., '/editor/style', concat($resources-endpoint, '/css'))"/>
    </xsl:template>
    
</xsl:stylesheet>