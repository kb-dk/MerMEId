<?xml version="1.0" encoding="UTF-8"?>

<!-- 
	Conversion of MEI metadata to HTML using XSLT 1.0
	Output intended for the Gade Edition
	
	Authors: 
	Axel Teich Geertinger & Sigfrid Lundberg
	Danish Centre for Music Publication
	The Royal Library, Copenhagen
	2014
	
-->

<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:m="http://www.music-encoding.org/ns/mei"
	xmlns:dcm="http://www.kb.dk/dcm" xmlns:xl="http://www.w3.org/1999/xlink"
	xmlns:foo="http://www.kb.dk/foo" xmlns:exsl="http://exslt.org/common"
	xmlns:java="http://xml.apache.org/xalan/java" xmlns:zs="http://www.loc.gov/zing/srw/"
	xmlns:marc="http://www.loc.gov/MARC21/slim" extension-element-prefixes="exsl java"
	exclude-result-prefixes="m xsl exsl foo java">

	<xsl:output method="xml" encoding="UTF-8" cdata-section-elements="" omit-xml-declaration="yes"
		indent="no" xml:space="default"/>

	<xsl:param name="hostname"/>
	<xsl:param name="doc"/>


	<!-- GLOBAL VARIABLES -->

	<!-- preferred language in titles and other multilingual fields -->
	<xsl:variable name="preferred_language">none</xsl:variable>
	<!-- general MerMEId settings -->
	<xsl:variable name="settings"
		select="document(concat('http://',$hostname,'/editor/forms/mei/mermeid_configuration.xml'))"/>
	<!-- file context - i.e. collection identifier like 'CNW' -->
	<xsl:variable name="file_context">
		<xsl:value-of
			select="/m:mei/m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type='file_collection']"
		/>
	</xsl:variable>
	<!-- files containing look-up information -->
	<xsl:variable name="bibl_file_name"
		select="string(concat('http://',$hostname,'/',$settings/dcm:parameters/dcm:exist_dir,'library/standard_bibliography.xml'))"/>
	<xsl:variable name="bibl_file" select="document($bibl_file_name)"/>
	<xsl:variable name="abbreviations_file_name"
		select="string(concat('http://',$hostname,'/',$settings/dcm:parameters/dcm:exist_dir,'library/abbreviations.xml'))"/>
	<xsl:variable name="abbreviations_file" select="document($abbreviations_file_name)"/>


	<!-- CREATE HTML DOCUMENT -->
	<xsl:template match="m:mei" xml:space="default">
		<html xml:lang="en" lang="en">
			<head>
				<xsl:call-template name="make_html_head"/>
			</head>
			<body>
				<div class="main">
					<xsl:call-template name="make_html_body"/>
				</div>
			</body>
		</html>
	</xsl:template>


	<!-- MAIN TEMPLATES -->
	<xsl:template name="make_html_head">
		<title>
			<xsl:call-template name="page_title"/>
		</title>

		<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=UTF-8"/>

		<!--<link rel="stylesheet" type="text/css" href="/editor/style/mei_to_html.css"/>-->

		<script type="text/javascript" src="/editor/js/toggle_openness.js">
			<xsl:text>
			</xsl:text>
		</script>
	</xsl:template>

	<xsl:template name="make_html_body" xml:space="default">
		
		<div id="main_content">
			<!-- main identification -->
			<xsl:variable name="catalogue_no">
				<xsl:value-of select="m:meiHead/m:workDesc/m:work/m:identifier[@type=$file_context]"/>
			</xsl:variable>

			<xsl:if test="m:meiHead/m:workDesc/m:work/m:identifier[@type=$file_context]/text()">
				<div class="series_header {$file_context}">
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
				</div>
			</xsl:if>

			<xsl:call-template name="body_main_content"/>
		</div>
	</xsl:template>


	<xsl:template name="body_main_content">

		<xsl:for-each select="m:meiHead/
			m:workDesc/
			m:work/
			m:titleStmt">
			<xsl:if test="m:title[@type='main' or not(@type)][text()]">
				<xsl:for-each select="m:title[@type='main' or not(@type)][text()]">
					<xsl:variable name="lang" select="@xml:lang"/>
					<xsl:variable name="language_class">
						<xsl:choose>
							<xsl:when
								test="position()&gt;1 and @xml:lang!=parent::node()/m:title[1]/@xml:lang"
								>alternative_language</xsl:when>
							<xsl:otherwise>preferred_language</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<h1 class="work_title">
						<xsl:element name="span">
							<xsl:attribute name="class">
								<xsl:value-of select="$language_class"/>
							</xsl:attribute>
							<xsl:apply-templates select="."/>
						</xsl:element>
					</h1>
					<xsl:for-each select="../m:title[@type='subordinate'][@xml:lang=$lang]">
						<h2 class="subtitle">
							<xsl:element name="span">
								<xsl:attribute name="class">
									<xsl:value-of select="$language_class"/>
								</xsl:attribute>
								<xsl:apply-templates select="."/>
							</xsl:element>
						</h2>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:if>
			<xsl:if
				test="m:title[@type='alternative'][text()] |
				m:title[@type='original'][text()]">
				<xsl:element name="h2">
					<xsl:for-each select="m:title[@type='original'][text()]">
						<xsl:element name="span">
							<xsl:call-template name="maybe_print_lang"/> Original title:
								<xsl:apply-templates select="."/>
						</xsl:element>
						<xsl:call-template name="maybe_print_br"/>
					</xsl:for-each>
					<xsl:for-each select="m:title[@type='alternative'][text()]">
						<xsl:element name="span">
							<xsl:call-template name="maybe_print_lang"/> (<xsl:apply-templates
								select="."/>) </xsl:element>
						<xsl:call-template name="maybe_print_br"/>
					</xsl:for-each>
				</xsl:element>
			</xsl:if>
		</xsl:for-each>

		<!-- sources -->
		<xsl:apply-templates select="//m:sourceDesc"/>
	</xsl:template>


	<!-- SUB-TEMPLATES -->

	<!-- generate a page title -->
	<xsl:template name="page_title">
		<xsl:for-each select="m:meiHead/
			m:workDesc/
			m:work/
			m:titleStmt">
			<xsl:choose>
				<xsl:when test="m:title[@type='main']//text()">
					<xsl:value-of select="m:title[@type='main']"/>
				</xsl:when>
				<xsl:when test="m:title[@type='uniform']//text()">
					<xsl:value-of select="m:title[@type='uniform']"/>
				</xsl:when>
				<xsl:when test="m:title[not(@type)]//text()">
					<xsl:value-of select="m:title[not(@type)]"/>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="m:respStmt/m:persName[@role='composer'][text()]"> - </xsl:if>
			<xsl:value-of select="m:respStmt/m:persName[@role='composer'][text()]"/>
		</xsl:for-each>
	</xsl:template>


	<xsl:template match="m:titleStmt/m:respStmt[m:persName[text()]]">
		<p>
			<xsl:for-each select="m:persName[text()]">
				<xsl:if test="@role and @role!=''">
					<span class="p_heading">
						<xsl:choose>
							<xsl:when test="@role='author'">Text author</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="capitalize">
									<xsl:with-param name="str" select="@role"/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:text>: </xsl:text>
					</span>
				</xsl:if>
				<xsl:apply-templates select="."/>
				<br/>
			</xsl:for-each>
		</p>
	</xsl:template>


	<!-- sources -->
	<xsl:template match="m:sourceDesc[m:source//text()]">
		<xsl:param name="global"/>
		<p>DESCRIPTION OF THE SOURCES</p>
		<!-- sort order lists must begin and end with a semicolon -->
		<xsl:variable name="state_order"
			select="';sketch;draft;fair copy;printers copy;first edition;later edition;'"/>
		<xsl:variable name="scoring_order"
			select="';score;score and parts;vocal score;piano score;choral score;short score;parts;'"/>
		<xsl:variable name="authority_order"
			select="';autograph;partly autograph;doubtful autograph;copy;'"/>
		<!-- collect all external source data first to create a complete list of sources -->
		<xsl:variable name="sources">
			<!-- skip reproductions (=reprints) - they are treated elsewhere. -->
			<!-- If listing global sources, list only those not referring to a specific version (if more than one) -->
			<xsl:for-each
				select="m:source[not(m:relationList/m:relation[@rel='isReproductionOf'])]
						[$global!='true' or ($global='true' and (count(//m:work/m:expressionList/m:expression)&lt;2
						or not(m:relationList/m:relation[@rel='isEmbodimentOf']/@target)))]">
				<xsl:choose>
					<xsl:when test="@target!=''">
						<!-- get external source description -->
						<xsl:variable name="ext_id" select="substring-after(@target,'#')"/>
						<xsl:variable name="doc_name"
							select="concat('http://',$hostname,'/',$settings/dcm:parameters/dcm:document_root,substring-before(@target,'#'))"/>
						<xsl:variable name="doc" select="document($doc_name)"/>
						<xsl:copy-of
							select="$doc/m:mei/m:meiHead/m:fileDesc/m:sourceDesc/m:source[@xml:id=$ext_id]"
						/>
					</xsl:when>
					<xsl:when test="*//text()">
						<xsl:copy-of select="."/>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		<!-- make the source list a nodeset -->
		<xsl:variable name="source_nodeset" select="exsl:node-set($sources)"/>
		<xsl:variable name="sources_sorted">
			<xsl:for-each select="$source_nodeset/m:source">
				<!-- process all sources, sorted according to classification -->
				<xsl:sort select="m:classification/m:termList/m:term[@classcode='DcmContentClass']"/>
				<xsl:sort
					select="m:classification/m:termList/m:term[@classcode='DcmPresentationClass']"/>
				<!-- adding 100 ensures that combinations of 1- and 2-digit numbers are sorted correctly -->
				<xsl:sort
					select="number(100 + string-length(substring-before($authority_order,concat(';',m:classification/m:termList/m:term[@classcode='DcmAuthorityClass'],';'))))"/>
				<xsl:sort
					select="number(100 + string-length(substring-before($state_order,concat(&quot;;&quot;,translate(m:classification/m:termList/m:term[@classcode=&quot;DcmStateClass&quot;],&quot;&apos;&quot;,&quot;&quot;),&quot;;&quot;))))"/>
				<xsl:sort
					select="number(100 + string-length(substring-before($scoring_order,concat(';',m:classification/m:termList/m:term[@classcode='DcmScoringClass'],';'))))"/>
				<xsl:sort
					select="m:classification/m:termList/m:term[@classcode='DcmCompletenessClass']"/>
				<xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:variable>
		<!-- make the sorted source list a nodeset too -->
		<xsl:variable name="source_nodeset_sorted" select="exsl:node-set($sources_sorted)"/>
		<xsl:for-each select="$source_nodeset_sorted/m:source">
			<xsl:choose>
				<xsl:when
					test="m:classification/m:termList/m:term[@classcode='DcmPresentationClass']='manuscript'
						and count(preceding-sibling::m:source[m:classification/m:termList/m:term[@classcode='DcmPresentationClass']='manuscript'])=0">
					<p>
						<b>Manuscript</b>
					</p>
				</xsl:when>
				<xsl:when
					test="contains(m:classification/m:termList/m:term[@classcode='DcmPresentationClass'],'print')
						and count(preceding-sibling::m:source[contains(m:classification/m:termList/m:term[@classcode='DcmPresentationClass'],'print')])=0">
					<p>
						<b>Printed</b>
					</p>
				</xsl:when>
				<xsl:when
					test="m:classification/m:termList/m:term[@classcode='DcmContentClass']='text'
						and count(preceding-sibling::m:source[m:classification/m:termList/m:term[@classcode='DcmContentClass']='text'])=0">
					<p>
						<b>Text</b>
					</p>
				</xsl:when>
			</xsl:choose>
			<p class="source"><xsl:apply-templates select="."/></p>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="list_agents">
		<xsl:if test="m:respStmt/m:persName[text()] |
			m:respStmt/m:corpName[text()]">
				<xsl:for-each
					select="m:respStmt/m:persName[text()] |
					m:respStmt/m:corpName[text()]">
					<br/><xsl:if test="string-length(@role) &gt; 0">
						<xsl:call-template name="capitalize">
							<xsl:with-param name="str" select="@role"/>
						</xsl:call-template>
						<xsl:text>: </xsl:text>
					</xsl:if>
					<xsl:value-of select="."/>
					<xsl:choose>
						<xsl:when test="position() &lt; last()">
							<xsl:text>, </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>. </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>

				<xsl:for-each
					select="m:geogName[text()] | 
					m:date[text()] |
					m:identifier[text()]">
					<xsl:if test="string-length(@type) &gt; 0">
						<xsl:apply-templates select="@type"/>
						<xsl:text>: </xsl:text>
					</xsl:if>
					<xsl:value-of select="."/>
					<xsl:choose>
						<xsl:when test="position() &lt; last()">
							<xsl:text>, </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>. </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				<xsl:text>
				</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="list_persons_by_role">
		<xsl:if test="count(m:persName[text()] | m:corpName[text()])>0">
			<xsl:for-each select="m:corpName[text()]|m:persName[text()]">
				<xsl:variable name="role">
					<xsl:call-template name="capitalize">
						<xsl:with-param name="str" select="@role"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="@role!=preceding-sibling::*[1]/@role or position()=1">
						<xsl:choose>
							<xsl:when test="@role=following-sibling::*[1]/@role">
								<xsl:if test="name()='persName' and normalize-space(@role)">
									<!-- make it plural... -->
									<xsl:variable name="label">
										<xsl:choose>
											<xsl:when
												test="substring(@role,string-length(@role),1)='y'">
												<xsl:value-of
												select="concat(substring($role,1,string-length($role)-1),'ies')"
												/>
											</xsl:when>
											<xsl:otherwise><xsl:value-of select="concat($role,'s')"
												/></xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:value-of select="$label"/><xsl:text>: </xsl:text>
								</xsl:if>
								<xsl:apply-templates select="."/>, </xsl:when>
							<xsl:otherwise>
								<xsl:if test="name()='persName' and normalize-space(@role)">
									<xsl:value-of select="$role"/>
									<xsl:text>: </xsl:text>
								</xsl:if>
								<xsl:apply-templates select="."/>
								<xsl:if test="following-sibling::m:persName/text()">
									<br/>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="@role=following-sibling::*[1]/@role">
								<xsl:apply-templates select="."/>, </xsl:when>
							<xsl:when test="not(following-sibling::*[1]/@role)">
								<xsl:apply-templates select="."/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="."/>
								<br/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<!-- source-related templates -->

	<xsl:template match="m:source[*[name()!='classification']//text()]|m:item[*//text()]">
		<xsl:param name="mode" select="''"/>
		<xsl:variable name="source_id" select="@xml:id"/>
		<xsl:if test="name()='item'"><br/></xsl:if>
		<span class="{name()}">
			<!-- source title -->
			<xsl:for-each select="m:titleStmt[m:title/text()]">
				<!-- should be (the editor is supposed to mention "source" in @type):
				<xsl:if test="normalize-space(../m:identifier[contains(translate(@type,'S','s'),'source')])">
					<b><xsl:apply-templates select="../m:identifier[contains(translate(@type,'S','s'),'source')]"
					/></b>:<xsl:text> </xsl:text>
				</xsl:if>
				-->
				<xsl:if test="normalize-space(../m:identifier)">
					<b><xsl:apply-templates select="../m:identifier"
					/></b>:<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:apply-templates select="m:title" mode="source_title"/>
			</xsl:for-each>
			<!-- item label -->
			<xsl:if
				test="local-name()='item' and normalize-space(@label) and name(..)!='componentGrp'">
				<!--  should be (the editor is supposed to mention "source" in @type):
				<xsl:if test="normalize-space(m:identifier[contains(translate(@type,'S','s'),'source')])">
					<b><xsl:apply-templates select="m:identifier[contains(translate(@type,'S','s'),'source')]"
					/></b>:<xsl:text> </xsl:text>
				</xsl:if>-->
				<xsl:if test="normalize-space(m:identifier[contains(translate(@type,'S','s'),'source')])">
					<b><xsl:apply-templates select="m:identifier[contains(translate(@type,'S','s'),'source')]"
					/></b>:<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="@label"/>
			</xsl:if>

			<xsl:for-each select="m:titleStmt[m:respStmt/m:persName/text()]">
				<xsl:call-template name="list_agents"/>
			</xsl:for-each>

			<xsl:apply-templates select="m:physDesc"/>

			<xsl:for-each select="m:notesStmt">
				<xsl:for-each select="m:annot[text() or *//text()]">
					<br/><xsl:apply-templates select="."/>
				</xsl:for-each>
				<!--<xsl:for-each select="m:annot[@type='links'][m:ptr[normalize-space(@target)]]">
					<xsl:for-each select="m:ptr[normalize-space(@target)]">
						<br/><xsl:apply-templates select="."/>
					</xsl:for-each>
				</xsl:for-each>-->
			</xsl:for-each>
			
			<xsl:for-each select="m:physDesc/m:titlePage[m:p//text()]">
				<br/><xsl:if test="not(@label) or @label=''">Title page</xsl:if>
				<xsl:value-of select="@label"/>
				<xsl:text>: </xsl:text>
				<xsl:for-each select="m:p[//text()]">
					<span class="titlepage">
						<xsl:apply-templates/>
					</span>
				</xsl:for-each>
				<xsl:text>
				</xsl:text>
			</xsl:for-each>
			

			<xsl:for-each
				select="m:pubStmt[normalize-space(concat(m:publisher, m:date, m:pubPlace))]">
				<xsl:comment>publication</xsl:comment>
					<xsl:if test="m:publisher/text()">
						<br/>Publisher: <xsl:apply-templates select="m:publisher"/>
						<xsl:if test="normalize-space(concat(m:date,m:pubPlace))">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:if>
					<xsl:apply-templates select="m:pubPlace"/>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="m:date"/>.
			</xsl:for-each>
			
			<xsl:for-each select="m:physDesc/m:plateNum[text()]">
				<br/>Pl. no. <xsl:apply-templates/>.
			</xsl:for-each>

			<xsl:for-each select="m:physDesc/m:provenance[normalize-space(*//text())]">
					<br/><xsl:text>Provenance: </xsl:text>
					<xsl:for-each select="m:eventList/m:event[*/text()]">
						<xsl:for-each select="m:p">
							<xsl:apply-templates/>
						</xsl:for-each>
						<xsl:for-each select="m:date[text()]">
							<xsl:text> (</xsl:text>
							<xsl:apply-templates select="."/>
							<xsl:text>)</xsl:text>
						</xsl:for-each>. </xsl:for-each>
			</xsl:for-each>


			<!-- List exemplars (items) last if there is more than one or it does have a heading of its own 
					Otherwise, this is a manuscript with some information given at item level, 
					which should be shown before the components.
				-->
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

			<!-- list reproductions (reprints) -->
			<xsl:for-each
				select="/*//m:source[m:relationList/m:relation[@rel='isReproductionOf'
					and substring-after(@target,'#')=$source_id]]">
				<xsl:if test="position()=1">
					<xsl:if test="not(m:titleStmt/m:title/text())">
						<br/>
						<br/>
						<span class="p_heading">Reprint:</span><br/>
					</xsl:if>
				</xsl:if>
				<xsl:apply-templates select=".">
					<xsl:with-param name="mode">reprint</xsl:with-param>
				</xsl:apply-templates>
			</xsl:for-each>

		</span>
	</xsl:template>
	
	<!-- source title formatting -->
	<xsl:template match="m:title" mode="source_title">
		<!-- italicize first part of source title -->
		<!-- [not really useful - no clear rules for what is to be italicized] -->
		<!--<xsl:choose>
			<xsl:when test="contains(.,',')">
				<i><xsl:value-of select="substring-before(.,',')"/></i>, <xsl:value-of select="substring-after(.,',')"/>
			</xsl:when>
			<xsl:otherwise><i><xsl:value-of select="."/></i></xsl:otherwise>
		</xsl:choose>-->
		<xsl:value-of select="."/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="../../m:itemList/m:item/m:physLoc" mode="source_title"/>
	</xsl:template>
	
	<xsl:template match="m:item/m:physLoc" mode="source_title">
		<xsl:variable name="repo">
			<xsl:choose>
				<xsl:when test="m:repository/m:corpName/text()">
					<xsl:value-of select="m:repository/m:corpName/text()"/>
				</xsl:when>
				<xsl:when test="m:repository/m:identifier[@authority='RISM']/text()">
					<xsl:value-of select="m:repository/m:identifier[@authority='RISM']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="m:repository/m:identifier"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="location">
			<xsl:choose>
				<xsl:when test="$repo!='' and m:identifier/text()">
					<xsl:value-of select="concat($repo,', ',m:identifier[text()][1])"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($repo,m:identifier[text()][1])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$location!=''">(<xsl:value-of select="$location"/>)</xsl:if>
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
			<!-- Add a DIV wrapper if item is a labeled manuscript item (for styling) -->
			<xsl:when
				test="(count(m:item)&lt;=1 and
				m:item/@label and m:item/@label!='' and
				../m:classification/m:termList/m:term[@classcode='DcmPresentationClass']='manuscript')">
				<div class="ms_item">
					<xsl:apply-templates select="m:item[*//text()]"/>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="m:item[*//text()]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="m:source/m:componentGrp | m:item/m:componentGrp">
		<xsl:variable name="labels" select="count(*[@label!=''])"/>
		<xsl:choose>
			<xsl:when test="count(*)&gt;1">
				<table cellpadding="0" cellspacing="0" border="0" class="source_component_list">
					<xsl:for-each select="m:item | m:source">
						<tr>
							<xsl:if test="$labels &gt; 0">
								<td class="label_cell">
									<xsl:if test="@label!=''">
										<p>
											<xsl:value-of select="@label"/>
											<xsl:text>: </xsl:text>
										</p>
									</xsl:if>
								</td>
							</xsl:if>
							<td>
								<xsl:apply-templates select="."/>
							</td>
						</tr>
					</xsl:for-each>
				</table>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="m:item | m:source"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="m:physDesc">
		<xsl:if test="m:dimensions[text()] | m:extent[text()]">
			<br/><xsl:for-each select="m:dimensions[text()] | m:extent[text()]">
				<!--<xsl:choose>
					<xsl:when
						test="contains(.,'x') and number(substring-before(.,'x')) and number(substring-after(.,'x'))">
						<xsl:value-of
							select="concat(number(substring-before(.,'x')),' x ',number(substring-after(.,'x')))"
						/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="."/>
					</xsl:otherwise>
					</xsl:choose>-->
				<xsl:value-of select="."/>
				<xsl:variable name="str">
					<xsl:apply-templates select="@unit"/>
				</xsl:variable>
				<xsl:variable name="str2">
					<xsl:call-template name="remove_">
						<xsl:with-param name="str" select="$str"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="normalize-space($str2)">
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="position()&lt;last()">
						<xsl:value-of select="normalize-space($str2)"/>,
						<xsl:text>
							</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space($str2)"/>.
						<xsl:text>
							</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:if>

		<xsl:apply-templates select="m:handList[m:hand/@medium!='' or m:hand/text()]"/>
		<xsl:apply-templates select="m:physMedium"/>
		<xsl:apply-templates select="m:watermark"/>
		<xsl:apply-templates select="m:condition"/>
	</xsl:template>

	<xsl:template match="m:physMedium[text()]">
		<br/><xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="m:watermark[text()]">
		<br/><xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="m:condition[text()]">
		<br/>Condition: <xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="m:physLoc">
		<!-- locations - both for <source>, <item> and <bibl> -->
		<xsl:for-each select="m:repository[*//text()]">
			<xsl:if test="m:corpName[text()]or m:identifier[text()]">
				<xsl:choose>
					<xsl:when test="m:corpName[text()]">
						<xsl:apply-templates select="m:corpName[text()]"/>
						<xsl:if test="m:identifier[text()]"> (<em><xsl:apply-templates
									select="m:identifier[text()]"/></em>) </xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="m:identifier[text()]">
							<em>
								<xsl:apply-templates select="."/>
							</em>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="../m:identifier[text()]">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:apply-templates select="m:identifier"/>
		<xsl:if test="m:identifier[text()] or m:repository[*//text()]">. </xsl:if>
		<xsl:for-each select="m:repository/m:ptr[normalize-space(@target)]">
			<xsl:apply-templates select="."/>
			<xsl:if test="position()!=last()">
				<xsl:text>, </xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="m:ptr[normalize-space(@target)]">
			<xsl:apply-templates select="."/>
			<xsl:if test="position()!=last()">
				<xsl:text>, </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- format scribe's name and medium -->
	<xsl:template match="m:hand" mode="scribe">
		<xsl:call-template name="lowercase">
			<xsl:with-param name="str" select="translate(@medium,'_',' ')"/>
		</xsl:call-template>
		<xsl:if test="./text()"> (<xsl:apply-templates select="."/>)</xsl:if>
	</xsl:template>

	<!-- list scribes -->
	<xsl:template match="m:handList">
		<xsl:if test="count(m:hand[@initial='true' and (@medium!='' or text())]) &gt; 0">
			<xsl:text>Written in </xsl:text>
			<xsl:for-each select="m:hand[@initial='true' and (@medium!='' or text())]">
				<xsl:if test="position()&gt;1 and position()&lt;last()">, </xsl:if>
				<xsl:if test="position()=last() and position()&gt;1">
					<xsl:text> and </xsl:text>
				</xsl:if>
				<xsl:apply-templates select="." mode="scribe"/></xsl:for-each>. </xsl:if>
		<xsl:if test="count(m:hand[@initial='false' and (@medium!='' or text())]) &gt; 0">
			<xsl:text>Additions in </xsl:text>
			<xsl:for-each select="m:hand[@initial='false']">
				<xsl:if test="position()&gt;1 and position()&lt;last()">, </xsl:if>
				<xsl:if test="position()=last() and position()&gt;1">
					<xsl:text> and </xsl:text>
				</xsl:if>
				<xsl:apply-templates select="." mode="scribe"/></xsl:for-each>. </xsl:if>
	</xsl:template>


	<xsl:template name="list_seperator">
		<xsl:if test="position() &gt; 1">
			<xsl:choose>
				<xsl:when test="position() &lt; last()">
					<xsl:text>, </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text> and </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>


	

	<xsl:template match="@type">
		<xsl:value-of select="translate(.,'_',' ')"/>
	</xsl:template>

	<xsl:template match="@unit">
		<xsl:variable name="pass1" select="translate(.,'_',' ')"/>
		<xsl:variable name="pass2">
			<xsl:choose>
				<xsl:when test="contains($pass1,'pages')">
					<xsl:value-of select="concat(substring-before($pass1,'pages'),'pp.',substring-after($pass1,'pages'))"/>
				</xsl:when>
				<xsl:when test="contains($pass1,'page')">
					<xsl:value-of select="concat(substring-before($pass1,'page'),'p.',substring-after($pass1,'page'))"/>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="$pass1"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$pass2"/>
	</xsl:template>
	
	<!-- GENERAL TOOL TEMPLATES -->

	<!-- output elements comma-separated -->
	<xsl:template match="*" mode="comma-separated">
		<xsl:if test="position() &gt; 1">, </xsl:if>
		<xsl:apply-templates select="."/>
	</xsl:template>

	<!-- output text in multiple languages -->
	<xsl:template match="*" mode="multilingual_text">
		<xsl:param name="preferred_found"/>
		<xsl:if test="@xml:lang=$preferred_language">
			<span class="preferred_language">
				<xsl:apply-templates select="."/>
			</span>
		</xsl:if>
		<!-- texts in non-preferred languages listed in document order -->
		<xsl:if test="@xml:lang!=$preferred_language">
			<xsl:if test="position()=1 and $preferred_found=0">
				<span class="preferred_language">
					<xsl:apply-templates select="."/>
				</span>
			</xsl:if>
			<xsl:if test="position()&gt;1 or $preferred_found&gt;0">
				<br/>
				<span class="alternative_language">[<xsl:value-of select="@xml:lang"/>:]
						<xsl:apply-templates select="."/></span>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<!-- convert lowercase to uppercase -->
	<xsl:template name="uppercase">
		<xsl:param name="str"/>
		<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyzæøå'"/>
		<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅ'"/>
		<xsl:value-of select="translate($str, $smallcase, $uppercase)"/>
	</xsl:template>

	<!-- convert uppercase to lowercase -->
	<xsl:template name="lowercase">
		<xsl:param name="str"/>
		<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyzæøå'"/>
		<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅ'"/>
		<xsl:value-of select="translate($str, $uppercase, $smallcase)"/>
	</xsl:template>

	<!-- change first letter to uppercase -->
	<xsl:template name="capitalize">
		<xsl:param name="str"/>
		<xsl:if test="$str">
			<xsl:call-template name="uppercase">
				<xsl:with-param name="str" select="substring($str,1,1)"/>
			</xsl:call-template>
			<xsl:value-of select="substring($str,2)"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="remove_">
		<!-- removes _ if it's there, otherwise just return the string passed as
			argument -->
		<xsl:param name="str"/>
		<xsl:choose>
			<xsl:when test="contains($str,'_')">
				<xsl:value-of
					select="concat(substring-before($str,'_'),
					' ',
					substring-after($str,'_'))"
				/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$str"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>



	<!-- change date format from YYYY-MM-DD to D.M.YYYY -->
	<!-- "??"-wildcards (e.g. "20??-09-??") are treated like numbers -->
	<xsl:template match="m:date">
		<xsl:variable name="date" select="normalize-space(.)"/>
		<xsl:choose>
			<xsl:when test="string-length($date)=10">
				<xsl:variable name="year" select="substring($date,1,4)"/>
				<xsl:variable name="month" select="substring($date,6,2)"/>
				<xsl:variable name="day" select="substring($date,9,2)"/>
				<xsl:choose>
					<!-- check if date format is YYYY-MM-DD; if so, display as D.M.YYYY -->
					<xsl:when
						test="(string(number($year))!='NaN' or string($year)='????' or (string(number(substring($year,1,2)))!='NaN' and substring($year,3,2)='??')) 
						and (string(number($month))!='NaN' or string($month)='??') and (string(number($day))!='NaN' or string($day)='??') and substring($date,5,1)='-' and substring($date,8,1)='-'">
						<xsl:choose>
							<xsl:when test="substring($day,1,1)='0'">
								<xsl:value-of select="substring($day,2,1)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$day"/>
							</xsl:otherwise>
						</xsl:choose>.<xsl:choose>
							<xsl:when test="substring($month,1,1)='0'">
								<xsl:value-of select="substring($month,2,1)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$month"/>
							</xsl:otherwise>
						</xsl:choose>.<xsl:value-of select="$year"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$date"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="maybe_print_lang">
		<xsl:variable name="lang" select="@xml:lang"/>
		<xsl:variable name="element" select="name(.)"/>
		<xsl:attribute name="xml:lang">
			<xsl:value-of select="@xml:lang"/>
		</xsl:attribute>
		<xsl:choose>
			<xsl:when
				test="position()&gt;1 and @xml:lang!=parent::node()/*[name()=$element][1]/@xml:lang">
				<xsl:attribute name="class">alternative_language</xsl:attribute>
				<!-- [<xsl:value-of
					select="concat(@xml:lang,':')"/>] -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="class">preferred_language</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="maybe_print_br">
		<xsl:if test="position()&lt;last()">
			<xsl:element name="br"/>
		</xsl:if>
	</xsl:template>
	
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
	
	
	<!-- omit pop-up information -->
	<xsl:template match="m:bibl//m:title | m:identifier[@authority='RISM'] | m:instrVoice/text() | 
		m:identifier/text() | m:identifier/@type">
		<xsl:value-of select="."/>
	</xsl:template>
	
	<!-- omit things not to print -->
	<xsl:template match="*[contains(@class,'noprint')]"/>
	


	<!-- HANDLE TEXT AND SPECIAL CHARACTERS -->

	<xsl:template name="key_accidental">
		<xsl:param name="attr"/>
		<span class="accidental">
			<xsl:choose>
				<xsl:when test="$attr='f'">&#x266d;</xsl:when>
				<xsl:when test="$attr='ff'">&#x266d;&#x266d;</xsl:when>
				<xsl:when test="$attr='s'">&#x266f;</xsl:when>
				<xsl:when test="$attr='ss'">x</xsl:when>
				<xsl:when test="$attr='n'">&#x266e;</xsl:when>
				<xsl:when test="$attr='-flat'">&#x266d;</xsl:when>
				<xsl:when test="$attr='-dblflat'">&#x266d;&#x266d;</xsl:when>
				<xsl:when test="$attr='-sharp'">&#x266f;</xsl:when>
				<xsl:when test="$attr='-dblsharp'">x</xsl:when>
				<xsl:when test="$attr='-neutral'">&#x266e;</xsl:when>
				<xsl:when test="$attr='-natural'">&#x266e;</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
		</span>
	</xsl:template>

	<!-- unicode replacements -->
	<xsl:template match="text()[contains(.,'♭')]">
		<!-- flat -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'♭'))"/>
		<span class="music_symbols">♭</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'♭'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'♮')]">
		<!-- natural -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'♮'))"/>
		<span class="music_symbols">♮</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'♮'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'♯')]">
		<!-- sharp -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'♯'))"/>
		<span class="music_symbols">♯</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'♯'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d10b;')]">
		<!-- segno -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d10b;'))"/>
		<span class="music_symbols">&#x1d10b;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d10b;]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d10c;')]">
		<!-- coda -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d10c;'))"/>
		<span class="music_symbols">&#x1d10c;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d10c;]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d11e;')]">
		<!-- g clef -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d11e;'))"/>
		<span class="music_symbols">&#x1d11e;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d11e;]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d122;')]">
		<!-- f clef -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d122;'))"/>
		<span class="music_symbols">&#x1d122;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d122;]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d12a;')]">
		<!-- dbl sharp -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d12a;'))"/>
		<span class="music_symbols">&#x1d12a;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d12a;]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d12b;')]">
		<!-- dbl flat -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d12b;'))"/>
		<span class="music_symbols">&#x1d12b;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d12b;]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d134;')]">
		<!-- common time -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d134;'))"/>
		<span class="music_symbols time_signature">&#x1d134;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d134;]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d135;')]">
		<!-- cut time -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d135;'))"/>
		<span class="music_symbols time_signature">&#x1d135;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d135;]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d13b;')]">
		<!-- whole rest -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d13b;'))"/>
		<span class="music_symbols">&#x1d13b;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d13b;]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d13b;')]">
		<!-- whole rest -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d13b;'))"/>
		<span class="music_symbols">&#x1d13b;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d13b;]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d13c;')]">
		<!-- half rest -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d13c;'))"/>
		<span class="music_symbols">&#x1d13c;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d13c;]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d13d;')]">
		<!-- quarter rest -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d13d;'))"/>
		<span class="music_symbols">&#x1d13d;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d13d;]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d13e;')]">
		<!-- eigth rest -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d13e;'))"/>
		<span class="music_symbols">&#x1d13e;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d13e;]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d13f;')]">
		<!-- 16th rest -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d13f;'))"/>
		<span class="music_symbols">&#x1d13f;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d13f;]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d15d;')]">
		<!-- whole note -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d15d;'))"/>
		<span class="music_symbols">&#x1d15d;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d15d;]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d15e;')]">
		<!-- half note -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d15e;'))"/>
		<span class="music_symbols">&#x1d15e;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d15e;]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d15f;')]">
		<!-- quarter note -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d15f;'))"/>
		<span class="music_symbols">&#x1d15f;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d15f;]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d160;')]">
		<!-- eigth note -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d160;'))"/>
		<span class="music_symbols">&#x1d160;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d160;]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&#x1d161;')]">
		<!-- 16th note -->
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&#x1d161;'))"/>
		<span class="music_symbols">&#x1d161;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[&#x1d161;]'))"/>
	</xsl:template>
	<!-- end unicode replacements -->

	<!-- ad hoc code replacements -->
	<xsl:template match="text()[contains(.,'[flat]')]">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[flat]'))"/>
		<span class="music_symbols">&#x266d;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[flat]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'[natural]')]">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[natural]'))"/>
		<span class="music_symbols">&#x266e;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[natural]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'[sharp]')]">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[sharp]'))"/>
		<span class="music_symbols">&#x266f;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[sharp]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'[dblflat]')]">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[dblflat]'))"/>
		<span class="music_symbols">&#x1d12b;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[dblflat]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'[dblsharp]')]">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[dblsharp]'))"/>
		<span class="music_symbols">&#x1d12a;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[dblsharp]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'[common]')]">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[common]'))"/>
		<span class="music_symbols time_signature">&#x1d134;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[common]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'[cut]')]">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[cut]'))"/>
		<span class="music_symbols time_signature">&#x1d135;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[cut]'))"/>
	</xsl:template>



	<!-- formatted text -->
	<xsl:template match="m:lb">
		<br/>
	</xsl:template>
	<xsl:template match="m:p[child::text()]">
		<br/><xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="m:p[not(child::text())]">
		<!-- ignore -->
	</xsl:template>
	<xsl:template match="m:rend[@fontweight = 'bold'][text()]">
		<b>
			<xsl:apply-templates/>
		</b>
	</xsl:template>
	<xsl:template match="m:rend[@fontstyle = 'italic'][text()]">
		<i>
			<xsl:apply-templates/>
		</i>
	</xsl:template>
	<xsl:template match="m:rend[@rend = 'underline'][text()]">
		<u>
			<xsl:apply-templates/>
		</u>
	</xsl:template>
	<xsl:template match="m:rend[@rend = 'sub'][text()]">
		<sub>
			<xsl:apply-templates/>
		</sub>
	</xsl:template>
	<xsl:template match="m:rend[@rend = 'sup'][text()]">
		<sup>
			<xsl:apply-templates/>
		</sup>
	</xsl:template>
	<xsl:template match="m:rend[@fontfam or @fontsize or @color][text()]">
		<xsl:variable name="atts">
			<xsl:if test="@fontfam">
				<xsl:value-of select="concat('font-family:',@fontfam,';')"/>
			</xsl:if>
			<xsl:if test="@fontsize">
				<xsl:value-of select="concat('font-size:',@fontsize,';')"/>
			</xsl:if>
			<xsl:if test="@color">
				<xsl:value-of select="concat('color:',@color,';')"/>
			</xsl:if>
		</xsl:variable>
		<xsl:element name="span">
			<xsl:attribute name="style">
				<xsl:value-of select="$atts"/>
			</xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="m:ref[@target][text()]">
		<xsl:element name="a">
			<xsl:attribute name="src">
				<xsl:value-of select="@target"/>
			</xsl:attribute>
			<xsl:attribute name="target">
				<xsl:value-of select="@xl:show"/>
			</xsl:attribute>
			<xsl:attribute name="title">
				<xsl:value-of select="@xl:title"/>
			</xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="m:rend[@halign][text()]">
		<xsl:element name="div">
			<xsl:attribute name="style">text-align:<xsl:value-of select="@halign"/>;</xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="m:list">
		<xsl:choose>
			<xsl:when test="@form = 'simple'">
				<ul>
					<xsl:for-each select="m:li">
						<li>
							<xsl:apply-templates/>
						</li>
					</xsl:for-each>
				</ul>
			</xsl:when>
			<xsl:when test="@form = 'ordered'">
				<ol>
					<xsl:for-each select="m:li">
						<li>
							<xsl:apply-templates/>
						</li>
					</xsl:for-each>
				</ol>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="m:fig[m:graphic[@target!='']]">
		<xsl:element name="img">
			<xsl:attribute name="src">
				<xsl:value-of select="m:graphic/@target"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>
	<!-- END TEXT HANDLING -->

</xsl:stylesheet>
