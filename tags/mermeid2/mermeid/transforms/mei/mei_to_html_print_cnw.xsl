<?xml version="1.0" encoding="UTF-8"?>

<!-- 
	Conversion of MEI metadata to HTML using XSLT 1.0
	This XSLT overrides a number of templates defined in mei_to_html.xsl 
	to produce output suited for printing. Please note: This file is intended specifically for the CNW catalogue.
	
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
	
	<!-- omit colophon -->
	<xsl:template match="*" mode="colophon"/>

	<!-- omit settings menu -->
	<xsl:template match="*" mode="settings_menu"/>
		
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

	<!-- show crosslinks as plain text -->
	<xsl:template match="m:relation" mode="relation_link">
		<!-- internal cross references between works in the catalogue are treated in a special way -->
		<xsl:variable name="mermeid_crossref">
			<xsl:choose>
				<xsl:when test="contains(@target,'://') or contains(@target,'#')">false</xsl:when>
				<xsl:otherwise>true</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="href">
			<xsl:choose>
				<xsl:when test="$mermeid_crossref='true'">
					<xsl:value-of select="concat($settings/dcm:parameters/dcm:server_name,$settings/dcm:parameters/dcm:exist_dir,'present.xq?doc=',@target)"/>
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
		<!-- this prints the link text -->
		<i><xsl:value-of select="$label"/></i>
		<xsl:if test="$mermeid_crossref='true'">
			<!-- get collection name and number from linked files -->
			<xsl:variable name="fileName"
				select="concat($settings/dcm:parameters/dcm:server_name,$settings/dcm:parameters/dcm:document_root,@target)"/>
			<xsl:variable name="linkedDoc" select="document($fileName)"/>
			<xsl:variable name="file_context"
				select="$linkedDoc/m:mei/m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type='file_collection']"/>
			<xsl:variable name="catalogue_no"
				select="$linkedDoc/m:mei/m:meiHead/m:workDesc/m:work/m:identifier[@label=$file_context]"/>
			<xsl:variable name="output">
				<!-- the printed catalogue omits the collection name ("CNW") -->
				<!--<xsl:value-of select="$file_context"/>
				<xsl:text> </xsl:text>-->
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
				&#160;<span class="work_number_reference"><xsl:value-of select="$output"/></span>
			</xsl:if>
		</xsl:if>
	</xsl:template>	
	
	
	<!-- do not make incpit graphics links -->
	<xsl:template match="m:incip" mode="graphic">
		<!-- make img tag only if a target file is specified and the path does not end with a slash -->
		<xsl:if test="normalize-space(m:graphic[@targettype='lowres']/@target) and 
			substring(m:graphic[@targettype='lowres']/@target,string-length(m:graphic[@targettype='lowres']/@target),1)!='/'">
			<xsl:element name="img">
				<xsl:attribute name="border">0</xsl:attribute>
				<xsl:attribute name="style">text-decoration: none;</xsl:attribute>
				<xsl:attribute name="alt"/>
				<xsl:attribute name="src">
					<xsl:value-of select="m:graphic[@targettype='lowres']/@target"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:if>
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


	<!-- relations to other works -->
	<xsl:template match="m:relationList" mode="relation_list">
		<xsl:if test="m:relation[@target!='']">
			<!-- loop through relations, but skip those where @label contains a ":"  -->
			<xsl:for-each select="m:relation[@rel!='' and not(normalize-space(substring-after(@label,':')))]">
				<xsl:variable name="rel" select="@rel"/>
				<xsl:if test="count(preceding-sibling::*[@rel=$rel])=0">
					<!-- one <div> per relation type -->
						<div class="relation_list">
							<xsl:variable name="label">
								<xsl:call-template name="translate_relation">
									<xsl:with-param name="label" select="@label"/>
									<xsl:with-param name="rel" select="@rel"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:if test="$label!=''">
								<span class="p_heading">
									<xsl:value-of select="$label"/>
								</span>
								<xsl:text> </xsl:text>
							</xsl:if>
							<xsl:if test="../m:relation[@rel=$rel or substring-before(@label,':')=$rel]">
									<xsl:for-each select="../m:relation[@rel=$rel and not(normalize-space(substring-after(@label,':')))]">
										<xsl:if test="position() &gt; 1">, </xsl:if>
										<xsl:apply-templates select="." mode="relation_link"/>
									</xsl:for-each>
							</xsl:if>
						</div>
				</xsl:if>
			</xsl:for-each>
			<!-- relations with @label containing ":" use the part before the ":" as label instead -->
			<xsl:for-each select="m:relation[@rel!='' and normalize-space(substring-after(@label,':'))]">
				<xsl:variable name="label" select="substring-before(@label,':')"/>
				<xsl:if test="count(preceding-sibling::*[substring-before(@label,':')=$label])=0">
						<div class="relation_list">
							<xsl:if test="$label!=''">
								<div class="p_heading">
									<xsl:value-of select="$label"/>:
								</div>
							</xsl:if>
							<xsl:if test="../m:relation[substring-before(@label,':')=$label]">
									<xsl:for-each select="../m:relation[substring-before(@label,':')=$label]">
										<xsl:if test="position() &gt; 1">, </xsl:if>
										<xsl:apply-templates select="." mode="relation_link"/>
									</xsl:for-each>
							</xsl:if>
						</div>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	

	
	<!-- Title pages -->
	<xsl:template match="m:titlePage">
		<br/>
		<xsl:if test="not(@label) or @label=''">Title page</xsl:if>
		<xsl:value-of select="@label"/>
		<xsl:text>: </xsl:text>
		<xsl:for-each select="m:p[//text()]">
			<span class="titlepage">
				<xsl:apply-templates/>
			</span>
		</xsl:for-each>
		<xsl:if test="position()=count(../m:titlePage)">
			<br/>
		</xsl:if>
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
	
	<xsl:template match="m:itemList">
		<xsl:choose>
			<!-- Show items as bulleted list if 
				1) there are more than one item or
				2) an item has a label, and source is not a manuscript -->
			<xsl:when
				test="count(m:item)&gt;1 or 
				(m:item/@label and m:item/@label!='' and
				../m:classification/m:termList/m:term[@classcode='DcmPresentationClass']!='manuscript')">
				<ul class="item_list">
					<xsl:for-each select="m:item[*//text()]">
						<li>
							<xsl:apply-templates select="."/>
						</li>
					</xsl:for-each>
				</ul>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="m:item[*//text()]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- Don't look up abbreviations -->
	<xsl:template match="text()[name(..)!='p' and name(..)!='persName' and name(..)!='ptr' and name(..)!='ref'] 
		| m:identifier/@label">
		<xsl:value-of select="."/>
	</xsl:template>
		
	
</xsl:stylesheet>
