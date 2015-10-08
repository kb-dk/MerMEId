<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		exclude-result-prefixes="xsl" version="1.0">

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  <xsl:strip-space elements="*"/>
  
  <xsl:param name="sort">a-z</xsl:param>
  <xsl:key name="titles" match="//div[@class='work']" use="substring(div[@class='title'],1,1)"/>
  
  <xsl:template match="/">
    <div class="threeCol">
      <div class="wrapper">
	<form action="" method="get">
	  <label>Sortér: </label>
	  <select name="sort" onchange="this.form.submit();">
	    <xsl:element name="option">
	      <xsl:attribute name="value">a-z</xsl:attribute>
	      <xsl:if test="$sort='a-z'">
		<xsl:attribute name="selected">true</xsl:attribute>
	      </xsl:if>
	      alfabetisk
	    </xsl:element>
	    <xsl:element name="option">
	      <xsl:attribute name="value">date</xsl:attribute>
	      <xsl:if test="$sort='date'">
		<xsl:attribute name="selected">true</xsl:attribute>
	      </xsl:if>
	      kronologisk
	    </xsl:element>
	  </select>
	</form>
	<xsl:if test="$sort='a-z'">
	  <xsl:call-template name="alphabet"/>
	</xsl:if>                    
	<div class="header" style="margin-bottom: 0.5em;">
	  <span style="display: inline-block; width: 6em;">Værknummer</span><span>Titel og årstal</span><br/>
	  <span style="display: inline-block; width: 6em;"><small>("Bjørnum-Hansen-nummer")</small></span>
	</div>
	<xsl:choose>
	  <xsl:when test="$sort='a-z'">
	    <xsl:for-each select=".//div[@class='work'][count(. | key('titles', substring(div[@class='title'],1,1))[1]) = 1]">
	      <xsl:sort select="div[@class='title']" order="ascending"/>						
	      <xsl:apply-templates select="." mode="alpha"/>
	    </xsl:for-each>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:apply-templates select="div" mode="chrono"/>
	  </xsl:otherwise>
	</xsl:choose>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template match="div[@class='work']" mode="alpha">
    <xsl:variable name="letter" select="substring(.//div[@class='title'],1,1)"/>
    <xsl:if test="$letter!=number($letter)">
      <h3 class="index_row">
	<a>
	  <xsl:attribute name="name"><xsl:value-of select="$letter"/></xsl:attribute>
	  <xsl:value-of select="$letter"/>
	</a>
      </h3>
    </xsl:if>
    <xsl:for-each select="key('titles', $letter)">
      <xsl:sort select="div[@class='title']" order="ascending" lang="da"/>
      <xsl:apply-templates mode="list_title" select="."/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="div[@class='work']" mode="chrono">
    <xsl:apply-templates mode="list_title" select="."/>
  </xsl:template>

  <xsl:template match="div[@class='work']" mode="list_title">
    <div class="title">
      <span style="display: inline-block; width: 6em;"><xsl:value-of select="div[@class='work_no']"/></span>
      <a>
	<xsl:attribute name="href">vaerk.html?id=<xsl:value-of select="@id"/></xsl:attribute>
	<xsl:value-of select="div[@class='title']"/>
	</a><xsl:text> </xsl:text>
	<xsl:if test="normalize-space(div[@class='year'])">(<xsl:value-of select="normalize-space(div[@class='year'])"/>)</xsl:if>
    </div>
  </xsl:template>
  
  <xsl:template match="div[@class='year_index']" mode="chrono">
    <h3 class="index_row">
      <a>
	<xsl:attribute name="name"><xsl:value-of select="normalize-space(.)"/></xsl:attribute>
	<xsl:value-of select="."/>
      </a>
      <div class="toplink"><a href="#top">Til top</a></div>
    </h3>
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
  
</xsl:stylesheet>
