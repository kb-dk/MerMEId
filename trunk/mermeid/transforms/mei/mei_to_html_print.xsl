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
		omit-xml-declaration="yes"/>
	
	<xsl:include href="mei_to_html_public.xsl"/>
	
	<!-- omit colophon -->
	<xsl:template match="*" mode="colophon"/>
	
	<!-- omit metre (as it is shown in the incipits) -->
	<xsl:template match="m:meter"/>
	
	<!-- show all folding sections -->
	<xsl:template match="*" mode="fold_section">
		<xsl:param name="heading"/>
		<xsl:param name="id"/>
		<xsl:param name="content"/>
		<!-- omit "Music" and "Sections" headings in print -->
		<xsl:if test="$heading!='Music' and $heading!='Sections'">
			<h3 class="section_heading"><xsl:value-of select="concat(' ',$heading)"/></h3>
		</xsl:if>
		<div class="folded_content">
			<xsl:copy-of select="$content"/>
		</div>
	</xsl:template>
	
</xsl:stylesheet>
