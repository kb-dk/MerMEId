<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.music-encoding.org/ns/mei" 
  xmlns:m="http://www.music-encoding.org/ns/mei" 
  xmlns:dcm="http://www.kb.dk/dcm" 
  xmlns:h="http://www.w3.org/1999/xhtml"
  xmlns:xl="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="m dcm h xl"
  version="1.0">
  
  <!-- 
  This XSLT creates a clean MEI encoding for public download 
  
  Axel Teich Geertinger & Sigfrid Lundberg
  Danish Centre for Music Editing
  The Royal Library, Copenhagen 2014
-->
  
  <xsl:output method="xml"
    encoding="UTF-8"
    omit-xml-declaration="yes" 
    indent="yes"/>
  <xsl:strip-space elements="*" />
  
  <xsl:param name="hostname"/>
  
  <!-- GLOBAL VARIABLES -->
  <xsl:variable name="settings"
    select="document(concat('http://',$hostname,'/editor/forms/mei/mermeid_configuration.xml'))"/>
  
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="m:annot[@type='private_notes']">
    <!-- private notes not shown in public -->
    <annot>
      <xsl:apply-templates select="@*"/>
      <xsl:comment> Private notes omitted </xsl:comment>
    </annot>
  </xsl:template>
  
  <!-- get external source description --> 
  <xsl:template match="m:source[@target!='']">
    <xsl:variable name="ext_id" select="substring-after(@target,'#')"/>
    <!-- Ouch! directory name "public" hard-coded here - can we find some more generic solution? -->
    <xsl:variable name="doc_name"
      select="concat('http://',$hostname,'/',$settings/dcm:parameters/dcm:exist_dir,'public/',substring-before(@target,'#'))"/>
    <xsl:variable name="doc" select="document($doc_name)"/>
    <source>
      <xsl:apply-templates select="@*[name()!='target' and name()!='xml:id' and name()!='label']"/>
      <xsl:attribute name="xml:id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      <xsl:comment> Source description imported from <xsl:value-of select="@target"/> </xsl:comment>
      <xsl:apply-templates
        select="$doc//m:meiHead/m:fileDesc/m:sourceDesc/m:source[@xml:id=$ext_id]/*[name()!='relationList']"/>
      <xsl:apply-templates select="m:relationList"/>
    </source>
  </xsl:template>
  
  
</xsl:transform>
