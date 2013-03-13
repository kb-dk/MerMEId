<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	       xmlns:h="http://www.w3.org/1999/xhtml" 
               xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:xl="http://www.w3.org/1999/xlink"
	       xmlns:foo="http://www.kb.dk"
	       xmlns:f="urn:files"
	       exclude-result-prefixes="h f xsl xl foo t"
	       version="1.0">

  <xsl:output method="xml"
	      encoding="UTF-8"/>

  <xsl:param name="host" select="'distest.kb.dk'"/>
	     

  <xsl:param name="list">
    <xsl:value-of 
	select="document('http://distest.kb.dk/storage/list_files.xq?query=%28andante+OR+andantino%29+AND+sonat*&amp;c=')"/>
  </xsl:param>

  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml" >
      <head>
	<title>Carl Nielsen Works</title>
	<xsl:element name="meta">
	  <xsl:attribute name="http-equiv">Content-Type</xsl:attribute>
	  <xsl:attribute name="content">text/html;charset=UTF-8</xsl:attribute>
	</xsl:element>
      </head>
      <body>
	<xsl:for-each select="//h:a[@title='View']">
	  <xsl:copy-of 
	      select="document(concat('http://',$host,@href))/h:html/h:body/*"/>
	</xsl:for-each>
      </body>
    </html>
  </xsl:template>

</xsl:transform>
