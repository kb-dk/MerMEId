<?xml version="1.0" encoding="UTF-8"?>

<!-- 
	Conversion of MEI metadata to HTML using XSLT 1.0
	
	Authors: 
	Axel Teich Geertinger & Sigfrid Lundberg
	Danish Centre for Music Publication
	The Royal Library, Copenhagen
	2015	
	
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
	<xsl:template match="m:annot[@type='links']"/>
	<xsl:template match="*" mode="comma-separated_links"/>
	<xsl:template match="*[m:ptr[normalize-space(@target)]]" mode="link_list_p"/>

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
		<!-- omit headings for "Music" and "Sections" -->
		<xsl:if test="
			$heading!='Music' and $heading!='Sections'">
			<h3 class="section_heading"><xsl:value-of select="concat(' ',$heading)"/></h3>
		</xsl:if>
		<xsl:copy-of select="$content"/>
	</xsl:template>
	
	<!-- Filter away all relations which are links to reproductions such as CNU -->
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

	<!-- Different formatting templates -->
	
	<!-- work identifiers -->
	<xsl:template match="m:meiHead/m:workDesc/m:work" mode="work_identifiers">
		<p>
			<!-- omit opus and CNW numbers here -->
			<xsl:for-each select="m:identifier[text() and contains(@label,'CNU')]">
				<xsl:if test="position() &gt; 1"><br/></xsl:if>
				<xsl:apply-templates select="@label"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="."/>
			</xsl:for-each>
			<xsl:if test="m:identifier[text() and @label='CNU'] and m:identifier[@label='FS' or @label='CNS']">
				<br/>
			</xsl:if>
			<!-- put FS and CNS numbers on a single line -->
			<xsl:for-each select="m:identifier[text() and (@label='CNS' or @label='FS')]">
				<xsl:if test="position() &gt; 1">, </xsl:if>
				<xsl:apply-templates select="@label"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="."/>
			</xsl:for-each>
		</p>
	</xsl:template>
	
	<!-- Title pages -->
	<xsl:template match="m:titlePage">
		<xsl:if test="position() &gt; 1">.</xsl:if>
		<xsl:text> </xsl:text>
		<xsl:if test="not(@label) or @label=''">Title page</xsl:if>
		<xsl:value-of select="@label"/>
		<xsl:text>: </xsl:text>
		<xsl:for-each select="m:p[//text()]">
			<span class="titlepage">
				<xsl:apply-templates/>
			</span>
		</xsl:for-each>
	</xsl:template>
	
	<!-- compact source description -->
	<xsl:template match="m:source[*[name()!='classification']//text()]|m:item[*//text()]">
		<xsl:param name="mode" select="''"/>
		<xsl:param name="reprints"/>
		<xsl:variable name="source_id" select="@xml:id"/>
		<xsl:variable name="html_content">
			<!-- source title -->
			<xsl:for-each select="m:titleStmt[m:title/text()]">
				<b><xsl:apply-templates select="m:title"/></b>.
			</xsl:for-each>
			<!-- item label -->
			<xsl:if test="local-name()='item' and normalize-space(@label) and name(..)!='componentGrp'">
				<xsl:value-of select="@label"/>.
			</xsl:if>
<!--			
			<xsl:call-template name="list_agents"/>			
			<xsl:apply-templates select="m:classification/m:termList[m:term[text()]]"/>
-->			
			<xsl:for-each select="m:titleStmt[m:respStmt/m:persName/text()]">
				<xsl:call-template name="list_agents"/>
			</xsl:for-each>
			
			<xsl:for-each select="m:pubStmt[normalize-space(concat(m:publisher, m:date, m:pubPlace))]">
					<xsl:if test="m:publisher/text()">
						<xsl:apply-templates select="m:publisher"/>
						<xsl:if test="normalize-space(concat(m:date,m:pubPlace))">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:if>
					<xsl:apply-templates select="m:pubPlace"/>
					<xsl:if test="m:date/text()">
						<xsl:text> </xsl:text>
						<xsl:apply-templates select="m:date"/>
					</xsl:if>
					<xsl:text>.</xsl:text>
			</xsl:for-each>
			
			<xsl:for-each select="m:physDesc">
				<xsl:apply-templates select="."/>
			</xsl:for-each>
			
			<xsl:for-each select="m:notesStmt">
				<xsl:for-each select="m:annot[text() or *//text()]">
					<xsl:apply-templates select="."/>
				</xsl:for-each>
			</xsl:for-each>
			
			<!-- source location and identifiers -->
			<xsl:for-each select="m:physLoc[m:repository//text() or m:identifier/text()]">
					<xsl:apply-templates select="."/>
			</xsl:for-each>
						
			<xsl:for-each select="m:identifier[text()]">
					(<xsl:apply-templates select="@label"/>
					<xsl:text> </xsl:text>
					<xsl:choose>
						<!-- some CNW-specific styling here -->
						<xsl:when test="contains(@label,'CNU') and contains(@label,'Source')">
							<b><xsl:apply-templates select="."/></b>) </xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="."/>. </xsl:otherwise>
					</xsl:choose>
			</xsl:for-each>
			
			<!-- List exemplars (items) last if there is more than one or if it does have a heading of its own. 
			     Otherwise, this is assumed to be a manuscript with some information given at item level, 
			     which should be shown before the components. -->
			<xsl:choose>
				<xsl:when
					test="local-name()='source' and 
					(count(m:itemList/m:item[//text()])&gt;1 or 
					(m:itemList/m:item/@label and m:itemList/m:item/@label!=''))">
					<xsl:apply-templates select="m:componentGrp"/>
					<xsl:apply-templates select="m:itemList"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="m:itemList"/>
					<xsl:apply-templates select="m:componentGrp"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- List reproductions (reprints) -->
			<xsl:if test="$reprints">
				<xsl:for-each select="$reprints/m:sourceDesc/m:source[m:relationList/m:relation[@rel='isReproductionOf'
					and substring-after(@target,'#')=$source_id]]">
					<xsl:if test="position()=1">
						<xsl:if test="not(m:titleStmt/m:title/text())">
							<br/>Reprint:
						</xsl:if>
					</xsl:if>
					<xsl:apply-templates select=".">
						<xsl:with-param name="mode">reprint</xsl:with-param>
					</xsl:apply-templates>
				</xsl:for-each>
			</xsl:if>			
			
		</xsl:variable>
		
		<!-- output the resulting source html -->
		<xsl:choose>
			<xsl:when test="local-name(.)='source'">
				<p class="source">
					<xsl:copy-of select="$html_content"/>
				</p>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$html_content"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	
	
</xsl:stylesheet>
