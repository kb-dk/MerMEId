<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dcm="http://www.kb.dk/dcm"
    xmlns:xf="http://www.w3.org/2002/xforms"
    version="2">
    
    <xsl:param name="xslt.resources-endpoint" select="'http://localhost:8080/exist/apps/mermeid/resources'"/>
    
    <xsl:param name="xslt.orbeon-endpoint" select="'http://172.17.0.2:8080/exist/apps/mermeid/forms'"/>
    <xsl:param name="xslt.exist-endpoint-seen-from-orbeon" select="'http://172.17.0.2:8080/exist/apps/mermeid/forms'"/>
    <xsl:param name="xslt.server-name"/>
    <xsl:param name="xslt.exist-dir"/>
    <xsl:param name="xslt.document-root"/>
    
    <xsl:variable name="xforms-parameters" as="element(dcm:parameters)">
        <parameters xmlns="http://www.kb.dk/dcm">
            
            <!-- paths -->
            
            <orbeon_dir><xsl:value-of select="$xslt.orbeon-endpoint"/></orbeon_dir>
            <form_home><xsl:value-of select="$xslt.exist-endpoint-seen-from-orbeon"/>/forms/mei/</form_home>
            
            <crud_home><xsl:value-of select="$xslt.exist-endpoint-seen-from-orbeon"/>/data/</crud_home>
            <library_crud_home><xsl:value-of select="$xslt.exist-endpoint-seen-from-orbeon"/>/library/</library_crud_home>
            <rism_crud_home><xsl:value-of select="$xslt.exist-endpoint-seen-from-orbeon"/>/rism_sigla/</rism_crud_home>
            
            <server_name><xsl:value-of select="$xslt.server-name"/></server_name>  
            <exist_dir><xsl:value-of select="$xslt.exist-dir"/></exist_dir>
            <document_root><xsl:value-of select="$xslt.document-root"/></document_root>
            
            <!-- Default editor settings - (boolean; set to 'true' or nothing)  -->
            <!-- Enable automatic revisionDesc (change log) entries? -->
            <automatic_log_main_switch>true</automatic_log_main_switch>
            
            <!-- The following settings add options to the editor's settings menu -->
            <!-- Enable attribute editor? -->
            <attr_editor_main_switch>true</attr_editor_main_switch>
            <!-- Enable xml:id display component? -->
            <id_main_switch>true</id_main_switch>
            <!-- Enable code inspector component? -->
            <code_inspector_main_switch>true</code_inspector_main_switch>
            
            
            <!-- Some elements used internally by XForms - not for user configuration -->
            <xml_file/>
            <return_uri/>
            <this_page/>
            <attr_editor/>
            <show_id/>
            <code_inspector/>
            
        </parameters>
    </xsl:variable>
    
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
            <xsl:value-of select="replace(., '.*model', concat($xslt.exist-endpoint-seen-from-orbeon, '/forms/mei/model'))"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@resource[contains(., 'model')]">
        <xsl:attribute name="resource">
            <xsl:value-of select="replace(., '.*model', concat($xslt.exist-endpoint-seen-from-orbeon, '/forms/mei/model'))"/>
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