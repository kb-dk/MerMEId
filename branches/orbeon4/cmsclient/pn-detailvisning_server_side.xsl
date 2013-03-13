<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="id"/>
  
  <xsl:template match="/">
    <div>
      <xsl:apply-templates select="xml/records/record[rec-number=$id]"/>
    </div>
  </xsl:template>



  <xsl:template match="record">
    <!-- Record formatting template -->
    <xsl:variable name="id" select="rec-number"/>
    <p>
      <strong>
	<xsl:apply-templates select="contributors/authors" mode="authors"/>
      </strong>
    </p>

    <h2><xsl:value-of select="titles/title"/></h2>

    <p class="indent"><span class="cell">Type: </span>
    <xsl:call-template name="translate_reftypes">
      <xsl:with-param name="reftype" select="ref-type/@name"/>
    </xsl:call-template>
    </p>
    <xsl:if test="normalize-space(dates/year/style)">
      <p class="indent">
	<span class="cell">År: </span>
	<span class="cell"><xsl:value-of select="dates/year/style"/></span>
      </p>
    </xsl:if>
    
    <xsl:choose> 

      <xsl:when test="ref-type/@name='Manuscript'">
	<xsl:if test="titles/secondary-title/style">
	  <h4><xsl:value-of select="titles/secondary-title/style"/></h4>
	</xsl:if> 
	<xsl:if test="normalize-space(dates/pub-dates/date/style)">
	  <p class="indent">
	    <span class="cell">Datering: </span>
	    <span class="cell"><xsl:value-of select="dates/pub-dates/date/style"/></span>
	  </p>
	</xsl:if>
	<xsl:if test="normalize-space(pages/style)">
	  <p class="indent">
	    <span class="cell">Antal sider: </span>
	    <span class="cell"><xsl:value-of select="pages/style"/></span>
	  </p>
	</xsl:if>
	<xsl:if test="normalize-space(concat(publisher/style,volume/style))">
	  <p class="indent">
	    <span class="cell">Lokation: </span>
	    <span class="cell">
	      <xsl:value-of select="publisher/style"/><xsl:text> </xsl:text>
	      <xsl:value-of select="call-num/style"/><xsl:text> </xsl:text>
	      <xsl:value-of select="volume/style"/>
	    </span>
	  </p>
	</xsl:if>
      </xsl:when>
      
      <xsl:when test="ref-type/@name='Book'">
	<xsl:if test="titles/secondary-title/style"><h4> (= <xsl:value-of select="titles/secondary-title/style"/>
	<xsl:if test="volume/style">, <xsl:value-of select="volume/style"/></xsl:if>)</h4></xsl:if> 
	<p class="indent">
	  <span class="cell">Udgivelse: </span>
	  <span class="cell">
	    <xsl:if test="normalize-space(publisher/style)"><xsl:value-of select="normalize-space(publisher/style)"/>, </xsl:if>
	    <xsl:if test="normalize-space(pub-location/style)"><xsl:value-of select="normalize-space(pub-location/style)"/></xsl:if>
	    <xsl:if test="normalize-space(dates/year/style)"> <xsl:value-of select="normalize-space(dates/year/style)"/></xsl:if>
	  </span>
	</p>
      </xsl:when>
      
      <xsl:when test="ref-type/@name='Book Section'">
	<xsl:if test="titles/secondary-title/style"> 
	  <p class="indent">
	    <span class="cell">Trykt i: </span>
	    <span class="cell">
	      <xsl:apply-templates select="contributors/secondary-authors" mode="editors"/>
	      <xsl:value-of select="normalize-space(titles/secondary-title/style)"/>
	      <xsl:if test="normalize-space(titles/tertiary-title/style)"> (= <xsl:value-of select="normalize-space(titles/tertiary-title/style)"/>
	      <xsl:if test="normalize-space(volume/style)">, <xsl:value-of select="normalize-space(volume/style)"/></xsl:if>)</xsl:if>.
	    </span>
	  </p>
	  <p class="indent">
	    <span class="cell">Udgivelse: </span>
	    <span class="cell">
	      <xsl:if test="normalize-space(publisher/style)"><xsl:value-of select="normalize-space(publisher/style)"/>, </xsl:if>
	      <xsl:if test="normalize-space(pub-location/style)"><xsl:value-of select="normalize-space(pub-location/style)"/></xsl:if>
	      <xsl:if test="normalize-space(dates/year/style)"> <xsl:value-of select="normalize-space(dates/year/style)"/></xsl:if>
	      <xsl:if test="normalize-space(pages/style)">, s. <xsl:value-of select="normalize-space(pages/style)"/></xsl:if>
	    </span>
	  </p>
	</xsl:if>
      </xsl:when> 

      <xsl:when test="ref-type/@name='Journal Article' or ref-type/@name='Magazine Article' or ref-type/@name='Interview' or ref-type/@name='Debate'">
	<p class="indent">
	  <span class="cell">Trykt i: </span>
	  <span class="cell">
	    <xsl:if test="normalize-space(periodical/full-title/style)">
	      <xsl:value-of select="normalize-space(periodical/full-title/style)"/>
	    </xsl:if>
	    <xsl:if test="not(normalize-space(periodical/full-title/style))">
	      <xsl:if test="normalize-space(titles/secondary-title/style)">
		<xsl:value-of select="titles/secondary-title/style"/>
	      </xsl:if>
	    </xsl:if>
	    <xsl:if test="normalize-space(volume/style)"><xsl:text> </xsl:text><xsl:value-of select="normalize-space(volume/style)"/></xsl:if>
	    <xsl:if test="normalize-space(number/style)"><xsl:text> </xsl:text><xsl:value-of select="normalize-space(number/style)"/></xsl:if>
	    <xsl:if test="normalize-space(dates/year/style)"><xsl:text> </xsl:text>(<xsl:value-of select="normalize-space(dates/year/style)"/>)</xsl:if>
	    <xsl:if test="normalize-space(publisher/style)"><xsl:value-of select="normalize-space(publisher/style)"/>, </xsl:if>
	    <xsl:if test="normalize-space(pub-location/style)"><xsl:value-of select="normalize-space(pub-location/style)"/></xsl:if>
	    <xsl:if test="normalize-space(pages/style)">, s. <xsl:value-of select="normalize-space(pages/style)"/></xsl:if>
	  </span>
	</p>
      </xsl:when> 				


      <xsl:when test="ref-type/@name='Newspaper Article'">
	<p class="indent">
	  <span class="cell">Trykt i: </span>
	  <span class="cell">
	    <xsl:if test="normalize-space(periodical/full-title/style)">
	      <xsl:value-of select="normalize-space(periodical/full-title/style)"/>
	    </xsl:if>
	    <xsl:if test="not(normalize-space(periodical/full-title/style))">
	      <xsl:if test="normalize-space(titles/secondary-title/style)">
		<xsl:value-of select="titles/secondary-title/style"/>
	      </xsl:if>
	    </xsl:if>
	    <xsl:text> </xsl:text>
	    <xsl:if test="normalize-space(dates/pub-dates/date/style)"><xsl:value-of select="dates/pub-dates/date/style"/></xsl:if>
	    <xsl:if test="not(normalize-space(dates/pub-dates/date/style))">
	      <xsl:if test="normalize-space(dates/year/style)"><xsl:value-of select="normalize-space(dates/year/style)"/></xsl:if>
	    </xsl:if>
	    <xsl:if test="normalize-space(pages/style)">, s. <xsl:value-of select="normalize-space(pages/style)"/></xsl:if>
	  </span>
	</p>
      </xsl:when> 				

      <xsl:when test="ref-type/@name='Pamphlet'">
	<xsl:if test="titles/secondary-title/style"><h4> (= <xsl:value-of select="titles/secondary-title/style"/>
	<xsl:if test="volume/style">, <xsl:value-of select="volume/style"/></xsl:if>)</h4></xsl:if> 
	<p class="indent"><span class="cell">Kontekst: </span>
	<xsl:value-of select="contributors/secondary-authors"/>
	</p>
	<xsl:if test="normalize-space(pages/style)">
	  <p class="indent">
	    <span class="cell">Side: </span>
	    <xsl:value-of select="pages/style"/>
	  </p>
	</xsl:if>				
	<xsl:if test="normalize-space(section/style)">
	  <p class="indent">
	    <span class="cell">Antal sider: </span>
	    <xsl:value-of select="section/style"/>
	  </p>
	</xsl:if>				
	<p class="indent"><span class="cell">Udgivelse: </span>
	<xsl:if test="normalize-space(publisher/style)"><xsl:value-of select="normalize-space(publisher/style)"/>, </xsl:if>
	<xsl:if test="normalize-space(pub-location/style)"><xsl:value-of select="normalize-space(pub-location/style)"/></xsl:if>
	<xsl:if test="normalize-space(dates/year/style)"> <xsl:value-of select="normalize-space(dates/year/style)"/></xsl:if>
	</p>
      </xsl:when>


      <xsl:when test="ref-type/@name='Unpublished Work'">
	<xsl:if test="normalize-space(titles/secondary-title/style)">
	  <h4><xsl:value-of select="titles/secondary-title/style"/></h4>
	</xsl:if> 
	<xsl:if test="normalize-space(dates/year/style)">
	  <p class="indent">
	    <span class="cell">År: </span>
	    <span class="cell"><xsl:value-of select="dates/year/style"/></span>
	  </p>
	</xsl:if>
	<xsl:if test="normalize-space(dates/pub-dates/date/style)">
	  <p class="indent">
	    <span class="cell">Datering: </span>
	    <span class="cell"><xsl:value-of select="dates/pub-dates/date/style"/></span>
	  </p>
	</xsl:if>
	<xsl:if test="normalize-space(pages/style)">
	  <p class="indent">
	    <span class="cell">Antal sider: </span>
	    <span class="cell"><xsl:value-of select="pages/style"/></span>
	  </p>
	</xsl:if>
	<xsl:if test="normalize-space(concat(publisher/style,volume/style))">
	  <p class="indent">
	    <span class="cell">Lokation: </span>
	    <span class="cell">
	      <xsl:value-of select="publisher/style"/><xsl:text> </xsl:text>
	      <xsl:value-of select="call-num/style"/><xsl:text> </xsl:text>
	      <xsl:value-of select="volume/style"/>
	    </span>
	  </p>
	</xsl:if>
      </xsl:when>
      
      
      <xsl:when test="ref-type/@name='Web Page'">
	<p class="indent">
	  <span class="cell">Udgivet af: </span>
	  <span class="cell">
	    <xsl:if test="normalize-space(contributors/secondary-authors/author/style)">
	      <xsl:value-of select="contributors/secondary-authors/author/style"/>
	      <xsl:if test="normalize-space(concat(periodical/full-title/style,titles/secondary-title/style))"><br/></xsl:if>						
	    </xsl:if>
	    <xsl:if test="normalize-space(periodical/full-title/style)">
	      <xsl:value-of select="normalize-space(periodical/full-title/style)"/>
	    </xsl:if>
	    <xsl:if test="not(normalize-space(periodical/full-title/style))">
	      <xsl:if test="normalize-space(titles/secondary-title/style)">
		<xsl:value-of select="titles/secondary-title/style"/>
	      </xsl:if>
	    </xsl:if>
	  </span>
	</p>
	<p class="indent">
	  <span class="cell">Dato: </span>
	  <span class="cell">
	    <xsl:if test="normalize-space(dates/pub-dates/date/style)"><xsl:value-of select="dates/pub-dates/date/style"/></xsl:if>
	    <xsl:if test="not(normalize-space(dates/pub-dates/date/style))">
	      <xsl:if test="normalize-space(dates/year/style)"><xsl:value-of select="normalize-space(dates/year/style)"/></xsl:if>
	    </xsl:if>
	  </span>
	</p>
      </xsl:when> 				
      
      
      <xsl:otherwise>
	<xsl:if test="titles/secondary-title/style"> 
	  <p class="indent">
	    <span class="cell">Trykt i: </span>
	    <span class="cell">
	      <xsl:apply-templates select="contributors/secondary-authors" mode="editors"/>
	      <xsl:value-of select="normalize-space(titles/secondary-title/style)"/>
	      <xsl:if test="normalize-space(titles/tertiary-title/style)"> (= <xsl:value-of select="normalize-space(titles/tertiary-title/style)"/>
	      <xsl:if test="normalize-space(volume/style)">, <xsl:value-of select="normalize-space(volume/style)"/></xsl:if>)</xsl:if>. 
	      <xsl:if test="normalize-space(publisher/style)"><xsl:value-of select="normalize-space(publisher/style)"/>, </xsl:if>
	      <xsl:if test="normalize-space(pub-location/style)"><xsl:value-of select="normalize-space(pub-location/style)"/></xsl:if>
	      <xsl:if test="normalize-space(dates/year/style)"> <xsl:value-of select="normalize-space(dates/year/style)"/></xsl:if>
	      <xsl:if test="normalize-space(pages/style)">, s. <xsl:value-of select="normalize-space(pages/style)"/></xsl:if>
	    </span>
	  </p>
	</xsl:if>
      </xsl:otherwise>
      
    </xsl:choose>
    
    <xsl:if test="normalize-space(reprint-edition)">
      <p class="indent">
	<span class="cell">Genoptrykt i: </span>
	<span class="cell"><xsl:value-of select="reprint-edition/style"/></span>
      </p>
    </xsl:if>
    <xsl:if test="normalize-space(orig-pub/style)">
      <p class="indent">
	<span class="cell">Oprindeligt udgivet i: </span>
	<span class="cell"><xsl:value-of select="orig-pub/style"/></span>
      </p>
    </xsl:if>
    <xsl:if test="normalize-space(language/style)">
      <p class="indent">
	<span class="cell">Sprog: </span>
	<span class="cell"><xsl:value-of select="language/style"/></span>
      </p>
    </xsl:if>
    
    <xsl:if test="abstract/style">
      <p class="indent">
	<span class="cell">Abstract: </span>
	<span class="cell"><xsl:value-of select="abstract/style"/></span>
      </p>
    </xsl:if>

    <xsl:if test="research-notes/style">
      <p class="indent">
	<span class="cell">Bemærkninger: </span>
	<span class="cell"><xsl:value-of select="research-notes/style"/></span>
      </p>
    </xsl:if>

    <xsl:if test="keywords/keyword/style">
      <p class="indent">
	<span class="cell">Emneord: </span>
	<span class="cell">
	  <xsl:for-each select="keywords/keyword">
	    <xsl:if test="position() &gt; 1">; </xsl:if> 
	    <xsl:value-of select="style"/>
	  </xsl:for-each>
	</span>
      </p>
    </xsl:if>
    
    <xsl:if test="label/style">
      <p class="indent">
	<span class="cell">Emneord: </span>
	<span class="cell"><xsl:value-of select="label/style"/></span>
      </p>
    </xsl:if>
    
    <xsl:if test="urls/related-urls/url/style">
      <xsl:variable name="url_href" select="urls/related-urls/url/style"/>
      <p class="indent">
	<span class="cell">Fuldtekst (PDF): </span>
	<span class="cell"><a href="" title="Link til fuldtekst">
	  <xsl:attribute name="href">artikler/<xsl:value-of select="$url_href"/></xsl:attribute>
	  <xsl:attribute name="target">_blank</xsl:attribute>
	  <img src="/da/kb/nb/mta/dcm/komponenter/grafik/pdf.png" alt="Download som pdf"/>
	  <xsl:text> </xsl:text>
	  <xsl:value-of select="$url_href"/>
	</a></span>
      </p>
    </xsl:if>
    
    
    <!-- For debugging:  Show category and type of reference -->			
    <!--p style="color:#999999"><small>Record ID: <xsl:value-of select="$id"/></small><br/>
	Ref. type: <small>
	<xsl:call-template name="translate_reftypes">
	<xsl:with-param name="reftype" select="ref-type/@name"/>		
	</xsl:call-template></small>
	</p--> 
    <!-- end debug -->
    
  </xsl:template>


  <xsl:template name="translate_reftypes">
    <xsl:param name="reftype"/>
    <xsl:choose>
      <xsl:when test="$reftype='Book'">Bog</xsl:when>
      <xsl:when test="$reftype='Book Section'">Artikel i bog</xsl:when>
      <xsl:when test="$reftype='Journal Article'">Tidsskriftartikel</xsl:when>
      <xsl:when test="$reftype='Magazine Article'">Øvrige artikler</xsl:when>
      <xsl:when test="$reftype='Manuscript'">Manuskript</xsl:when>
      <xsl:when test="$reftype='Newspaper Article'">Avisartikel</xsl:when>
      <xsl:when test="$reftype='Pamphlet'">Hæfte</xsl:when>
      <xsl:when test="$reftype='Unpublished Work'">Upubliceret værk</xsl:when>
      <xsl:when test="$reftype='Web Page'">Webside</xsl:when>
    </xsl:choose>
  </xsl:template>


  <!-- Templates for names lists -->
  
  <xsl:template match="authors" mode="authors">
    <xsl:variable name="number_of_authors" select="count(author)"/>
    <xsl:if test="$number_of_authors = 1">
      <xsl:apply-templates select="author"/>
    </xsl:if>
    <xsl:if test="$number_of_authors &gt; 1">
      <xsl:for-each select="author">
	<xsl:if test="position() &gt; 1 and position() &lt; $number_of_authors">, </xsl:if>
	<xsl:if test="position() = $number_of_authors"> og </xsl:if>
	<xsl:apply-templates select="current()"/>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="authors" mode="editors">
    <xsl:variable name="number_of_authors" select="count(author)"/>
    <xsl:if test="$number_of_authors = 1">
      <xsl:value-of select="author/style"/> (red):
    </xsl:if>
    <xsl:if test="$number_of_authors &gt; 1">
      <xsl:for-each select="author">
	<xsl:if test="position() &gt; 1 and position() &lt; $number_of_authors">, </xsl:if>
	<xsl:if test="position() = $number_of_authors"> og </xsl:if>
	<xsl:value-of select="style"/>
	</xsl:for-each> (red.):
    </xsl:if>
  </xsl:template>	
  
  <xsl:template match="secondary-authors" mode="editors">
    <xsl:variable name="number_of_authors" select="count(author)"/>
    <xsl:if test="$number_of_authors = 1">
      <xsl:call-template name="straightname"><xsl:with-param name="fullname" select="author/style"/></xsl:call-template> (ed.): 
    </xsl:if>
    <xsl:if test="$number_of_authors &gt; 1">
      <xsl:call-template name="straightname"><xsl:with-param name="fullname" select="author/style"/></xsl:call-template> et al. (eds.): 
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="author" mode="invert">
    <xsl:choose>
      <xsl:when test="not(contains(style,','))">
	<!-- Transform Firstname Lastname into Lastname, Firstname -->
	<!-- NB! Authors should always be entered as Lastname, Firstname in Endnote, as this function can only correct the format, not the sort order! --> 
	<xsl:variable name="fullname" select="concat(style,',')"/>
	<xsl:call-template name="nameshift">
	  <xsl:with-param name="fullname" select="normalize-space($fullname)"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="style"/>
      </xsl:otherwise>
    </xsl:choose>	
  </xsl:template>
  

  <!-- Templates for names output formatting -->
  
  <xsl:template name="straightname">
    <!-- Reformats Lastname, Firstname into Firstname Lastname -->
    <xsl:param name="fullname"/>
    <xsl:choose>
      <xsl:when test="contains($fullname,',')">
	<xsl:value-of select="substring-after($fullname,',')"/> <xsl:value-of select="substring-before($fullname,',')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$fullname"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="nameshift">
    <!-- Reformats Secondname Lastname, Firstname into Lastname, Firstname Secondname -->
    <xsl:param name="fullname"/>
    <xsl:choose>
      <xsl:when test="contains(substring-before($fullname,','),' ')">
	<!-- Debugging only -->
	<!-- <p><em>call with param: <xsl:value-of select="concat(substring-after($fullname,' '),' ',substring-before($fullname,' '))"/></em></p> -->
	<!-- End debug -->
	<xsl:call-template name="nameshift">
	  <xsl:with-param name="fullname" select="normalize-space(concat(substring-after($fullname,' '),' ',substring-before($fullname,' ')))"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$fullname"/>
      </xsl:otherwise>
    </xsl:choose>		
  </xsl:template>
</xsl:stylesheet>
