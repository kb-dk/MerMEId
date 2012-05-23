<?xml version="1.0" encoding="UTF-8"?>

<!-- 
Conversion of MEI metadata to HTML using XSLT 1.0

Author: 
Axel Teich Geertinger
Danish Centre for Music Publication
The Royal Library, Copenhagen

Last modified 2011-12-21
-->

<xsl:stylesheet version="1.0" 
		xmlns="http://www.w3.org/1999/xhtml" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:m="http://www.music-encoding.org/ns/mei" 
		xmlns:t="http://www.tei-c.org/ns/1.0"
		xmlns:xl="http://www.w3.org/1999/xlink" 
		xmlns:foo="http://www.kb.dk" 
		exclude-result-prefixes="m xsl">

	<xsl:output method="xml" encoding="UTF-8"/>

	<!-- GLOBAL VARIABLES -->
	<!-- preferred language in titles and other multilingual fields -->
	<xsl:variable name="preferred_language">none</xsl:variable>

	<!-- CREATE HTML DOCUMENT -->
	<xsl:template match="m:mei" xml:space="default">
		<html xml:lang="en" lang="en">
			<head>
				<xsl:call-template name="make_html_head"/>
			</head>
			<body>
				<xsl:call-template name="make_html_body"/>
			</body>
		</html>
	</xsl:template>

	<!-- MAIN TEMPLATES -->
	<xsl:template name="make_html_head">
		<title>HTML Preview</title>

		<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=UTF-8"/>

		<link rel="stylesheet" type="text/css" href="/editor/style/mei_to_html.css"/>

		<script>          
			function show(id) {
			var e = document.getElementById(id);
			e.style.display = 'block';
			}
			
			function hide(id) {
			var e = document.getElementById(id);
			e.style.display = 'none';
			}
		</script>

	</xsl:template>

	<xsl:template name="make_html_body" xml:space="default">
		<!-- main identification -->
		<xsl:for-each select="m:meihead/m:encodingdesc/m:projectdesc/m:p/m:list[@n='use']/m:item">
			<!-- match file context and identifying numbers to get the catalogue's name and the work's number in it -->
			<xsl:variable name="file_context" select="normalize-space(.)"/>
			<xsl:if test="count(../../../../../m:filedesc/m:pubstmt/m:identifier[@type=$file_context])!=0">
				<xsl:variable name="catalogue_no"
					select="../../../../../m:filedesc/m:pubstmt/m:identifier[@type=$file_context]"/>
				<div class="cat_number">
					<a>
						<xsl:value-of select="$file_context"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="$catalogue_no"/>
					</a>
				</div>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="normalize-space(m:meihead/m:filedesc/m:titlestmt/m:respstmt/m:persname[@type='composer'])">
			<p>
				<xsl:apply-templates select="m:meihead/m:filedesc/m:titlestmt/m:respstmt/m:persname[@type='composer']"/>
			</p>
		</xsl:if>
		<h2>
			<xsl:variable name="preferred_main_title_found"
				select="count(m:meihead/m:filedesc/m:titlestmt/m:title[@type='main' and @xml:lang=$preferred_language])"/>
			<xsl:apply-templates
				select="m:meihead/m:filedesc/m:titlestmt/m:title[@type='main' and @xml:lang=$preferred_language and normalize-space()!='']"
				mode="multilingual_text">
				<xsl:with-param name="preferred_found" select="$preferred_main_title_found"/>
			</xsl:apply-templates>
			<xsl:apply-templates
				select="m:meihead/m:filedesc/m:titlestmt/m:title[@type='main' and @xml:lang!=$preferred_language and normalize-space()!='']"
				mode="multilingual_text">
				<xsl:with-param name="preferred_found" select="$preferred_main_title_found"/>
			</xsl:apply-templates>
		</h2>
		<h3>
			<xsl:variable name="preferred_subtitle_found"
				select="count(m:meihead/m:filedesc/m:titlestmt/m:title[@type='subordinate' and @xml:lang=$preferred_language])"/>
			<xsl:apply-templates
				select="m:meihead/m:filedesc/m:titlestmt/m:title[@type='subordinate' and @xml:lang=$preferred_language and normalize-space()!='']"
				mode="multilingual_text">
				<xsl:with-param name="preferred_found" select="$preferred_subtitle_found"/>
			</xsl:apply-templates>
			<xsl:apply-templates
				select="m:meihead/m:filedesc/m:titlestmt/m:title[@type='subordinate' and @xml:lang!=$preferred_language]"
				mode="multilingual_text">
				<xsl:with-param name="preferred_found" select="$preferred_subtitle_found"/>
			</xsl:apply-templates>
		</h3>
		<xsl:if test="normalize-space(m:meihead/m:filedesc/m:titlestmt/m:title[@type='alternative'])">
			<p>Alternative title: <xsl:variable name="preferred_alt_title_found"
					select="count(m:meihead/m:filedesc/m:titlestmt/m:title[@type='alternative' and @xml:lang=$preferred_language])"/>
				<xsl:apply-templates
					select="m:meihead/m:filedesc/m:titlestmt/m:title[@type='alternative' and @xml:lang=$preferred_language and normalize-space()!='']"
					mode="multilingual_text">
					<xsl:with-param name="preferred_found" select="$preferred_alt_title_found"/>
				</xsl:apply-templates>
				<xsl:apply-templates
					select="m:meihead/m:filedesc/m:titlestmt/m:title[@type='alternative' and @xml:lang!=$preferred_language and normalize-space()!='']"
					mode="multilingual_text">
					<xsl:with-param name="preferred_found" select="$preferred_alt_title_found"/>
				</xsl:apply-templates>
			</p>
		</xsl:if>
		<!-- other identifiers -->
		<xsl:apply-templates select="m:meihead/m:filedesc/m:pubstmt"/>
		<!-- dedicatee -->
		<xsl:if test="normalize-space(m:meihead/m:filedesc/m:titlestmt/m:respstmt/m:persname[@type='dedicatee'])">
			<p><span class="p_heading">Dedicatee: </span><xsl:value-of
					select="normalize-space(m:meihead/m:filedesc/m:titlestmt/m:respstmt/m:persname[@type='dedicatee'])"
				/>.</p>
		</xsl:if>
		<!-- textual sources -->
		<xsl:if
			test="normalize-space(concat(m:meihead/m:filedesc/m:titlestmt/m:respstmt/m:persname[@type='text_author'],m:meihead/m:filedesc/m:titlestmt/m:respstmt/m:persname[@type='text_incipit']))">
			<p><span class="p_heading">Text: </span>
				<xsl:value-of
					select="normalize-space(m:meihead/m:filedesc/m:titlestmt/m:respstmt/m:persname[@type='text_author'])"
				/>. </p>
		</xsl:if>
		<!-- general description  -->
		<xsl:if test="normalize-space(m:meihead/m:filedesc/m:notesstmt/m:annot[@type='general_description'])">
			<p>
				<xsl:apply-templates select="m:meihead/m:filedesc/m:notesstmt/m:annot[@type='general_description']"/>
			</p>
		</xsl:if>
		<!-- external links -->
		<xsl:if test="normalize-space(m:meihead/m:filedesc/m:notesstmt/m:annot[@type='links']/m:extptr/@xl:href)">
			<p>See also: <xsl:apply-templates
					select="m:meihead/m:filedesc/m:notesstmt/m:annot[@type='links']/m:extptr[normalize-space(@xl:href)]"
					mode="comma-separated"/>
			</p>
		</xsl:if>
		<!-- composition history -->
		<xsl:if
			test="normalize-space(m:meihead/m:profiledesc/m:creation/m:p[@type='note']) or normalize-space(m:meihead/m:profiledesc/m:creation/m:p/m:date)">
			<p>
				<xsl:if test="normalize-space(m:meihead/m:profiledesc/m:creation/m:p/m:date)">
					<span class="p_heading">Date of composition: </span><xsl:apply-templates
						select="m:meihead/m:profiledesc/m:creation/m:p/m:date"/>.<br/>
				</xsl:if>
				<xsl:apply-templates select="m:meihead/m:profiledesc/m:creation/m:p[@type='note']"/>
			</p>
		</xsl:if>
		<!-- list instrumentation at top level if there is no more than one work component OR if instrumentation is indicated on first component only-->
		<xsl:choose>
			<!-- if only 1 work component: -->
			<xsl:when test="count(m:music/m:body/m:mdiv)=1">
				<!-- show instrumentation if non-empty -->
				<xsl:if	test="count(m:music/m:body/m:mdiv[1]/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))])>0">
					<xsl:apply-templates select="m:music/m:body/m:mdiv[1]/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp"/>
				</xsl:if>
			</xsl:when>
			<!-- if more than one component (sub-works): -->
			<xsl:otherwise>
				<!-- show instrumentation if first components' instrumentation is non-empty -->				
				<xsl:if test="count(m:music/m:body/m:mdiv[1]/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))])>0">
					<!-- AND it is the only component with instrumentation -->
					<xsl:if	test="count(m:music/m:body/m:mdiv[m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))]])=1">
						<xsl:apply-templates select="m:music/m:body/m:mdiv[1]/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp"/>
					</xsl:if>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>		
		<!-- list sub-works/acts and movements -->
		<xsl:apply-templates select="m:music/m:body/m:mdiv/m:score"/>
		<!-- list performances -->
		<xsl:apply-templates
			select="m:meihead/m:profiledesc/m:eventlist[normalize-space(concat(m:event/m:date,m:event/m:geogname[@type='venue'],m:event/m:geogname[@type='place'],m:event/m:persname[@type='soloist']))!='']"/>
		<!-- external links  -->
		<xsl:if
			test="normalize-space(m:meihead/m:filedesc/m:notesstmt/m:annot[@type='links']/m:extptr[@xl:role!='CNU source description']/@xl:href)!=''">
			<p>See also: <!-- skip CNU source desc. (shown somewhere else) -->
				<xsl:apply-templates
					select="m:meihead/m:filedesc/m:notesstmt/m:annot[@type='links']/m:extptr[@xl:role!='CNU source description' and @xl:href!='']"
					mode="comma-separated"/>
			</p>
		</xsl:if>
		<!-- list sources -->
		<xsl:apply-templates
			select="m:meihead/m:filedesc/m:sourcedesc[normalize-space(m:source/m:titlestmt/m:title)!='']"/>
		<!-- bibliography -->
		<xsl:if
			test="count(m:music/m:front/t:div[t:head='Bibliography']/t:listBibl[@type='primary']/t:bibl[normalize-space(concat(t:author,t:name[@role='recipient'],t:date))])&gt;0">
			<xsl:apply-templates select="m:music/m:front/t:div[t:head='Bibliography']/t:listBibl[@type='primary']"
				mode="all"/>
		</xsl:if>
		<xsl:if
			test="count(m:music/m:front/t:div[t:head='Bibliography']/t:listBibl[@type='secondary']/t:bibl[normalize-space(concat(t:title[@level='a'],t:title[@level='m']))])&gt;0">
			<xsl:apply-templates select="m:music/m:front/t:div[t:head='Bibliography']/t:listBibl[@type='secondary']"
				mode="all"/>
		</xsl:if>
		<!-- to be deleted when database is transformed to have @type on listBibl -->
		<xsl:if
			test="count(m:music/m:front/t:div[t:head='Bibliography']/t:listBibl[count(@type)=0]/t:bibl[normalize-space(concat(t:title[@level='a'],t:title[@level='m']))])&gt;0">
			<xsl:apply-templates select="m:music/m:front/t:div[t:head='Bibliography']/t:listBibl[count(@type)=0]"
				mode="all"/>
		</xsl:if>
		<!-- end delete -->
		<xsl:if
			test="count(m:music/m:front/t:div[t:head='Bibliography']/t:listBibl[@type='documentation']/t:bibl[normalize-space(concat(t:date,t:title))])&gt;0">
			<xsl:apply-templates select="m:music/m:front/t:div[t:head='Bibliography']/t:listBibl[@type='documentation']"
				mode="all"/>
		</xsl:if>
		<xsl:apply-templates select="m:meihead/m:revisiondesc"/>
	</xsl:template>


	<!-- SUB-TEMPLATES -->

	<!-- identifiers -->
	<xsl:template match="m:meihead/m:filedesc/m:pubstmt">
		<p>
			<xsl:for-each select="m:identifier">
				<xsl:if test="normalize-space(.)!='' and normalize-space(./@type)!=''">
					<xsl:value-of select="normalize-space(@type)"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="normalize-space(.)"/>
					<br/>
				</xsl:if>
			</xsl:for-each>
		</p>
	</xsl:template>

	<!-- sub-works -->
	<xsl:template match="m:music/m:body/m:mdiv/m:score">
		<xsl:if test="normalize-space(m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:title)">
			<h3>
				<xsl:variable name="preferred_work_title_found"
					select="count(m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:title[@xml:lang=$preferred_language])"/>
				<xsl:apply-templates
					select="m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:title[@xml:lang=$preferred_language]"
					mode="multilingual_text">
					<xsl:with-param name="preferred_found" select="$preferred_work_title_found"/>
				</xsl:apply-templates>
				<xsl:apply-templates
					select="m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:title[@xml:lang!=$preferred_language]"
					mode="multilingual_text">
					<xsl:with-param name="preferred_found" select="$preferred_work_title_found"/>
				</xsl:apply-templates>
			</h3>
		</xsl:if>

		<!-- show instrumentation at sub-work level if: 1) more than one sub-work -->
		<xsl:if test="count(../../m:mdiv)&gt;1">
			<!-- AND 2) if indicated in any other than the first -->				
			<xsl:if test="count(../../m:mdiv[1]/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))]) 
				!= count(../../m:mdiv/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))])">
				<!-- AND this component's instrumentation is indicated -->
				<xsl:if	test="count(m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))])>0">
					<xsl:apply-templates select="m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp"/>
				</xsl:if>
			</xsl:if>
		</xsl:if>		
		

		<xsl:variable name="key_found"
			select="normalize-space(concat(m:app/m:rdg[@type='metadata']/m:scoredef/@key.pname,m:app/m:rdg[@type='metadata']/m:scoredef/@key.accid, m:app/m:rdg[@type='metadata']/m:scoredef/@key.mode))"/>
		<xsl:variable name="text_author_found"
			select="normalize-space(m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:persname[@type='text_author'])"/>
		<xsl:variable name="edited_score_found"
			select="normalize-space(m:app/m:rdg[@type='edited_score']/m:annot[@type='links']/m:extptr[normalize-space(@xl:href!='')]/@xl:title)"/>
		<xsl:if test="concat($key_found,$text_author_found,$edited_score_found)!=''">
			<p>
				<xsl:if test="$key_found!=''">
					<xsl:apply-templates select="m:app/m:rdg[@type='metadata']/m:scoredef" mode="key"/>
					<xsl:if test="concat($text_author_found,$edited_score_found)!=''">
						<br/>
					</xsl:if>
				</xsl:if>
				<xsl:if test="$text_author_found!=''"> Text author: <xsl:value-of
						select="normalize-space(m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:persname[@type='text_author'])"/>
					<xsl:if test="$edited_score_found!=''"><br/></xsl:if>
				</xsl:if>
				<xsl:if test="$edited_score_found!=''"> Edited score: <xsl:for-each
						select="m:app/m:rdg[@type='edited_score']/m:annot[@type='links']/m:extptr[normalize-space(@xl:href)!='']">
						<xsl:if test="position()&gt;1">, </xsl:if>
						<a target="_blank">
							<xsl:attribute name="href"><xsl:value-of select="@xl:href"/></xsl:attribute>
							<xsl:value-of select="@xl:title"/>
						</a>
					</xsl:for-each>
				</xsl:if>
			</p>
		</xsl:if>
		<!-- test for non-empty movements (i.e. title or tempo specified) -->
		<xsl:if test="normalize-space(concat(m:section, m:section/@n))">
			<xsl:variable name="mdiv_id" select="position()"/>
			<xsl:variable name="movements_shown_id" select="concat('movements_shown_',$mdiv_id)"/>
			<xsl:variable name="movements_hidden_id" select="concat('movements_hidden_',$mdiv_id)"/>
			<div class="fold_icon" style="display:none" id="{$movements_hidden_id}">
				<p class="p_heading" title="Click to view movements"
					onclick="show('{$movements_shown_id}');hide('{$movements_hidden_id}')">
					<img class="noprint" style="display:inline" border="0" src="/editor/images/plus.png"/> Movements
				</p>
			</div>
			<div id="{$movements_shown_id}">
				<p class="fold_icon" title="Click to hide movements"
					onclick="show('{$movements_hidden_id}');hide('{$movements_shown_id}')">
					<img class="noprint" style="display:inline" border="0" src="/editor/images/minus.png"/>
					<span class="p_heading"> Movements</span>
				</p>
				<div class="folded_content">
					<xsl:apply-templates select="m:section[normalize-space(concat(.,@n))]"/>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- work-related templates -->

	<!-- performances -->
	<xsl:template match="m:meihead/m:profiledesc/m:eventlist">
		<xsl:variable name="performances"
			select="count(m:event[normalize-space(concat(m:date,m:geogname,m:persname,m:corpname)) != ''])"/>
		<xsl:if test="$performances &gt; 0">
			<div id="perf_hidden" class="fold_icon">
				<p class="p_heading" title="Click to view performances" onclick="show('perf_shown');hide('perf_hidden')"
						><img class="noprint" style="display:inline" border="0" src="/editor/images/plus.png"/>
					Performances</p>
			</div>
			<div id="perf_shown" style="display:none">
				<p class="fold_icon" title="Click to hide performances" onclick="show('perf_hidden');hide('perf_shown')">
					<img class="noprint" style="display:inline" border="0" src="/editor/images/minus.png"/>
					<span class="p_heading"> Performances</span>
				</p>
				<div class="folded_content">

					<table class="performances" cellpadding="0" cellspacing="0" border="0">
						<xsl:if test="$performances &gt; 0">
							<xsl:apply-templates
								select="m:event[normalize-space(concat(m:date,m:geogname,m:persname,m:corpname)) != '']"
								mode="performance_details"/>
						</xsl:if>
					</table>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- performance-related templates -->

	<!-- performance details -->
	<xsl:template match="m:event" mode="performance_details">
		<tr>
			<td nowrap="nowrap">
				<xsl:if test="normalize-space(m:date) != ''">
					<xsl:apply-templates select="m:date"/>&#160; </xsl:if>
			</td>
			<td>
				<xsl:if test="normalize-space(m:geogname[@type='venue']) != ''">
					<xsl:text> </xsl:text>
					<xsl:value-of select="m:geogname[@type='venue']"/>
					<xsl:if test="normalize-space(m:geogname[@type='place']) != ''">, </xsl:if>
				</xsl:if>
				<xsl:if test="normalize-space(m:geogname[@type='place']) != ''">
					<xsl:text> </xsl:text>
					<xsl:value-of select="m:geogname[@type='place']"/>
				</xsl:if>
				<xsl:if
					test="normalize-space(concat(m:corpname,m:persname[@type='conductor'],m:persname[@type='soloist']))!=''"
					> (</xsl:if>
				<xsl:if test="normalize-space(m:corpname[@type='ensemble']) != ''">
					<xsl:value-of select="m:corpname[@type='ensemble']"/>
					<xsl:if test="normalize-space(m:persname[@type='conductor']) != ''"> conducted by <xsl:value-of
							select="m:persname[@type='conductor']"/></xsl:if>
					<xsl:if test="normalize-space(m:persname[@type='soloist']) != ''">, </xsl:if>
				</xsl:if>
				<xsl:if
					test="normalize-space(m:corpname[@type='ensemble']) = '' and normalize-space(m:persname[@type='conductor']) != ''">conductor:<xsl:text> </xsl:text>
					<xsl:value-of select="m:persname[@type='conductor']"/>
					<xsl:if test="normalize-space(m:persname[@type='soloist']) != ''">, </xsl:if>
				</xsl:if>
				<xsl:if test="normalize-space(m:persname[@type='soloist']) != ''">
					<xsl:apply-templates select="." mode="soloists"/>
				</xsl:if>
				<xsl:if
					test="normalize-space(concat(m:corpname,m:persname[@type='conductor'],m:persname[@type='soloist']))!=''"
					>)</xsl:if>
				<xsl:if
					test="normalize-space(concat(m:geogname[@type='venue'],m:geogname[@type='place'],m:corpname,m:persname[@type='conductor'],m:persname[@type='soloist']))!=''"
					>.<xsl:text> </xsl:text></xsl:if>
				<xsl:if test="normalize-space(m:title)!='' and m:title!='Other performance'">
					<xsl:value-of select="m:title"/>.<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:variable name="no_of_reviews"
					select="count(t:bibl[normalize-space(concat(t:title[@level='a'],t:title[@level='j']))])"/>
				<xsl:if test="$no_of_reviews &gt; 0">
					<xsl:choose>
						<xsl:when test="$no_of_reviews = 1">
							<br/>Review: </xsl:when>
						<xsl:otherwise>
							<br/>Reviews: </xsl:otherwise>
					</xsl:choose>
					<xsl:for-each select="t:bibl[normalize-space(concat(t:title[@level='a'],t:title[@level='j']))]">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</xsl:if>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="m:event" mode="soloists">
		<xsl:variable name="no_of_soloists" select="count(m:persname[@type='soloist'])"/>
		<xsl:if test="$no_of_soloists &gt; 0">
			<xsl:choose>
				<xsl:when test="$no_of_soloists = 1"> soloist: </xsl:when>
				<xsl:otherwise> soloists: </xsl:otherwise>
			</xsl:choose>
			<xsl:for-each select="m:persname[@type='soloist']">
				<xsl:if test="position() &gt; 1">, </xsl:if>
				<xsl:value-of select="."/>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<!-- instrumentation -->
	<xsl:template match="m:scoredef/m:staffgrp">
		<p>
			<span class="p_heading">Instrumentation: </span>
			<!-- basic ensemble -->
			<xsl:apply-templates select="m:staffgrp[contains(@label.full,'Basic')]" mode="comma-separated"/>
			<!-- soloists -->
			<xsl:if
				test="count(m:staffgrp[@label.full='Soloists']/m:staffdef[normalize-space(@label.abbr)!='' or normalize-space(@label.full)!=''])&gt;0"
				> Soloists: <xsl:apply-templates select="m:staffgrp[@label.full='Soloists']" mode="comma-separated"/>
			</xsl:if>
			<!-- named characters -->
			<xsl:if
				test="count(m:staffgrp[@label.full='Characters']/m:staffdef[normalize-space(@label.abbr)!='' or normalize-space(@label.full)!=''])&gt;0"
				> Named characters: <xsl:apply-templates select="m:staffgrp[@label.full='Characters']"
					mode="comma-separated"/>
			</xsl:if>
			<!-- choirs -->
			<xsl:if
				test="count(m:staffgrp[@label.full='Choirs']/m:staffdef[normalize-space(@label.abbr)!='' or normalize-space(@label.full)!=''])&gt;0"
				> Choir: <xsl:apply-templates select="m:staffgrp[@label.full='Choirs']" mode="comma-separated"/>
			</xsl:if>
		</p>
	</xsl:template>

	<!-- list instruments in group -->
	<xsl:template match="m:staffgrp" mode="comma-separated">
		<!--		<xsl:variable name="number_of_items" select="count(staffdef[normalize-space(concat(@label.abbr,@label.full))!=''])"/>
	No. of instr.:<xsl:value-of select="$number_of_items"/>-->
		<xsl:for-each select="m:staffdef[normalize-space(concat(@label.full, @label.abbr))!='']">
			<xsl:if test="position() &gt; 1">, </xsl:if>
			<xsl:call-template name="replace_strings">
				<xsl:with-param name="input_text" select="concat(@label.full, @label.abbr)"/>
			</xsl:call-template>
		</xsl:for-each>
		<br/>
	</xsl:template>

	<!-- movements -->
	<xsl:template match="m:section">
		<xsl:variable name="preferred_movement_title_found"
			select="count(m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:title[@xml:lang=$preferred_language][normalize-space()])"/>
		<p class="movement_heading">
			<xsl:variable name="movement_number" select="normalize-space(@n)"/>
			<xsl:variable name="movement_tempo" select="normalize-space(m:app/m:rdg[@type='metadata']/m:tempo)"/>
			<xsl:if test="$movement_number">
				<!-- format as roman numerals if possible -->
				<xsl:choose>
					<xsl:when test="string(number($movement_number))!='NaN'">
						<xsl:number format="I" value="normalize-space(@n)"/>.<xsl:text> </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$movement_number"/>.<xsl:text> </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$preferred_movement_title_found&gt;0">
					<xsl:variable name="movement_title">
						<xsl:apply-templates
							select="m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:title[@xml:lang=$preferred_language]">
							<xsl:with-param name="preferred_found" select="1"/>
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:value-of select="$movement_title"/>
					<xsl:if test="$movement_tempo!=''">.<xsl:text> </xsl:text></xsl:if>
					<xsl:value-of select="$movement_tempo"/>
				</xsl:when>
				<xsl:when test="normalize-space(m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:title)">
					<xsl:variable name="movement_title">
						<xsl:apply-templates
							select="m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:title[normalize-space()][1]">
							<xsl:with-param name="preferred_found" select="1"/>
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:value-of select="$movement_title"/>
					<xsl:if test="$movement_tempo!=''">.<xsl:text> </xsl:text></xsl:if>
					<xsl:value-of select="$movement_tempo"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$movement_tempo"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:variable name="offset" select="number(1-$preferred_movement_title_found)"/>
			<xsl:apply-templates
				select="m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:title[@xml:lang!=$preferred_language and position() &gt; $offset]"
				mode="multilingual_text">
				<xsl:with-param name="preferred_found" select="1"/>
			</xsl:apply-templates>
		</p>
		<xsl:variable name="meter_found"
			select="normalize-space(concat(m:app/m:rdg[@type='metadata']/m:scoredef/@meter.count,m:app/m:rdg[@type='metadata']/m:scoredef/@meter.sym))"/>
		<xsl:variable name="key_found"
			select="normalize-space(concat(m:app/m:rdg[@type='metadata']/m:scoredef/@key.pname,m:app/m:rdg[@type='metadata']/m:scoredef/@key.accid, m:app/m:rdg[@type='metadata']/m:scoredef/@key.mode))"/>
		<xsl:variable name="text_incipit_found"
			select="normalize-space(m:app/m:rdg[@type='incipit']/m:div[@type='text_incipit']/m:p)"/>
		<xsl:variable name="edited_score_found"
			select="normalize-space(m:app/m:rdg[@type='edited_score']/m:annot[@type='links']/m:extptr[normalize-space(@xl:href!='')]/@xl:title)"/>
		<xsl:if test="concat($key_found,$meter_found,$text_incipit_found,$edited_score_found)!=''">
			<p>
				<xsl:if test="$key_found!=''">
					<xsl:apply-templates select="m:app/m:rdg[@type='metadata']/m:scoredef" mode="key"/>
					<xsl:if test="concat($meter_found,$text_incipit_found,$edited_score_found)!=''">
						<br/>
					</xsl:if>
				</xsl:if>
				<xsl:if test="$meter_found!=''"> Metre: <xsl:if
						test="normalize-space(m:app/m:rdg[@type='metadata']/m:scoredef/@meter.count)">
						<span class="meter"><xsl:value-of select="m:app/m:rdg[@type='metadata']/m:scoredef/@meter.count"
								/>/<xsl:value-of select="m:app/m:rdg[@type='metadata']/m:scoredef/@meter.unit"/></span>
					</xsl:if>
					<xsl:if test="m:app/m:rdg[@type='metadata']/m:scoredef/@meter.sym!=''">
						<span class="timesig">
							<xsl:choose>
								<xsl:when test="m:app/m:rdg[@type='metadata']/m:scoredef/@meter.sym='common'"
									>c</xsl:when>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="m:app/m:rdg[@type='metadata']/m:scoredef/@meter.sym='cut'">C</xsl:when>
							</xsl:choose>
						</span>
					</xsl:if>
					<xsl:if test="concat($text_incipit_found,$edited_score_found)!=''"><br/></xsl:if>
				</xsl:if>
				<xsl:if test="$text_incipit_found!=''"> Text incipit: <xsl:variable name="preferred_text_incipit_found"
						select="count(m:app/m:rdg[@type='incipit']/m:div[@type='text_incipit']/m:p[@xml:lang=$preferred_language])"/>
					<xsl:apply-templates
						select="m:app/m:rdg[@type='incipit']/m:div[@type='text_incipit']/m:p[@xml:lang=$preferred_language]"
						mode="multilingual_text">
						<xsl:with-param name="preferred_found" select="$preferred_text_incipit_found"/>
					</xsl:apply-templates>
					<xsl:apply-templates
						select="m:app/m:rdg[@type='incipit']/m:div[@type='text_incipit']/m:p[@xml:lang!=$preferred_language]"
						mode="multilingual_text">
						<xsl:with-param name="preferred_found" select="$preferred_text_incipit_found"/>
					</xsl:apply-templates>
					<xsl:if test="$edited_score_found!=''"><br/></xsl:if>
				</xsl:if>
				<xsl:if test="$edited_score_found!=''"> Edited score: <xsl:for-each
						select="m:app/m:rdg[@type='edited_score']/m:annot[@type='links']/m:extptr[normalize-space(@xl:href)!='']">
						<xsl:if test="position()&gt;1">, </xsl:if>
						<a target="_blank">
							<xsl:attribute name="href"><xsl:value-of select="@xl:href"/></xsl:attribute>
							<xsl:value-of select="@xl:title"/>
						</a>
					</xsl:for-each>
				</xsl:if>
			</p>
		</xsl:if>
		<!-- find incipits -->
		<xsl:variable name="number_of_lowres_incipits"
			select="count(m:app/m:rdg[@type='incipit']/m:annot[@type='links']/m:extptr[@targettype='lowres'])"/>
		<xsl:if test="$number_of_lowres_incipits &gt; 0">
			<p>
				<xsl:apply-templates select="m:app/m:rdg[@type='incipit']/m:annot[@type='links']"/>
			</p>
		</xsl:if>
	</xsl:template>

	<!-- incipits -->
	<xsl:template match="m:app/m:rdg[@type='incipit']/m:annot[@type='links']">
		<xsl:variable name="number_of_hires" select="count(m:extptr[@targettype='hires'])"/>
		<xsl:for-each select="m:extptr[@targettype='lowres' and normalize-space(@xl:href)]">
			<xsl:choose>
				<xsl:when test="../m:extptr[@targettype='hires'][position()]">
					<!-- if more than one incipit per movement, the order of lowres and hires images must match -->
					<a target="incipit" title="Click to enlarge image" style="text-decoration:none;">
						<xsl:attribute name="href">
							<xsl:value-of select="../m:extptr[@targettype='hires']/@xl:href"/>
						</xsl:attribute>
						<xsl:attribute name="onclick">window.open("<xsl:value-of
								select="../m:extptr[@targettype='hires']/@xl:href"
							/>","incipit","height=450,width=960,toolbar=0,status=0,menubar=0,resizable=1,location=0,scrollbars=1");
							return false;</xsl:attribute>
						<img class="incipit_lowres" border="0" alt="incipit">
							<xsl:attribute name="src">
								<xsl:value-of select="@xl:href"/>
							</xsl:attribute>
						</img>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<img class="incipit_lowres" alt="incipit">
						<xsl:attribute name="src">
							<xsl:value-of select="@xl:href"/>
						</xsl:attribute>
					</img>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<!-- key -->
	<xsl:template match="m:app/m:rdg[@type='metadata']/m:scoredef" mode="key">
		<xsl:call-template name="uppercase">
			<xsl:with-param name="str" select="@key.pname"/>
		</xsl:call-template>
		<!-- if text output is wanted instead of font embedding -->
		<!--
	<xsl:text> </xsl:text>
	<xsl:choose>
	<xsl:when test="@key.accid='n'">natural </xsl:when>
	<xsl:when test="@key.accid='f'">flat </xsl:when>
	<xsl:when test="@key.accid='s'">sharp </xsl:when>
	<xsl:when test="@key.accid='ff'">double flat </xsl:when>
	<xsl:when test="@key.accid='ss'">double sharp </xsl:when>
	<xsl:otherwise/>
	</xsl:choose> -->
		<xsl:if test="@key.accid and @key.accid!='n' and @key.accid!=''">
			<xsl:call-template name="key_accidental">
				<xsl:with-param name="attr" select="@key.accid"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:text> </xsl:text>
		<xsl:value-of select="@key.mode"/>
	</xsl:template>

	<!-- sources -->
	<xsl:template match="m:sourcedesc">
		<xsl:if test="m:source[normalize-space(m:titlestmt/m:title)]">
			<div id="source_hidden" class="fold_icon">
				<p class="p_heading" title="Click to view sources" onclick="show('source_shown');hide('source_hidden')"
						><img class="noprint" style="display:inline" border="0" src="/editor/images/plus.png"/>
					Sources</p>
			</div>
			<div id="source_shown" style="display:none">
				<p class="fold_icon" title="Click to hide sources" onclick="show('source_hidden');hide('source_shown')">
					<img class="noprint" style="display:inline" border="0" src="/editor/images/minus.png"/>
					<span class="p_heading"> Sources</span>
				</p>
				<div class="folded_content">
					<xsl:if
						test="normalize-space(../m:notesstmt/m:annot[@type='links']/m:extptr[@targettype='CNU source description']/@xl:href)">
						<!-- link to CNU source descriptions -->
						<p>See also: <a target="blank"><xsl:attribute name="href"><xsl:value-of
										select="../m:notesstmt/m:annot[@type='links']/m:extptr[@targettype='CNU source description']/@xl:href"
									/></xsl:attribute> CNU source descriptions</a><br/>&#160; </p>
					</xsl:if>
					<xsl:for-each select="m:source[normalize-space(m:titlestmt/m:title)]">
						<!-- view only sources with a title -->
						<div class="source">
							<p>
								<strong>
									<!-- source title -->
									<xsl:apply-templates select="m:titlestmt/m:title"/>
								</strong>
								<br/>
							</p>
							<xsl:if test="m:classification/m:keywords[normalize-space(m:term)]">
								<div class="classification">[Source classification: <xsl:for-each
										select="m:classification/m:keywords/m:term[normalize-space()]">
										<xsl:if test="position()&gt;1">;&#160;</xsl:if>
										<xsl:value-of select="."/>
									</xsl:for-each>] </div>
							</xsl:if>
							<!-- contributors -->
							<xsl:if test="m:titlestmt/m:respstmt[normalize-space(m:persname)]">
								<p>
									<xsl:for-each select="m:titlestmt/m:respstmt/m:persname[normalize-space()]">
										<xsl:if test="position()&gt;1">
											<br/>
										</xsl:if>
										<xsl:if test="normalize-space(@type)">
											<xsl:call-template name="capitalize">
												<xsl:with-param name="str" select="@type"/>
											</xsl:call-template>: </xsl:if>
										<xsl:value-of select="."/>
									</xsl:for-each>
								</p>
							</xsl:if>
							<!-- source location -->
							<xsl:if
								test="normalize-space(concat(m:physdesc/m:physloc/m:repository/m:corpname, m:physdesc/m:physloc/m:repository/m:identifier))">
								<p><xsl:if test="normalize-space(m:physdesc/m:physloc/m:repository/m:corpname)">
										<em><xsl:value-of select="m:physdesc/m:physloc/m:repository/m:corpname"
												disable-output-escaping="yes"/></em>
										<xsl:if test="normalize-space(m:physdesc/m:physloc/m:repository/m:identifier)"
											>,&#160;</xsl:if>
									</xsl:if>
									<xsl:if test="normalize-space(m:physdesc/m:physloc/m:repository/m:identifier)"
											><xsl:value-of select="m:physdesc/m:physloc/m:repository/m:identifier"
											disable-output-escaping="yes"/>
									</xsl:if>. <xsl:apply-templates
										select="m:physdesc/m:physloc/m:repository/m:extptr[normalize-space(@xl:href)]"
										mode="comma-separated"/>
								</p>
							</xsl:if>
							<xsl:if test="normalize-space(m:physdesc/m:provenance/m:eventlist/m:event)">
								<p>Provenance:&#160; <xsl:for-each
										select="m:physdesc/m:provenance/m:eventlist/m:event[normalize-space()]">
										<xsl:if test="normalize-space(concat(@notbefore,@notafter))">
											<xsl:choose>
												<xsl:when test="normalize-space(@notbefore)=normalize-space(@notafter)">
													<!-- exact date -->
													<xsl:value-of select="@notbefore"/>:&#160; </xsl:when>
												<xsl:when test="normalize-space(@notbefore)=''">
													<!-- not after -->
													<xsl:value-of select="@notafter"/> or earlier:&#160; </xsl:when>
												<xsl:when test="normalize-space(@notafter)=''">
													<!-- not before -->
													<xsl:value-of select="@notbefore"/> or later:&#160; </xsl:when>
												<xsl:otherwise>
													<!-- between --> Between <xsl:value-of select="@notbefore"/> and
														<xsl:value-of select="@notafter"/>:&#160; </xsl:otherwise>
											</xsl:choose>
										</xsl:if>
										<xsl:value-of select="."/>. </xsl:for-each>
								</p>
							</xsl:if>
							<!-- dating -->
							<xsl:choose>
								<xsl:when
									test="m:classification/m:keywords/m:term[@classcode='DcmPresentationClass']='manuscript'">
									<!-- manuscript dating -->
									<xsl:if test="normalize-space(concat(m:pubstmt/m:geogname, m:pubstmt/m:date))!=''">
										<p>Manuscript dated: <xsl:if test="normalize-space(m:pubstmt/m:geogname) != ''"
													><xsl:value-of select="m:pubstmt/m:geogname"/>,&#160;</xsl:if>
											<xsl:apply-templates select="m:pubstmt/m:date"/>.</p>
									</xsl:if>
								</xsl:when>
								<xsl:otherwise>
									<!-- list printed editions -->
									<xsl:apply-templates select="m:pubstmt"/>
								</xsl:otherwise>
							</xsl:choose>
							<!-- physical description -->
							<xsl:if test="normalize-space(concat(m:physdesc/m:dimensions,m:physdesc/m:extent))!=''">
								<p>
									<xsl:if test="normalize-space(m:physdesc/m:dimensions)!=''">
										<xsl:apply-templates select="m:physdesc" mode="comma-separated">
											<xsl:with-param name="desc_elements" select="m:physdesc/m:dimensions"/>
										</xsl:apply-templates>. </xsl:if>
									<xsl:if test="normalize-space(m:physdesc/m:extent)!=''">
										<xsl:apply-templates select="m:physdesc" mode="comma-separated">
											<xsl:with-param name="desc_elements" select="m:physdesc/m:extent"/>
										</xsl:apply-templates>. </xsl:if>
								</p>
							</xsl:if>
							<xsl:if test="m:physdesc/m:handlist/m:hand[@medium!='']">
								<p>
									<xsl:apply-templates select="m:physdesc/m:handlist">
										<xsl:with-param name="initial">true</xsl:with-param>
									</xsl:apply-templates>
									<xsl:apply-templates select="m:physdesc/m:handlist">
										<xsl:with-param name="initial">false</xsl:with-param>
									</xsl:apply-templates>
								</p>
							</xsl:if>
							<xsl:if test="normalize-space(m:physdesc/m:physmedium)">
								<p>
									<xsl:value-of select="normalize-space(m:physdesc/m:physmedium)"
										disable-output-escaping="yes"/>
								</p>
							</xsl:if>
							<xsl:for-each select="m:physdesc/m:titlepage[normalize-space(m:p)]">
								<p>
									<xsl:if test="position() = 1">Title page: </xsl:if>
									<xsl:if test="position() &gt; 1">Secondary title page: </xsl:if>
									<xsl:apply-templates/>
								</p>
								<!-- HTML enabled -->
							</xsl:for-each>
							<!-- source description text -->
							<xsl:if test="normalize-space(m:notesstmt/m:annot[@type='source_description'])">
								<p>
									<xsl:apply-templates select="m:notesstmt/m:annot[@type='source_description']"/>
								</p>
								<!-- HTML enabled -->
							</xsl:if>
							<xsl:if test="normalize-space(m:notesstmt/m:annot[@type='links']/m:extptr/@xl:href)">
								<p>See also: <xsl:apply-templates select="m:notesstmt/m:annot[@type='links']/m:extptr"
										mode="comma-separated"/>
								</p>
							</xsl:if>
						</div>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- source-related templates -->

	<!-- arrange multiple physdesc elements -->
	<xsl:template match="m:physdesc" mode="comma-separated">
		<xsl:param name="desc_elements"/>
		<xsl:variable name="number_of_items" select="count($desc_elements)"/>
		<xsl:for-each select="$desc_elements">
			<xsl:if test="position() &gt; 1">, </xsl:if>
			<xsl:value-of select="."/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="./@unit"/>
		</xsl:for-each>
	</xsl:template>

	<!-- format scribe's name and medium -->
	<xsl:template match="m:hand" mode="scribe">
		<xsl:call-template name="lowercase">
			<xsl:with-param name="str" select="translate(@medium,'_',' ')"/>
		</xsl:call-template>
		<xsl:if test="normalize-space(.)"> (<xsl:value-of select="normalize-space(.)"/>)</xsl:if>
	</xsl:template>

	<!-- list scribes -->
	<xsl:template match="m:handlist">
		<xsl:param name="initial"/>
		<xsl:variable name="number_of_scribes" select="count(m:hand[@initial=$initial])"/>
		<xsl:if test="$number_of_scribes &gt; 0">
			<xsl:choose>
				<xsl:when test="$initial='true'">Written in </xsl:when>
				<xsl:otherwise>Additions in </xsl:otherwise>
			</xsl:choose>
			<xsl:for-each select="m:hand[@initial=$initial]">
				<xsl:if test="position() &gt; 1 and position() &lt; $number_of_scribes">, </xsl:if>
				<xsl:if test="position() = $number_of_scribes and position() &gt; 1"> and </xsl:if>
				<xsl:apply-templates select="." mode="scribe"/>
			</xsl:for-each>. </xsl:if>
	</xsl:template>

	<!-- list editions -->
	<xsl:template match="m:source/m:pubstmt">
		<p>
			<xsl:if test="normalize-space(m:respstmt/m:corpname)!=''"><xsl:value-of select="m:respstmt/m:corpname"/>, </xsl:if>
			<xsl:if test="normalize-space(m:geogname) != ''"><xsl:value-of select="m:geogname"/>&#160;</xsl:if>
			<xsl:if test="normalize-space(m:date) !=''">
				<xsl:apply-templates select="m:date"/>
			</xsl:if>
			<xsl:if
				test="normalize-space(m:date) !='' or normalize-space(m:geogname) != '' or normalize-space(m:respstmt/m:corpname)!=''"
				>.</xsl:if>
			<xsl:if test="normalize-space(m:identifier[@type='plate_no']) != ''"> Plate no. <xsl:value-of
					select="m:identifier[@type='plate_no']"/>. </xsl:if>
		</p>
	</xsl:template>


	<!-- bibliography -->

	<xsl:template match="m:music/m:front/t:div[t:head='Bibliography']/t:listBibl" mode="all">
		<xsl:variable name="number_of_bibl"
			select="count(t:bibl[normalize-space(concat(t:author,t:name[@type='recipient'],t:date,t:title[@level='a'],t:title[@level='m']))!=''])"/>
		<xsl:if test="$number_of_bibl &gt; 0">
			<div class="fold_icon">
				<xsl:attribute name="id">bibl_hidden_<xsl:value-of select="@type"/></xsl:attribute>
				<p class="p_heading" title="Click to view bibliography">
					<xsl:attribute name="onclick">show('bibl_shown_<xsl:value-of select="@type"
							/>');hide('bibl_hidden_<xsl:value-of select="@type"/>')</xsl:attribute>
					<img style="display:inline" border="0" src="/editor/images/plus.png"/>
					<xsl:choose>
						<xsl:when test="@type='primary'"> Primary texts </xsl:when>
						<xsl:when test="@type='documentation'"> Documentation </xsl:when>
						<xsl:otherwise> Bibliography </xsl:otherwise>
					</xsl:choose>
				</p>
			</div>
			<div style="display:none">
				<xsl:attribute name="id">bibl_shown_<xsl:value-of select="@type"/></xsl:attribute>
				<p class="fold_icon" title="Click to hide bibliography">
					<xsl:attribute name="onclick">show('bibl_hidden_<xsl:value-of select="@type"
							/>');hide('bibl_shown_<xsl:value-of select="@type"/>')</xsl:attribute>
					<img style="display:inline" border="0" src="/editor/images/minus.png"/>
					<span class="p_heading">
						<xsl:choose>
							<xsl:when test="@type='primary'"> Primary texts </xsl:when>
							<xsl:when test="@type='documentation'"> Documentation </xsl:when>
							<xsl:otherwise> Bibliography </xsl:otherwise>
						</xsl:choose>
					</span>
				</p>
				<div class="folded_content">
					<xsl:apply-templates select="." mode="bibl_paragraph"/>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- render bibliography items as paragraphs or tables -->
	<xsl:template match="m:music/m:front/t:div[t:head='Bibliography']/t:listBibl" mode="bibl_paragraph">
		<!-- Letters and diary entries are listed first under separate headings -->
		<xsl:if
			test="count(t:bibl[@type='Letter' and normalize-space(concat(t:author,t:name[@role='recipient'],t:date))]) &gt; 0">
			<p class="p_subheading">Letters:</p>
			<table class="letters">
				<xsl:for-each
					select="t:bibl[@type='Letter' and normalize-space(concat(t:author,t:name[@role='recipient'],t:date))]">
					<xsl:apply-templates select="."/>
				</xsl:for-each>
			</table>
		</xsl:if>
		<xsl:if test="count(t:bibl[@type='Diary entry' and normalize-space(concat(t:author,t:date))]) &gt; 0">
			<p class="p_subheading">Diary entries:</p>
			<table class="letters">
				<xsl:for-each select="t:bibl[@type='Diary entry' and normalize-space(concat(t:author,t:date))]">
					<xsl:apply-templates select="."/>
				</xsl:for-each>
			</table>
		</xsl:if>
		<xsl:if
			test="count(t:bibl[(@type='Letter' or @type='Diary entry') and normalize-space(concat(t:author,t:date))])&gt;0 and 
		  count(t:bibl[@type!='Letter' and @type!='Diary entry' and normalize-space(concat(t:author,t:title[@level='a'],t:title[@level='m']))])&gt;0">
			<p class="p_heading">Other:</p>
		</xsl:if>
		<xsl:for-each
			select="t:bibl[@type!='Letter' and @type!='Diary entry' and normalize-space(concat(t:author,t:title[@level='a'],t:title[@level='m']))]">
			<p class="bibl_record">
				<xsl:apply-templates select="."/>
			</p>
		</xsl:for-each>
	</xsl:template>

	<!-- bibliographic record formatting template -->
	<xsl:template match="t:bibl">
		<xsl:choose>
			<xsl:when test="@type='Monograph'">
				<xsl:if test="normalize-space(t:title[@level='m'])!=''">
					<!-- show entry only if a title is stated -->
					<xsl:if test="normalize-space(t:author)!=''">
						<xsl:apply-templates select="current()" mode="authors"/>
					</xsl:if>
					<xsl:if test="normalize-space(t:author)=''">
						<!-- use ed. if no author is stated -->
						<xsl:if test="normalize-space(t:editor)!=''">
							<xsl:apply-templates select="current()" mode="editors"/>
						</xsl:if>
					</xsl:if>
					<em>
						<xsl:value-of select="normalize-space(t:title[@level='m'])"/>
					</em>
					<xsl:if test="normalize-space(t:title[@level='s'])!=''"> (= <xsl:value-of
							select="normalize-space(t:title[@level='s'])"/>
						<xsl:if test="normalize-space(t:biblScope[@type='volume'])!=''">, Vol.<xsl:value-of
								select="normalize-space(t:biblScope[@type='volume'])"/></xsl:if>)</xsl:if>
					<xsl:if test="normalize-space(concat(t:publisher,t:pubPlace,t:date))!=''">. <xsl:if
							test="normalize-space(t:publisher)!=''">
							<xsl:value-of select="normalize-space(t:publisher)"/>, </xsl:if>
						<xsl:if test="normalize-space(t:pubPlace)!=''">
							<xsl:value-of select="normalize-space(t:pubPlace)"/></xsl:if>
						<xsl:if test="normalize-space(t:date)!=''"><xsl:text> </xsl:text><xsl:value-of
								select="normalize-space(t:date)"/></xsl:if>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="normalize-space(t:title[@level='s'])=''">
							<xsl:apply-templates select="current()" mode="volumes_pages"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="normalize-space(t:biblScope[@type='pages'])">, p. <xsl:value-of
									select="t:biblScope[@type='pages']"/>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:if test="normalize-space(t:title[@level='s'])=''"> </xsl:if>
				</xsl:if>
			</xsl:when>

			<xsl:when test="@type='Article in Book'">
				<!-- show entry only if a title is stated -->
				<xsl:if test="normalize-space(t:title[@level='a'])!=''">
					<xsl:if test="normalize-space(t:author)!=''"><xsl:apply-templates select="current()" mode="authors"
						/>
					</xsl:if>
					<em><xsl:value-of select="normalize-space(t:title[@level='a'])"/></em>
					<xsl:choose>
						<xsl:when test="normalize-space(t:title[@level='m'])!=''">, in: <xsl:if
								test="normalize-space(t:editor)!=''"><xsl:apply-templates select="current()"
									mode="editors"/>
							</xsl:if>
							<xsl:value-of select="normalize-space(t:title[@level='m'])"/>
							<xsl:choose>
								<xsl:when test="normalize-space(t:title[@level='s'])!=''"> (= <xsl:value-of
										select="normalize-space(t:title[@level='s'])"/>
									<xsl:if test="normalize-space(t:biblScope[@type='volume'])!=''">, Vol.<xsl:value-of
											select="normalize-space(t:biblScope[@type='volume'])"/></xsl:if>)</xsl:when>
								<xsl:otherwise>
									<xsl:if test="normalize-space(t:biblScope[@type='volume'])!=''">, Vol.<xsl:value-of
											select="normalize-space(t:biblScope[@type='volume'])"/></xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="normalize-space(t:title[@level='s'])!=''">, in: <xsl:value-of
										select="normalize-space(t:title[@level='s'])"/>
									<xsl:if test="normalize-space(t:biblScope[@type='volume'])!=''">, Vol.<xsl:value-of
											select="normalize-space(t:biblScope[@type='volume'])"/></xsl:if>
								</xsl:when>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="normalize-space(concat(t:publisher,t:pubPlace,t:date))!=''">. <xsl:if
							test="normalize-space(t:publisher)!=''">
							<xsl:value-of select="normalize-space(t:publisher)"/>, </xsl:if>
						<xsl:if test="normalize-space(t:pubPlace)!=''">
							<xsl:value-of select="normalize-space(t:pubPlace)"/></xsl:if>
						<xsl:if test="normalize-space(t:date)!=''"><xsl:text> </xsl:text><xsl:value-of
								select="normalize-space(t:date)"/></xsl:if>
					</xsl:if>
					<xsl:if test="normalize-space(t:biblScope[@type='pages'])!=''">, p. <xsl:value-of
							select="normalize-space(t:biblScope[@type='pages'])"/>
					</xsl:if>. </xsl:if>
			</xsl:when>

			<xsl:when test="@type='Journal Article'">
				<!-- show entry only if a title or journal/newspaper name is stated -->
				<xsl:if test="normalize-space(concat(t:title[@level='a'],t:title[@level='j']))!=''">
					<xsl:if test="normalize-space(t:title[@level='a'])!=''">
						<xsl:if test="normalize-space(t:author)!=''"><xsl:apply-templates select="current()"
								mode="authors"/>
						</xsl:if> '<xsl:value-of select="normalize-space(t:title[@level='a'])"/>'<xsl:if
							test="normalize-space(t:title[@level='j'])!=''">, in: </xsl:if>
					</xsl:if>
					<xsl:if test="normalize-space(t:title[@level='j'])!=''"><em><xsl:value-of
								select="t:title[@level='j']"/></em></xsl:if>
					<xsl:if test="normalize-space(t:biblScope[@type='volume'])!=''">, <xsl:value-of
							select="normalize-space(t:biblScope[@type='volume'])"/></xsl:if><xsl:if
						test="normalize-space(t:biblScope[@type='number'])!=''">/<xsl:value-of
							select="normalize-space(t:biblScope[@type='number'])"/></xsl:if>
					<xsl:if test="normalize-space(t:date)!=''"> (<xsl:apply-templates select="t:date"/>)</xsl:if>
					<xsl:if test="normalize-space(t:biblScope[@type='pages'])!=''">, p. <xsl:value-of
							select="t:biblScope[@type='pages']"/></xsl:if>. </xsl:if>
			</xsl:when>

			<xsl:when test="@type='Web resource'">
				<!-- show entry only if a title is stated -->
				<xsl:if test="normalize-space(t:title)">
					<xsl:if test="normalize-space(t:author)!=''"><xsl:apply-templates select="t:author"/>: </xsl:if>
					<em><xsl:value-of select="t:title"/></em>
					<xsl:if test="normalize-space(concat(t:biblScope[normalize-space()], t:publisher, t:pubPlace))">. </xsl:if>
					<xsl:if test="normalize-space(t:biblScope[@type='volume'])">, vol.<xsl:value-of
							select="normalize-space(t:biblScope[@type='volume'])"/></xsl:if>
					<xsl:if test="normalize-space(t:publisher)">
						<xsl:value-of select="normalize-space(t:publisher)"/>
						<xsl:if test="normalize-space(concat(t:pubPlace,t:biblScope[@type='pages']))">, </xsl:if>
					</xsl:if>
					<xsl:if test="normalize-space(t:pubPlace)">
						<xsl:value-of select="normalize-space(t:pubPlace)"/></xsl:if>
					<xsl:if test="normalize-space(t:date)">
						<xsl:apply-templates select="t:date"/></xsl:if>
					<xsl:if test="normalize-space(t:biblScope[@type='pages'])">, p. <xsl:value-of
							select="normalize-space(t:biblScope[@type='pages'])"/></xsl:if>. </xsl:if>
			</xsl:when>

			<xsl:when test="@type='Letter'">
				<!-- show entry only if a sender, recipient or date is stated -->
				<xsl:if test="normalize-space(concat(t:author, t:name[@role='recipient'],t:date))!=''">
					<tr>
						<td>
							<xsl:if test="normalize-space(t:date)!=''"><xsl:apply-templates select="t:date"
								/>&#160;</xsl:if>
						</td>
						<td>
							<xsl:if test="normalize-space(t:author)!=''">
								<xsl:choose>
									<xsl:when test="normalize-space(t:date)!=''"> from </xsl:when>
									<xsl:otherwise>From </xsl:otherwise>
								</xsl:choose>
								<xsl:value-of select="t:author"/>
							</xsl:if>
							<xsl:if test="normalize-space(t:name[@role='recipient'])!=''">
								<xsl:choose>
									<xsl:when test="normalize-space(t:author)!=''"> to </xsl:when>
									<xsl:otherwise>To</xsl:otherwise>
								</xsl:choose>
								<xsl:value-of select="t:name[@role='recipient']"/>
							</xsl:if>, <xsl:if
								test="normalize-space(concat(t:msIdentifier/t:repository, t:msIdentifier/t:idno))">
								<em><xsl:value-of select="t:msIdentifier/t:repository"/>
								</em>
								<xsl:if
									test="normalize-space(t:msIdentifier/t:repository) and normalize-space(t:msIdentifier/t:idno)">
									<xsl:text> </xsl:text>
								</xsl:if>
								<xsl:value-of select="t:msIdentifier/t:idno"/>
							</xsl:if>
							<xsl:if test="normalize-space(t:ref[@type='editions']/t:bibl/t:title)">
								<xsl:apply-templates select="t:ref[@type='editions']"/>
							</xsl:if>
							<xsl:if test="normalize-space(t:ref[count(@type)=0]/@target)">
								<xsl:text> </xsl:text>
								<xsl:element name="a">
									<xsl:attribute name="href"><xsl:value-of select="t:ref[count(@type)=0]/@target"
										/></xsl:attribute>Fulltext </xsl:element>
							</xsl:if>
						</td>
					</tr>
				</xsl:if>
			</xsl:when>

			<xsl:when test="@type='Diary entry'">
				<!-- show entry only if a sender, recipient or date is stated -->
				<xsl:if test="normalize-space(concat(t:author,t:date))!=''">
					<tr>
						<td>
							<xsl:if test="normalize-space(t:date)!=''"><xsl:apply-templates select="t:date"
								/>&#160;</xsl:if>
						</td>
						<td>
							<!-- do not display name if it is the composer's own diary -->
							<xsl:if
								test="normalize-space(t:author)!='' and normalize-space(t:author)!=normalize-space(../../../../../m:meihead/m:filedesc/m:titlestmt/m:respstmt/m:persname[@type='composer'])">
								<xsl:text> </xsl:text>
								<xsl:value-of select="t:author"/>
								<xsl:if
									test="normalize-space(concat(t:msIdentifier/t:repository, t:msIdentifier/t:idno))">,
								</xsl:if>
							</xsl:if>
							<xsl:if test="normalize-space(concat(t:msIdentifier/t:repository, t:msIdentifier/t:idno))">
								<em>
									<xsl:value-of select="t:msIdentifier/t:repository"/>
								</em>
								<xsl:if
									test="normalize-space(t:msIdentifier/t:repository) and normalize-space(t:msIdentifier/t:idno)">
									<xsl:text> </xsl:text>
								</xsl:if>
								<xsl:value-of select="t:msIdentifier/t:idno"/>
							</xsl:if>
							<xsl:if test="normalize-space(t:ref[@type='editions']/t:bibl/t:title)">
								<xsl:apply-templates select="t:ref[@type='editions']"/>
							</xsl:if>
							<xsl:if test="normalize-space(t:ref[count(@type)=0]/@target)">
								<xsl:text> </xsl:text>
								<xsl:element name="a">
									<xsl:attribute name="href"><xsl:value-of select="t:ref[count(@type)=0]/@target"
										/></xsl:attribute>Fulltext </xsl:element>
							</xsl:if>
						</td>
					</tr>
				</xsl:if>
			</xsl:when>

			<xsl:otherwise>
				<xsl:if test="normalize-space(t:author)!=''"><xsl:apply-templates select="t:author"/>: </xsl:if>
				<xsl:if test="normalize-space(t:title)!=''">
					<em><xsl:value-of select="t:title"/></em>
				</xsl:if>
				<xsl:if test="normalize-space(t:biblScope[@type='volume'])">, vol.<xsl:value-of
						select="normalize-space(t:biblScope[@type='volume'])"/></xsl:if>. <xsl:if
					test="normalize-space(t:publisher)">
					<xsl:value-of select="normalize-space(t:publisher)"/>, </xsl:if>
				<xsl:if test="normalize-space(t:pubPlace)">
					<xsl:value-of select="normalize-space(t:pubPlace)"/></xsl:if>
				<xsl:if test="normalize-space(t:date)">
					<xsl:apply-templates select="t:date"/></xsl:if>
				<xsl:if test="normalize-space(t:biblScope[@type='pages'])">, p. <xsl:value-of
						select="normalize-space(t:biblScope[@type='pages'])"/></xsl:if>. * </xsl:otherwise>
		</xsl:choose>
		<!-- links to full text (exception: letters and diary entries handled elsewhere) -->
		<xsl:if test="normalize-space(t:ref/@target) and not(@type='Diary entry' or @type='Letter')">
			<a target="_blank" title="Link to full text">
				<xsl:attribute name="href">
					<xsl:value-of select="normalize-space(t:ref/@target)"/>
				</xsl:attribute>
				<xsl:value-of select="t:ref/@target"/>
			</a>
		</xsl:if>
	</xsl:template>

	<!-- list authors -->
	<xsl:template match="t:bibl" mode="authors">
		<xsl:variable name="number_of_authors" select="count(t:author)"/>
		<xsl:if test="$number_of_authors = 1"><xsl:value-of select="t:author"/>: </xsl:if>
		<xsl:if test="$number_of_authors &gt; 1">
			<xsl:for-each select="t:author">
				<xsl:if test="position() &gt; 1 and position() &lt; $number_of_authors">, </xsl:if>
				<xsl:if test="position() = $number_of_authors"> and </xsl:if>
				<xsl:value-of select="t:author"/>
			</xsl:for-each>: </xsl:if>
	</xsl:template>

	<!-- list editors -->
	<xsl:template match="t:bibl" mode="editors">
		<xsl:variable name="number_of_editors" select="count(t:editor)"/>
		<xsl:if test="$number_of_editors = 1"><xsl:value-of select="t:editor"/> (ed.): </xsl:if>
		<xsl:if test="$number_of_editors &gt; 1">
			<xsl:for-each select="t:editor">
				<xsl:if test="position() &gt; 1 and position() &lt; $number_of_editors">, </xsl:if>
				<xsl:if test="position() = $number_of_editors"> and </xsl:if>
				<xsl:value-of select="t:editor"/>
			</xsl:for-each> (eds.): </xsl:if>
	</xsl:template>

	<!-- list editions of letters, diaries etc. -->
	<xsl:template match="t:ref[@type='editions']">
		<xsl:variable name="number_of_editions" select="count(t:bibl)"/> (<xsl:for-each select="t:bibl">
			<xsl:if test="position() &gt; 1">,<xsl:text> </xsl:text></xsl:if>
			<xsl:value-of select="t:title"/><xsl:text> </xsl:text><xsl:value-of select="t:biblScope"/>
		</xsl:for-each>) </xsl:template>


	<!-- format volume, issue and page numbers -->
	<xsl:template match="t:bibl" mode="volumes_pages">
		<xsl:variable name="number_of_volumes" select="count(t:biblScope[@type='volume' and normalize-space(.)!=''])"/>
		<xsl:variable name="number_of_pages" select="count(t:biblScope[@type='pages' and normalize-space(.)!=''])"/>
		<xsl:choose>
			<xsl:when test="$number_of_volumes &gt; 0">: <xsl:for-each select="t:biblScope[@type='volume']">
					<xsl:if test="position() &gt; 1">; </xsl:if> Vol. <xsl:value-of select="."/>
					<xsl:if test="normalize-space(../t:biblScope[@type='number'][position()])">/<xsl:value-of
							select="normalize-space(../t:biblScope[@type='number'][position()])"/></xsl:if>
					<xsl:if test="normalize-space(../t:biblScope[@type='pages'][position()])">, p. <xsl:value-of
							select="normalize-space(../t:biblScope[@type='pages'][position()])"/></xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="normalize-space(t:biblScope[@type='pages'])!=''">, p. <xsl:value-of
						select="t:biblScope[@type='pages']"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>. </xsl:template>

	<!-- display external link -->
	<xsl:template match="m:extptr">
		<xsl:if test="normalize-space(@xl:href)">
			<a target="_blank">
				<xsl:attribute name="href">
					<xsl:value-of select="@xl:href"/>
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test="normalize-space(@xl:title)!=''">
						<xsl:call-template name="capitalize">
							<xsl:with-param name="str" select="@xl:title"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="normalize-space(@targettype)!=''">
						<xsl:call-template name="capitalize">
							<xsl:with-param name="str" select="@targettype"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@xl:href"/>
					</xsl:otherwise>
				</xsl:choose>
			</a>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="m:revisiondesc">
		<xsl:apply-templates select="m:change[normalize-space(m:date)!=''][last()]" mode="last"/>
	</xsl:template>

	<xsl:template match="m:revisiondesc/m:change" mode="last">
		<div class="latest_revision"> 
			<br/>Last changed 
			<xsl:value-of select="m:date"/>
			<xsl:if test="normalize-space(m:respstmt/m:persname)">
				by <i><xsl:value-of select="m:respstmt/m:persname"/></i>
			</xsl:if>
		</div>
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
				<span class="alternative_language">[<xsl:value-of select="@xml:lang"/>:] <xsl:apply-templates select="."
					/></span>
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


	<!-- change date format from YYYY-MM-DD to D.M.YYYY -->
	<!-- "??"-wildcards (e.g. "20??-09-??") are treated like numbers -->
	<xsl:template match="t:date|m:date">
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


	<!-- HANDLE SPECIAL CHARACTERS -->

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


	<!-- find accidental codes and other things to replace in strings -->

	<!-- add replacement data to the xml -->
	<xsl:template match="m:meihead">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
			<foo:string_replacement>
				<!-- accidentals -->
				<foo:search>
					<foo:find>[flat]</foo:find>
					<foo:replace>&lt;span class="accidental"&gt;&#x266d;&lt;/span&gt;</foo:replace>
				</foo:search>
				<foo:search>
					<foo:find>[sharp]</foo:find>
					<foo:replace>&lt;span class="accidental"&gt;&#x266f;&lt;/span&gt;</foo:replace>
				</foo:search>
				<foo:search>
					<foo:find>[dblflat]</foo:find>
					<foo:replace>&lt;span class="accidental"&gt;&#x266d;&#x266d;&lt;/span&gt;</foo:replace>
				</foo:search>
				<foo:search>
					<foo:find>[dblsharp]</foo:find>
					<foo:replace>&lt;span class="accidental"&gt;x&lt;/span&gt;</foo:replace>
				</foo:search>
				<foo:search>
					<foo:find>[natural]</foo:find>
					<foo:replace>&lt;span class="accidental"&gt;&#x266e;&lt;/span&gt;</foo:replace>
				</foo:search>
				<!-- time signatures -->
				<foo:search>
					<foo:find>[common]</foo:find>
					<foo:replace>&lt;span class="timesig"&gt;c&lt;/span&gt;</foo:replace>
				</foo:search>
				<foo:search>
					<foo:find>[cut]</foo:find>
					<foo:replace>&lt;span class="timesig"&gt;C&lt;/span&gt;</foo:replace>
				</foo:search>
				<!-- runes -->
				<foo:search>
					<foo:find>&lt;runes&gt;</foo:find>
					<foo:replace>&lt;span class="runes"&gt;</foo:replace>
				</foo:search>
				<foo:search>
					<foo:find>&lt;/runes&gt;</foo:find>
					<foo:replace>&lt;/span&gt;</foo:replace>
				</foo:search>
			</foo:string_replacement>
		</xsl:copy>
	</xsl:template>

	<!-- replace all items in replacement list -->
	<xsl:template name="replace_strings" match="@*|node()">
		<xsl:param name="input_text" select="."/>
		<xsl:param name="search">1</xsl:param>
		<xsl:variable name="replaced_text">
			<xsl:call-template name="string_replace">
				<xsl:with-param name="input_text" select="$input_text"/>
				<xsl:with-param name="find" select="document('')//foo:search[$search]/foo:find"/>
				<xsl:with-param name="replace" select="document('')//foo:search[$search]/foo:replace"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$search &lt; count(document('')//foo:search)">
				<xsl:call-template name="replace_strings">
					<xsl:with-param name="input_text" select="$replaced_text"/>
					<xsl:with-param name="search" select="$search + 1"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$replaced_text" disable-output-escaping="yes"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- standard string replace template with HTML output enabled -->
	<xsl:template name="string_replace">
		<xsl:param name="input_text"/>
		<xsl:param name="find"/>
		<xsl:param name="replace"/>
		<xsl:choose>
			<xsl:when test="contains($input_text, $find)">
				<xsl:value-of select="substring-before($input_text, $find)"/>
				<xsl:value-of select="$replace"/>
				<xsl:call-template name="string_replace">
					<xsl:with-param name="input_text" select="substring-after($input_text, $find)"/>
					<xsl:with-param name="find" select="$find"/>
					<xsl:with-param name="replace" select="$replace"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$input_text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
