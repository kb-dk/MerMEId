<?xml version="1.0" encoding="UTF-8"?>

<!-- 
	Conversion of MEI metadata to HTML using XSLT 1.0
	
	Authors: 
	Axel Teich Geertinger & Sigfrid Lundberg
	Danish Centre for Music Publication
	The Royal Library, Copenhagen 2014
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
	
	
	<xsl:strip-space elements="*"/>

	<xsl:include href="mei_to_html.xsl"/>

	<!-- MAIN TEMPLATE -->
	<xsl:template match="m:mei" xml:space="default">
		<div class="content_box">
			<div id="main_content">
				<div id="backlink" class="noprint">
					<a href="javascript:history.back();">Back</a>
				</div>

				<!-- main identification -->
				<xsl:variable name="file_context">
					<xsl:value-of
						select="m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type='file_collection']"
					/>
				</xsl:variable>

				<xsl:variable name="catalogue_no">
					<xsl:value-of
						select="m:meiHead/m:workDesc/m:work/m:identifier[@label=$file_context]"/>
				</xsl:variable>

				<div class="info_bar {$file_context}">
					<xsl:if
						test="m:meiHead/m:workDesc/m:work/m:identifier[@label=$file_context]/text()">
						<span class="list_id">
							<xsl:value-of select="$file_context"/>
							<xsl:text> </xsl:text>
							<xsl:choose>
								<xsl:when test="string-length($catalogue_no)&gt;11">
									<xsl:variable name="part1"
										select="substring($catalogue_no, 1, 11)"/>
									<xsl:variable name="part2" select="substring($catalogue_no, 12)"/>
									<xsl:variable name="delimiter"
										select="substring(concat(translate($part2,'0123456789',''),' '),1,1)"/>
									<xsl:value-of
										select="concat($part1,substring-before($part2,$delimiter),'...')"
									/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$catalogue_no"/>
								</xsl:otherwise>
							</xsl:choose>
						</span>
					</xsl:if>
					<span class="tools noprint">
						<a href="./download_xml.xq?doc={$doc}" title="Get this record as XML (MEI)"
							target="_blank">
							<img src="/editor/images/xml.gif" alt="XML" border="0"/>
						</a>
					</span>
				</div>

				<xsl:call-template name="body_main_content"/>
			</div>
		</div>
	</xsl:template>

	<!-- SUB-TEMPLATES -->

	<!-- need to override this template in order to call the right xquery (document.xq instead of present.xq) -->
	<xsl:template match="m:relation" mode="relation_link">
		<!-- In public viewing, we need to know the collection directory name -->
		<xsl:variable name="coll_dir">
			<xsl:call-template name="lowercase">
				<xsl:with-param name="str" select="$file_context"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- cross references between works in the catalogue are treated in a special way -->
		<xsl:variable name="mermeid_crossref">
			<xsl:choose>
				<xsl:when test="contains(@target,'://') or contains(@target,'#')">false</xsl:when>
				<xsl:otherwise>true</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="href">
			<xsl:choose>
				<xsl:when test="$mermeid_crossref='true'">
					<!-- This line is different from mei_to_html.xsl-->
					<xsl:value-of select="concat('document.xq?doc=',@target)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@target"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="label">
			<xsl:choose>
				<xsl:when test="normalize-space(substring-after(@label,':'))"><xsl:value-of select="normalize-space(substring-after(@label,':'))"/></xsl:when>
				<xsl:otherwise><xsl:apply-templates select="@label"/></xsl:otherwise>
			</xsl:choose>
			<xsl:if test="not(@label) or @label=''">
				<xsl:value-of select="@target"/>
			</xsl:if>
		</xsl:variable>
		<a href="{$href}" title="{$label}"><xsl:value-of select="$label"/></a>&#160;
		<xsl:if test="$mermeid_crossref='true'">
			<!-- get collection name and number from linked files -->
			<!-- could also be: <xsl:variable name="fileName"
				select="concat(concat($settings/dcm:parameters/dcm:server_name,$settings/dcm:parameters/dcm:document_root,@target))"/>-->
			<xsl:variable name="fileName"
				select="concat($settings/dcm:parameters/dcm:server_name,$settings/dcm:parameters/dcm:exist_dir,$coll_dir,'/data/',@target)"/>
			<xsl:variable name="linkedDoc" select="document($fileName)"/>
			<xsl:variable name="file_context"
				select="$linkedDoc/m:mei/m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type='file_collection']"/>
			<xsl:variable name="catalogue_no"
				select="$linkedDoc/m:mei/m:meiHead/m:workDesc/m:work/m:identifier[@label=$file_context]"/>
			<xsl:variable name="output">
				<xsl:value-of select="$file_context"/>
				<xsl:text> </xsl:text>
				<xsl:choose>
					<xsl:when test="string-length($catalogue_no)&gt;11">
						<xsl:variable name="part1" select="substring($catalogue_no, 1, 11)"/>
						<xsl:variable name="part2" select="substring($catalogue_no, 12)"/>
						<xsl:variable name="delimiter"
							select="substring(concat(translate($part2,'0123456789',''),' '),1,1)"/>
						<xsl:value-of
							select="concat($part1,substring-before($part2,$delimiter),'...')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$catalogue_no"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="normalize-space($catalogue_no)!=''">
				<a class="work_number_reference" href="{$href}" title="{$label}"><xsl:value-of select="$output"/></a>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<!-- omit music details shown in the incipits -->
	<xsl:template match="m:meter"/>
	<xsl:template match="m:tempo"/>
	<xsl:template match="m:incipText"/>
	
	<!-- Only show last revision instead of full colophon -->
	<xsl:template match="*" mode="colophon">
		<div class="colophon">
			<xsl:apply-templates select="//m:revisionDesc//m:change[normalize-space(@isodate)!=''][last()]" mode="last"/>
		</div>
	</xsl:template>	

</xsl:stylesheet>
