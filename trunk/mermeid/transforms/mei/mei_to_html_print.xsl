<?xml version="1.0" encoding="UTF-8"?>

<!-- 
	Conversion of MEI metadata to HTML using XSLT 1.0
	
	Authors: 
	Axel Teich Geertinger & Sigfrid Lundberg
	Danish Centre for Music Publication
	The Royal Library, Copenhagen
	2010-2014	
	
-->


<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:m="http://www.music-encoding.org/ns/mei" 
	xmlns:dcm="http://www.kb.dk/dcm" 
	xmlns:xl="http://www.w3.org/1999/xlink" 
	xmlns:foo="http://www.kb.dk/foo"
	xmlns:exsl="http://exslt.org/common" 
	xmlns:java="http://xml.apache.org/xalan/java"
	xmlns:zs="http://www.loc.gov/zing/srw/" 
	xmlns:marc="http://www.loc.gov/MARC21/slim" 
	extension-element-prefixes="exsl java" 
	exclude-result-prefixes="m xsl exsl foo java">
	
	<xsl:output method="xml" encoding="UTF-8" 
		cdata-section-elements="" 
		omit-xml-declaration="yes" indent="no"/>
	
	<xsl:strip-space elements="*"/>
	
	
	<xsl:include href="mei_to_html.xsl"/>
	
	<!-- Exceptions/alterations -->
	
	<!-- show crosslinks as plain text -->
	<!--<xsl:template match="m:relation[@label!='']" mode="relation_link">
		<p><xsl:value-of select="@label"/></p>
	</xsl:template>-->	
	
	
	<!-- omit colophon -->
	<xsl:template match="*" mode="colophon"/>
	
	<!-- omit music details shown in the incipits -->
	<xsl:template match="m:meter"/>
	<xsl:template match="m:tempo"/>
	<xsl:template match="m:key[normalize-space(concat(@pname,@accid,@mode))]"/>
	<xsl:template match="m:incipText"/>
	
	<!-- omit links -->
	<xsl:template match="m:ptr"/>

	<!-- omit sources -->
	<xsl:template match="m:sourceDesc"/>
	<xsl:template match="m:source"/>
	
	
	<!-- omit bibliography -->
	<xsl:template match="m:work/m:biblList"/>
	
	<!-- omit pop-up information -->
	<xsl:template match="m:bibl//m:title | m:identifier[@authority='RISM'] | m:instrVoice/text() | 
		m:identifier/text() | m:identifier/@label">
		<xsl:value-of select="."/>
	</xsl:template>
	
	<!-- omit all things not intended for print -->
	<xsl:template match="*[contains(@class,'noprint')]"/>
	
	
	<!-- expand all folding sections -->
	<xsl:template match="*" mode="fold_section">
		<xsl:param name="heading"/>
		<xsl:param name="id"/>
		<xsl:param name="content"/>
		<xsl:choose>
			<!-- omit sources -->
			<xsl:when test="$heading='Sources'"/>
			<xsl:otherwise>
				<!-- omit headings for "Music" and "Sections" -->
				<xsl:if test="
					$heading!='Music' and $heading!='Sections'">
					<h3 class="section_heading"><xsl:value-of select="concat(' ',$heading)"/></h3>
				</xsl:if>
					<xsl:copy-of select="$content"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Filter away all links to reproductions such as CNU -->
	<xsl:template match="m:work/m:relationList | m:expression/m:relationList">
		<xsl:variable name="relationList">
			<relationList xmlns="http://www.music-encoding.org/ns/mei">
				<xsl:for-each select="m:relation[@rel!='hasReproduction']">
					<xsl:copy-of select="."/>
				</xsl:for-each>
			</relationList>
		</xsl:variable>
		<!-- make the list a nodeset -->
		<xsl:variable name="relationList_nodeset" select="exsl:node-set($relationList)"/>
		<xsl:apply-templates select="$relationList_nodeset/m:relationList" mode="relation_list"/>
	</xsl:template>
	
</xsl:stylesheet>
