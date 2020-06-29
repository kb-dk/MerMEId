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
    
    <xsl:variable name="old-index-jsp-regexp">\s*((xxf:)?instance\('parameters'\)|\$parameters)/dcm:orbeon_dir,\s*'\?uri='</xsl:variable>
    <xsl:variable name="old-uri-request-parameter">,\s*xxf:get-request-parameter\('uri'\),\s*'&amp;</xsl:variable>
    <xsl:variable name="old-form-home-form-xml">,\s*((xxf:)?instance\('parameters'\)|\$parameters)/dcm:form_home,\s*'([^&amp;]+)&amp;</xsl:variable>
    <xsl:variable name="form_home_replacement">'<xsl:value-of select="$xforms-parameters/dcm:form_home"/>$5?</xsl:variable>
    <xsl:variable name="request-path-replacement">xxf:get-request-path(), '?</xsl:variable>
    
    <xsl:template match="@value[contains(., '?uri=') and contains(., 'xxf:get-request-parameter(')]" priority="2">       
        <xsl:attribute name="value">
            <xsl:value-of select="replace(., concat($old-index-jsp-regexp, $old-uri-request-parameter), $request-path-replacement)"/>
        </xsl:attribute>        
    </xsl:template>
    
    <xsl:template match="@value[contains(., '?uri=')]">
        <xsl:attribute name="value">
            <xsl:value-of select="replace(., concat($old-index-jsp-regexp, $old-form-home-form-xml), $form_home_replacement)"/>
        </xsl:attribute>
    </xsl:template>
           
    <xsl:template match="@select[contains(., '?uri=')]">
        <xsl:attribute name="select">
            <xsl:value-of select="replace(., concat($old-index-jsp-regexp, $old-form-home-form-xml), $form_home_replacement)"/>
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