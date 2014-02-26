<?xml version="1.0" encoding="UTF-8" ?>
<!-- 
  This XSLT creates a clean MEI encoding for public download 
  
  Axel Teich Geertinger & Sigfrid Lundberg
  Danish Centre for Music Publication
  The Royal Library, Copenhagen 2014
  
-->
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.music-encoding.org/ns/mei" 
  xmlns:m="http://www.music-encoding.org/ns/mei" 
  xmlns:dcm="http://www.kb.dk/dcm" 
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns:h="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  exclude-result-prefixes="xsl m t exsl"
  version="1.0">
  
  <xsl:output method="xml"
    encoding="UTF-8"
    omit-xml-declaration="yes" 
    indent="yes"/>
  <xsl:strip-space elements="*" />
  <xsl:strip-space elements="node"/>
  
  <xsl:param name="hostname"/>
  
  <!-- GLOBAL VARIABLES -->
  <xsl:variable name="settings"
    select="document(concat('http://',$hostname,'/editor/forms/mei/mermeid_configuration.xml'))"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="@*|*"/>
  </xsl:template>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="m:annot[@type='private_notes']">
    <!-- private notes not shown in public -->
    <m:annot>
      <xsl:apply-templates select="@*"/>
      <xsl:comment> Private notes omitted </xsl:comment>
    </m:annot>
  </xsl:template>
  
  <!-- get external source description -->
  <xsl:template match="m:source[@target!='']">
    <xsl:variable name="ext_id" select="substring-after(@target,'#')"/>
    <xsl:variable name="doc_name"
      select="concat('http://',$hostname,'/',$settings/dcm:parameters/dcm:document_root,substring-before(@target,'#'))"/>
    <xsl:variable name="doc" select="document($doc_name)"/>
    <m:source>
      <xsl:apply-templates select="@*[name()!='target' and name()!='xml:id']"/>
      <xsl:attribute name="xml:id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      <xsl:comment> Source description imported from <xsl:value-of select="@target"/> </xsl:comment>
      <!-- copy all elements from external description except relations -->
      <xsl:apply-templates
        select="$doc/m:mei/m:meiHead/m:fileDesc/m:sourceDesc/m:source[@xml:id=$ext_id]/*[name()!='relationList']"/>
      <xsl:apply-templates select="m:relationList"/>
    </m:source>
  </xsl:template>
  
  
</xsl:transform>
