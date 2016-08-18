<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:m="http://www.music-encoding.org/ns/mei"
	xmlns:dcm="http://www.kb.dk/dcm" 
	xmlns:xl="http://www.w3.org/1999/xlink"
	xmlns:foo="http://www.kb.dk/foo" 
	xmlns:exsl="http://exslt.org/common"
	xmlns:java="http://xml.apache.org/xalan/java" 
	xmlns:zs="http://www.loc.gov/zing/srw/"
	xmlns:marc="http://www.loc.gov/MARC21/slim" extension-element-prefixes="exsl java"
	exclude-result-prefixes="m xsl exsl foo java">

	<!-- 
		Conversion of MEI metadata to HTML using XSLT 1.0
		
		Authors: 
		Axel Teich Geertinger & Sigfrid Lundberg
		Danish Centre for Music Editing
		The Royal Library, Copenhagen
		2010-2016	
	-->
	
	<xsl:output method="xml" encoding="UTF-8" cdata-section-elements="" omit-xml-declaration="yes"
		indent="no" xml:space="default"/>

	<xsl:strip-space elements="*"/>

	<xsl:param name="doc"/>
	<xsl:param name="hostname"/>


	<!-- GLOBAL VARIABLES -->

	<!-- preferred language in titles and other multilingual fields -->
	<xsl:variable name="preferred_language">none</xsl:variable>
	<!-- general MerMEId settings -->
	<xsl:variable name="settings"
		select="document(concat('http://',$hostname,'/editor/forms/mei/mermeid_configuration.xml'))"/>
	<!-- file context - i.e. collection identifier like 'CNW' -->
	<xsl:variable name="file_context">
		<xsl:value-of
			select="/m:mei/m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type='file_collection'][1]"
		/>
	</xsl:variable>
	<!-- files containing look-up information -->
	<xsl:variable name="bibl_file_name"
		select="string(concat($settings/dcm:parameters/dcm:server_name,$settings/dcm:parameters/dcm:exist_dir,'library/standard_bibliography.xml'))"/>
	<xsl:variable name="bibl_file" select="document($bibl_file_name)"/>
	<xsl:variable name="abbreviations_file_name"
		select="string(concat($settings/dcm:parameters/dcm:server_name,$settings/dcm:parameters/dcm:exist_dir,'library/abbreviations.xml'))"/>
	<xsl:variable name="abbreviations_file" select="document($abbreviations_file_name)"/>

	
	<!-- CREATE HTML DOCUMENT -->

	<xsl:template match="m:mei" xml:space="default">
		<html xml:lang="en" lang="en">
			<head>
				<xsl:call-template name="make_html_head"/>
			</head>
			<body>
				<div class="main" id="main_content">
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

		<link rel="stylesheet" type="text/css" href="./style/mei_to_html.css"/>

		<script type="text/javascript" src="/editor/js/toggle_openness.js">
	      <xsl:text>
    	  </xsl:text>
		</script>
		
		<!-- Include the Verovio toolkit for displaying incipits if needed -->
		<!--<script src="http://www.verovio.org/javascript/latest/verovio-toolkit.js">-->
		<xsl:if test="//m:incip/m:score/* or normalize-space(//m:incipCode[@form='pae' or @form='PAE' or @form='plaineAndEasie'])">
			<script src="http://www.verovio.org/javascript/latest/verovio-toolkit-light.js" type="text/javascript">
		    	<xsl:text>
	    		</xsl:text>
			</script>
			<script type="text/javascript">
				/* Create the Verovio toolkit instance */
				var vrvToolkit = new verovio.toolkit();
			</script>
		</xsl:if>
		
	</xsl:template>

	<xsl:template name="make_html_body" xml:space="default">

		<!-- main identification -->
		<xsl:variable name="catalogue_no">
			<xsl:value-of select="m:meiHead/m:workDesc/m:work/m:identifier[@label=$file_context]"/>
		</xsl:variable>

		<xsl:if test="$file_context!=''">
			<div class="series_header {$file_context}">
				<a>
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
				</a>
			</div>
		</xsl:if>

		<xsl:call-template name="body_main_content"/>

		<xsl:for-each
			select="m:meiHead/m:fileDesc/m:notesStmt/m:annot[@type='private_notes' and text()]">
			<div class="private">
				<div class="private_heading">[Private notes]</div>
				<div class="private_content">
					<xsl:apply-templates select="."/>
				</div>
			</div>
		</xsl:for-each>

	</xsl:template>


	<xsl:template name="body_main_content">

		<!-- generate links for choosing the languages to display -->
		<xsl:apply-templates select="." mode="settings_menu"/>

		<xsl:for-each select="m:meiHead/
			  m:workDesc/
			  m:work/
			  m:titleStmt/m:respStmt">
			<xsl:for-each select="m:persName[@role='composer'][text()]">
				<p class="composer_top">
					<xsl:apply-templates select="."/>
				</p>
			</xsl:for-each>
		</xsl:for-each>

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

					<xsl:for-each
						select="../m:title[@type='alternative'][@xml:lang=$lang and text()]">
						<h2 class="subtitle alternative_title">
							<xsl:element name="span">
								<xsl:attribute name="class"><xsl:value-of select="$language_class"
									/></xsl:attribute> (<xsl:apply-templates select="."/>)
							</xsl:element>
						</h2>
					</xsl:for-each>

				</xsl:for-each>
			</xsl:if>

			<!-- don't forget alternative titles in other languages than the main title(s) -->
			<xsl:for-each select="m:title[@type='alternative' and text()]">
				<xsl:variable name="lang" select="@xml:lang"/>
				<xsl:if
					test="not(../m:title[(@type='main' or not(@type)) and text() and @xml:lang=$lang])">
					<xsl:element name="h2">
						<xsl:element name="span">
							<xsl:call-template name="maybe_print_lang"/>([<xsl:value-of
								select="$lang"/>]: <xsl:apply-templates select="."/>)</xsl:element>
						<xsl:call-template name="maybe_print_br"/>
					</xsl:element>
				</xsl:if>
			</xsl:for-each>

			<xsl:if test="m:title[@type='original'][text()]">
				<!-- m:title[@type='uniform'] omitted 
	     		(available for searching only, not for display - add it to the list if you want)-->
				<xsl:element name="h2">

					<!-- uniform titles omitted 
					<xsl:for-each select="m:title[@type='uniform'][text()]">
						<xsl:element name="span">
							<xsl:call-template name="maybe_print_lang"/> Uniform title:
							<xsl:apply-templates select="."/>
						</xsl:element>
						<xsl:call-template name="maybe_print_br"/>
					</xsl:for-each>-->

					<xsl:for-each select="m:title[@type='original'][text()]">
						<xsl:element name="span">
							<xsl:call-template name="maybe_print_lang"/> Original title:
								<xsl:apply-templates select="."/>
						</xsl:element>
						<xsl:call-template name="maybe_print_br"/>
					</xsl:for-each>

				</xsl:element>

			</xsl:if>
		</xsl:for-each>


		<!-- other identifiers -->
		<xsl:apply-templates select="m:meiHead/m:workDesc/m:work[m:identifier/text()]"
			mode="work_identifiers"/>

		<!-- persons -->
		<xsl:apply-templates
			select="m:meiHead/
		m:workDesc/
		m:work/
		m:titleStmt/
		m:respStmt[m:persName[text()]]">
			<xsl:with-param name="exclude">composer</xsl:with-param>
		</xsl:apply-templates>

		<!-- text source -->
		<xsl:for-each
			select="m:meiHead/m:workDesc/m:work/m:titleStmt/m:title[@type='text_source'][text()]">
			<div>
				<xsl:if test="position()=1">
					<span class="p_heading">Text source: </span>
				</xsl:if>
				<xsl:element name="span">
					<xsl:call-template name="maybe_print_lang"/>
					<xsl:apply-templates select="."/>
				</xsl:element>
			</div>
		</xsl:for-each>

		<!-- general description -->
		<xsl:for-each select="m:meiHead/m:workDesc/m:work/m:notesStmt/m:annot[@type='general_description'][//text()]">
			<xsl:if test="normalize-space(@label)">
				<p class="p_heading"><xsl:value-of select="@label"/></p>
			</xsl:if>
			<xsl:apply-templates select="."/>
		</xsl:for-each>
		<xsl:apply-templates select="m:meiHead/m:workDesc/m:work/m:notesStmt/m:annot[@type='links'][m:ptr[normalize-space(@target)]]" mode="link_list_p"/>
		
		<!-- related files -->
		<xsl:apply-templates select="m:meiHead/m:workDesc/m:work/m:relationList"/>

		<!-- work history -->
		<xsl:apply-templates
			select="m:meiHead/m:workDesc/m:work/m:history[m:creation[*/text()] or m:p[text()]]"
			mode="history"/>

		<!-- works with versions: show global sources and performances before version details -->
		<xsl:if test="count(m:meiHead/m:workDesc/m:work/m:expressionList/m:expression)&gt;1">
			<!-- global sources -->
			<xsl:apply-templates
				select="m:meiHead/m:fileDesc/m:sourceDesc[count(m:source[not(m:relationList/m:relation[@rel='isEmbodimentOf']/@target)])&gt;0]">
				<xsl:with-param name="global">true</xsl:with-param>
			</xsl:apply-templates>
			<!-- work-level performances  -->
			<xsl:apply-templates
				select="m:meiHead/m:workDesc/m:work/m:history[m:eventList[@type='performances']//text()]"
				mode="performances"/>
		</xsl:if>

		<!-- top-level expression (versions and one-movement work details) -->
		<xsl:apply-templates select="m:meiHead/m:workDesc/m:work/m:expressionList/m:expression"
			mode="top_level"/>

		<!-- works with only one version: show performances and global sources after movements -->
		<xsl:if test="count(m:meiHead/m:workDesc/m:work/m:expressionList/m:expression)&lt;2">
			<!-- sources -->
			<xsl:apply-templates
				select="m:meiHead/m:fileDesc/m:sourceDesc[normalize-space(*//text()) or m:source/@target!='']"/>
			<!-- work-level performances -->
			<xsl:apply-templates
				select="m:meiHead/m:workDesc/m:work/m:history[m:eventList[@type='performances']//text()]"
				mode="performances"/>
			<!-- Performances entered at expression level displayed at work level if only one expression -->
			<xsl:apply-templates
				select="m:meiHead/m:workDesc/m:work/m:expressionList/m:expression/m:history[m:eventList[@type='performances']//text()]"
				mode="performances"/>
		</xsl:if>

		<!-- works with versions: draw separator before general bibliography -->
		<xsl:if test="count(m:meiHead/m:workDesc/m:work/m:expressionList/m:expression)&gt;1">
			<xsl:if test="m:meiHead/m:workDesc/m:work/m:biblList[m:bibl/*[text()]]">
				<hr class="noprint"/>
			</xsl:if>
		</xsl:if>

		<!-- bibliography -->
		<xsl:apply-templates select="m:meiHead/m:workDesc/m:work/m:biblList[m:bibl/*[text()]]"/>

		<xsl:apply-templates select="." mode="colophon"/>

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


	<!-- settings -->
	<xsl:template match="*" mode="settings_menu">
		<div class="settings colophon noprint">
			<a
				href="javascript:loadcssfile('/editor/style/html_hide_languages.css'); hide('load_alt_lang_css'); show('remove_alt_lang_css')"
				id="load_alt_lang_css" class="noprint">Hide alternative languages</a>
			<a style="display:none"
				href="javascript:removecssfile('/editor/style/html_hide_languages.css'); hide('remove_alt_lang_css'); show('load_alt_lang_css')"
				id="remove_alt_lang_css" class="noprint">Show alternative languages</a>
		</div>
	</xsl:template>


	<xsl:template match="m:titleStmt/m:respStmt[m:persName[text()]]">
		<!-- certain roles may be excluded from the list -->
		<xsl:param name="exclude"/>		
		<!-- list persons grouped by role -->
		<p>
			<xsl:for-each select="m:persName[text() and not(contains($exclude,@role))]">
				<xsl:variable name="role" select="@role"/>
				<xsl:variable name="displayed_role">
					<xsl:choose>
						<xsl:when test="@role='author'">Text author</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="capitalize">
								<xsl:with-param name="str" select="@role"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="count(../m:persName[text() and @role=$role]) > 1">
						<xsl:text>s</xsl:text>
					</xsl:if>
				</xsl:variable>
				<xsl:if test="count(preceding-sibling::*[@role=$role])=0">
					<!-- one <div> per role -->
					<div class="list_block">
						<span class="p_heading">
							<xsl:value-of select="$displayed_role"/>
							<xsl:text>: </xsl:text>
						</span>
						<xsl:for-each select="../m:persName[text() and @role=$role]">
							<xsl:apply-templates select="."/>
							<xsl:if test="count(following-sibling::*[@role=$role])>0">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</div>
				</xsl:if>
			</xsl:for-each>
			<!-- finally, list names without roles -->
			<xsl:for-each select="m:persName[text() and (not(@role) or @role='')]">
				<div class="list_block">
					<xsl:apply-templates select="."/>
				</div>
			</xsl:for-each>
		</p>
	</xsl:template>

	<!-- work identifiers -->
	<xsl:template match="m:meiHead/m:workDesc/m:work" mode="work_identifiers">
		<p>
			<xsl:for-each select="m:identifier[text()]">
				<!--<xsl:variable name="type"><xsl:apply-templates select="@label"/></xsl:variable>
	    <xsl:value-of select="concat($type,' ',.)"/>-->
				<xsl:apply-templates select="@label"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="."/>
				<xsl:if test="position()&lt;last()">
					<br/>
				</xsl:if>
			</xsl:for-each>
		</p>
	</xsl:template>

	<!-- Relations -->
	<xsl:template match="m:relationList" mode="link_without_label">
		<xsl:if test="m:relation[@target!='']">
			<p>
				<xsl:for-each select="m:relation[@target!='']">
					<img src="/editor/images/html_link.png" title="Link to external resource"/>
					<xsl:element name="a">
						<xsl:attribute name="href">
							<xsl:apply-templates select="@target"/>
						</xsl:attribute>
						<xsl:apply-templates select="@label"/>
						<xsl:if test="not(@label) or @label=''">
							<xsl:value-of select="@target"/>
						</xsl:if>
					</xsl:element>
					<xsl:if test="position()&lt;last()">, </xsl:if>
				</xsl:for-each>
			</p>
		</xsl:if>
	</xsl:template>

	<xsl:template match="m:relationList">
		<xsl:apply-templates select="." mode="relation_list"/>
		<!-- this detour is necessary to enable overriding the default behaviour in 
	 style sheets including this one (e.g., a print style sheet) -->
	</xsl:template>

	<xsl:template match="m:relationList" mode="relation_list">
		<xsl:if test="m:relation[@target!='']">
			<!-- loop through relations, but skip those where @label contains a ":"  -->
			<xsl:for-each
				select="m:relation[@rel!='' and not(normalize-space(substring-after(@label,':')))]">
				<xsl:variable name="rel" select="@rel"/>
				<xsl:if test="count(preceding-sibling::*[@rel=$rel])=0">
					<!-- one <div> per relation type -->
					<div class="list_block">
						<div class="relation_list">
							<xsl:variable name="label">
								<xsl:call-template name="translate_relation">
									<xsl:with-param name="label" select="@label"/>
									<xsl:with-param name="rel" select="@rel"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:if test="$label!=''">
								<div class="p_heading relation_list_label">
									<xsl:value-of select="$label"/>
								</div>
							</xsl:if>
							<xsl:if
								test="../m:relation[@rel=$rel or substring-before(@label,':')=$rel]">
								<div class="relations">
									<xsl:for-each
										select="../m:relation[@rel=$rel and not(normalize-space(substring-after(@label,':')))]">
										<xsl:apply-templates select="." mode="relation_link"/>
										<xsl:if test="position()!=last()">
											<br/>
										</xsl:if>
									</xsl:for-each>
								</div>
							</xsl:if>
						</div>
					</div>
				</xsl:if>
			</xsl:for-each>
			<!-- relations with @label containing ":" use the part before the ":" as label instead -->
			<xsl:for-each
				select="m:relation[@rel!='' and normalize-space(substring-after(@label,':'))]">
				<xsl:variable name="label" select="substring-before(@label,':')"/>
				<xsl:if test="count(preceding-sibling::*[substring-before(@label,':')=$label])=0">
					<!-- one <div> per relation type -->
					<div class="list_block">
						<div class="relation_list">
							<xsl:if test="$label!=''">
								<div class="p_heading relation_list_label">
									<xsl:value-of select="$label"/>: </div>
							</xsl:if>
							<xsl:if test="../m:relation[substring-before(@label,':')=$label]">
								<div class="relations">
									<xsl:for-each
										select="../m:relation[substring-before(@label,':')=$label]">
										<xsl:apply-templates select="." mode="relation_link"/>
										<xsl:if test="position()!=last()">
											<br/>
										</xsl:if>
									</xsl:for-each>
								</div>
							</xsl:if>
						</div>
					</div>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="m:relation[not(@rel) or @rel='']">
				<!-- this shouldn't really be necessary - relations without @rel are not valid -->
				<div>
					<xsl:for-each select="m:relation[not(@rel) or @rel='']">
						<xsl:apply-templates select="." mode="relation_link"/>
					</xsl:for-each>
				</div>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
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
					<xsl:value-of
						select="concat($settings/dcm:parameters/dcm:server_name,$settings/dcm:parameters/dcm:exist_dir,'present.xq?doc=',@target)"
					/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@target"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="label">
			<xsl:choose>
				<xsl:when test="normalize-space(substring-after(@label,':'))"><xsl:value-of
						select="normalize-space(substring-after(@label,':'))"/></xsl:when>
				<xsl:otherwise><xsl:apply-templates select="@label"/></xsl:otherwise>
			</xsl:choose>
			<xsl:if test="not(@label) or @label=''">
				<xsl:value-of select="@target"/>
			</xsl:if>
		</xsl:variable>
		<xsl:apply-templates select="." mode="relation_reference">
			<xsl:with-param name="href"><xsl:value-of select="$href"/></xsl:with-param>
			<xsl:with-param name="title"><xsl:value-of select="$label"/></xsl:with-param>
			<xsl:with-param name="class"/>
			<xsl:with-param name="text"><xsl:value-of select="$label"/></xsl:with-param>
		</xsl:apply-templates>
		<!--<a href="{$href}" title="{$label}"><xsl:value-of select="$label"/></a>-->&#160;<xsl:if
			test="$mermeid_crossref='true'">
			<!-- get collection name and number from linked files -->
			<!-- was: <xsl:variable name="fileName"	select="concat('http://',$hostname,'/storage/dcm/',@target)"/> -->
			<xsl:variable name="fileName"
				select="concat($settings/dcm:parameters/dcm:server_name,$settings/dcm:parameters/dcm:document_root,@target)"/>
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
				<xsl:apply-templates select="." mode="relation_reference">
					<xsl:with-param name="href"><xsl:value-of select="$href"/></xsl:with-param>
					<xsl:with-param name="title"><xsl:value-of select="$label"/></xsl:with-param>
					<xsl:with-param name="class">work_number_reference</xsl:with-param>
					<xsl:with-param name="text"><xsl:value-of select="$output"/></xsl:with-param>
				</xsl:apply-templates>
				<!--<a class="work_number_reference" href="{$href}" title="{$label}"><xsl:value-of
						select="$output"/></a>-->
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="relation_reference">
		<xsl:param name="href"/>
		<xsl:param name="title"/>
		<xsl:param name="class"/>
		<xsl:param name="text"/>
		<a href="{$href}" title="{$title}" class="{$class}"><xsl:value-of select="$text"/></a>
	</xsl:template>
	
	<xsl:template name="translate_relation">
		<xsl:param name="rel"/>
		<xsl:param name="label"/>
		<xsl:choose>
			<xsl:when test="$rel='hasAbridgement'">Abridged version:</xsl:when>
			<xsl:when test="$rel='isAbridgementOf'">Abridged version of:</xsl:when>
			<xsl:when test="$rel='hasAdaptation'">Adaptation:</xsl:when>
			<xsl:when test="$rel='isAdaptationOf'">Adaptation of:</xsl:when>
			<xsl:when test="$rel='hasAlternate'">Alternate:</xsl:when>
			<xsl:when test="$rel='isAlternateOf'">Alternate of:</xsl:when>
			<xsl:when test="$rel='hasArrangement'">Arrangement:</xsl:when>
			<xsl:when test="$rel='isArrangementOf'">Arrangement of:</xsl:when>
			<xsl:when test="$rel='hasComplement'">Complement:</xsl:when>
			<xsl:when test="$rel='isComplementOf'">Complement to:</xsl:when>
			<xsl:when test="$rel='hasEmbodiment'">Embodiment:</xsl:when>
			<xsl:when test="$rel='isEmbodimentOf'">Embodiment of:</xsl:when>
			<xsl:when test="$rel='hasExemplar'">Exemplar:</xsl:when>
			<xsl:when test="$rel='isExemplarOf'">Exemplar of:</xsl:when>
			<xsl:when test="$rel='hasImitation'">Imitation:</xsl:when>
			<xsl:when test="$rel='isImitationOf'">Imitation of:</xsl:when>
			<xsl:when test="$rel='hasPart'">Includes:</xsl:when>
			<xsl:when test="$rel='isPartOf'">Contained in:</xsl:when>
			<xsl:when test="$rel='hasRealization'">Realization:</xsl:when>
			<xsl:when test="$rel='isRealizationOf'">Realization of:</xsl:when>
			<xsl:when test="$rel='hasReconfiguration'">Reconfiguration:</xsl:when>
			<xsl:when test="$rel='isReconfigurationOf'">Reconfigurationof:</xsl:when>
			<xsl:when test="$rel='hasReproduction'">
				<xsl:choose>
					<xsl:when test="contains($label,'Edition')">Edition:</xsl:when>
					<xsl:otherwise>Reproduction (edition or facsimile):</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$rel='isReproductionOf'">Reproduction of:</xsl:when>
			<xsl:when test="$rel='hasRevision'">Revised version:</xsl:when>
			<xsl:when test="$rel='isRevisionOf'">Revised version of:</xsl:when>
			<xsl:when test="$rel='hasSuccessor'">Succeeded by:</xsl:when>
			<xsl:when test="$rel='isSuccessorOf'">Succeeds:</xsl:when>
			<xsl:when test="$rel='hasSupplement'">Supplement:</xsl:when>
			<xsl:when test="$rel='isSummarizationOf'">Summarizes:</xsl:when>
			<xsl:when test="$rel='hasSummarization'">Summarization:</xsl:when>
			<xsl:when test="$rel='isSupplementOf'">Supplement to:</xsl:when>
			<xsl:when test="$rel='hasTransformation'">Transformation:</xsl:when>
			<xsl:when test="$rel='isTransformationOf'">Transformation of:</xsl:when>
			<xsl:when test="$rel='hasTranslation'">Translated version:</xsl:when>
			<xsl:when test="$rel='isTranslationOf'">Translation of:</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$rel"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="m:expression" mode="top_level">
		<!-- top-level expression (versions and one-movement work details) -->
		<!-- show title/tempo/number as heading only if more than one version -->
		<xsl:if test="count(../m:expression)&gt;1">
			<!--<p>&#160;</p>-->
			<!--<xsl:variable name="title">
				<xsl:apply-templates select="m:titleStmt">
					<xsl:with-param name="tempo">
						<xsl:apply-templates select="m:tempo"/>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:if test="normalize-space($title)">
				<h2>
					<xsl:value-of select="$title"/>
				</h2>
			</xsl:if>-->
			<xsl:if test="normalize-space(m:titleStmt//text())">
				<h2 class="expression_heading">
					<xsl:apply-templates select="m:titleStmt"/>
				</h2>
			</xsl:if>
		</xsl:if>
		<xsl:if test="m:identifier/text()">
			<p>
				<xsl:for-each select="m:identifier[text()]">
					<xsl:apply-templates select="@label"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="."/>
					<xsl:if test="position()&lt;last()">
						<br/>
					</xsl:if>
				</xsl:for-each>
			</p>
		</xsl:if>
		<!-- persons -->
		<xsl:apply-templates select="m:titleStmt/m:respStmt[m:persName]"/>
		<!-- version history -->
		<xsl:apply-templates select="m:history[//text()]" mode="history"/>
		<!-- performers -->
		<xsl:apply-templates select="m:perfMedium[*//text()]"/>
		<!-- meter, key, incipit – only relevant at this level in single movement works -->
		<xsl:apply-templates select="m:tempo[text()]"/>
		<xsl:if test="m:meter[normalize-space(concat(@count,@unit,@sym))]">
			<xsl:apply-templates select="m:meter"/>
		</xsl:if>
		<xsl:apply-templates select="m:key[normalize-space(concat(@pname,@accid,@mode))]"/>
		<xsl:apply-templates select="m:extent"/>
		<xsl:apply-templates select="m:incip"/>
		<!-- external relation links -->
		<xsl:apply-templates select="m:relationList[m:relation[@target!='']]"/>
		<!-- components (movements) -->
		<xsl:for-each
			select="m:componentGrp[normalize-space(*//text()[1]) or *//@n!='' or *//@pitch!='' or *//@symbol!='' or *//@count!='']">
			<xsl:apply-templates select="." mode="fold_section">
				<xsl:with-param name="id" select="concat('movements',generate-id(),position())"/>
				<xsl:with-param name="heading">Music</xsl:with-param>
				<xsl:with-param name="content">
					<xsl:apply-templates select="m:expression"/>
				</xsl:with-param>
			</xsl:apply-templates>
		</xsl:for-each>
		<!-- version-specific sources -->
		<xsl:if test="count(../m:expression)&gt;1">
			<xsl:variable name="expression_id" select="@xml:id"/>
			<xsl:for-each
				select="/m:mei/m:meiHead/m:fileDesc/
		  m:sourceDesc[(normalize-space(*//text()) or m:source/@target!='') 
		  and m:source/m:relationList/m:relation[@rel='isEmbodimentOf' and substring-after(@target,'#')=$expression_id]]">

				<!-- collect all reproductions (reprints) - they will be needed later -->
				<xsl:variable name="collect_reprints">
					<sourceDesc xmlns="http://www.music-encoding.org/ns/mei">
						<xsl:for-each
							select="m:source[m:relationList/m:relation[@rel='isReproductionOf']]">
							<xsl:copy-of select="."/>
						</xsl:for-each>
					</sourceDesc>
				</xsl:variable>
				<!-- make it a nodeset -->
				<xsl:variable name="reprints" select="exsl:node-set($collect_reprints)"/>

				<xsl:apply-templates select="." mode="fold_section">
					<xsl:with-param name="id"
						select="concat('version_source',generate-id(.),$expression_id)"/>
					<xsl:with-param name="heading">Sources</xsl:with-param>
					<xsl:with-param name="content">
						<!-- collect all external source data first to create a complete list of sources -->
						<xsl:variable name="sources">
							<!-- skip reproductions (=reprints) - they are treated elsewhere -->
							<xsl:for-each
								select="m:source[m:relationList/m:relation[@rel='isEmbodimentOf' 
			  and substring-after(@target,'#')=$expression_id] and 
			  not(m:relationList/m:relation[@rel='isReproductionOf'])]">
								<xsl:choose>
									<xsl:when test="@target!=''">
										<!-- get external source description -->
										<xsl:variable name="ext_id"
											select="substring-after(@target,'#')"/>
										<xsl:variable name="doc_name"
											select="concat($settings/dcm:parameters/dcm:server_name,$settings/dcm:parameters/dcm:document_root,substring-before(@target,'#'))"/>
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
						<xsl:for-each select="$source_nodeset/m:source">
							<xsl:apply-templates select=".">
								<xsl:with-param name="reprints" select="$reprints"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:if>
		<!-- version performances -->
		<xsl:if test="count(../m:expression)&gt;1">
			<xsl:apply-templates select="m:history[m:eventList[@type='performances']//text()]"
				mode="performances"/>
		</xsl:if>
	</xsl:template>
	<!-- end top-level expressions (versions) -->


	<xsl:template match="m:expression">
		<!-- display title etc. only with components or versions -->
		<xsl:if
			test="ancestor-or-self::*[local-name()='componentGrp'] or count(../m:expression)&gt;1">
			<xsl:if test="@n!='' or m:titleStmt//text()">
				<xsl:variable name="level">
					<!-- expression headings start with <H3>, decreasing in size with each level -->
					<xsl:choose>
						<xsl:when test="ancestor-or-self::*[local-name()='componentGrp']">
							<xsl:value-of
								select="count(ancestor-or-self::*[local-name()='componentGrp'])+2"/>
						</xsl:when>
						<xsl:otherwise>3</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="element" select="concat('h',$level)"/>
				<xsl:element name="{$element}">
					<xsl:attribute name="class">movement_heading</xsl:attribute>
					<xsl:if test="@n!=''">
						<xsl:value-of select="@n"/>
						<xsl:text>. </xsl:text>
					</xsl:if>
					<xsl:apply-templates select="m:titleStmt[//text()]"/>
				</xsl:element>
			</xsl:if>
		</xsl:if>
		<xsl:apply-templates select="m:tempo[text()]"/>
		<xsl:if test="m:meter[normalize-space(concat(@count,@unit,@sym))]">
			<xsl:apply-templates select="m:meter"/>
		</xsl:if>
		<xsl:apply-templates select="m:key[normalize-space(concat(@pname,@accid,@mode))]"/>
		<xsl:apply-templates select="m:extent"/>
		<xsl:apply-templates select="m:incip"/>
		<xsl:apply-templates select="m:titleStmt/m:respStmt[m:persName]"/>
		<xsl:apply-templates
			select="m:perfMedium[m:instrumentation[m:instrVoice or m:instrVoiceGrp] or m:castList/m:castItem]"
			mode="subLevel"/>
		<xsl:apply-templates select="m:relationList[m:relation[@target!='']]"/>
		<xsl:for-each select="m:notesStmt/m:annot[not(@type='links') and //text()]">
			<p>
				<xsl:apply-templates/>
			</p>
		</xsl:for-each>
		<xsl:apply-templates select="m:componentGrp"/>
	</xsl:template>


	<xsl:template match="m:expression/m:titleStmt">
		<xsl:if test="m:title/text()">
			<xsl:for-each select="m:title[text()]">
				<xsl:choose>
					<xsl:when test="position()&gt;1">
						<span class="alternative_language">
							<!-- uncomment this to display indication of language (like [de] or [en])
		   <xsl:text>[</xsl:text>
		   <xsl:value-of select="@xml:lang"/>
		   <xsl:text>] </xsl:text>-->
							<xsl:apply-templates/>
							<xsl:if test="position()&lt;last()">
								<br/>
							</xsl:if>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="."/>
						<xsl:if test="position()&lt;last()">
							<br/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template match="m:expression/m:componentGrp">
		<xsl:choose>
			<xsl:when test="count(m:expression)&gt;1">
				<!-- displaying movements non-folding 
	     <xsl:element name="ul">
	     <xsl:attribute name="class">movement_list</xsl:attribute>
	     <xsl:if test="count(m:item|m:expression)=1">
	     <xsl:attribute name="class">single_movement</xsl:attribute>
	     </xsl:if>
	     <xsl:for-each select="m:expression">
	     <li>
	     <xsl:apply-templates select="."/>
	     </li>
	     </xsl:for-each>
	     </xsl:element>
	-->

				<xsl:apply-templates select="." mode="fold_section">
					<xsl:with-param name="id"
						select="concat('subsection',../../@xml:id,generate-id(),position())"/>
					<xsl:with-param name="heading">Sections</xsl:with-param>
					<xsl:with-param name="content">
						<xsl:element name="ul">
							<xsl:attribute name="class">movement_list</xsl:attribute>
							<xsl:if test="count(m:item|m:expression)=1">
								<xsl:attribute name="class">single_movement</xsl:attribute>
							</xsl:if>
							<xsl:for-each select="m:expression">
								<li>
									<xsl:apply-templates select="."/>
								</li>
							</xsl:for-each>
						</xsl:element>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="count(m:expression)=1">
				<ul class="single_movement">
					<li>
						<xsl:apply-templates select="m:expression"/>
					</li>
				</ul>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="m:incip">
		<xsl:for-each select="m:incipCode[text()]">
			<p>
					<xsl:choose>
						
						<xsl:when test="@form='plaineAndEasie' or @form='PAE' or @form='pae'">
							<xsl:variable name="id" select="concat('incip_pae_',generate-id())"/>
							<xsl:element name="div">
								<xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
								<xsl:text> </xsl:text>
							</xsl:element>
							<!-- use Verovio for rendering PAE incipits -->
							<script type="text/javascript">
							  /* The Plain and Easy code to be rendered */
							  var data = "@data:<xsl:value-of select="."/>";

							  /* Render the data and insert it as content of the target div */
							  document.getElementById("<xsl:value-of select="$id"/>").innerHTML = vrvToolkit.renderData( 
							      data, 
							      JSON.stringify({ 
							      	inputFormat: 'pae',
							      	pageWidth: 3000,
							      	pageHeight: 400,
    								border: 0,
    								scale: 30,
    								adjustPageHeight: 1,
    								ignoreLayout: 1
							      	}) 
							  );
							</script>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="normalize-space(@form)"><xsl:value-of select="@form"/>: </xsl:when>
								<xsl:otherwise><span class="label">Music incipit: </span></xsl:otherwise>
							</xsl:choose>
							<xsl:apply-templates select="."/>
						</xsl:otherwise>
					</xsl:choose>
			</p>
		</xsl:for-each>
		<xsl:apply-templates select="m:incipText[//text()]"/>
		<xsl:apply-templates select="." mode="graphic"/>
		<xsl:apply-templates select="m:score"/>
	</xsl:template>

	<xsl:template match="m:incip/m:score[*]">
		<xsl:variable name="id" select="concat('incip_score_',generate-id())"/>
		<xsl:variable name="xml_id" select="concat($id,'_xml')"/>
		<xsl:element name="div">
			<xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
            <xsl:text> </xsl:text>
		</xsl:element>
		
		<!-- put the MEI incipit XML into the document here -->
		<xsl:element name="script">
			<xsl:attribute name="id"><xsl:value-of select="$xml_id"/></xsl:attribute>
			<xsl:attribute name="type">text/xmldata</xsl:attribute>
			<mei xmlns="http://www.music-encoding.org/ns/mei" meiversion="2013">
				<music>
					<body>
						<mdiv>
							<xsl:copy-of select="."/>
						</mdiv>
					</body>
				</music>
			</mei>
		</xsl:element>
		<!-- use Verovio for rendering MEI incipits -->
		<script type="text/javascript">
		  /* The MEI encoding to be rendered */
		  var data = document.getElementById('<xsl:value-of select="$xml_id"/>').innerHTML;
		  /* Render the data and insert it as content of the target div */
		  document.getElementById("<xsl:value-of select="$id"/>").innerHTML = vrvToolkit.renderData( 
		      data, 
		      JSON.stringify({ 
		      	inputFormat: 'mei',
		      	pageWidth: 3000,
    			border: 0,
    			scale: 30,
    			adjustPageHeight: 1,
    			ignoreLayout: 1
		      	}) 
		  );
		</script>
	</xsl:template>
	
	<xsl:template match="m:incipText">
		<xsl:if test="m:p/text()">
			<div class="list_block">
				<div class="relation_list">
					<span class="p_heading relation_list_label">Text incipit: </span>
					<span class="relations">
						<xsl:for-each select="m:p[text()]">
							<xsl:element name="span">
								<xsl:call-template name="maybe_print_lang"/>
								<xsl:apply-templates/>
							</xsl:element>
							<xsl:if test="position() &lt; last()">
								<br/>
							</xsl:if>
						</xsl:for-each>
					</span>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template match="m:incip" mode="graphic">
		<!-- make img tag only if a target file is specified and the path does not end with a slash -->
		<xsl:if
			test="normalize-space(m:graphic[@targettype='lowres']/@target) and 
		  substring(m:graphic[@targettype='lowres']/@target,string-length(m:graphic[@targettype='lowres']/@target),1)!='/'">
			<p>
				<xsl:choose>
					<xsl:when
						test="m:graphic[@targettype='lowres']/@target and m:graphic[@targettype='hires']/@target">
						<a target="incipit" title="Click to enlarge image"
							style="text-decoration: none;">
							<xsl:attribute name="href">
								<xsl:value-of select="m:graphic[@targettype='hires']/@target"/>
							</xsl:attribute>
							<xsl:attribute name="onclick"> window.open('<xsl:value-of
									select="m:graphic[@targettype='hires']/@target"/>','incipit','height=550,width=1250,toolbar=0,status=0,menubar=0,resizable=1,location=0,scrollbars=1');return false; </xsl:attribute>
							<xsl:element name="img">
								<xsl:attribute name="border">0</xsl:attribute>
								<xsl:attribute name="style">text-decoration: none;</xsl:attribute>
								<xsl:attribute name="alt"/>
								<xsl:attribute name="src">
									<xsl:value-of select="m:graphic[@targettype='lowres']/@target"/>
								</xsl:attribute>
							</xsl:element>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="img">
							<xsl:attribute name="border">0</xsl:attribute>
							<xsl:attribute name="style">text-decoration: none;</xsl:attribute>
							<xsl:attribute name="alt"/>
							<xsl:attribute name="src">
								<xsl:value-of select="m:graphic[@targettype='lowres']/@target"/>
							</xsl:attribute>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</p>
		</xsl:if>
	</xsl:template>

	<xsl:template match="m:meter">
		<xsl:if test="position() = 1">
			<span class="label">Metre: </span>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="@count!='' and @unit!=''">
				<span class="meter">
					<span class="meter_count">
						<xsl:value-of select="@count"/>
					</span>
					<br/>
					<span class="meter_unit">
						<xsl:value-of select="@unit"/>
					</span>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<span class="music_symbols time_signature">
					<xsl:choose>
						<xsl:when test="@sym='common'">&#x1d134;</xsl:when>
						<xsl:when test="@sym='cut'">&#x1d135;</xsl:when>
					</xsl:choose>
				</span>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="position()=last()">
			<br/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="m:key[@pname or @accid or @mode]">
		<p>
			<span class="label">Key: </span>
			<xsl:value-of select="translate(@pname,'abcdefgh','ABCDEFGH')"/>
			<xsl:if test="@accid and @accid!='n'">
				<xsl:call-template name="key_accidental">
					<xsl:with-param name="attr" select="@accid"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:text> </xsl:text>
			<xsl:value-of select="@mode"/>
		</p>
	</xsl:template>

	<xsl:template match="m:tempo">
		<xsl:variable name="level">
			<!-- expression headings start with <H3>, decreasing in size with each level -->
			<xsl:choose>
				<xsl:when test="ancestor-or-self::*[local-name()='componentGrp']">
					<xsl:value-of select="count(ancestor-or-self::*[local-name()='componentGrp'])+2"
					/>
				</xsl:when>
				<xsl:otherwise>3</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="element" select="concat('h',$level)"/>
		<xsl:choose>
			<xsl:when test="../@n!='' or ../m:titleStmt/m:title!=''">
				<p>
					<span class="label">Tempo: </span>
					<xsl:apply-templates/>
				</p>
			</xsl:when>
			<xsl:otherwise>
				<!-- if movement has no title, format the tempo as title instead -->
				<xsl:element name="{$element}">
					<xsl:attribute name="class">movement_heading</xsl:attribute>
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="m:expression/m:extent[text()]">
		<p>Extent: <xsl:apply-templates/>&#160;<xsl:apply-templates select="@unit"/></p>
	</xsl:template>


	<!-- colophon -->
	<xsl:template match="*" mode="colophon">
		<div class="colophon">
			<br/>
			<div class="hr">&#160;</div>
			<xsl:if test="m:meiHead/m:fileDesc/m:titleStmt/m:title[text()]">
				<p class="colophon_heading">File title:</p>
				<p>
					<xsl:value-of select="m:meiHead/m:fileDesc/m:titleStmt/m:title[text()][1]"/>
				</p>
			</xsl:if>
			<xsl:if test="m:meiHead/m:fileDesc/m:seriesStmt/m:title/text()">
				<p class="colophon_heading">Series:</p>
				<xsl:for-each select="m:meiHead/m:fileDesc/m:seriesStmt/m:title//text()">
					<p>
						<xsl:value-of select="."/>
						<xsl:for-each
							select="../identifier[normalize-space(@type) and @type!='file_collection' and text()]">
							<br/>
							<xsl:value-of select="@type"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="."/>
						</xsl:for-each>
						<xsl:if test="position()!=last()">
							<br/>
						</xsl:if>
					</p>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="m:meiHead/m:fileDesc/m:pubStmt/m:respStmt/*[name()!='resp']//text()">
				<p class="colophon_heading">File publication:</p>
				<xsl:for-each
					select="m:meiHead/m:fileDesc/m:pubStmt/m:respStmt/m:corpName[//text()]">
					<p>
						<xsl:choose>
							<xsl:when test="text() or m:expan/text()">
								<xsl:apply-templates select="text()"/>
								<xsl:apply-templates select="m:expan"/>
								<xsl:if test="m:abbr/text()"> (<xsl:value-of select="m:abbr"
									/>)</xsl:if>
								<br/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="m:abbr/text()">
									<xsl:value-of select="m:abbr"/>
									<br/>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>

						<xsl:for-each select="m:address/m:addrLine[m:ptr/@target or text()]">
							<xsl:choose>
								<xsl:when test="m:ptr/@target">
									<xsl:choose>
										<xsl:when test="m:ptr/text()">
											<xsl:value-of select="m:ptr/text()"/>
											<xsl:text>: </xsl:text>
										</xsl:when>
										<xsl:when test="normalize-space(m:ptr/@label)">
											<xsl:value-of select="m:ptr/@label"/>
											<xsl:text>: </xsl:text>
										</xsl:when>
									</xsl:choose>
									<xsl:element name="a">
										<xsl:attribute name="href">
											<xsl:value-of select="m:ptr/@target"/>
										</xsl:attribute>
										<xsl:value-of select="m:ptr/@target"/>
									</xsl:element>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="."/>
								</xsl:otherwise>
							</xsl:choose>
							<br/>
						</xsl:for-each>
					</p>
				</xsl:for-each>
				<xsl:if test="m:meiHead/m:fileDesc/m:pubStmt/m:date/text()">
					<p>
						<xsl:value-of select="m:meiHead/m:fileDesc/m:pubStmt/m:date"/>
					</p>
				</xsl:if>

				<!-- list editors and others -->
				<xsl:if test="m:meiHead/m:fileDesc/m:pubStmt/m:respStmt[m:persName[text()]]">
					<p>
						<xsl:apply-templates
							select="m:meiHead/m:fileDesc/m:pubStmt/m:respStmt[m:persName[text()]]"
							mode="list_persons_by_role"/>
					</p>
				</xsl:if>

				<xsl:if test="m:meiHead/m:fileDesc/m:pubStmt/m:availability//text()">
					<p>
						<xsl:for-each
							select="m:meiHead/m:fileDesc/m:pubStmt/m:availability/m:acqSource[text()]">
							<br/>
							<xsl:value-of select="."/>
						</xsl:for-each>
						<xsl:for-each
							select="m:meiHead/m:fileDesc/m:pubStmt/m:availability/m:accessRestrict[text()]">
							<br/>
							<xsl:value-of select="."/>
						</xsl:for-each>
						<xsl:for-each
							select="m:meiHead/m:fileDesc/m:pubStmt/m:availability/m:useRestrict[text()]">
							<br/>
							<xsl:value-of select="."/>
						</xsl:for-each>
					</p>
				</xsl:if>
			</xsl:if>
			<xsl:apply-templates select="m:meiHead/m:revisionDesc"/>
		</div>
	</xsl:template>


	<!-- work-related templates -->

	<!-- perfMedium templates -->
	<xsl:template match="m:perfMedium">
		<xsl:param name="full" select="true()"/>
		<xsl:if test="m:instrumentation[* and //text()]">
			<div class="perfmedium list_block">
				<xsl:for-each select="m:instrumentation[*]">
					<!-- Overall intrumentation is assumed to be defined at top expression level, not work level -->
					<xsl:variable name="topLevelInstrumentation" 
						select="ancestor-or-self::m:expression[local-name(../..)='work']/m:perfMedium/m:instrumentation"/>
					<xsl:variable name="SortingValues">
						<xsl:call-template name="makeSortList">
							<xsl:with-param name="nodeset" select="$topLevelInstrumentation"/>
						</xsl:call-template>
					</xsl:variable>				
					<div class="relation_list">
						<xsl:if test="position()=1 and $full">
							<span class="p_heading relation_list_label">Instrumentation: </span>
						</xsl:if>
						<xsl:apply-templates select="m:instrVoiceGrp[*//text()]">
							<xsl:with-param name="SortList" select="$SortingValues"/>
						</xsl:apply-templates>
						<xsl:apply-templates select="m:instrVoice[not(@solo='true')][text()]">
							<!-- Sort instruments according to top-level list -->
							<xsl:sort data-type="number" select="string-length(substring-before($SortingValues,concat(',',@n,',')))"/>
						</xsl:apply-templates>
						<xsl:if test="count(m:instrVoice[@solo='true'])&gt;0">
							<xsl:if test="count(m:instrVoice[not(@solo='true')])&gt;0">
								<br/>
							</xsl:if>
							<span class="p_heading:">Soloist<xsl:if
									test="count(m:instrVoice[@solo='true'])&gt;1">s</xsl:if>:</span>
							<xsl:apply-templates select="m:instrVoice[@solo='true'][text()]"/>
						</xsl:if>
					</div>
				</xsl:for-each>
			</div>
		</xsl:if>
		<xsl:apply-templates select="m:castList[*//text()]">
			<xsl:with-param name="full" select="$full"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="m:instrVoiceGrp[*//text()]">
		<xsl:param name="SortList"/>
		<div>
		<xsl:if test="m:head[text()]">
			<xsl:value-of select="m:head"/>
			<xsl:if test="m:instrVoice[text()]">
				<xsl:text>:</xsl:text>
			</xsl:if>
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:for-each select="m:instrVoice[text()]">
			<xsl:sort data-type="number" select="string-length(substring-before($SortList,concat(',',@n,',')))"/>			
			<xsl:apply-templates select="."/>
			<xsl:if test="position()&lt;last()">
				<xsl:text>, </xsl:text>
			</xsl:if>
		</xsl:for-each>
		</div>
	</xsl:template>

	<xsl:template match="m:instrVoice">
		<xsl:if test="@count &gt; 1">
			<xsl:apply-templates select="@count"/>
		</xsl:if>
		<xsl:text> </xsl:text>
		<xsl:apply-templates/>
		<xsl:if test="position()&lt;last()">
			<xsl:text>, 
      </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="m:castList">
		<xsl:param name="full" select="true()"/>
		<div class="perfmedium list_block">
			<div class="relation_list">
				<xsl:if test="$full">
					<span class="p_heading relation_list_label">Roles: </span>
				</xsl:if>
				<xsl:element name="span">
					<xsl:if test="$full">
						<xsl:attribute name="class">relations</xsl:attribute>
					</xsl:if>
					<xsl:for-each
						select="m:castItem/m:role/m:name[count(@xml:lang[.=ancestor-or-self::m:castItem/preceding-sibling::*//@xml:lang])=0 or not(@xml:lang)]">
						<!-- iterate over languages -->
						<xsl:variable name="lang" select="@xml:lang"/>
						<xsl:element name="span">
							<xsl:call-template name="maybe_print_lang"/>
							<xsl:apply-templates select="../../../../m:castList" mode="castlist">
								<xsl:with-param name="lang" select="$lang"/>
								<xsl:with-param name="full" select="$full"/>
							</xsl:apply-templates>
						</xsl:element>
						<xsl:if test="position()&lt;last()">
							<br/>
						</xsl:if>
					</xsl:for-each>
				</xsl:element>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="m:castList" mode="castlist">
		<xsl:param name="lang" select="'en'"/>
		<xsl:param name="full" select="true()"/>
		<!-- Overall cast list is assumed to be defined at top expression level, not work level -->
		<xsl:variable name="topLevelCastList" 
			select="ancestor-or-self::m:expression[local-name(../..)='work']/m:perfMedium/m:castList"/>
		<xsl:variable name="SortingValues">
			<xsl:call-template name="makeSortList">
				<xsl:with-param name="nodeset" select="$topLevelCastList"/>
			</xsl:call-template>
		</xsl:variable>				
		<xsl:for-each select="m:castItem/m:role/m:name[@xml:lang=$lang]">
			<!-- Sort cast list according to top-level list -->
			<xsl:sort data-type="number" select="string-length(substring-before($SortingValues,concat(',',../../@n,',')))"/>			
			<xsl:apply-templates select="."/>
			<xsl:if test="$full">
				<xsl:apply-templates select="../../m:roleDesc[@xml:lang=$lang]"/>
				<xsl:for-each select="../../m:instrVoice[text()]"> (<xsl:value-of select="."
					/>)</xsl:for-each>
			</xsl:if>
			<xsl:if test="position() &lt; last()">
				<xsl:text>; </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="m:roleDesc">
		<xsl:if test="normalize-space(.)">, <xsl:value-of select="."/></xsl:if>
	</xsl:template>

	<xsl:template match="m:perfMedium" mode="subLevel">
		<xsl:apply-templates select=".">
			<xsl:with-param name="full" select="false()"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template name="makeSortList">
		<xsl:param name="nodeset"/>
		<!-- make a list of @n values to use as a sort list for sub-level instrumentations and cast lists -->
		<xsl:text>',</xsl:text>
		<xsl:for-each select="$nodeset//*">
			<xsl:value-of select="@xml:id"/><xsl:text>,</xsl:text>
		</xsl:for-each>
		<xsl:text>'</xsl:text>
	</xsl:template>
		
	<!-- end perfMedium -->

	<!-- history -->
	<xsl:template match="m:history[*//text()]" mode="history">
		<!-- composition history -->
		<xsl:if test="m:creation/m:date[text()] or m:creation/m:geogName[text()]">
			<xsl:if test="position()=1">
				<xsl:variable name="label">
					<!-- Use label "Composition" only at work level or if there is only 1 expression -->
					<xsl:choose>
						<xsl:when
							test="name(..)='work' or count(/m:meiHead/m:work/m:expressionList/m:expression[//text()])=1"
							>Composition</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when
									test="m:creation/m:date[text()] and m:creation/m:geogName[text()]"
									>Date and place</xsl:when>
								<xsl:when test="m:creation/m:geogName[text()]">Place</xsl:when>
								<xsl:otherwise>Date</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<p><span class="p_heading"><xsl:value-of select="$label"/>: </span>
					<xsl:apply-templates select="m:creation/m:geogName"/>
					<xsl:if test="m:creation/m:date[text()] and m:creation/m:geogName[text()]"
						><xsl:text> </xsl:text></xsl:if>
					<xsl:apply-templates select="m:creation/m:date"/>.</p>
			</xsl:if>
		</xsl:if>

		<xsl:apply-templates select="m:p[//text()]"/>

		<!-- history time line -->
		<xsl:for-each select="m:eventList[@type='history' and m:event[//text()]]">
			<table>
				<xsl:for-each select="m:event[//text()]">
					<xsl:apply-templates select="." mode="performance_details"/>
				</xsl:for-each>
			</table>
		</xsl:for-each>
	</xsl:template>

	<!-- performances -->
	<xsl:template match="m:history" mode="performances">
		<xsl:if test="m:eventList[@type='performances']//text()">
			<xsl:apply-templates select="." mode="fold_section">
				<xsl:with-param name="id" select="concat('history',generate-id(.),position())"/>
				<xsl:with-param name="heading">Performances</xsl:with-param>
				<xsl:with-param name="content">
					<div>
						<table>
							<xsl:for-each
								select="m:eventList[@type='performances']/m:event[//text()]">
								<xsl:apply-templates select="." mode="performance_details"/>
							</xsl:for-each>
						</table>
					</div>
				</xsl:with-param>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<!-- sources -->
	<xsl:template match="m:sourceDesc">
		<xsl:param name="global"/>
		<!-- collect all reproductions (reprints) - they will be needed later -->
		<xsl:variable name="collect_reprints">
			<sourceDesc xmlns="http://www.music-encoding.org/ns/mei">
				<xsl:for-each select="m:source[m:relationList/m:relation[@rel='isReproductionOf']]">
					<xsl:copy-of select="."/>
				</xsl:for-each>
			</sourceDesc>
		</xsl:variable>
		<!-- make it a nodeset -->
		<xsl:variable name="reprints" select="exsl:node-set($collect_reprints)"/>

		<xsl:apply-templates select="." mode="fold_section">
			<xsl:with-param name="id" select="concat('source',generate-id(.),position())"/>
			<xsl:with-param name="heading">Sources</xsl:with-param>
			<xsl:with-param name="content">
				<!-- collect all external source data first to create a complete list of sources -->
				<xsl:variable name="sources">
					<!-- If listing global sources, list only those not referring to a specific version (if more than one) -->
					<xsl:for-each
						select="m:source
		      [$global!='true' or ($global='true' and (count(//m:work/m:expressionList/m:expression)&lt;2
		      or not(m:relationList/m:relation[@rel='isEmbodimentOf']/@target)))]">
						<xsl:choose>
							<xsl:when test="@target!=''">
								<!-- get external source description -->
								<xsl:variable name="ext_id" select="substring-after(@target,'#')"/>
								<xsl:variable name="doc_name"
									select="concat($settings/dcm:parameters/dcm:server_name,$settings/dcm:parameters/dcm:document_root,substring-before(@target,'#'))"/>
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

				<xsl:variable name="sorted_sources">
					<!-- loop through the selected sources; skip reproductions at this point -->
					<xsl:for-each select="$source_nodeset/m:source[not(m:relationList/m:relation[@rel='isReproductionOf']/@target)]">
						<xsl:copy-of select="."/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="sorted_sources_nodeset" select="exsl:node-set($sorted_sources)"/>

				<xsl:apply-templates select="$sorted_sources_nodeset/m:source">
					<!-- also send the collection of all reprints to the template -->
					<xsl:with-param name="reprints" select="$reprints"/>
				</xsl:apply-templates>

			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<!-- performance-related templates -->

	<!-- performance details -->
	<xsl:template match="m:event" mode="performance_details">
		<tr>
			<td nowrap="nowrap">
				<xsl:apply-templates select="m:date"/>
			</td>
			<td>
				<xsl:apply-templates select="m:head"/>
				<xsl:for-each select="m:geogName[text()]">
					<xsl:apply-templates select="."/>
					<xsl:if test="position() &lt; last()">, </xsl:if>
					<xsl:if
						test="position()=last() and count(../m:corpName[text()]|../m:persName[text()])=0"
						>. </xsl:if>
				</xsl:for-each>
				<xsl:for-each select="m:corpName[text()]|
			      m:persName[text()]">
					<xsl:if test="position()=1"> (</xsl:if>
					<xsl:choose>
						<xsl:when test="@role!=preceding-sibling::*[name()='persName' or name()='corpName'][1]/@role or position()=1">
							<xsl:choose>
								<xsl:when test="@role=following-sibling::*[name()='persName' or name()='corpName'][1]/@role">
									<xsl:if test="name()='persName' and normalize-space(@role)">
										<xsl:value-of select="concat(@role,'s')"
										/><xsl:text>: </xsl:text>
									</xsl:if>
									<xsl:apply-templates select="."/>; </xsl:when>
								<xsl:otherwise>
									<xsl:if test="name()='persName' and normalize-space(@role)">
										<xsl:value-of select="@role"/>
										<xsl:text>: </xsl:text>
									</xsl:if>
									<xsl:apply-templates select="."/>
									<xsl:if test="following-sibling::m:persName/text()">; </xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="@role=following-sibling::*[name()='persName' or name()='corpName'][1]/@role">
									<xsl:apply-templates select="."/>; </xsl:when>
								<xsl:when test="not(following-sibling::*[name()='persName' or name()='corpName'][1]/@role)">
									<xsl:apply-templates select="."/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="."/>; </xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="position() = last()">
						<xsl:text>). </xsl:text>
					</xsl:if>
				</xsl:for-each>

				<xsl:for-each select="m:p[text()]">
					<xsl:apply-templates/>
					<xsl:text> </xsl:text>
				</xsl:for-each>

				<xsl:if test="@evidence!=''">
					<xsl:variable name="evidence" select="@evidence"/> [Evidence:
						<xsl:apply-templates select="/m:mei/m:meiHead//*[@xml:id=$evidence]"/>] </xsl:if>

				<xsl:for-each select="m:biblList">
					<xsl:variable name="no_of_refs" select="count(m:bibl[m:title/text()])"/>
					<xsl:if test="$no_of_refs &gt; 0">
						<xsl:choose>
							<xsl:when test="m:head='Reviews' and $no_of_refs = 1">
								<br/>Review: </xsl:when>
							<xsl:otherwise>
								<br/><xsl:value-of select="m:head"/>: </xsl:otherwise>
						</xsl:choose>
						<xsl:for-each select="m:bibl[m:title/text()]">
							<xsl:apply-templates select=".">
								<xsl:with-param name="compact" select="'true'"/>
							</xsl:apply-templates><xsl:text> </xsl:text>
						</xsl:for-each>
					</xsl:if>
				</xsl:for-each>

			</td>
		</tr>
	</xsl:template>

	<xsl:template match="m:event" mode="soloists">
		<xsl:variable name="no_of_soloists" select="count(m:persName[@type='soloist'])"/>
		<xsl:if test="$no_of_soloists &gt; 0">
			<xsl:choose>
				<xsl:when test="$no_of_soloists = 1"> soloist: </xsl:when>
				<xsl:otherwise> soloists: </xsl:otherwise>
			</xsl:choose>
			<xsl:for-each select="m:persName[@type='soloist']">
				<xsl:if test="position() &gt; 1">, </xsl:if>
				<xsl:value-of select="."/>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template name="list_agents">
		<xsl:if test="m:respStmt/m:persName[text()] |
		  m:respStmt/m:corpName[text()]">
			<xsl:for-each
				select="m:respStmt/m:persName[text()] |
			    m:respStmt/m:corpName[text()]">
				<xsl:choose>
					<xsl:when test="@role!=preceding-sibling::*[1]/@role or position()=1">
						<xsl:choose>
							<xsl:when test="@role=following-sibling::*[1]/@role">
								<xsl:if test="name()='persName' and normalize-space(@role)">
									<xsl:call-template name="capitalize">
										<xsl:with-param name="str" select="concat(@role,'s')"/>
									</xsl:call-template><xsl:text>: </xsl:text>
								</xsl:if>
								<xsl:apply-templates select="."/>, </xsl:when>
							<xsl:otherwise>
								<xsl:if test="name()='persName' and normalize-space(@role)">
									<xsl:call-template name="capitalize">
										<xsl:with-param name="str" select="@role"/>
									</xsl:call-template>
									<xsl:text>: </xsl:text>
								</xsl:if>
								<xsl:apply-templates select="."/>
								<xsl:if test="following-sibling::m:persName/text()">; </xsl:if>
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
								<xsl:apply-templates select="."/>; </xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="position() = last()">
					<xsl:text>. </xsl:text>
				</xsl:if>
			</xsl:for-each>


			<xsl:for-each
				select="m:geogName[text()] | 
		  m:date[text()] |
		  m:identifier[text()]">
				<xsl:if test="string-length(@label) &gt; 0">
					<xsl:apply-templates select="@label"/>
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

	<xsl:template match="m:source[*[name()!='classification']//text()] | m:item[*[name()!='classification']//text()]">
		<xsl:param name="mode" select="''"/>
		<xsl:param name="reprints"/>
		<xsl:variable name="source_id" select="@xml:id"/>
		<div>
			<xsl:attribute name="id">
				<xsl:choose>
					<xsl:when test="@xml:id">
						<xsl:value-of select="@xml:id"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="generate-id(.)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="local-name()='source'">
				<xsl:attribute name="class">source</xsl:attribute>
			</xsl:if>
			<!-- generate decreasing headings -->
			<xsl:variable name="level">
				<xsl:choose>
					<xsl:when test="$mode='reprint'">4</xsl:when>
					<xsl:when test="name(..)='componentGrp'">5</xsl:when>
					<xsl:when test="count(ancestor-or-self::*[name()='itemList']) &gt; 0">
						<xsl:value-of
							select="count(ancestor-or-self::*[name()='componentGrp' or name()='itemList'])+3"
						/>
					</xsl:when>
					<xsl:otherwise>3</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="heading_element" select="concat('h',$level)"/>
			<!-- source title -->
			<xsl:variable name="label">
				<xsl:choose>
					<xsl:when test="name(..)='componentGrp'"/>
					<xsl:otherwise><xsl:value-of select="@label"/>
						<xsl:if test="@label!='' and m:titleStmt/m:title/text()">
							<xsl:text>: </xsl:text>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="m:titleStmt/m:title/text() or @label!=''">
				<xsl:choose>
					<xsl:when
						test="local-name()='item' and normalize-space(@label) and name(..)!='componentGrp'">
						<!-- item label -->
						<xsl:element name="{$heading_element}">
							<xsl:value-of select="@label"/>
						</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="normalize-space($label)">
								<xsl:element name="{$heading_element}">
										<xsl:value-of select="$label"/>
								</xsl:element>
							</xsl:when>
							<xsl:when test="m:titleStmt/m:title/text()">
								<xsl:element name="{$heading_element}">
									<xsl:apply-templates select="m:titleStmt/m:title"/>
								</xsl:element>
							</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			
			<xsl:if test="m:respStmt/m:persName[text()] |
		    m:respStmt/m:corpName[text()]">
				<p>
					<xsl:call-template name="list_agents"/>
				</p>
			</xsl:if>

			<xsl:apply-templates select="m:classification/m:termList[m:term[text()]]"/>

			<xsl:for-each select="m:titleStmt[m:respStmt/m:persName/text()]">
				<xsl:comment> contributors </xsl:comment>
				<p>
					<xsl:call-template name="list_agents"/>
				</p>
			</xsl:for-each>

			<xsl:for-each
				select="m:pubStmt[normalize-space(concat(m:publisher, m:date, m:pubPlace))]">
				<xsl:comment>publication</xsl:comment>
				<div>
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
					<!--<xsl:call-template name="list_agents"/>-->
				</div>
			</xsl:for-each>

			<xsl:for-each select="m:physDesc">
				<xsl:apply-templates select="."/>
			</xsl:for-each>

			<xsl:for-each select="m:notesStmt">
				<xsl:for-each select="m:annot[text() or *//text()]">
					<xsl:apply-templates select="."/>
				</xsl:for-each>
				<xsl:apply-templates
					select="m:annot[@type='links'][m:ptr[normalize-space(@target)]]"
					mode="link_list_p"/>
			</xsl:for-each>

			<!-- source location and identifiers -->
			<xsl:for-each
				select="m:physLoc[m:repository//text() or m:identifier/text() or m:ptr/@target]">
				<div>
					<xsl:apply-templates select="."/>
				</div>
			</xsl:for-each>

			<xsl:for-each select="m:physDesc/m:provenance[*//text()]">
				<div>
					<xsl:text>Provenance: </xsl:text>
					<xsl:for-each select="m:eventList/m:event[*/text()]">
						<xsl:for-each select="m:p">
							<xsl:apply-templates/>
						</xsl:for-each>
						<xsl:for-each select="m:date[text()]">
							<xsl:text> (</xsl:text>
							<xsl:apply-templates select="."/>
							<xsl:text>)</xsl:text>
						</xsl:for-each>. </xsl:for-each>
				</div>
			</xsl:for-each>

			<xsl:for-each select="m:identifier[text()]">
				<div>
					<xsl:apply-templates select="@label"/>
					<xsl:text> </xsl:text>
					<xsl:choose>
						<!-- some CNW-specific styling here -->
						<xsl:when test="contains(@label,'CNU') and contains(@label,'Source')">
							<b><xsl:apply-templates select="."/></b>. </xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="."/>. </xsl:otherwise>
					</xsl:choose>
				</div>
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
				<xsl:variable name="count" select="count($reprints/m:sourceDesc/m:source[m:relationList/m:relation[@rel='isReproductionOf'
					and substring-after(@target,'#')=$source_id]])"/>
				<xsl:for-each
					select="$reprints/m:sourceDesc/m:source[m:relationList/m:relation[@rel='isReproductionOf'
		    and substring-after(@target,'#')=$source_id]]">
					<xsl:if test="position()=1">
						<xsl:if test="not(m:titleStmt/m:title/text())">
							<br/>
							<xsl:choose>
								<xsl:when test="$count > 1">
									<p class="p_heading">Reprints:</p>
								</xsl:when>
								<xsl:otherwise>
									<p class="p_heading">Reprint:</p>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
					</xsl:if>
					<xsl:apply-templates select=".">
						<xsl:with-param name="mode">reprint</xsl:with-param>
					</xsl:apply-templates>
				</xsl:for-each>
			</xsl:if>

		</div>
	</xsl:template>

	<xsl:template match="m:classification/m:termList[m:term[text()]]">
		<div class="classification">
			<xsl:variable name="sort_order"
				select="'DcmContentClass,DcmPresentationClass,DcmAuthorityClass,DcmScoringClass,DcmStateClass,DcmCompletenessClass'"/>
			<xsl:for-each select="m:term[text()]">
				<xsl:sort select="string-length(substring-before($sort_order,@classcode))"/>
				<xsl:if test="position()=1">[Classification: </xsl:if>
				<xsl:value-of select="."/>
				<xsl:choose>
					<xsl:when test="position()=last()">]</xsl:when>
					<xsl:otherwise>
						<xsl:text>, </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</div>
	</xsl:template>


	<xsl:template match="*[m:ptr[normalize-space(@target)]]" mode="link_list_p">
		<!-- link list wrapped in a <p> -->
		<p>
			<xsl:apply-templates select="." mode="comma-separated_links"/>
		</p>
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
											<xsl:text> </xsl:text>
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
			<p>
				<xsl:for-each select="m:dimensions[text()] | m:extent[text()]">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
					<xsl:call-template name="remove_">
						<xsl:with-param name="str" select="@unit"/>
					</xsl:call-template>
					<xsl:choose>
						<xsl:when test="position()&lt;last()">
							<xsl:text>;
	      </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>.
	      </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				<xsl:text>
	</xsl:text>
			</p>
		</xsl:if>

		<xsl:apply-templates select="m:titlePage[m:p//text()]"/>

		<xsl:for-each select="m:plateNum[text()]">
			<p>Pl. no. <xsl:apply-templates/>.</p>
		</xsl:for-each>
		<xsl:apply-templates select="m:handList[m:hand/@medium!='' or m:hand/text()]"/>
		<xsl:apply-templates select="m:physMedium"/>
		<xsl:apply-templates select="m:watermark"/>
		<xsl:apply-templates select="m:condition"/>
	</xsl:template>

	<xsl:template match="m:titlePage">
		<div>
			<xsl:if test="not(@label) or @label=''">Title page</xsl:if>
			<xsl:value-of select="@label"/>
			<xsl:text>: </xsl:text>
			<xsl:for-each select="m:p[//text()]">
				<span class="titlepage">
					<xsl:apply-templates/>
				</span>
			</xsl:for-each>
		</div>
	</xsl:template>

	<xsl:template match="m:physMedium[text()]">
		<div>
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="m:watermark[text()]">
		<div>Watermark: <xsl:apply-templates/></div>
	</xsl:template>

	<xsl:template match="m:condition[text()]">
		<div>Condition: <xsl:apply-templates/></div>
	</xsl:template>

	<xsl:template match="m:physLoc">
		<!-- locations and shelf marks - both for <source>, <item> and <bibl> -->
		<xsl:for-each select="m:repository[*//text()]">
			<!-- (RISM) identifier -->
			<xsl:for-each select="m:identifier[text()]">
				<span class="rism">
					<xsl:apply-templates select="."/>
				</span>
			</xsl:for-each>
			<xsl:variable name="location">
				<!-- Repository name, Place -->
				<xsl:apply-templates select="m:corpName[text()]"/>
				<xsl:if test="m:corpName[text()] and m:geogName[text()]">
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:apply-templates select="m:geogName[text()]"/>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="m:identifier[text()] and normalize-space($location)">
					<!-- Format: RISM siglum (Repository name, Place) -->
					<xsl:text> (</xsl:text>
					<xsl:copy-of select="$location"/>
					<xsl:text>)</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<!-- Format: Repository name, Place -->
					<xsl:copy-of select="$location"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="../m:identifier[text()]">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:apply-templates select="m:identifier"/>
		<xsl:if test="m:identifier[text()] or m:repository[*//text()]">. </xsl:if>
		<xsl:apply-templates select="m:repository/m:ptr[normalize-space(@target)]"
			mode="comma-separated_links"/>
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


	<!-- bibliography -->

	<xsl:template name="print_bibliography_type">
		<span class="p_heading">
			<xsl:choose>
				<xsl:when test="m:head!=''">
					<xsl:value-of select="m:head"/>
				</xsl:when>
				<xsl:otherwise> Bibliography </xsl:otherwise>
			</xsl:choose>
		</span>
	</xsl:template>

	<xsl:template match="m:biblList">
		<xsl:if test="m:bibl/*[local-name()!='genre']//text()">
			<xsl:apply-templates select="." mode="fold_section">
				<xsl:with-param name="id" select="concat('bib',generate-id(),position())"/>
				<xsl:with-param name="heading">
					<xsl:call-template name="print_bibliography_type"/>
				</xsl:with-param>
				<xsl:with-param name="content">
					<xsl:apply-templates select="." mode="bibl_paragraph"/>
				</xsl:with-param>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<!-- render bibliography items as paragraphs or tables -->
	<xsl:template match="m:biblList" mode="bibl_paragraph">
		<!-- Letters and diary entries are listed first under separate headings -->
		<xsl:if test="count(m:bibl[m:genre='letter' and *[local-name()!='genre']//text()]) &gt; 0">
			<p class="p_subheading">Letters:</p>
			<table class="letters">
				<xsl:for-each select="m:bibl[m:genre='letter' and *[local-name()!='genre']//text()]">
					<xsl:apply-templates select="."/>
				</xsl:for-each>
			</table>
		</xsl:if>
		<xsl:if
			test="count(m:bibl[m:genre='diary entry' and *[local-name()!='genre']//text()]) &gt; 0">
			<p class="p_subheading">Diary entries:</p>
			<table class="letters">
				<xsl:for-each
					select="m:bibl[m:genre='diary entry' and *[local-name()!='genre']//text()]">
					<xsl:apply-templates select="."/>
				</xsl:for-each>
			</table>
		</xsl:if>
		<xsl:if
			test="count(m:bibl[m:genre='manuscript' and *[local-name()!='genre']//text()]) &gt; 0">
			<p class="p_subheading">Manuscripts:</p>
			<xsl:for-each select="m:bibl[m:genre='manuscript' and *[local-name()!='genre']//text()]">
				<p class="bibl_record">
					<xsl:apply-templates select="."/>
				</p>
			</xsl:for-each>
		</xsl:if>
		<xsl:if
			test="count(m:bibl[(m:genre='letter' or m:genre='diary entry' or m:genre='manuscript') and *[local-name()!='genre']//text()])&gt;0 and 
	      count(m:bibl[m:genre!='letter' and m:genre!='diary entry'  and m:genre!='manuscript' and *[local-name()!='genre']//text()])&gt;0">
			<p class="p_heading">Other:</p>
		</xsl:if>
		<xsl:for-each
			select="m:bibl[m:genre!='letter' and m:genre!='diary entry' and m:genre!='manuscript' and *[local-name()!='genre']//text()]">
			<p class="bibl_record">
				<xsl:apply-templates select="."/>
			</p>
		</xsl:for-each>
	</xsl:template>

	<!-- bibliographic record formatting template -->
	<xsl:template match="m:bibl">
		<xsl:param name="compact" select="'false'"/>

		<xsl:choose>
			<xsl:when test="m:genre='book' and not(m:genre='article')">
				<xsl:if test="m:title[@level='m']/text()">
					<!-- show entry only if a title is stated -->
					<xsl:choose>
						<xsl:when test="m:author/text()">
							<xsl:call-template name="list_authors"/>:
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="list_editors"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates select="m:title[@level='m']" mode="bibl_title">
						<xsl:with-param name="quotes" select="'false'"/>
						<xsl:with-param name="italic" select="'true'"/>
					</xsl:apply-templates>
					<xsl:if test="m:title[@level='s']/text()"> (= <xsl:apply-templates
							select="m:title[@level='s']"/>
						<xsl:if test="m:biblScope[@unit='vol']/text()">, vol. <xsl:apply-templates
								select="m:biblScope[@unit='vol']"/>
						</xsl:if>)</xsl:if>
					<xsl:apply-templates select="m:imprint">
						<xsl:with-param name="append_to_text">true</xsl:with-param>
					</xsl:apply-templates>
					<xsl:choose>
						<xsl:when test="normalize-space(m:title[@level='s'])=''">
							<xsl:apply-templates select="current()" mode="volumes_pages"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="normalize-space(m:biblScope[@unit='page'])">,
									<xsl:apply-templates select="m:biblScope[@unit='page']"
									mode="pp"/>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates select="m:biblScope[not(@unit) or @unit='']" mode="volumes_pages"/>
					<xsl:if test="normalize-space(m:title[@level='s'])=''"> </xsl:if>
				</xsl:if>. </xsl:when>

			<xsl:when test="m:genre='article' and m:genre='book'">
				<!-- show entry only if a title is stated -->
				<xsl:if test="m:title[@level='a']/text()">
					<xsl:if test="m:author/text()">
						<xsl:call-template name="list_authors"/>:
					</xsl:if>
					<xsl:apply-templates select="m:title[@level='a']" mode="bibl_title">
						<xsl:with-param name="quotes" select="'true'"/>
						<xsl:with-param name="italic" select="'false'"/>
					</xsl:apply-templates>
					<xsl:choose>
						<xsl:when test="m:title[@level='m']/text()">, in: <xsl:if
								test="m:editor/text()">
								<xsl:call-template name="list_editors"/>
							</xsl:if>
							<xsl:apply-templates select="m:title[@level='m']" mode="bibl_title">
								<xsl:with-param name="quotes" select="'false'"/>
								<xsl:with-param name="italic" select="'true'"/>
							</xsl:apply-templates>
							<xsl:choose>
								<xsl:when test="m:title[@level='s']/text()">(= <xsl:apply-templates
										select="m:title[@level='s']/text()"/>
									<xsl:if test="m:biblScope[@unit='vol']/text()">, vol.
											<xsl:value-of select="m:biblScope[@unit='vol']/text()"/>
									</xsl:if>) </xsl:when>
								<xsl:otherwise>
									<xsl:if test="m:biblScope[@unit='vol']/text()">, vol.
											<xsl:value-of
											select="normalize-space(m:biblScope[@unit='vol'])"
										/></xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="normalize-space(m:title[@level='s'])!=''">, in:
										<xsl:apply-templates select="m:title[@level='s' and text()]"/>
									<xsl:if test="normalize-space(m:biblScope[@unit='vol'])!=''">,
										vol. <xsl:value-of
											select="normalize-space(m:biblScope[@unit='vol'])"
										/></xsl:if>
								</xsl:when>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if
						test="normalize-space(concat(m:imprint/m:publisher,m:imprint/m:pubPlace,m:imprint/m:date))!=''"
						> (<xsl:if test="normalize-space(m:imprint/m:publisher)!=''">
							<xsl:value-of select="normalize-space(m:imprint/m:publisher)"/>: </xsl:if>
						<xsl:if test="normalize-space(m:imprint/m:pubPlace)!=''">
							<xsl:value-of select="normalize-space(m:imprint/m:pubPlace)"/></xsl:if>
						<xsl:if test="normalize-space(m:imprint/m:date)!=''"
								><xsl:text> </xsl:text><xsl:value-of
								select="normalize-space(m:imprint/m:date)"/></xsl:if>
						<xsl:text>)</xsl:text>
					</xsl:if>
					<xsl:if test="normalize-space(m:biblScope[@unit='page'])!=''">
						<xsl:text>, </xsl:text>
						<xsl:apply-templates select="m:biblScope[@unit='page']" mode="pp"/>
					</xsl:if>
					<xsl:apply-templates select="m:biblScope[not(@unit) or @unit='']" mode="volumes_pages"/>. </xsl:if>
			</xsl:when>

			<xsl:when
				test="(m:genre='journal' or m:genre='newspaper') and (m:genre='article' or m:genre='interview')">
				<!-- show entry only if some type of title is stated -->
				<xsl:if test="m:title/text()">
					<xsl:if test="normalize-space(m:title[@level='a'])!=''">
						<xsl:if test="m:author/text()">
							<xsl:call-template name="list_authors"/>:
						</xsl:if>
						<xsl:apply-templates select="m:title[@level='a']" mode="bibl_title">
							<xsl:with-param name="quotes" select="'true'"/>
							<xsl:with-param name="italic" select="'false'"/>
						</xsl:apply-templates>
						<xsl:if test="m:title[@level='j']/text()">. </xsl:if>
					</xsl:if>
					<xsl:if test="m:title[@level='j']/text()">
						<xsl:apply-templates select="m:title[@level='j']" mode="bibl_title">
							<xsl:with-param name="quotes" select="'false'"/>
							<xsl:with-param name="italic" select="'true'"/>
						</xsl:apply-templates>
					</xsl:if>
					<xsl:if test="normalize-space(m:biblScope[@unit='vol'])!=''">, <xsl:value-of
							select="normalize-space(m:biblScope[@unit='vol'])"/></xsl:if>
					<xsl:if test="normalize-space(m:biblScope[@unit='issue'])!=''">/<xsl:value-of
							select="normalize-space(m:biblScope[@unit='issue'])"/></xsl:if>
					<xsl:if test="normalize-space(m:imprint/m:date)!=''">, <xsl:apply-templates
							select="m:imprint/m:date"/></xsl:if>
					<xsl:if test="normalize-space(m:biblScope[@unit='page'])!=''">,
							<xsl:apply-templates select="m:biblScope[@unit='page']" mode="pp"
						/></xsl:if>
					<xsl:apply-templates select="m:biblScope[not(@unit) or @unit='']" mode="volumes_pages"/>
					<!-- if the author is given, but no article title, put the author last -->
					<xsl:if test="not(normalize-space(m:title[@level='a'])!='') and m:author/text()">
						<xsl:text> (</xsl:text>
						<xsl:for-each select="m:author">
							<xsl:if test="position()&gt;1">
								<xsl:text>, </xsl:text>
							</xsl:if>
							<xsl:apply-templates select="."/>
						</xsl:for-each>
						<xsl:text>)</xsl:text>
					</xsl:if>
					<xsl:text>. </xsl:text>
				</xsl:if>
			</xsl:when>

			<xsl:when test="m:genre='web site'">
				<!-- show entry only if a title or URI is stated -->
				<xsl:if test="normalize-space(concat(m:title,m:ptr))">
					<xsl:if test="normalize-space(m:author)!=''"><xsl:apply-templates
							select="m:author"/>: </xsl:if>
					<xsl:apply-templates select="m:title[text()]" mode="bibl_title">
						<xsl:with-param name="quotes" select="'false'"/>
						<xsl:with-param name="italic" select="'true'"/>
					</xsl:apply-templates>
					<xsl:if test="normalize-space(m:imprint/m:date) and normalize-space(m:title)">. </xsl:if>
					<xsl:apply-templates select="m:imprint/m:date"/>
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:when>

			<xsl:when test="m:genre='letter'">
				<tr>
					<td class="date_col">
						<xsl:apply-templates select="m:creation/m:date[text()]"/><xsl:if
							test="m:creation/m:geogName/text() and m:creation/m:date/text()">, </xsl:if>
						<xsl:apply-templates select="m:creation/m:geogName/text()"/>&#160;&#160; </td>
					<td>
						<xsl:if test="m:author/text()">
							<xsl:choose>
								<xsl:when test="m:creation/m:date/text()"> from </xsl:when>
								<xsl:otherwise>From </xsl:otherwise>
							</xsl:choose>
							<!--<xsl:value-of select="m:author"/>-->
							<xsl:call-template name="list_authors"/>
						</xsl:if>
						<xsl:if test="m:recipient/text()">
							<xsl:choose>
								<xsl:when test="m:author/text()"> to </xsl:when>
								<xsl:otherwise>To </xsl:otherwise>
							</xsl:choose>
							<xsl:value-of select="m:recipient"/>
						</xsl:if>
						<xsl:if test="(m:author/text() or m:recipient/text()) and m:physLoc//text()"
							>, </xsl:if>
						<xsl:apply-templates select="m:physLoc[*//text()]"/>
						<xsl:call-template name="hosts"/>
						<xsl:apply-templates select="m:annot"/>
						<xsl:apply-templates select="m:ptr"/>
					</td>
				</tr>
			</xsl:when>

			<xsl:when test="m:genre='diary entry'">
				<tr>
					<td class="date_col">
						<xsl:apply-templates select="m:creation/m:date[text()]"/><xsl:if
							test="m:creation/m:geogName/text() and m:creation/m:date/text()">, </xsl:if>
						<xsl:apply-templates select="m:creation/m:geogName/text()"/>&#160;&#160; </td>
					<td>
						<!-- do not display name if it is the composer's own diary -->
						<xsl:if
							test="m:author/text() or (m:author/text() and m:author!=/*//m:work/m:titleStmt/m:respStmt/m:persName[@role='composer'])">
							<xsl:text> </xsl:text>
							<xsl:value-of select="m:author"/>
							<xsl:if
								test="m:physLoc[m:repository//text() or m:identifier/text() or m:ptr/@target]"
								>, </xsl:if>
						</xsl:if>
						<xsl:apply-templates
							select="m:physLoc[m:repository//text() or m:identifier/text() or m:ptr/@target]"/>
						<xsl:call-template name="hosts"/>
						<xsl:apply-templates select="m:annot"/>
						<xsl:apply-templates select="m:ptr"/>
					</td>
				</tr>
			</xsl:when>

			<xsl:when test="m:genre='manuscript'">
				<xsl:if test="m:author//text()"><xsl:apply-templates select="m:author"/>: </xsl:if>
				<xsl:if test="m:title//text()">
					<xsl:apply-templates select="m:title" mode="bibl_title">
						<xsl:with-param name="quotes" select="'false'"/>
						<xsl:with-param name="italic" select="'true'"/>
					</xsl:apply-templates>
					<xsl:text>. </xsl:text>
				</xsl:if>
				<xsl:if test="m:creation/m:geogName//text()">
					<xsl:apply-templates select="m:creation/m:geogName"/>
					<xsl:if test="m:creation/m:date//text()">
						<xsl:text> </xsl:text>
					</xsl:if>
				</xsl:if>
				<xsl:apply-templates select="m:physLoc[*//text()]"/>
				<xsl:if test="m:creation/m:date//text()">
					<xsl:apply-templates select="m:creation/m:date"/>. </xsl:if>
			</xsl:when>

			<xsl:when test="contains(m:genre,'concert') and contains(m:genre,'program')">
				<xsl:if test="m:title//text()">
					<em>
						<xsl:apply-templates select="m:title"/>
					</em>
					<xsl:if test="not(contains('.!?',substring(m:title,string-length(m:title),1)))"
						>.</xsl:if>
				</xsl:if>
				<xsl:apply-templates select="m:annot">
					<xsl:with-param name="compact" select="'true'"/>
				</xsl:apply-templates>
				<xsl:if test="m:imprint//text()">. </xsl:if>
				<xsl:for-each select="m:imprint[*//text()]">
					<xsl:if test="m:publisher/text()">
						<xsl:apply-templates select="m:publisher"/><xsl:if
							test="m:pubPlace//text() or m:date//text()">, </xsl:if></xsl:if>
					<xsl:value-of select="m:pubPlace"/>
					<xsl:if test="m:date/text()">
						<xsl:text> </xsl:text>
						<xsl:apply-templates select="m:date[text()]"/>
					</xsl:if>. </xsl:for-each>
				<xsl:call-template name="hosts"/>
				<xsl:apply-templates select="m:ptr"/>
			</xsl:when>

			<xsl:otherwise>
				<!-- unrecognized reference types are marked with an asterisk -->
				<xsl:if test="m:author//text()"><xsl:apply-templates select="m:author"/>: </xsl:if>
				<xsl:if test="m:title//text()">
					<em><xsl:apply-templates select="m:title"/></em>
				</xsl:if>
				<xsl:if test="m:biblScope[@unit='vol']//text()">, vol. <xsl:value-of
						select="normalize-space(m:biblScope[@unit='vol'])"/></xsl:if>.
					<xsl:apply-templates select="m:imprint"/>
				<xsl:if test="m:creation/m:date//text()">
					<xsl:apply-templates select="m:creation/m:date"/></xsl:if>
				<xsl:if test="m:biblScope[@unit='page']//text()">, <xsl:apply-templates
					select="m:biblScope[@unit='page']" mode="pp"/></xsl:if>
				<xsl:apply-templates select="m:biblScope[not(@unit) or @unit='']" mode="volumes_pages"/>.* </xsl:otherwise>
		</xsl:choose>

		<!-- links to full text (exception: letters and diary entries handled elsewhere) -->
		<xsl:if
			test="not(m:genre='diary entry' or m:genre='letter' or (contains(m:genre,'concert') and contains(m:genre,'program')))">
			<xsl:apply-templates select="m:annot">
				<xsl:with-param name="compact" select="'true'"/>
			</xsl:apply-templates>
			<xsl:call-template name="hosts"/>
			<xsl:apply-templates select="m:ptr"/>
		</xsl:if>
	</xsl:template>

	<!-- bibl-related templates -->

	<xsl:template match="m:bibl/m:title" mode="bibl_title">
		<xsl:param name="quotes" select="'false'"/>
		<xsl:param name="italic" select="'false'"/>
		<xsl:variable name="title">
			<xsl:choose>
				<xsl:when test="substring(.,1,1)='[' and substring(.,string-length(.),1)=']'">
					<xsl:value-of select="substring(.,2,string-length(.)-2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="brackets">
			<xsl:choose>
				<xsl:when test="substring(.,1,1)='[' and substring(.,string-length(.),1)=']'"
					>true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$brackets='true'">
			<xsl:text>[</xsl:text>
		</xsl:if>
		<xsl:if test="$quotes='true'">
			<xsl:text>'</xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$italic='true'">
				<i>
					<xsl:value-of select="$title"/>
				</i>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$title"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$quotes='true'">
			<xsl:text>'</xsl:text>
		</xsl:if>
		<xsl:if test="$brackets='true'">
			<xsl:text>]</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="m:bibl/m:annot">
		<xsl:param name="compact" select="'false'"/>
		<xsl:choose>
			<xsl:when test="$compact='true'">
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="text()"/>
				<xsl:apply-templates select="m:p" mode="paragraph_to_line_break"/>
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<div>
					<xsl:apply-templates select="text()"/>
					<xsl:apply-templates select="m:p" mode="paragraph_to_line_break"/>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- editions containing (the text of) the item -->
	<xsl:template name="hosts">
		<xsl:for-each select="m:relatedItem[@rel='host' and *//text()]">
			<xsl:if test="position()=1"> (</xsl:if>
			<xsl:if test="position() &gt; 1">;<xsl:text> </xsl:text></xsl:if>
			<xsl:apply-templates select="m:bibl/m:title"/>
			<xsl:apply-templates select="m:bibl" mode="volumes_pages"/>
			<xsl:if test="position()=last()">)</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- imprint -->
	<xsl:template match="m:imprint[*//text()]">
		<xsl:param name="append_to_text"/>
		<xsl:if test="$append_to_text='true' and ../m:title/text()">. </xsl:if>
		<xsl:if test="m:publisher/text()">
			<xsl:apply-templates select="m:publisher"/>: </xsl:if>
		<xsl:value-of select="m:pubPlace"/>
		<xsl:if test="m:date/text()">
			<xsl:text> </xsl:text>
			<xsl:apply-templates select="m:date"/>
			<xsl:if test="not($append_to_text='true')">.</xsl:if>
		</xsl:if>
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

	<!-- list authors in bibliographic references -->
	<xsl:template name="list_authors">
		<xsl:for-each select="m:author">
			<xsl:call-template name="list_seperator"/>
			<xsl:apply-templates select="."/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="m:author">
		<xsl:value-of select="."/>
		<xsl:if test="@type and @type!=''">
			<xsl:text> </xsl:text>(<xsl:value-of select="@type"/>)</xsl:if>
	</xsl:template>

	<!-- list editors in bibliographic references -->
	<xsl:template name="list_editors">
		<xsl:for-each select="m:editor[text()]">
			<xsl:call-template name="list_seperator"/>
			<xsl:value-of select="."/>
			<xsl:if test="position()=last()">
				<xsl:choose>
					<xsl:when test="position() &gt;1">
						<xsl:text> (eds.): </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> (ed.): </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<!-- format volume, issue and page numbers -->
	<xsl:template mode="volumes_pages" match="m:bibl">
		<xsl:variable name="number_of_volumes" select="count(m:biblScope[@unit='vol' and text()])"/>
		<xsl:choose>
			<xsl:when test="$number_of_volumes &gt; 0">: <xsl:for-each
					select="m:biblScope[@unit='vol' and text()]">
					<xsl:if test="position()&gt;1">; </xsl:if> vol. <xsl:value-of select="."/>
					<xsl:if test="../m:biblScope[@unit='issue'][position()]/text()">/<xsl:value-of
							select="../m:biblScope[@unit='issue'][position()]"/></xsl:if>
					<xsl:if test="../m:biblScope[@unit='page'][position()]/text()">,
							<xsl:apply-templates select="../m:biblScope[@unit='page'][position()]"
							mode="pp"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="number_of_issues"
					select="count(m:biblScope[@unit='issue' and text()])"/>
				<xsl:choose>
					<xsl:when test="$number_of_issues &gt; 0">
						<xsl:for-each select="m:biblScope[@unit='issue' and text()]">
							<xsl:if test="position()&gt;1">; </xsl:if>
							<xsl:value-of select="."/>
							<xsl:if test="../m:biblScope[@unit='page'][position()]/text()">,
									<xsl:apply-templates
									select="../m:biblScope[@unit='page'][position()]" mode="pp"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="m:biblScope[contains(@unit,'page') and text()]">
							<xsl:if test="position()=1">, </xsl:if>
							<xsl:if test="position()&gt;1">; </xsl:if>
							<xsl:apply-templates select="." mode="pp"/>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:for-each
			select="m:biblScope[@unit and (@unit!='vol' and @unit!='issue' and @unit!='page')]">
			<xsl:text> </xsl:text>
			<xsl:choose>
				<xsl:when test="@unit='no'">no.</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@unit"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text> </xsl:text>
			<xsl:value-of select="."/>
		</xsl:for-each>
		<xsl:apply-templates select="m:biblScope[not(@unit) or @unit='']" mode="volumes_pages"/>
	</xsl:template>

	<xsl:template match="m:biblScope[not(@unit) or @unit='']" mode="volumes_pages">
		<xsl:if test="preceding-sibling::*[name()='biblScope']">,</xsl:if>
		<xsl:text> </xsl:text>
		<xsl:value-of select="."/>		
	</xsl:template>

	<xsl:template match="m:biblScope[@unit='page' and text()]" mode="pp">
		<xsl:choose>
			<xsl:when test="translate(.,' 0123456789','')!=''">pp.</xsl:when>
			<xsl:otherwise>p.</xsl:otherwise>
		</xsl:choose>
		<xsl:text> </xsl:text>
		<xsl:value-of select="."/>
	</xsl:template>

	<!-- display external link -->
	<xsl:template match="m:ptr[normalize-space(@target) or normalize-space(@xl:href)]">
		<img src="/editor/images/html_link.png" title="Link to external resource"/>
		<a target="_blank">
			<xsl:attribute name="href">
				<xsl:choose>
					<xsl:when test="normalize-space(@target)">
						<xsl:value-of select="@target"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@xl:href"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="normalize-space(@label)">
					<xsl:value-of select="@label"/>
				</xsl:when>
				<xsl:when test="normalize-space(@targettype)">
					<xsl:call-template name="capitalize">
						<xsl:with-param name="str" select="@targettype"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="normalize-space(@target)">
							<xsl:value-of select="@target"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@xl:href"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</a>
	</xsl:template>
	
	<!-- authority files -->
	<xsl:template match="*[@authURI!='' and @dbkey!='']">
		<xsl:value-of select="."/>
		<xsl:element name="a">
			<xsl:attribute name="href"><xsl:value-of select="concat(@authURI,'/',@dbkey)"/></xsl:attribute>
			<xsl:attribute name="target">_blank</xsl:attribute>
			<xsl:attribute name="style">text-decoration:none;</xsl:attribute>
			<img src="/editor/images/external_link.gif" alt="link" title="Link to authority file" border="0"/></xsl:element>
	</xsl:template>
	
	<!-- display change log -->
	<xsl:template match="m:revisionDesc">
		<xsl:apply-templates select="m:change[normalize-space(@isodate)!=''][last()]" mode="last"/>
		<xsl:if test="count(m:change) &gt; 0">
			<div class="revision_history">
				<xsl:apply-templates select="." mode="fold_section">
					<xsl:with-param name="id" select="'revisionhistory'"/>
					<xsl:with-param name="heading">Revision history</xsl:with-param>
					<xsl:with-param name="content">
						<table>
							<tr>
								<th>Date </th>
								<th>Responsible </th>
								<th>Description</th>
							</tr>
							<xsl:apply-templates
								select="m:change[*//text() or @isodate!='' or @resp!='']" mode="all"
							/>
						</table>
					</xsl:with-param>
				</xsl:apply-templates>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template match="m:revisionDesc/m:change" mode="all">
		<tr>
			<td>
				<xsl:value-of select="@isodate"/>
				<xsl:text>&#160;</xsl:text>
			</td>
			<td>
				<xsl:value-of select="@resp"/>
				<xsl:text>&#160;</xsl:text>
			</td>
			<td>
				<!-- make sure cell are not empty -->
				<xsl:choose>
					<xsl:when test="*//text()">
						<xsl:apply-templates select="*//text()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>&#160;</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="m:revisionDesc/m:change" mode="last">
		<br/>Last changed <xsl:value-of select="@isodate"/>
		<xsl:if test="normalize-space(@resp)"> by <i><xsl:value-of select="@resp"/></i></xsl:if>
	</xsl:template>

	<xsl:template match="@type">
		<xsl:value-of select="translate(.,'_',' ')"/>
	</xsl:template>

	<!-- GENERAL TOOL TEMPLATES -->

	<!-- output elements comma-separated -->
	<xsl:template match="*" mode="comma-separated">
		<xsl:if test="position() &gt; 1">, </xsl:if>
		<xsl:apply-templates select="."/>
	</xsl:template>

	<xsl:template match="*" mode="comma-separated_links">
		<!-- special treatment for links to enable links-specific overriding of template -->
		<xsl:apply-templates select="." mode="comma-separated"/>
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



	<!-- change date format from YYYY-MM-DD to D Month YYYY -->
	<!-- "??"-wildcards (e.g. "20??-09-??") are treated like numbers -->
	<xsl:template match="m:date">
		<xsl:variable name="date" select="normalize-space(.)"/>
		<xsl:choose>
			<xsl:when test="string-length($date)=10">
				<xsl:variable name="year" select="substring($date,1,4)"/>
				<xsl:variable name="month" select="substring($date,6,2)"/>
				<xsl:variable name="day" select="substring($date,9,2)"/>
				<xsl:choose>
					<!-- check if date format is YYYY-MM-DD; if so, display as D Month YYY -->
					<xsl:when
						test="(string(number($year))!='NaN' or string($year)='????' or (string(number(substring($year,1,2)))!='NaN' and substring($year,3,2)='??')) 
		    and (string(number($month))!='NaN' or string($month)='??') and (string(number($day))!='NaN' or string($day)='??') and substring($date,5,1)='-' and substring($date,8,1)='-'">
						<xsl:choose>
							<xsl:when test="$day='??'"><!-- just skip "??" days --></xsl:when>
							<xsl:when test="substring($day,1,1)='0'">
								<xsl:value-of select="substring($day,2,1)"/>
								<xsl:text> </xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$day"/>
								<xsl:text> </xsl:text>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:call-template name="month">
							<xsl:with-param name="monthstring" select="($month)"/>
						</xsl:call-template>
						<xsl:text> </xsl:text>
						<xsl:value-of select="$year"/>
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

	<!-- change date format from YYYY-MM-DD to D.M.YYYY -->
	<!-- "??"-wildcards (e.g. "20??-09-??") are treated like numbers -->
	<xsl:template match="m:date" mode="DMYYYY">
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

	<xsl:template name="month">
		<xsl:param name="monthstring"/>
		<xsl:variable name="number" select="number($monthstring)"/>
		<xsl:choose>
			<xsl:when test="$number=1">Jan.</xsl:when>
			<xsl:when test="$number=2">Feb.</xsl:when>
			<xsl:when test="$number=3">Mar.</xsl:when>
			<xsl:when test="$number=4">Apr.</xsl:when>
			<xsl:when test="$number=5">May</xsl:when>
			<xsl:when test="$number=6">June</xsl:when>
			<xsl:when test="$number=7">July</xsl:when>
			<xsl:when test="$number=8">Aug.</xsl:when>
			<xsl:when test="$number=9">Sept.</xsl:when>
			<xsl:when test="$number=10">Oct.</xsl:when>
			<xsl:when test="$number=11">Nov.</xsl:when>
			<xsl:when test="$number=12">Dec.</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$monthstring"/>
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

	<xsl:template match="*" mode="fold_section">
		<xsl:param name="heading"/>
		<xsl:param name="id"/>
		<xsl:param name="content"/>
		<script type="application/javascript"><xsl:text>openness["</xsl:text><xsl:value-of select="$id"/><xsl:text>"]=false;</xsl:text></script>
		<xsl:text>
    </xsl:text>
		<div class="fold">
			<h3 class="section_heading" id="p{$id}">
				<span onclick="toggle('{$id}')" title="Click to show or hide">
					<img class="noprint" id="img{$id}" border="0" src="/editor/images/plus.png"
						alt="-"/>
					<xsl:value-of select="concat(' ',$heading)"/>
				</span>
			</h3>
			<div class="folded_content" style="display:none" id="{$id}">
				<xsl:copy-of select="$content"/>
			</div>
		</div>
	</xsl:template>


	<!-- HANDLE TEXT AND SPECIAL CHARACTERS -->

	<xsl:template name="maybe_print_br">
		<xsl:if test="position()&lt;last()">
			<xsl:element name="br"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="m:p" mode="paragraph_to_line_break">
		<!-- changes paragraphs to running text with line breaks instead of new paragraphs  -->
		<xsl:apply-templates/>
		<xsl:call-template name="maybe_print_br"/>
	</xsl:template>

	<!-- Automatic cross references? 
       
       ... need to somehow get the name of the file to link to before this works ...
       ... probably better to wait until links can actually be entered and edited in MerMEId ...
       
       <xsl:template match="text()[contains(.,concat(/m:mei/m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type='file_collection'],' '))]">
       <xsl:variable name="search_for" select="concat(/m:mei/m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type='file_collection'],' ')"/>
       <xsl:variable name="remainder" select="substring-after(.,$search_for)"/>
       <xsl:variable name="end_char" select="substring(translate($remainder,'0123456789',''),1,1)"/>
       <xsl:variable name="number" select="substring-before($remainder,$end_char)"/>
       <xsl:apply-templates select="exsl:node-set(substring-before(.,$search_for))"/>
       <xsl:choose>
       <xsl:when test="$number">
       <a title="" 
       href="http://dcm-udv-01.kb.dk/storage/cnw/document.xq?doc=cnw0132.xml" 
       class="work_number_reference"><xsl:value-of select="concat($search_for,$number)"/></a>
       <xsl:apply-templates select="exsl:node-set(substring-after($remainder,$number))"/>
       </xsl:when>
       <xsl:otherwise>
       <xsl:value-of select="$search_for"/>
       <xsl:apply-templates select="exsl:node-set($remainder)"/>
       </xsl:otherwise>
       </xsl:choose>
       </xsl:template>
  -->

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

	
	<!-- entity replacements -->
	<xsl:template match="text()">
		<xsl:apply-templates select="." mode="entities"/>
	</xsl:template>	
	
	<xsl:template match="text()[contains(.,'&amp;nbsp;')]" mode="entities">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&amp;nbsp;'))" mode="entities"/>&#160;<xsl:apply-templates select="exsl:node-set(substring-after(.,'&amp;nbsp;'))" mode="entities"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&amp;lt;')]" mode="entities">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&amp;lt;'))" mode="entities"/>&#60;<xsl:apply-templates select="exsl:node-set(substring-after(.,'&amp;lt;'))" mode="entities"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'&amp;gt;')]" mode="entities">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'&amp;gt;'))" mode="entities"/>&#62;<xsl:apply-templates select="exsl:node-set(substring-after(.,'&amp;gt;'))" mode="entities"/>
	</xsl:template>

	<!-- ad hoc code replacements -->
	<xsl:template match="text()[contains(.,'[flat]')]" mode="entities">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[flat]'))" mode="entities"/>
		<span class="music_symbols">&#x266d;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[flat]'))" mode="entities"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'[natural]')]" mode="entities">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[natural]'))" mode="entities"/>
		<span class="music_symbols">&#x266e;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[natural]'))" mode="entities"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'[sharp]')]" mode="entities">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[sharp]'))" mode="entities"/>
		<span class="music_symbols">&#x266f;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[sharp]'))" mode="entities"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'[dblflat]')]" mode="entities">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[dblflat]'))" mode="entities"/>
		<span class="music_symbols">&#x1d12b;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[dblflat]'))" mode="entities"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'[dblsharp]')]" mode="entities">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[dblsharp]'))" mode="entities"/>
		<span class="music_symbols">&#x1d12a;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[dblsharp]'))" mode="entities"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'[common]')]" mode="entities">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[common]'))" mode="entities"/>
		<span class="music_symbols time_signature">&#x1d134;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[common]'))" mode="entities"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'[cut]')]" mode="entities">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[cut]'))" mode="entities"/>
		<span class="music_symbols time_signature">&#x1d135;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[cut]'))" mode="entities"/>
	</xsl:template>

	<!-- music character wrapping -->
	<xsl:template match="text()[contains(.,'♭')]" mode="entities">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'♭'))" mode="entities"/>
		<span class="music_symbols">♭</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'♭'))" mode="entities"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'♮')]" mode="entities">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'♮'))" mode="entities"/>
		<span class="music_symbols">♮</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'♮'))" mode="entities"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'♯')]" mode="entities">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'♯'))" mode="entities"/>
		<span class="music_symbols">♯</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'♯'))" mode="entities"/>
	</xsl:template>
	
	
	<!-- Look up abbreviations -->

	<xsl:template match="m:identifier[@authority='RISM'][text()]">
		<xsl:variable name="vUpper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
		<xsl:variable name="vLower" select="'abcdefghijklmnopqrstuvwxyz'"/>
		<xsl:variable name="vAlpha" select="concat($vUpper, $vLower)"/>
		<xsl:variable name="country" select="substring-before(.,'-')"/>
		<xsl:variable name="archive" select="substring-after(.,'-')"/>
		<xsl:choose>
			<!-- RISM sigla should match [A-Z]+-[A-Z]+[a-z]* -->
			<xsl:when test="string-length($country)>0 and
				string-length($archive)>0 and
				string-length(translate($country,$vUpper,''))=0 and 
				string-length(translate($archive,$vAlpha,''))=0">
				<xsl:variable name="RISM_file_name"
					select="string(concat($settings/dcm:parameters/dcm:server_name,$settings/dcm:parameters/dcm:exist_dir,'rism_sigla/',
					substring-before(normalize-space(.),'-'),'.xml'))"/>
				<xsl:choose>
					<xsl:when test="boolean(document($RISM_file_name))">
						<xsl:variable name="RISM_file" select="document($RISM_file_name)"/>
						<xsl:variable name="siglum" select="normalize-space(.)"/>
						<xsl:choose>
							<xsl:when test="$RISM_file//marc:datafield[marc:subfield[@code='g']=$siglum]">
								<xsl:variable name="record"
									select="$RISM_file//marc:datafield[marc:subfield[@code='g']=$siglum]"/>
								<a href="javascript:void(0);" class="abbr">
									<xsl:value-of select="."/>
									<span class="expan">
										<xsl:value-of select="$record/marc:subfield[@code='a']"/>,
										<xsl:value-of select="$record/marc:subfield[@code='c']"/>
									</span>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="."/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="m:bibl//m:title">
		<xsl:variable name="title" select="."/>
		<xsl:variable name="reference"
			select="$bibl_file//m:biblList[m:head=$file_context or m:head='' or not(m:head)]/m:bibl[@label=$title]"/>
		<xsl:choose>
			<xsl:when test="$reference/m:title">
				<a href="javascript:void(0);" class="abbr">
					<xsl:value-of select="$title"/>
					<span class="expan">
						<xsl:apply-templates select="$reference"/>
					</span>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- General abbreviations in text blocks and identifier labels. -->
	<xsl:template match="text()[parent::node() and name(..)!='p' and name(..)!='persName' and name(..)!='ptr' and name(..)!='ref'] 
		| m:identifier/@label">
		<!-- The parent::node() check above is necessary to avoid infinite looping -->
		<xsl:variable name="string" select="concat(' ',.,' ')"/>
		<xsl:variable name="abbr"
			select="$abbreviations_file/m:p/m:choice/m:abbr[contains(translate($string,';:[]()/','       '),concat(' ',.,' '))]"/>
		<xsl:choose>
			<xsl:when test="$abbr">
				<xsl:variable name="expan"
					select="$abbreviations_file/m:p/m:choice/m:expan[../m:abbr=$abbr]"/>
				<xsl:variable name="pos1" select="string-length(substring-before($string,$abbr))"/>
				<xsl:apply-templates select="exsl:node-set(substring(.,1,number($pos1)-1))"/>
				<a href="javascript:void(0);" class="abbr"><xsl:value-of select="$abbr"/><span class="expan">
					<xsl:choose>
						<!-- if the expansion is a nodeset, a <bibl> element for example, process it -->
						<xsl:when test="$expan/*">
							<xsl:apply-templates select="$expan"/>
						</xsl:when>
						<!-- otherwise just plain text; no further processing -->
						<xsl:otherwise>
							<xsl:value-of select="$expan"/>
						</xsl:otherwise>
					</xsl:choose>
				</span></a>
				<xsl:variable name="pos2" select="number($pos1)+string-length($abbr)"/>
				<xsl:apply-templates select="exsl:node-set(substring(.,$pos2))"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- <apply-templates/> would cause infinite loop -->
				<xsl:apply-templates select="exsl:node-set(string(.))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- End look up abbreviations -->
	
	<!-- formatted text -->
	<xsl:template match="m:lb">
		<br/>
	</xsl:template>
	<xsl:template match="m:p[normalize-space(.)]">
		<p>
			<xsl:apply-templates/>
		</p>
	</xsl:template>
	<xsl:template match="m:p[not(child::text()) and not(child::node())]">
		<!-- ignore -->
	</xsl:template> 
	<xsl:template match="m:rend[@fontweight = 'bold'][normalize-space(.)]">
		<b>
			<xsl:apply-templates/>
		</b>
	</xsl:template>
	<xsl:template match="m:rend[@fontstyle = 'italic'][normalize-space(.)]">
		<i>
			<xsl:apply-templates/>
		</i>
	</xsl:template>
	<xsl:template match="m:rend[@rend = 'underline'][normalize-space(.)]">
		<u>
			<xsl:apply-templates/>
		</u>
	</xsl:template>
	<xsl:template match="m:rend[@rend = 'line-through'][normalize-space(.)]">
		<span style="text-decoration: line-through;">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	<xsl:template match="m:rend[@rend = 'sub'][normalize-space(.)]">
		<sub>
			<xsl:apply-templates/>
		</sub>
	</xsl:template>
	<xsl:template match="m:rend[@rend = 'sup'][normalize-space(.)]">
		<sup>
			<xsl:apply-templates/>
		</sup>
	</xsl:template>
	<xsl:template match="m:rend[@fontfam or @fontsize or @color][normalize-space(.)]">
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
	<xsl:template match="m:ref[@target][normalize-space(.)]">
		<xsl:element name="a">
			<xsl:attribute name="href">
				<xsl:value-of select="@target"/>
			</xsl:attribute>
			<xsl:attribute name="target">
				<xsl:choose>
					<xsl:when test="@xl:show='new'">_blank</xsl:when>
					<xsl:when test="@xl:show='replace'">_self</xsl:when>
					<xsl:otherwise><xsl:value-of select="@xl:show"/></xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="title">
				<xsl:value-of select="@xl:title"/>
			</xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="m:rend[@halign][normalize-space(.)]">
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
