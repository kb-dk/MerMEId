<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
		xmlns="http://www.w3.org/1999/xhtml" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >

  <xsl:param name="sort" select="'a-z'" />
  <xsl:key name="titles" match="record" use="substring(titles/title/style,1,1)"/>
  <xsl:key name="dates" match="record" use="dates/year/style"/>
  <xsl:key name="type" match="record" use="ref-type/@name"/>

  <xsl:template match="/">
    <div>
      <!-- Main content template -->

      <p>
	Samlingen indeholder 
	<xsl:value-of select="count(xml/records/record)"/>
	tekster i fuldtekst.
      </p>

      <form action="" method="get">
	<label>Sortér: </label>
	<select name="sort" onchange="this.form.submit();">
	  <option value="a-z" selected="">alfabetisk (a-å)</option>
	  <xsl:element name="option">
	    <xsl:attribute name="value">z-a</xsl:attribute>
	    <xsl:if test="$sort='z-a'">
	      <xsl:attribute name="selected">true</xsl:attribute>
	    </xsl:if>
	    alfabetisk (å-a)
	  </xsl:element>
	  <xsl:element name="option">
	    <xsl:attribute name="value">date</xsl:attribute>
	    <xsl:if test="$sort='date'">
	      <xsl:attribute name="selected">true</xsl:attribute>
	    </xsl:if>
	    kronologisk (ældste først)
	  </xsl:element>
	  <xsl:element name="option">
	    <xsl:attribute name="value">date_inv</xsl:attribute>
	    <xsl:if test="$sort='date_inv'">
	      <xsl:attribute name="selected">true</xsl:attribute>
	    </xsl:if>
	    kronologisk (nyeste først)
	  </xsl:element>
	  <xsl:element name="option">
	    <xsl:attribute name="value">type</xsl:attribute>
	    <xsl:if test="$sort='type'">
	      <xsl:attribute name="selected">true</xsl:attribute>
	    </xsl:if>
	    efter publikationstype
	  </xsl:element>
	</select>
      </form>
      
      <xsl:choose>
	<xsl:when test="$sort='a-z'">
	  <xsl:call-template name="alphabet"/>
	  <xsl:for-each select="xml/records/record[count(. | key('titles', substring(titles/title/style,1,1))[1]) = 1]">
	    <xsl:sort 
		lang="da"
		select="titles/title/style" 
		order="ascending"/>						
	    <xsl:apply-templates select="." mode="alpha"/>
	  </xsl:for-each>
	</xsl:when>
	<xsl:when test="$sort='z-a'">
	  <xsl:call-template name="alphabet"/>
	  <xsl:for-each select="xml/records/record[count(. | key('titles', substring(titles/title/style,1,1))[1]) = 1]">
	    <xsl:sort
		lang="da"
		select="titles/title/style" 
		order="descending"/>						
	    <xsl:apply-templates select="." mode="alpha"/>
	  </xsl:for-each>
	</xsl:when>
	<xsl:when test="$sort='date'">
	  <hr/>
	  <xsl:for-each select="xml/records/record[count(. | key('dates', dates/year/style)[1]) = 1]">
	    <xsl:sort select="dates/year/style" order="ascending"/>						
	    <xsl:apply-templates select="." mode="chrono"/>
	  </xsl:for-each>
	</xsl:when>
	<xsl:when test="$sort='date_inv'">
	  <hr/>
	  <xsl:for-each select="xml/records/record[count(. | key('dates', dates/year/style)[1]) = 1]">
	    <xsl:sort select="dates/year/style" order="descending"/>						
	    <xsl:apply-templates select="." mode="chrono"/>
	  </xsl:for-each>
	</xsl:when>
	<xsl:when test="$sort='type'">
	  <p>
	    <a href="#Manuscript">Manuskript</a><br/>
	    <a href="#Book">Bog</a><br/>
	    <a href="#Book Section">Artikel i bog</a><br/>
	    <a href="#Journal Article">Tidsskriftartikel</a><br/>
	    <a href="#Newspaper Article">Avisartikel</a><br/>
	    <a href="#Magazine Article">Magasin</a><br/>
	    <a href="#Pamphlet">Hæfte</a><br/>
	    <a href="#Interview">Interview</a><br/>
	    <a href="#Debate">Debat</a><br/>
	    <a href="#Unpublished Work">Upubliceret værk</a><br/>
	    <a href="#Web Page">Webside</a>
	  </p>
	  <hr/>
	  <xsl:apply-templates select="xml/records/record[count(. | key('type', 'Manuscript')[1]) = 1]" mode="pubtype"/>
	  <xsl:apply-templates select="xml/records/record[count(. | key('type', 'Book')[1]) = 1]" mode="pubtype"/>
	  <xsl:apply-templates select="xml/records/record[count(. | key('type', 'Book Section')[1]) = 1]" mode="pubtype"/>
	  <xsl:apply-templates select="xml/records/record[count(. | key('type', 'Journal Article')[1]) = 1]" mode="pubtype"/>
	  <xsl:apply-templates select="xml/records/record[count(. | key('type', 'Newspaper Article')[1]) = 1]" mode="pubtype"/>
	  <xsl:apply-templates select="xml/records/record[count(. | key('type', 'Magazine Article')[1]) = 1]" mode="pubtype"/>
	  <xsl:apply-templates select="xml/records/record[count(. | key('type', 'Pamphlet')[1]) = 1]" mode="pubtype"/>
	  <xsl:apply-templates select="xml/records/record[count(. | key('type', 'Unpublished Work')[1]) = 1]" mode="pubtype"/>
	  <xsl:apply-templates select="xml/records/record[count(. | key('type', 'Web Page')[1]) = 1]" mode="pubtype"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:for-each select="xml/records/record[count(. | key('titles', substring(titles/title/style,1,1))[1]) = 1]">
	    <xsl:sort select="titles/title/style" order="ascending"/>						
	    <xsl:apply-templates select="." mode="alpha"/>
	  </xsl:for-each>
	</xsl:otherwise>
      </xsl:choose>
      <div class="clear">
	<xsl:text>
	</xsl:text>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template match="record" mode="alpha">
    <xsl:variable name="letter" select="substring(titles/title/style,1,1)"/>
    <h3>
      <a>
	<xsl:attribute name="name"><xsl:value-of select="$letter"/></xsl:attribute>
	<xsl:value-of select="$letter"/>
      </a>
    </h3>
    <ul>
      <xsl:for-each select="key('titles', $letter)">
	<xsl:sort select="titles/title/style" order="ascending"/>
	<li>
	  <a>
	    <xsl:attribute name="href">
	      <xsl:value-of select="concat(
				    '?',
				    'sheet=pn-detailvisning_server_side.xsl',
				    '&amp;',
				    'id=',rec-number)"/>
	    </xsl:attribute>
	    <xsl:value-of select="titles/title/style"/>
	    </a><xsl:text> </xsl:text>
	    <xsl:if test="normalize-space(dates/year/style)">(<xsl:value-of select="normalize-space(dates/year/style)"/>)</xsl:if>
	</li>
      </xsl:for-each>
    </ul>
  </xsl:template>


  <xsl:template match="record" mode="chrono">
    <xsl:variable name="year" select="normalize-space(dates/year/style)"/>
    <h3>
      <a>
	<xsl:attribute name="name"><xsl:value-of select="$year"/></xsl:attribute>
	<xsl:value-of select="$year"/>
      </a>
    </h3>
    <ul>
      <xsl:for-each select="key('dates', $year)">
	<li>
	  <a>
	    <xsl:attribute name="href">
	      <xsl:value-of select="concat(
				    '?',
				    'sheet=pn-detailvisning_server_side.xsl',
				    '&amp;',
				    'id=',rec-number)"/>
	    </xsl:attribute>
	    <xsl:value-of select="titles/title/style"/>
	  </a>
	</li>
      </xsl:for-each>
    </ul>
  </xsl:template>
  

  <xsl:template match="record" mode="pubtype">
    <xsl:variable name="pubtype" select="ref-type/@name"/>
    <h3>
      <a>
	<xsl:attribute name="name"><xsl:value-of select="$pubtype"/></xsl:attribute>
	<xsl:call-template name="translate_reftypes">
	  <xsl:with-param name="reftype" select="$pubtype"/>
	</xsl:call-template>
      </a>
    </h3>
    <ul>
      <xsl:for-each select="key('type', $pubtype)">
	<xsl:sort select="titles/title/style" order="ascending"/>
	<li>
	  <a>
	    <xsl:attribute name="href">
	      <xsl:value-of select="concat(
				    '?',
				    'sheet=pn-detailvisning_server_side.xsl',
				    '&amp;',
				    'id=',
				    rec-number)"/>
	    </xsl:attribute>
	    <xsl:value-of select="titles/title/style"/>
	    </a><xsl:text> </xsl:text>
	    <xsl:if test="normalize-space(dates/year/style)">(<xsl:value-of select="normalize-space(dates/year/style)"/>)</xsl:if>
	</li>
      </xsl:for-each>
    </ul>
  </xsl:template>
  
  
  <xsl:template name="alphabet">
    <p>
      <a href="#A">A</a><xsl:text> </xsl:text>
      <a href="#B">B</a><xsl:text> </xsl:text>
      <a href="#C">C</a><xsl:text> </xsl:text>
      <a href="#D">D</a><xsl:text> </xsl:text>
      <a href="#E">E</a><xsl:text> </xsl:text>
      <a href="#F">F</a><xsl:text> </xsl:text>
      <a href="#G">G</a><xsl:text> </xsl:text>
      <a href="#H">H</a><xsl:text> </xsl:text>
      <a href="#I">I</a><xsl:text> </xsl:text>
      <a href="#J">J</a><xsl:text> </xsl:text>
      <a href="#K">K</a><xsl:text> </xsl:text>
      <a href="#L">L</a><xsl:text> </xsl:text>
      <a href="#M">M</a><xsl:text> </xsl:text>
      <a href="#N">N</a><xsl:text> </xsl:text>
      <a href="#O">O</a><xsl:text> </xsl:text>
      <a href="#P">P</a><xsl:text> </xsl:text>
      <a href="#Q">Q</a><xsl:text> </xsl:text>
      <a href="#R">R</a><xsl:text> </xsl:text>
      <a href="#S">S</a><xsl:text> </xsl:text>
      <a href="#T">T</a><xsl:text> </xsl:text>
      <a href="#U">U</a><xsl:text> </xsl:text>
      <a href="#V">V</a><xsl:text> </xsl:text>
      <a href="#W">W</a><xsl:text> </xsl:text>
      <a href="#X">X</a><xsl:text> </xsl:text>
      <a href="#Y">Y</a><xsl:text> </xsl:text>
      <a href="#Z">Z</a><xsl:text> </xsl:text>
      <a href="#Æ">Æ</a><xsl:text> </xsl:text>
      <a href="#Ø">Ø</a><xsl:text> </xsl:text>
      <a href="#Å">Å</a>
    </p>			
    <hr/>
  </xsl:template>


  <xsl:template name="translate_reftypes">
    <xsl:param name="reftype"/>
    <xsl:choose>
      <xsl:when test="$reftype='Book'">Bog</xsl:when>
      <xsl:when test="$reftype='Book Section'">Artikel i bog</xsl:when>
      <xsl:when test="$reftype='Journal Article'">Tidsskriftartikel</xsl:when>
      <xsl:when test="$reftype='Magazine Article'">Magasin</xsl:when>
      <xsl:when test="$reftype='Debate'">Debat</xsl:when>
      <xsl:when test="$reftype='Manuscript'">Manuskript</xsl:when>
      <xsl:when test="$reftype='Newspaper Article'">Avisartikel</xsl:when>
      <xsl:when test="$reftype='Pamphlet'">Hæfte</xsl:when>
      <xsl:when test="$reftype='Unpublished Work'">Upubliceret værk</xsl:when>
      <xsl:when test="$reftype='Web Page'">Webside</xsl:when>
      <xsl:otherwise><xsl:value-of select="$reftype"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
