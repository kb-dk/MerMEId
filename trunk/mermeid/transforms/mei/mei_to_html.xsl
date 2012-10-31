<?xml version="1.0" encoding="UTF-8"?>

<!-- 
	Conversion of MEI metadata to HTML using XSLT 1.0
	
	Authors: 
	Axel Teich Geertinger & Sigfrid Lundberg
	Danish Centre for Music Publication
	The Royal Library, Copenhagen
	
-->

<xsl:stylesheet version="1.0" 
	xmlns="http://www.w3.org/1999/xhtml" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:m="http://www.music-encoding.org/ns/mei" 
	xmlns:t="http://www.tei-c.org/ns/1.0"
	xmlns:dcm="http://www.kb.dk/dcm"
	xmlns:xl="http://www.w3.org/1999/xlink" 
	xmlns:foo="http://www.kb.dk/foo" 
	xmlns:exsl="http://exslt.org/common"
	xmlns:java="http://xml.apache.org/xalan/java"
	extension-element-prefixes="exsl java"
	exclude-result-prefixes="m xsl exsl foo java">
	
	<xsl:output 
		method="xml" 
		encoding="UTF-8"
		omit-xml-declaration="yes"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:param name="hostname"/>
	
	<!-- GLOBAL VARIABLES -->
	<!-- preferred language in titles and other multilingual fields -->
	<xsl:variable name="preferred_language">none</xsl:variable>
	<xsl:variable name="settings" select="document(concat('http://',$hostname,'/editor/forms/mei/mermeid_configuration.xml'))" />
	
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
		
		<script type="text/javascript">
			//<xsl:comment> 
				<![CDATA[ 
      var openness = new Array();

      function toggle(id) {
          var img  = document.getElementById("img" + id);
          var para = document.getElementById("p"   + id);
	  if(id in openness && openness[id]) {
	      para.title = "Click to open";
	      img.alt = "+";
	      img.src = "/editor/images/plus.png";
	      hide(id);
	      openness[id] = false;
	  } else if(id in openness && !openness[id]) {
	      para.title = "Click to close";
	      img.alt = "-";
	      img.src = "/editor/images/minus.png";
	      show(id);
	      openness[id] = true;
	  } else {
	      para.title = "Click to open";
	      img.alt = "+";
	      img.src = "/editor/images/plus.png";
	      show(id);
	      openness[id] = true;
	  }
      }

      function show(id) {
	  	var e = document.getElementById(id);
	  	e.style.display = 'block';
      }
      
      function hide(id) {
	  	var e = document.getElementById(id);
	  	e.style.display = 'none';
      }
      
      function loadcssfile(filename){
 		var fileref=document.createElement("link");
  		fileref.setAttribute("rel", "stylesheet");
  		fileref.setAttribute("type", "text/css");
  		fileref.setAttribute("href", filename);
 		if (typeof fileref!="undefined") document.getElementsByTagName("head")[0].appendChild(fileref);
	  }

	  function removecssfile(filename){
 		var allsuspects=document.getElementsByTagName("link");
 		for (var i=allsuspects.length; i>=0; i--){ //search backwards within nodelist for matching elements to remove
  			if (allsuspects[i] && allsuspects[i].getAttribute("href")!=null && allsuspects[i].getAttribute("href").indexOf(filename)!=-1)
			   allsuspects[i].parentNode.removeChild(allsuspects[i]) //remove element by calling parentNode.removeChild()
 		}
	  }

      ]]>
      // </xsl:comment>
		</script>
	</xsl:template>
		
	<xsl:template name="make_html_body" xml:space="default">
		<!-- main identification -->
		
		<xsl:variable name="file_context">
			<xsl:value-of 
				select="m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type='file_collection']"/>
		</xsl:variable>
		
		<xsl:variable name="catalogue_no">
			<xsl:value-of select="m:meiHead/m:workDesc/m:work/m:identifier[@type=$file_context]"/>
		</xsl:variable>
		
		<xsl:if test="m:meiHead/m:workDesc/m:work/m:identifier[@type=$file_context]/text()">
			<div class="series_header {$file_context}">
				<a>
					<xsl:value-of select="$file_context"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="$catalogue_no"/>
				</a>
			</div>
		</xsl:if>
		
		<div class="settings colophon">
			<a href="javascript:loadcssfile('/editor/style/html_hide_languages.css'); hide('load_alt_lang_css'); show('remove_alt_lang_css')" id="load_alt_lang_css">Hide alternative languages</a>
			<a style="display:none" href="javascript:removecssfile('/editor/style/html_hide_languages.css'); hide('remove_alt_lang_css'); show('load_alt_lang_css')" id="remove_alt_lang_css">Show alternative languages</a>
		</div>
		
		<xsl:for-each 
			select="m:meiHead/
			m:workDesc/
			m:work/
			m:titleStmt/m:respStmt">
			<xsl:for-each select="m:persName[@role='composer']">
				<p>
					<xsl:apply-templates select="."/>
				</p>
			</xsl:for-each>
		</xsl:for-each>
		
		<xsl:for-each 
			select="m:meiHead/
			m:workDesc/
			m:work/
			m:titleStmt">
			
			<xsl:if test="m:title[@type='main' or not(@type)][text()]">
				<h1>
					<xsl:for-each select="m:title[@type='main' or not(@type)][text()]">
						<xsl:element name="span">
							<xsl:call-template name="maybe_print_lang"/>
							<xsl:apply-templates select="."/>
						</xsl:element>
						<xsl:call-template name="maybe_print_br" />
						
					</xsl:for-each>
				</h1>
			</xsl:if>
			
			<xsl:if 
				test="m:title[@type='alternative'][text()] |
				m:title[@type='uniform'][text()]     |
				m:title[@type='original'][text()]    |
				m:title[@type='subordinate'][text()]">
				
				<xsl:element name="h2">
					
					<xsl:for-each select="m:title[@type='uniform'][text()]">
						<xsl:element name="span">
							<xsl:call-template name="maybe_print_lang"/>
							<xsl:apply-templates select="."/>
						</xsl:element>
						<xsl:call-template name="maybe_print_br" />
					</xsl:for-each>
					
					<xsl:for-each select="m:title[@type='original'][text()]">
						<xsl:element name="span">
							<xsl:call-template name="maybe_print_lang"/>
							<xsl:apply-templates select="."/>
						</xsl:element>
						<xsl:call-template name="maybe_print_br" />
					</xsl:for-each>
					
					<xsl:for-each select="m:title[@type='subordinate'][text()]">
						<xsl:element name="span">
							<xsl:call-template name="maybe_print_lang"/>
							<xsl:apply-templates select="."/>
						</xsl:element>
						<xsl:call-template name="maybe_print_br" />
					</xsl:for-each>
					
					<xsl:for-each select="m:title[@type='alternative'][text()]">
						<xsl:element name="span">
							<xsl:call-template name="maybe_print_lang"/>
							(<xsl:apply-templates select="."/>)
						</xsl:element>
						<xsl:call-template name="maybe_print_br" />
					</xsl:for-each>
				</xsl:element>
				
			</xsl:if>			
		</xsl:for-each>
		
		
		<!-- other identifiers -->
		<xsl:if test="m:meiHead/m:workDesc/m:work/m:identifier/text()">
			<p>
				<xsl:for-each select="m:meiHead/m:workDesc/m:work/m:identifier[text()]">
					<xsl:value-of 
						select="concat(@type,' ',.)"/><xsl:if test="position()&lt;last()"><br/></xsl:if>
				</xsl:for-each>
			</p>
		</xsl:if>
		
		<xsl:for-each 
			select="m:meiHead/
			m:workDesc/
			m:work/
			m:titleStmt/
			m:respStmt[m:persName]">
			<p>
				<xsl:for-each select="m:persName[text()][@role!='composer']">
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
					<xsl:apply-templates select="."/><br/>
				</xsl:for-each>
			</p>
		</xsl:for-each>
		
		<xsl:for-each select="m:meiHead/m:workDesc/m:work/m:titleStmt/m:title[@type='text_source'][text()]">
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
		
		<xsl:for-each 
			select="m:meiHead/
			m:workDesc/
			m:work/
			m:notesStmt">
			<xsl:if test="m:annot[@type='general_description']">
				<p>
					<xsl:apply-templates select="m:annot[@type='general_description']"/>
				</p>
			</xsl:if>			
			<xsl:for-each select="m:annot[@type='links'][m:ptr[@target!='']]">
				<p><img src="/editor/images/html_link.png" title="Link to external resource"/>
					<xsl:for-each select="m:ptr[@target!='']">
						<xsl:element name="a">
							<xsl:attribute name="href">
								<xsl:value-of select="@target"/>
							</xsl:attribute>
							<xsl:apply-templates select="@xl:title"/>
							<xsl:if test="not(@xl:title) or @xl:title=''">
								<xsl:value-of select="@target"/>
							</xsl:if>
						</xsl:element>
					</xsl:for-each>
				</p>
			</xsl:for-each>
		</xsl:for-each>
		
		<!-- related files -->
		<xsl:apply-templates select="m:meiHead/m:workDesc/m:work/m:relationList" mode="external"/>

		<!-- show work history and global sources first if more than one version -->
		<xsl:if test="count(m:meiHead/m:workDesc/m:work/m:expressionList/m:expression)&gt;1">
			
			<!-- work history -->
			<xsl:apply-templates 
				select="m:meiHead/
				m:workDesc/
				m:work/
				m:history[m:creation[*/text()] or m:p[text()] or m:eventList[m:event/*//text()]]"/>
			
			<!-- global sources -->
			<xsl:if test="count(m:meiHead/m:workDesc/m:work/m:expressionList/m:expression)&lt;2
				or count(m:meiHead/m:fileDesc/m:sourceDesc/m:source[not(m:relationList/m:relation[@rel='isEmbodimentOf']/@target)])&gt;0">
				<xsl:apply-templates 
					select="m:meiHead[count(m:workDesc/m:work/m:expressionList/m:expression)&lt;2]/
					m:fileDesc/
					m:sourceDesc[normalize-space(*//text()) or m:source/@target!='']"/>
			</xsl:if>
		</xsl:if>
		

		<!-- top-level expression (versions and one-movement work details) -->
		<xsl:for-each select="m:meiHead/
			m:workDesc/
			m:work/
			m:expressionList/
			m:expression">
			<!-- show title/tempo/number as heading only if more than one version -->
			<xsl:apply-templates select="m:titleStmt[count(../../m:expression)&gt;1]">
				<xsl:with-param name="tempo">
					<xsl:apply-templates select="m:tempo"/>
				</xsl:with-param>
			</xsl:apply-templates>			
			
			<!-- performers -->
			<xsl:apply-templates select="m:perfMedium[*//m:instrVoice/text()]"/>
			
			<!-- meter, key, incipit – only relevant at this level in single movement works -->
			<xsl:apply-templates select="m:tempo[text()]"/>
			<xsl:apply-templates select="m:meter[normalize-space(concat(@count,@unit,@sym))]"/>
			<xsl:apply-templates select="m:key[normalize-space(concat(@pname,@accid,@mode))]"/>
			<xsl:apply-templates select="m:incip"/>			
			
			<!-- external links -->
			<xsl:for-each select="m:relationList[m:relation[@target!='']]">
				<p><xsl:text>Related resources: </xsl:text>
					<xsl:for-each select="m:relation[@target!='']">
						<img src="/editor/images/html_link.png" title="Link to external resource"/>
						<xsl:element name="a">
							<xsl:attribute name="href">
								<xsl:apply-templates select="@target"/>
							</xsl:attribute>
							<xsl:apply-templates select="@label"/>
							<xsl:if test="not(@label) or @label=''"><xsl:value-of select="@target"/></xsl:if>
						</xsl:element>
						<xsl:if test="position()&lt;last()">, </xsl:if>
					</xsl:for-each>
				</p>
			</xsl:for-each>
			
			<!-- components (movements) -->
			<xsl:for-each select="m:componentGrp[normalize-space(*//text()[1]) or *//@n!='' or *//@pitch!='' or *//@symbol!='' or *//@count!='']">
				
				<xsl:variable name="mdiv_id" 
					select="concat('movements',generate-id(),position())"/>
				
				<div class="fold">
					
					<p class="p_heading" 
						id="p{$mdiv_id}"
						onclick="toggle('{$mdiv_id}')"
						title="Click to open">
						
						<xsl:text>
						</xsl:text><script type="application/javascript"><xsl:text>
							openness["</xsl:text><xsl:value-of select="$mdiv_id"/><xsl:text>"]=false;
							</xsl:text></script>
						<xsl:text>
						</xsl:text>
						
						<img 
							class="noprint" 
							style="display:inline;" 
							id="img{$mdiv_id}"
							border="0" 
							src="/editor/images/plus.png" alt="-"/> Music
					</p>
					
					<div class="folded_content" style="display:none" id="{$mdiv_id}">						
						<xsl:apply-templates select="m:expression"/>
					</div>
					
				</div>			
			</xsl:for-each>
			
			<!-- version history -->	
			<xsl:if test="count(/m:mei/m:meiHead/m:workDesc/m:work/m:expressionList/m:expression)&gt;1">
			<xsl:apply-templates 
				select="m:history[m:creation[*/text()] or m:p[text()] or m:eventList[m:event[*//text()]]]"/>
			</xsl:if>
			
			<!-- version-specific sources -->
			<xsl:if test="count(../m:expression)&gt;1">
				<xsl:variable name="expression_id" select="@xml:id"/>
				<xsl:for-each 
					select="/m:mei/m:meiHead/m:fileDesc/
					m:sourceDesc[(normalize-space(*//text()) or m:source/@target!='') 
					and m:source/m:relationList/m:relation[@rel='isEmbodimentOf' and substring-after(@target,'#')=$expression_id]]">
					<xsl:variable name="source_id" 
						select="concat('version_source',generate-id(.),$expression_id)"/>
					
					<div class="fold">
						<xsl:text>
						</xsl:text><script type="application/javascript"><xsl:text>
							openness["</xsl:text><xsl:value-of select="$source_id"/><xsl:text>"]=false;
							</xsl:text></script>
						<xsl:text>
						</xsl:text>
						<p class="p_heading" 
							id="p{$source_id}"
							title="Click to open" 
							onclick="toggle('{$source_id}')">
							<img class="noprint" 
								style="display:inline;" 
								border="0" 
								id="img{$source_id}"
								alt="+"
								src="/editor/images/plus.png"/>
							Sources
						</p>
						
						<div  id="{$source_id}" style="display:none;" class="folded_content">
							<!-- skip reproductions (=reprints) -->
							<xsl:for-each select="m:source[m:relationList/m:relation[@rel='isEmbodimentOf' 
								and substring-after(@target,'#')=$expression_id] and 
								not(m:relationList/m:relation[@rel='isReproductionOf'])]">
								<xsl:choose>
									<xsl:when test="@target!=''">
										<!-- get external source description -->
										<xsl:variable name="ext_id" select="substring-after(@target,'#')"/>
										<xsl:variable name="doc_name" select="concat('http://',$hostname,'/',$settings/dcm:parameters/dcm:document_root,substring-before(@target,'#'))"/>
										<xsl:variable name="doc" select="document($doc_name)"/>
										<xsl:apply-templates select="$doc/m:mei/m:meiHead/m:fileDesc/m:sourceDesc/m:source[@xml:id=$ext_id]"/>
									</xsl:when>
									<xsl:when test="m:titleStmt/m:title/text()">
										<xsl:apply-templates select="."/>
									</xsl:when>
								</xsl:choose>
							</xsl:for-each>
						</div>
					</div>
				</xsl:for-each>
			</xsl:if>
			
		</xsl:for-each>
		<!-- end top-level expressions (versions) -->
		
		<!-- show work history and global sources _after_ movements if only one version -->
		<xsl:if test="count(m:meiHead/m:workDesc/m:work/m:expressionList/m:expression)&lt;2">
		
			<!-- work history -->		
			<xsl:apply-templates 
				select="m:meiHead/
				m:workDesc/
				m:work/
				m:history[m:creation[//text()] or m:p[text()] or m:eventList[m:event[*//text()]]]"/>
			
			<!-- global sources -->
			<xsl:if test="count(m:meiHead/m:workDesc/m:work/m:expressionList/m:expression)&lt;2
				or count(m:meiHead/m:fileDesc/m:sourceDesc/m:source[not(m:relationList/m:relation[@rel='isEmbodimentOf']/@target)])&gt;0">
			<xsl:apply-templates 
				select="m:meiHead[count(m:workDesc/m:work/m:expressionList/m:expression)&lt;2]/
				m:fileDesc/
				m:sourceDesc[normalize-space(*//text()) or m:source/@target!='']"/>
			</xsl:if>
			
		</xsl:if>
		
		<!-- bibliography -->
		<xsl:apply-templates 
			select="m:meiHead/
			m:fileDesc/
			m:notesStmt/
			m:annot[@type='bibliography']/
			t:listBibl[t:bibl/*[text()]]"/>		
		
		
		<!-- colophon -->
		<div class="colophon">
			<br/>
			<hr/>
			<xsl:if test="m:meiHead/m:fileDesc/m:titleStmt/m:title[text()]">
				<p><em>File title:</em><br/></p> 
				<p>
					<xsl:value-of select="m:meiHead/m:fileDesc/m:titleStmt/m:title[text()][1]"/>
				</p>
			</xsl:if>
			<xsl:if test="m:meiHead/m:fileDesc/m:seriesStmt/m:title/text()">
				<p><em>Series:</em><br/></p> 
				<p>
					<xsl:for-each select="m:meiHead/m:fileDesc/m:seriesStmt/m:title">
						<xsl:value-of select="."/>
						<xsl:for-each select="../identifier[normalize-space(@type) and @type!='file_collection' and text()]">
							<br/><xsl:value-of select="@type"/><xsl:text> </xsl:text><xsl:value-of select="."/>
						</xsl:for-each>
						<xsl:if test="position()!=last()"><br/></xsl:if>
					</xsl:for-each>
				</p>
			</xsl:if>
			<xsl:if test="m:meiHead/m:fileDesc/m:pubStmt/m:respStmt//text()">
				<p><em>File publication:</em></p>
				<p>
					<xsl:value-of select="m:meiHead/m:fileDesc/m:pubStmt/m:respStmt/m:corpName/m:expan"/>
					<xsl:choose>
						<xsl:when test="m:meiHead/m:fileDesc/m:pubStmt/m:respStmt/m:corpName/m:expan/text()">
							(<xsl:value-of select="m:meiHead/m:fileDesc/m:pubStmt/m:respStmt/m:corpName/m:abbr"/>)
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="m:meiHead/m:fileDesc/m:pubStmt/m:respStmt/m:corpName/m:abbr"/>
						</xsl:otherwise>
					</xsl:choose>
					<br/>
					<xsl:for-each select="m:meiHead/m:fileDesc/m:pubStmt/m:respStmt/m:corpName/m:address/m:addrLine[m:ptr/@target or text()]">
						<xsl:choose>
							<xsl:when test="m:ptr/@target">
								<xsl:choose>
									<xsl:when test="m:ptr/text()"><xsl:value-of select="m:ptr/text()"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="m:ptr/@xl:title"/></xsl:otherwise>
								</xsl:choose>
								<xsl:text>: </xsl:text>
								<xsl:element name="a">
									<xsl:attribute name="href"><xsl:value-of select="m:ptr/@target"/></xsl:attribute>
									<xsl:value-of select="m:ptr/@target"/>
								</xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="."/>
							</xsl:otherwise>
						</xsl:choose>
						<br/>
					</xsl:for-each>
					<xsl:value-of select="m:meiHead/m:fileDesc/m:pubStmt/m:date"/>
				</p>
				<p>
					<xsl:for-each select="m:meiHead/m:fileDesc/m:pubStmt/m:respStmt/m:persName[text()]">
						<xsl:value-of select="."/>
						<xsl:if test="@role/text()">(<xsl:value-of select="@role"/>)</xsl:if>
						<xsl:if test="position()!=last()"><br/></xsl:if>
					</xsl:for-each>
				</p>
			</xsl:if>
			<xsl:apply-templates select="m:meiHead/m:revisionDesc"/>
		</div>
		
		<xsl:for-each select="m:meiHead/m:fileDesc/m:notesStmt/m:annot[@type='private_notes' and text()]">
			<div class="private">
				<div class="private_heading">[Private notes]</div>
				<div class="private_content"><xsl:apply-templates select="."/></div>
			</div>
		</xsl:for-each>
		
	</xsl:template>
	
	
	<!-- SUB-TEMPLATES -->
	
	<xsl:template match="m:relationList" mode="external">
		<xsl:for-each select="m:relation[@target!='']">
			<xsl:variable name="rel" select="@rel"/>
			<xsl:if test="count(preceding-sibling::*[@rel=$rel])=0">
				<!-- one <p> per relation type -->
				<p>
					<div class="p_heading">
						<xsl:choose>
							<xsl:when test="@rel='hasPart'">Contains:</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="@rel='isPartOf'">Contained in:</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="@rel='hasAlternate'">Alternate version:</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="@rel='isAlternateOf'">Alternate version of:</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="@rel='hasArrangement'">Arrangement:</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="@rel='isArrangementOf'">Arrangement of:</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="@rel='hasRevision'">Revised version:</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="@rel='isRevisionOf'">Revised version of:</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="@rel='hasImitation'">Imitation:</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="@rel='isImitationOf'">Imitation of:</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="@rel='hasTranslation'">Translated version:</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="@rel='isTranslationOf'">Translation of:</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="@rel='hasAdaptation'">Adaptation:</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="@rel='isAdaptationOf'">Adaptation of:</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="@rel='hasAbridgement'">Abridged version:</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="@rel='isAbridgementOf'">Abridged version of:</xsl:when>
						</xsl:choose>
					</div>
					<xsl:for-each select="../m:relation[@rel=$rel]">
						<xsl:element name="a">
							<xsl:attribute name="href">
								<xsl:value-of select="concat('http://',$hostname,'/storage/present.xq?doc=',@target)"/>
							</xsl:attribute>
							<xsl:apply-templates select="@label"/>
							<xsl:if test="not(@label) or @label=''">
								<xsl:value-of select="@target"/>
							</xsl:if>
						</xsl:element>
						<xsl:if test="position()!=last()"><br/></xsl:if>
					</xsl:for-each>
				</p>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	
	<xsl:template match="m:expression">
		<!-- display title etc. only with components or versions -->
		<xsl:apply-templates select="m:titleStmt[ancestor-or-self::*[local-name()='componentGrp'] or count(../m:expression)&gt;1]"/>
		<xsl:apply-templates select="m:perfMedium[m:instrumentation[m:instrVoice or m:instrVoiceGrp] or m:castList/m:castItem]" mode="subLevel"/>
		<xsl:apply-templates select="m:tempo[text()]"/>		
		<xsl:apply-templates select="m:meter[normalize-space(concat(@count,@unit,@sym))]"/>
		<xsl:apply-templates select="m:key[normalize-space(concat(@pname,@accid,@mode))]"/>
		<xsl:apply-templates select="m:incip"/>
		<xsl:apply-templates select="m:componentGrp"/>
	</xsl:template>
	
	<xsl:template match="m:expression/m:titleStmt">
		<xsl:variable name="level">
			<!-- expression headings start with <H3>, decreasing in size with each level -->
			<xsl:choose>
				<xsl:when test="ancestor-or-self::*[local-name()='componentGrp']">
					<xsl:value-of select="count(ancestor-or-self::*[local-name()='componentGrp'])+2"/>
				</xsl:when>
				<xsl:otherwise>3</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="element" select="concat('h',$level)"/>
		<xsl:if test="concat(../@n,m:title)!=''">
			<xsl:element name="{$element}">
				<xsl:choose>
					<xsl:when test="../@n!='' and m:title=''">
						<strong><xsl:value-of select="../@n"/></strong>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="m:title/text()">
							<xsl:for-each select="m:title[text()]">
								<xsl:choose>
									<xsl:when test="position()&gt;1">
										<span class="alternative_language">
											<xsl:text>[</xsl:text><xsl:value-of select="@xml:lang"/><xsl:text>] </xsl:text>
											<xsl:apply-templates/>
											<xsl:if test="position()&lt;last()"><br/></xsl:if>
										</span>
									</xsl:when>
									<xsl:otherwise>
										<strong>
											<xsl:value-of select="../@n"/>
											<xsl:if test="../@n!=''"><xsl:text>. </xsl:text></xsl:if>
											<xsl:apply-templates/>
											<xsl:if test="position()&lt;last()"><br/></xsl:if>
										</strong>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
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
				
				<xsl:variable name="mdiv_id" 
					select="concat('subsection',../../@xml:id,generate-id(),position())"/>
				
				<div class="fold">
					<p class="p_heading" 
						id="p{$mdiv_id}"
						onclick="toggle('{$mdiv_id}')"
						title="Click to open">
						<xsl:text>
						</xsl:text><script type="application/javascript"><xsl:text>
							openness["</xsl:text><xsl:value-of select="$mdiv_id"/><xsl:text>"]=false;
							</xsl:text></script>
						<xsl:text>
						</xsl:text>
						<img 
							class="noprint" 
							style="display:inline;" 
							id="img{$mdiv_id}"
							border="0" 
							src="/editor/images/plus.png" alt="-"/> Sections
						
					</p>
					<div class="folded_content" style="display:none" id="{$mdiv_id}">						
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
					</div>
				</div>	
				<!-- end test -->				
				
				
			</xsl:when>
			<xsl:otherwise>
				<ul class="single_movement">
					<li>
						<xsl:apply-templates select="m:expression"/>
					</li>
				</ul>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	
	<xsl:template match="m:incip">
		<xsl:for-each select="m:incipCode[text()]">
			<p>
				<span class="label">
					<xsl:choose>
						<xsl:when test="normalize-space(@analog)"><xsl:value-of select="@analog"/>: </xsl:when>
						<xsl:otherwise>Music incipit: </xsl:otherwise>
					</xsl:choose>
				</span>
				<xsl:apply-templates select="."/>
			</p>
		</xsl:for-each>
		<xsl:if test="normalize-space(m:graphic[@targettype='lowres']/@target)!=''">
			<p>
				<xsl:choose>
					<xsl:when test="m:graphic[@targettype='lowres']/@target and m:graphic[@targettype='hires']/@target">
						<a target="incipit" 
							title="Click to enlarge image" 
							style="text-decoration: none;">
							<xsl:attribute name="href">
								<xsl:value-of select="m:graphic[@targettype='hires']/@target"/>
							</xsl:attribute>
							<xsl:attribute name="onclick">
								window.open("<xsl:value-of select="m:graphic[@targettype='hires']/@target" />","incipit","height=550,width=1250,toolbar=0,status=0,menubar=0,resizable=1,location=0,scrollbars=1");return false;
							</xsl:attribute>
							<xsl:element name="img">
								<xsl:attribute name="border">0</xsl:attribute>
								<xsl:attribute name="style">text-decoration: none;</xsl:attribute>
								<xsl:attribute name="alt"></xsl:attribute>
								<xsl:attribute name="src"> 
									<xsl:value-of select="m:graphic[@targettype='lowres']/@target" />
								</xsl:attribute>
							</xsl:element>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="img">
							<xsl:attribute name="border">0</xsl:attribute>
							<xsl:attribute name="style">text-decoration: none;</xsl:attribute>
							<xsl:attribute name="alt"></xsl:attribute>
							<xsl:attribute name="src"> 
								<xsl:value-of select="m:graphic[@targettype='lowres']/@target" />
							</xsl:attribute>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</p>
		</xsl:if>
		<xsl:apply-templates select="m:score"/>
		<xsl:variable name="text_incipit"><xsl:value-of select="m:incipText"/></xsl:variable>
		<xsl:if test="normalize-space($text_incipit)">
			<p>
				<xsl:for-each select="m:incipText/m:p[text()]">
					<xsl:if test="position() = 1"><span class="label">Text incipit: </span></xsl:if>
					<xsl:element name="span">
						<xsl:call-template name="maybe_print_lang"/>
						<xsl:apply-templates/>
					</xsl:element>
					<xsl:if test="position() &lt; last()"><br/></xsl:if>
				</xsl:for-each>
			</p>
		</xsl:if>	
	</xsl:template>
	
	<xsl:template match="m:incip/m:score"/>
	
	<xsl:template match="m:meter">
		<p>
			<xsl:if test="position() = 1"><span class="label">Metre: </span></xsl:if>
			<xsl:choose>
				<xsl:when test="@count!='' and @unit!=''">
					<span class="meter"><xsl:value-of select="concat(@count,'/',@unit)"/></span>
				</xsl:when>
				<xsl:otherwise>
					<span class="timesig">
						<xsl:choose>
							<xsl:when test="@sym='common'">c</xsl:when>
							<xsl:when test="@sym='cut'">C</xsl:when>
						</xsl:choose>
					</span>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="position()=last()"><br/></xsl:if>
		</p>
	</xsl:template>
	
	<xsl:template match="m:key[@pname or @accid or @mode]">
		<p>
			<span class="label">Key: </span>
			<xsl:value-of select="translate(@pname,'abcdefgh','ABCDEFGH')"/> 
			<xsl:if test="@accid"><xsl:call-template name="key_accidental">
				<xsl:with-param name="attr" select="@accid"/>
			</xsl:call-template></xsl:if><xsl:text> </xsl:text>
			<xsl:value-of select="@mode"/>
		</p>
	</xsl:template>
	
	<xsl:template match="m:tempo">
		<xsl:variable name="level">
			<!-- expression headings start with <H3>, decreasing in size with each level -->
			<xsl:choose>
				<xsl:when test="ancestor-or-self::*[local-name()='componentGrp']">
					<xsl:value-of select="count(ancestor-or-self::*[local-name()='componentGrp'])+2"/>
				</xsl:when>
				<xsl:otherwise>3</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="element" select="concat('h',$level)"/>
		<xsl:choose>
			<xsl:when test="../@n!='' or ../m:titleStmt/m:title!=''">
				<p><span class="label">Tempo: </span><xsl:apply-templates/></p>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="{$element}">
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- work-related templates -->
	
	<!-- perfMedium templates -->
	<xsl:template match="m:perfMedium">
		<xsl:param name="full" select="true()"/>
		<xsl:for-each select="m:instrumentation[*]">
			<p>
				<xsl:if test="position()=1 and $full">
					<span class="label">Instrumentation: </span><br/>
				</xsl:if>
				<xsl:apply-templates select="m:instrVoiceGrp"/>
				<xsl:apply-templates select="m:instrVoice[not(@solo='true')][text()]"/>
				<xsl:if test="count(m:instrVoice[@solo='true'])&gt;0">
					<xsl:if test="count(m:instrVoice[not(@solo='true')])&gt;0">
						<br/>
					</xsl:if>
					<span class="p_heading:">Soloist<xsl:if test="count(m:instrVoice[@solo='true'])&gt;1">s</xsl:if>:</span>
					<xsl:apply-templates select="m:instrVoice[@solo='true'][text()]"/>
				</xsl:if>
			</p>
		</xsl:for-each>
		<xsl:apply-templates select="m:castList[*//text()]">
			<xsl:with-param name="full" select="$full"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="m:instrVoiceGrp">
		<xsl:if test="m:head[text()]">
			<xsl:value-of select="m:head"/>
			<xsl:if test="m:instrVoice[text()]"><xsl:text>:</xsl:text></xsl:if>
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:for-each select="m:instrVoice[text()]">
			<xsl:apply-templates select="."/><xsl:if 
				test="position()&lt;last()"><xsl:text>, </xsl:text></xsl:if>
		</xsl:for-each>
		<br/>
	</xsl:template>
	
	<xsl:template match="m:instrVoice">
		<xsl:if test="@count &gt; 1">
			<xsl:apply-templates select="@count"/>
		</xsl:if>
		<xsl:text> </xsl:text>
		<xsl:apply-templates/><xsl:if 
			test="position()&lt;last()"><xsl:text>, 
		</xsl:text></xsl:if>
	</xsl:template>

	<xsl:template match="m:castList">
		<xsl:param name="full" select="true()"/>
		<p>
			<xsl:if test="$full">
				<span class="label">Roles: </span>
			</xsl:if>
			<xsl:for-each select="m:castItem/m:role/m:name[count(@xml:lang[.=ancestor-or-self::m:castItem/preceding-sibling::*//@xml:lang])=0 or not(@xml:lang)]">
				<!-- iterate over languages -->
				<xsl:variable name="lang" select="@xml:lang"/>
				<xsl:element name="span">
					<xsl:call-template name="maybe_print_lang"/>
					<xsl:apply-templates select="../../../../m:castList" mode="castlist">
						<xsl:with-param name="lang" select="$lang"/>
						<xsl:with-param name="full" select="$full"></xsl:with-param>
					</xsl:apply-templates>
				</xsl:element>
				<xsl:if test="position() &lt; last()"><br/></xsl:if>
			</xsl:for-each>
		</p>
	</xsl:template>
	
	<xsl:template match="m:castList" mode="castlist">
		<xsl:param name="lang" select="'en'"/>
		<xsl:param name="full" select="true()"></xsl:param>
		<xsl:for-each select="m:castItem/m:role/m:name[@xml:lang=$lang]">
			<xsl:apply-templates select="."/><xsl:if test="$full"><xsl:apply-templates 
				select="../../m:roleDesc[@xml:lang=$lang]"/><xsl:for-each 
					select="../../m:instrVoice[text()]"> (<xsl:value-of select="."/>)</xsl:for-each></xsl:if><xsl:if 
				test="position() &lt; last()"><xsl:text>; </xsl:text></xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="m:roleDesc">
			<xsl:if test="normalize-space(.)">, <xsl:value-of select="."/></xsl:if>
	</xsl:template>

	<xsl:template match="m:perfMedium" mode="subLevel">
		<xsl:variable name="topLevelInstrumentation" select="ancestor-or-self::m:expression[local-name(../..)='work']/m:perfMedium/m:instrumentation"/>
		<xsl:variable name="thisExpressionId" select="parent::node()/@xml:id"/>
		<!-- create a <perfMedium> result tree containing a copy of the performers referenced in this movement -->
		<xsl:variable name="perfMedium">			
			<xsl:element name="perfMedium" namespace="http://www.music-encoding.org/ns/mei">
				<xsl:element name="instrumentation" namespace="http://www.music-encoding.org/ns/mei">
					<xsl:variable name="instrVoiceGrps" select="$topLevelInstrumentation/m:instrVoiceGrp[@xml:id=/*//m:expression[@xml:id=$thisExpressionId]/m:perfMedium//m:instrVoiceGrp/@n]"/>
					<xsl:for-each select="$instrVoiceGrps">
						<xsl:element name="instrVoiceGrp" namespace="http://www.music-encoding.org/ns/mei">
							<xsl:copy-of select="m:head"/>
							<xsl:copy-of select="m:instrVoice[text()][@xml:id=/*//m:expression[@xml:id=$thisExpressionId]/m:perfMedium//m:instrVoice/@n]"/>
						</xsl:element>
					</xsl:for-each>
					<xsl:copy-of select="$topLevelInstrumentation/m:instrVoice[text()][@xml:id=/*//m:expression[@xml:id=$thisExpressionId]/m:perfMedium/m:instrumentation/m:instrVoice/@n]"/>
				</xsl:element>
				<xsl:element name="castList" namespace="http://www.music-encoding.org/ns/mei">
					<xsl:variable name="topLevelCastList" select="ancestor-or-self::m:expression[local-name(../..)='work']/m:perfMedium/m:castList"/>
					<xsl:copy-of select="$topLevelCastList/m:castItem[//text()][@xml:id=/*//m:expression[@xml:id=$thisExpressionId]/m:perfMedium/m:castList/m:castItem/@n]"/>
				</xsl:element>
			</xsl:element>
		</xsl:variable>
		<xsl:apply-templates select="exsl:node-set($perfMedium)/m:perfMedium">
			<xsl:with-param name="full" select="false()"/>
		</xsl:apply-templates>
	</xsl:template>
	<!-- end perfMedium -->
	
	<!-- history -->		
	<xsl:template match="m:history[*//text()]">
		<xsl:variable 
			name="historydiv_id" 
			select="concat('history',generate-id(.),position())"/>
		<xsl:text>
		</xsl:text>
		<script type="application/javascript"><xsl:text>
			openness["</xsl:text><xsl:value-of select="$historydiv_id"/><xsl:text>"]=false;
			</xsl:text></script>
		<xsl:text>
		</xsl:text>
		
		<div class="fold" style="display:block;">
			<p class="p_heading" 
				id="p{$historydiv_id}"
				title="Click to open"
				onclick="toggle('{$historydiv_id}')">
				<img 
					id="img{$historydiv_id}"
					class="noprint" 
					style="display:inline" 
					border="0" 
					src="/editor/images/plus.png" 
					alt="+"/> History
			</p>				
			<div class="folded_content" id="{$historydiv_id}" style="display:none;">
				
				<!-- composition history -->
				<xsl:for-each select="m:creation/m:date[text()]">
					<xsl:if test="position()=1">
						<p><span class="p_heading">
							Date of composition: 
						</span>
							<xsl:apply-templates/>.
						</p>
					</xsl:if>
				</xsl:for-each>		
				<xsl:for-each select="m:p[text()]">
					<p><xsl:apply-templates/></p>
				</xsl:for-each>		
				<xsl:for-each select="m:eventList[@type='history' and m:event[m:date/text() | m:title/text()]]">
					<table>
						<xsl:for-each select="m:event[m:date/text() | m:title/text()]">
							<tr>
								<td nowrap="nowrap">
									<xsl:apply-templates select="m:date"/>
								</td>
								<td>
									<xsl:apply-templates select="m:title"/>
								</td>
							</tr>
						</xsl:for-each>
					</table>
				</xsl:for-each>
				<!-- performances -->
				<xsl:choose>
					<xsl:when test="name(parent::node())='work' and count(../m:expressionList/m:expression)=1">
						<xsl:apply-templates select="../m:expressionList/m:expression/m:history/m:eventList[@type='performances' and m:event//text()]"/>
					</xsl:when>
					<xsl:when test="name(parent::node())!='work' and count(/m:mei/m:meiHead/m:workDesc/m:work/m:expressionList/m:expression) &gt; 1">
						<xsl:apply-templates select="m:eventList[@type='performances' and m:event//text()]"/>
					</xsl:when>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template match="m:eventList[@type='performances']">
		<xsl:if test="m:event//text()">
			<div class="fold" style="display:block;">
				<p class="p_heading">Performances</p>				
				<table>
					<xsl:for-each select="m:event[//text()]">
						<xsl:apply-templates select="." mode="performance_details"/>
					</xsl:for-each>
				</table>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- sources -->
	<xsl:template match="m:sourceDesc">
		
		<xsl:variable name="source_id" 
			select="concat('source',generate-id(.),position())"/>
		
		<div class="fold">
			<xsl:text>
			</xsl:text><script type="application/javascript"><xsl:text>
				openness["</xsl:text><xsl:value-of select="$source_id"/><xsl:text>"]=false;
				</xsl:text></script>
			<xsl:text>
			</xsl:text>
			<p class="p_heading" 
				id="p{$source_id}"
				title="Click to open" 
				onclick="toggle('{$source_id}')">
				<img class="noprint" 
					style="display:inline;" 
					border="0" 
					id="img{$source_id}"
					alt="+"
					src="/editor/images/plus.png"/>
				Sources
			</p>
			
			<div  id="{$source_id}" style="display:none;" class="folded_content">
				<!-- skip reproductions (=reprints) here -->
				<xsl:for-each select="m:source[not(m:relationList/m:relation[@rel='isReproductionOf'])]">
					<xsl:choose>
						<xsl:when test="@target!=''">
							<!-- get external source description -->
							<xsl:variable name="ext_id" select="substring-after(@target,'#')"/>
							<xsl:variable name="doc_name" select="concat('http://',$hostname,'/',$settings/dcm:parameters/dcm:document_root,substring-before(@target,'#'))"/>
							<xsl:variable name="doc" select="document($doc_name)"/>
							<xsl:apply-templates select="$doc/m:mei/m:meiHead/m:fileDesc/m:sourceDesc/m:source[@xml:id=$ext_id]"/>
						</xsl:when>
						<xsl:when test="m:titleStmt/m:title/text()">
							<xsl:apply-templates select="."/>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</div>
		</div>
	</xsl:template>
	
	<!-- performance-related templates -->
	
	<!-- performance details -->
	<xsl:template match="m:event" mode="performance_details">
		<tr>
			<td nowrap="nowrap">
				<xsl:apply-templates select="m:date"/>
			</td>
			<td>
				<xsl:for-each select="m:geogName[text()]">
					<xsl:apply-templates select="."/>
					<xsl:if test="position() &lt; last()">, </xsl:if>
					<xsl:if test="position()=last() and count(../m:corpName[text()]|../m:persName[text()])=0">. </xsl:if>
				</xsl:for-each>
				<xsl:for-each select="m:corpName[text()]|
					m:persName[text()]">
					<xsl:if test="position()=1"> (</xsl:if>
					<xsl:choose>
						<xsl:when test="@role='conductor'">conducted by </xsl:when>
						<xsl:when test="@role='soloist'">
							<xsl:if test="not(preceding-sibling::m:persName[@role='soloist'])">
								<xsl:choose>
									<xsl:when 
										test="count(following-sibling::m:persName[@role='soloist'])&gt;1">
										<xsl:text>soloists: </xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>soloist: </xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
						</xsl:when>
					</xsl:choose>
					<xsl:apply-templates select="."/>
					<xsl:choose>
						<xsl:when test="position() = last()"><xsl:text>). </xsl:text></xsl:when>
						<xsl:otherwise>, </xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				
				<xsl:if test="m:title[text()] and m:title!='Other performance'">
					<xsl:apply-templates select="m:title"/>.<xsl:text> </xsl:text>
				</xsl:if>
				
				<xsl:if test="@evidence!=''">
					<xsl:variable name="evidence" select="@evidence"/>
					[Evidence: 
					<xsl:apply-templates select="/m:mei/m:meiHead//*[@xml:id=$evidence]"/>]
				</xsl:if>
				
				<xsl:for-each select="t:listBibl">
					
					<xsl:variable name="no_of_reviews"
						select="count(t:bibl[t:title/text()])"/>
					<xsl:if test="$no_of_reviews &gt; 0">
						<xsl:choose>
							<xsl:when test="$no_of_reviews = 1">
								<br/>Review: </xsl:when>
							<xsl:otherwise>
								<br/>Reviews: </xsl:otherwise>
						</xsl:choose>
						<xsl:for-each select="t:bibl[t:title/text()]">
							<xsl:apply-templates select="."/>
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
			<p>
				<xsl:for-each select="m:respStmt/m:persName[text()] |
					m:respStmt/m:corpName[text()]">
					<xsl:if test="string-length(@role) &gt; 0">
						<xsl:call-template name="capitalize">
							<xsl:with-param name="str" select="@role"/>
						</xsl:call-template><xsl:text>: </xsl:text>
					</xsl:if>
					<xsl:value-of select="."/>
					<xsl:choose>
						<xsl:when test="position() &lt; last()"><xsl:text>, </xsl:text></xsl:when>
						<xsl:otherwise><xsl:text>. </xsl:text></xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				
				<xsl:for-each select="m:geogName[text()] | 
					m:date[text()] |
					m:identifier[text()]">
					<xsl:if test="string-length(@type) &gt; 0">
						<xsl:value-of select="@type"/><xsl:text>: </xsl:text>
					</xsl:if>
					<xsl:value-of select="."/>
					<xsl:choose>
						<xsl:when test="position() &lt; last()"><xsl:text>, </xsl:text></xsl:when>
						<xsl:otherwise><xsl:text>. </xsl:text></xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				<xsl:text>
				</xsl:text>
			</p>
		</xsl:if>
	</xsl:template>
	
	<!-- source-related templates -->
	
	<xsl:template match="m:source|m:item">
		<xsl:param name="mode" select="''"/>
		<xsl:variable name="source_id" select="@xml:id"/>
		<xsl:if test="m:titleStmt/m:title/text() 
			or local-name()='item'
			or m:relationList/m:relation[@rel='isReproductionOf']">
			<div>
				<xsl:attribute name="id">
					<xsl:choose>
						<xsl:when test="@xml:id"><xsl:value-of  select="@xml:id"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="generate-id(.)"/></xsl:otherwise>
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
							<xsl:value-of select="count(ancestor-or-self::*[name()='componentGrp' or name()='itemList'])+3"/>
						</xsl:when>
						<xsl:otherwise>3</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="heading_element" select="concat('h',$level)"></xsl:variable>
				<xsl:for-each select="m:titleStmt[m:title/text()]">
					<xsl:element name="{$heading_element}">
						<!-- source or item title -->
						<xsl:apply-templates select="m:title"/>
					</xsl:element>
				</xsl:for-each>
				
				<xsl:call-template name="list_agents"/>
				
				<xsl:for-each select="m:classification/m:termList[m:term[text()]]">
					<div class="classification">
						<xsl:for-each select="m:term[text()]">
							<xsl:if test="position()=1">
								[Source classification:
							</xsl:if>
							<xsl:value-of select="."/>
							<xsl:choose>    
								<xsl:when test="position()=last()">]</xsl:when>
								<xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</div>
				</xsl:for-each>
				
				<xsl:for-each select="m:titleStmt[m:respStmt/m:persName/text()]">					
					<xsl:comment> contributors </xsl:comment>
					<xsl:call-template name="list_agents"/>	
				</xsl:for-each>
				
				<xsl:for-each select="m:pubStmt[//text()]">					
					<xsl:comment>publication</xsl:comment>
					<div>
						<xsl:if test="m:respStmt/m:corpName/text()">
							<xsl:apply-templates select="m:respStmt/m:corpName"/>
							<xsl:if test="normalize-space(concat(m:date,m:geogName))">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:if>
						<xsl:apply-templates select="m:geogName"/>
						<xsl:text> </xsl:text>
						<xsl:apply-templates select="m:date"/>
						<xsl:if test="normalize-space(concat(m:respStmt/m:corpName, m:date, m:geogName))">.</xsl:if>
						<!--<xsl:call-template name="list_agents"/>-->
					</div>
				</xsl:for-each>
				
				
				<xsl:comment> physical description </xsl:comment>				
				<xsl:for-each select="m:physDesc">
					<xsl:apply-templates select="."/>
				</xsl:for-each>
				
				<xsl:for-each select="m:notesStmt">
					<xsl:for-each select="m:annot[text()]">
						<p>
							<xsl:apply-templates select="."/>	    
						</p>
					</xsl:for-each>
					<xsl:for-each select="m:annot[@type='links'][m:ptr[@target!='']]">
						<p>
							<xsl:for-each select="m:ptr[@target!='']">
								<img src="/editor/images/html_link.png" title="Link to external resource"/>
								<xsl:element name="a">
									<xsl:attribute name="href">
										<xsl:apply-templates select="@target"/>
									</xsl:attribute>
									<xsl:apply-templates select="@xl:title"/>
								</xsl:element>
							</xsl:for-each>
						</p>
					</xsl:for-each>
				</xsl:for-each>
				
				
				<!-- source location and identifiers -->
				<xsl:variable name="components" select="count(../../m:componentGrp/m:item[//text()])"/>
				<xsl:for-each 
					select="m:physDesc/m:physLoc">					
					<xsl:for-each select="m:repository[m:corpName[text()]|m:identifier[text() and (not(@type) or @type='')]]">
						<div> 
							<xsl:for-each select="m:corpName[text()]|m:identifier[text() and (not(@type) or @type='')]">
								<xsl:choose>
									<xsl:when test="name(.)='corpName'">
										<em><xsl:apply-templates select="."/></em>
										<xsl:text> </xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="."/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:if test="position()=last()"><xsl:text>. </xsl:text></xsl:if>
							</xsl:for-each>
							
							<xsl:for-each select="m:ptr[normalize-space(@target)]">
								<img src="/editor/images/html_link.png" title="Link to external resource"/>
								<xsl:element name="a">
									<xsl:attribute name="href">
										<xsl:value-of select="@target"/>
									</xsl:attribute>  
									<xsl:value-of select="@xl:title"/>
								</xsl:element>
								<xsl:choose>
									<xsl:when test="position()=last()"><xsl:text>. </xsl:text></xsl:when>
									<xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
							
						</div>					
					</xsl:for-each>
				</xsl:for-each>
				
				<xsl:for-each select="m:physDesc/m:provenance[*//text()]">
					<div>
						<xsl:text>Provenance: </xsl:text>
						<xsl:for-each select="m:eventList/m:event[*/text()]">
							<xsl:apply-templates select="m:title"/>
							<xsl:for-each select="m:date[text()]">
								<xsl:text> (</xsl:text>
								<xsl:apply-templates select="."/>
								<xsl:text>)</xsl:text>
							</xsl:for-each>.
						</xsl:for-each>
					</div>
				</xsl:for-each>
				
				<xsl:for-each select="m:identifier[text()]">
					<div>
						<xsl:apply-templates select="@type"/><xsl:text> </xsl:text>
						<xsl:choose>
							<!-- some CNW-specific styling here -->
							<xsl:when test="@type='CNU Source'">
								<b><xsl:apply-templates select="."/></b>.
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="."/>.
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</xsl:for-each>
				
				<!-- List exemplars (items) last if there is more than one or it does have a heading of its own 
					 Otherwise, this is a manuscript with some information given at item level, 
					 which should be shown before the components.
				-->
				<xsl:choose>
					<xsl:when test="local-name()='source' and 
						(count(m:itemList/m:item[//text()])&gt;1 or 
						m:itemList/m:item/m:titleStmt/m:title/text())">
						<xsl:apply-templates select="m:componentGrp"/>
						<xsl:apply-templates select="m:itemList"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="m:itemList"/>
						<xsl:apply-templates select="m:componentGrp"/>
					</xsl:otherwise>
				</xsl:choose>
				
				<!-- list reproductions (reprints) -->
				<xsl:for-each select="/*//m:source[m:relationList/m:relation[@rel='isReproductionOf'
					and substring-after(@target,'#')=$source_id]]">
					<xsl:if test="position()=1">
						<xsl:if test="not(m:titleStmt/m:title/text())">
							<p class="p_heading">Reprint:</p>
						</xsl:if>
					</xsl:if>
					<xsl:apply-templates select=".">
						<xsl:with-param name="mode">reprint</xsl:with-param>
					</xsl:apply-templates>
				</xsl:for-each>
				
			</div>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="m:itemList">		
		<xsl:choose>
			<xsl:when test="count(m:item)&gt;1 or m:item/m:titleStmt/m:title/text()">
				<ul class="item_list">
					<xsl:for-each select="m:item">
						<li>
							<xsl:apply-templates select="."/>
						</li>
					</xsl:for-each>
				</ul>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="m:item"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template match="m:source/m:componentGrp | m:item/m:componentGrp">
		<xsl:variable name="labels" select="count(m:item[@label!=''])"/>
		<xsl:choose>
			<xsl:when test="count(m:item)&gt;1">
				<table cellpadding="0" cellspacing="0" border="0" class="source_component_list">
					<xsl:for-each select="m:item">
						<tr>
							<xsl:if test="$labels &gt; 0">
								<td class="label_cell">
									<xsl:for-each select="@label">
										<p><xsl:value-of select="."/><xsl:text>: </xsl:text></p>
									</xsl:for-each>
								</td>
							</xsl:if>
							<td><xsl:apply-templates select="."/></td>
						</tr>
					</xsl:for-each>
				</table>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="m:item"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template match="m:physDesc">
		<xsl:if test="m:dimensions[text()] | m:extent[text()]">
			<p>
				<xsl:for-each select="m:dimensions[text()] | m:extent[text()]">
					<xsl:value-of select="."/><xsl:text> </xsl:text>
					<xsl:call-template name="remove_">
						<xsl:with-param name="str" select="@unit"/>
					</xsl:call-template>
					<xsl:choose><xsl:when test="position()&lt;last()"><xsl:text>,
					</xsl:text></xsl:when><xsl:otherwise><xsl:text>.
					</xsl:text></xsl:otherwise></xsl:choose>
				</xsl:for-each>
				<xsl:text>
				</xsl:text>
			</p>
		</xsl:if>
		
		<xsl:for-each select="m:titlePage[m:p/text()]">
			<p>
				<xsl:if test="not(@label) or @label=''">Title page</xsl:if>
				<xsl:apply-templates select="@label"/><xsl:text>: </xsl:text>
				<xsl:apply-templates select="m:p"/>
				<xsl:text>
				</xsl:text>
			</p>
		</xsl:for-each>
		
		<xsl:for-each select="m:plateNum[text()]">
			<p>Pl. No. <xsl:apply-templates select="."/>.</p>
		</xsl:for-each>
		
		<xsl:apply-templates select="m:handList[m:hand/@medium!='' or m:hand/text()]"/>
		
	</xsl:template>
	
	<!-- format scribe's name and medium -->
	<xsl:template match="m:hand" mode="scribe">
		<xsl:call-template name="lowercase">
			<xsl:with-param name="str" select="translate(@medium,'_',' ')"/>
		</xsl:call-template>
		<xsl:if test="./text()"> (<xsl:apply-templates select="."/>)</xsl:if></xsl:template>
	
	<!-- list scribes -->
	<xsl:template match="m:handList">
		<xsl:if test="count(m:hand[@initial='true' and (@medium!='' or text())]) &gt; 0">
			<xsl:text>Written in </xsl:text>
			<xsl:for-each select="m:hand[@initial='true' and (@medium!='' or text())]">
				<xsl:if test="position()&gt;1 and position()&lt;last()">, 
				</xsl:if>
				<xsl:if test="position()=last() and position()&gt;1"> 
					<xsl:text> and </xsl:text>
				</xsl:if>
				<xsl:apply-templates select="." mode="scribe"/></xsl:for-each>. 
		</xsl:if>
		<xsl:if test="count(m:hand[@initial='false' and (@medium!='' or text())]) &gt; 0">
			<xsl:text>Additions in </xsl:text>
			<xsl:for-each select="m:hand[@initial='false']">
				<xsl:if test="position()&gt;1 and position()&lt;last()">, 
				</xsl:if>
				<xsl:if test="position()=last() and position()&gt;1"> 
					<xsl:text> and </xsl:text>
				</xsl:if>
				<xsl:apply-templates select="." mode="scribe"/></xsl:for-each>. 
		</xsl:if>
	</xsl:template>
	
	
	<!-- bibliography -->
	
	<xsl:template name="print_bibliography_type">
		<span class="p_heading">
			<xsl:choose>
				<xsl:when test="@type='primary'"> Primary texts </xsl:when>
				<xsl:when test="@type='documentation'"> Documentation </xsl:when>
				<xsl:otherwise> Bibliography </xsl:otherwise>
			</xsl:choose>
		</span>
	</xsl:template>
	
	
	<xsl:template match="t:listBibl">
		
		<xsl:variable name="bib_id" select="concat('bib',generate-id(.),position())"/>
		
		<xsl:text>
		</xsl:text>
		
		<script type="application/javascript"><xsl:text>
			openness["</xsl:text><xsl:value-of select="$bib_id"/><xsl:text>"]=false;
			</xsl:text></script>
		<xsl:text>
		</xsl:text>
		
		<div class="fold">
			
			<p class="p_heading" 
				id="p{$bib_id}" 
				title="Click to open"
				onclick="toggle('{$bib_id}')" >
				<img style="display:inline" 
					id="img{$bib_id}" 
					border="0" 
					src="/editor/images/plus.png" alt="+"/>
				<xsl:call-template name="print_bibliography_type" />
			</p>
			
			<div class="folded_content" style="display:none">
				<xsl:attribute name="id"><xsl:value-of select="$bib_id"/></xsl:attribute>
				
				<xsl:apply-templates select="." mode="bibl_paragraph"/>
				
			</div>
			
		</div>
		
	</xsl:template>
	
	<!-- render bibliography items as paragraphs or tables -->
	<xsl:template match="t:listBibl" mode="bibl_paragraph">
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
		<xsl:if test="count(t:bibl[@type='Diary_entry' and normalize-space(concat(t:author,t:date))]) &gt; 0">
			<p class="p_subheading">Diary entries:</p>
			<table class="letters">
				<xsl:for-each select="t:bibl[@type='Diary_entry' and normalize-space(concat(t:author,t:date))]">
					<xsl:apply-templates select="."/>
				</xsl:for-each>
			</table>
		</xsl:if>
		<xsl:if
			test="count(t:bibl[(@type='Letter' or @type='Diary_entry') and normalize-space(concat(t:author,t:date))])&gt;0 and 
			count(t:bibl[@type!='Letter' and @type!='Diary_entry' and normalize-space(concat(t:author,t:title[@level='a'],t:title[@level='m']))])&gt;0">
			<p class="p_heading">Other:</p>
		</xsl:if>
		<xsl:for-each
			select="t:bibl[@type!='Letter' and @type!='Diary_entry' and normalize-space(concat(t:author,t:title[@level='a'],t:title[@level='m']))]">
			<p class="bibl_record">
				<xsl:apply-templates select="."/>
			</p>
		</xsl:for-each>
	</xsl:template>
	
	<!-- bibliographic record formatting template -->
	<xsl:template match="t:bibl">
		<xsl:choose>
			<xsl:when test="@type='Monograph'">
				<xsl:if test="t:title[@level='m']/text()">
					<!-- show entry only if a title is stated -->
					<xsl:choose>
						<xsl:when test="t:author/text()">
							<xsl:call-template name="list_authors"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="list_editors"/>
						</xsl:otherwise>
					</xsl:choose>
					<em>
						<xsl:apply-templates select="t:title[@level='m']"/>
					</em>
					<xsl:if test="t:title[@level='s']/text()"> 
						(= 
						<xsl:apply-templates select="t:title[@level='s']"/>
						<xsl:if test="t:biblScope[@type='volume']/text()">, Vol.
							<xsl:apply-templates select="t:biblScope[@type='volume']"/>
						</xsl:if>
						)
					</xsl:if>
					<xsl:if test="normalize-space(concat(t:publisher,t:pubPlace,t:date))!=''">.
						<xsl:if test="t:publisher/text()">
							<xsl:apply-templates select="t:publisher"/>,
						</xsl:if>
						<xsl:if test="t:pubPlace/text()">
							<xsl:value-of select="normalize-space(t:pubPlace)"/>
						</xsl:if>
						<xsl:if test="t:date/text()"><xsl:text> </xsl:text>
							<xsl:apply-templates select="t:date"/>
						</xsl:if>
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
			
			<xsl:when test="@type='Article_in_book'">
				<!-- show entry only if a title is stated -->
				<xsl:if test="t:title[@level='a']/text()">
					<xsl:if test="t:author/text()">
						<xsl:call-template name="list_authors" />
					</xsl:if>
					<em>
						<xsl:value-of select="t:title[@level='a']"/>
					</em>
					<xsl:choose>
						<xsl:when test="t:title[@level='m']/text()">, in:
							<xsl:if test="t:editor/text()">
								<xsl:call-template name="list_editors"/>
							</xsl:if>
							<xsl:value-of select="t:title[@level='m']/text()"/>
							<xsl:choose>
								<xsl:when test="t:title[@level='s']/text()">(=
									<xsl:apply-templates select="t:title[@level='s']/text()"/>
									<xsl:if test="t:biblScope[@type='volume']/text()">,
										Vol.
										<xsl:value-of select="t:biblScope[@type='volume']/text()"/>
									</xsl:if>)
								</xsl:when>
								<xsl:otherwise>
									<xsl:if test="t:biblScope[@type='volume']/text()">, Vol.<xsl:value-of
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
					<xsl:if test="normalize-space(t:biblScope[@type='pp'])!=''">, p. <xsl:value-of
						select="normalize-space(t:biblScope[@type='pp'])"/>
					</xsl:if>. </xsl:if>
			</xsl:when>
			
			<xsl:when test="@type='Journal_article'">
				<!-- show entry only if a title or journal/newspaper name is stated -->
				<xsl:if test="t:title[@level='a']/text()|t:title[@level='j']/text()">
					
					<xsl:if test="normalize-space(t:title[@level='a'])!=''">
						<xsl:if test="t:author/text()">
							<xsl:call-template name="list_authors"/>
						</xsl:if> 
						'<xsl:value-of select="t:title[@level='a']/text()"/>'<xsl:if
							test="t:title[@level='j']/text()">, in: </xsl:if>
					</xsl:if>
					<xsl:if test="t:title[@level='j']/text()">
						<em><xsl:apply-templates select="t:title[@level='j']"/></em>
					</xsl:if>
					<xsl:if test="normalize-space(t:biblScope[@type='volume'])!=''">, <xsl:value-of
						select="normalize-space(t:biblScope[@type='volume'])"/></xsl:if><xsl:if
							test="normalize-space(t:biblScope[@type='number'])!=''">/<xsl:value-of
								select="normalize-space(t:biblScope[@type='number'])"/></xsl:if>
					<xsl:if test="normalize-space(t:date)!=''"> (<xsl:apply-templates select="t:date"/>)</xsl:if>
					<xsl:if test="normalize-space(t:biblScope[@type='pp'])!=''">, p. <xsl:value-of
						select="t:biblScope[@type='pp']"/></xsl:if>. </xsl:if>
			</xsl:when>
			
			<xsl:when test="@type='Web_resource'">
				<!-- show entry only if a title is stated -->
				<xsl:if test="normalize-space(t:title)">
					<xsl:if test="normalize-space(t:author)!=''"><xsl:apply-templates select="t:author"/>: </xsl:if>
					<em><xsl:value-of select="t:title"/></em>
					<xsl:if test="normalize-space(concat(t:biblScope[normalize-space()], t:publisher, t:pubPlace))">. </xsl:if>
					<xsl:if test="normalize-space(t:biblScope[@type='volume'])">, vol.<xsl:value-of
						select="normalize-space(t:biblScope[@type='volume'])"/></xsl:if>
					<xsl:if test="normalize-space(t:publisher)">
						<xsl:value-of select="normalize-space(t:publisher)"/>
						<xsl:if test="normalize-space(concat(t:pubPlace,t:biblScope[@type='pp']))">, </xsl:if>
					</xsl:if>
					<xsl:if test="normalize-space(t:pubPlace)">
						<xsl:value-of select="normalize-space(t:pubPlace)"/></xsl:if>
					<xsl:if test="normalize-space(t:date)">
						<xsl:apply-templates select="t:date"/></xsl:if>
					<xsl:if test="normalize-space(t:biblScope[@type='pp'])">, p. <xsl:value-of
						select="normalize-space(t:biblScope[@type='pp'])"/></xsl:if>. </xsl:if>
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
			
			<xsl:when test="@type='Diary_entry'">
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
				<xsl:if test="normalize-space(t:biblScope[@type='pp'])">, p. <xsl:value-of
					select="normalize-space(t:biblScope[@type='pp'])"/></xsl:if>. * </xsl:otherwise>
		</xsl:choose>
		<!-- links to full text (exception: letters and diary entries handled elsewhere) -->
		<xsl:if test="normalize-space(t:ref/@target) and not(@type='Diary_entry' or @type='Letter')">
			<img src="/editor/images/html_link.png" title="Link to external resource"/>
			<a target="_blank" title="Link to full text">
				<xsl:attribute name="href">
					<xsl:value-of select="normalize-space(t:ref/@target)"/>
				</xsl:attribute>
				<xsl:value-of select="t:ref/@target"/>
			</a>
		</xsl:if>
	</xsl:template>
	
	
	<xsl:template name="list_seperator">
		<xsl:if test="position() &gt; 1">
			<xsl:choose>
				<xsl:when test="position() &lt; last()"><xsl:text>, </xsl:text></xsl:when>
				<xsl:otherwise><xsl:text> and </xsl:text></xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<!-- list authors -->
	<xsl:template name="list_authors">
		<xsl:for-each select="t:author">
			<xsl:call-template name="list_seperator"/>
			<xsl:apply-templates select="."/><xsl:if test="position() = last()">: </xsl:if>
		</xsl:for-each> 
	</xsl:template>
	
	<!-- list editors -->
	<xsl:template name="list_editors">
		<xsl:for-each select="t:editor[text()]">
			<xsl:call-template name="list_seperator"/>
			<xsl:value-of select="."/>
			<xsl:if test="position()=last()">
				<xsl:choose>
					<xsl:when test="position() &gt;1"><xsl:text> (eds.): </xsl:text></xsl:when>
					<xsl:otherwise><xsl:text> (ed.): </xsl:text></xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<!-- list editions of letters, diaries etc. -->
	<xsl:template match="t:ref[@type='editions']">
		<xsl:variable name="number_of_editions" select="count(t:bibl)"/> (<xsl:for-each select="t:bibl">
			<xsl:if test="position() &gt; 1">,<xsl:text> </xsl:text></xsl:if>
			<xsl:value-of select="t:title"/><xsl:text> </xsl:text><xsl:value-of select="t:biblScope"/>
		</xsl:for-each>) </xsl:template>
	
	
	<!-- format volume, issue and page numbers -->
	
	<xsl:template mode="volumes_pages" match="*">
		
		<xsl:variable name="number_of_volumes" 
			select="t:biblScope[@type='volume'][text()]"/>
		
		<xsl:variable name="number_of_pages" select="count(t:biblScope[@type='pp' and normalize-space(.)!=''])"/>
		<xsl:choose>
			<xsl:when test="$number_of_volumes &gt; 0">: <xsl:for-each select="t:biblScope[@type='volume']">
				<xsl:if test="position() &gt; 1">; </xsl:if> Vol. <xsl:value-of select="."/>
				<xsl:if test="normalize-space(../t:biblScope[@type='number'][position()])">/<xsl:value-of
					select="normalize-space(../t:biblScope[@type='number'][position()])"/></xsl:if>
				<xsl:if test="normalize-space(../t:biblScope[@type='pp'][position()])">, p. <xsl:value-of
					select="normalize-space(../t:biblScope[@type='pp'][position()])"/></xsl:if>
			</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="normalize-space(t:biblScope[@type='pp'])!=''">, p. <xsl:value-of
					select="t:biblScope[@type='pp']"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>. 
	</xsl:template>
	
	<!-- display external link -->
	<xsl:template match="m:extptr">
		<xsl:if test="normalize-space(@xl:href)">
			<img src="/editor/images/html_link.png" title="Link to external resource"/>
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
	
	<xsl:template match="m:revisionDesc">
		<xsl:apply-templates select="m:change[normalize-space(m:date)!=''][last()]" mode="last"/>
	</xsl:template>
	
	<xsl:template match="m:revisionDesc/m:change" mode="last">
		<div class="latest_revision"> 
			<br/>Last changed 
			<xsl:value-of select="m:date"/>
			<xsl:if test="normalize-space(m:respStmt/m:persName)">
				by <i><xsl:value-of select="m:respStmt/m:persName"/></i>
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
	
	<xsl:template name="remove_">
		<!-- removes _ if it's there, otherwise just return the string passed as
			argument -->
		<xsl:param name="str"/>
		<xsl:choose>
			<xsl:when test="contains($str,'_')">
				<xsl:value-of select="concat(substring-before($str,'_'),
					' ',
					substring-after($str,'_'))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$str"/> 
			</xsl:otherwise>
		</xsl:choose>
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
	
	
	<xsl:template name="maybe_print_lang">
		<xsl:attribute name="xml:lang">
			<xsl:value-of select="@xml:lang"/>
		</xsl:attribute>
		<xsl:choose>
			<xsl:when test="position()&gt;1">
				<xsl:attribute name="class">alternative_language</xsl:attribute>
				[<xsl:value-of select="concat(@xml:lang,':')"/>]
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
	
	<!-- replacements -->
	<xsl:template match="text()[contains(.,'[flat]')]">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[flat]'))"/>
		<span class="accidental">&#x266d;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[flat]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'[natural]')]">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[natural]'))"/>
		<span class="accidental">&#x266e;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[natural]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'[sharp]')]">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[sharp]'))"/>
		<span class="accidental">&#x266f;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[sharp]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'[dblflat]')]">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[dblflat]'))"/>
		<span class="accidental">&#x266d;&#x266d;</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[dblflat]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'[dblsharp]')]">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[dblsharp]'))"/>
		<span class="accidental">x</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[dblsharp]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'[common]')]">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[common]'))"/>
		<span class="timesig">c</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[common]'))"/>
	</xsl:template>
	<xsl:template match="text()[contains(.,'[cut]')]">
		<xsl:apply-templates select="exsl:node-set(substring-before(.,'[cut]'))"/>
		<span class="timesig">C</span>
		<xsl:apply-templates select="exsl:node-set(substring-after(.,'[cut]'))"/>
	</xsl:template>
	
	<xsl:template match="text()">
		<xsl:copy-of select="."/>
	</xsl:template>

	<!-- formatted text -->
	<xsl:template match="m:lb">
		<br/>
	</xsl:template> 
	<xsl:template match="m:p">
		<p><xsl:apply-templates/></p>
	</xsl:template>
	<xsl:template match="m:rend[@fontweight = 'bold']">
		<b><xsl:apply-templates/></b>
	</xsl:template>
	<xsl:template match="m:rend[@fontstyle = 'ital']">
		<i><xsl:apply-templates/></i>
	</xsl:template>
	<xsl:template match="m:rend[@rend = 'underline']">
		<u><xsl:apply-templates/></u>
	</xsl:template>
	<xsl:template match="m:rend[@rend = 'sub']">
		<sub><xsl:apply-templates/></sub>
	</xsl:template>
	<xsl:template match="m:rend[@rend = 'sup']">
		<sup><xsl:apply-templates/></sup>
	</xsl:template>
	<xsl:template match="m:rend[@fontfam or @fontsize or @color]">
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
			<xsl:attribute name="style"><xsl:value-of select="$atts"/></xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="m:ref[@target]">
		<xsl:element name="a">
			<xsl:attribute name="src"><xsl:value-of select="@target"/></xsl:attribute>
			<xsl:attribute name="target"><xsl:value-of select="@xl:show"/></xsl:attribute>
			<xsl:attribute name="title"><xsl:value-of select="@xl:title"/></xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="m:rend[@halign]">
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
					<li><xsl:apply-templates/></li>
				</xsl:for-each>
				</ul>
			</xsl:when>
			<xsl:when test="@form = 'ordered'">
				<ol>
				<xsl:for-each select="m:li">
					<li><xsl:apply-templates/></li>
				</xsl:for-each>
				</ol>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="m:fig[m:graphic]">
		<xsl:element name="img">
			<xsl:attribute name="src"><xsl:value-of select="m:graphic/@target"/></xsl:attribute>
		</xsl:element>
	</xsl:template> 
	<!-- END TEXT HANDLING -->	
	
</xsl:stylesheet>
