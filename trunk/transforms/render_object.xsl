<xsl:transform xmlns:h="http://www.w3.org/1999/xhtml"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       version="1.0">

<!--
Renders a page
Author: Sigfrid Lundberg (slu@kb.dk)
$Id: render_object.xsl,v 1.2 2010/02/09 13:40:15 slu Exp $
-->

  <xsl:param name="xml_file" select="'mods99042030.edit'"/>

  <xsl:template match="/">
    <h:html>
      <h:head>
	<h:title>
	 html title
	</h:title>
	<h:meta http-equiv="Content-Type"  content="application/xhtml+xml;charset=UTF-8"/>
      </h:head>
      <h:body>
	<h:p>
	  [
	  <xsl:element name="h:a">html</xsl:element>
	  <xsl:text> || </xsl:text>
	  <xsl:element name="h:a">
	    <xsl:attribute name="href">
	      <xsl:value-of select="concat(substring-before($xml_file,'edit'),'xml')"/>
	    </xsl:attribute>
	  xml</xsl:element>
	  <xsl:text> || </xsl:text>
	  <xsl:element name="h:a">
	    <xsl:attribute name="href">
	      <xsl:value-of select="concat(substring-before($xml_file,'edit'),'edit')"/>
	    </xsl:attribute>
	  edit</xsl:element>
	  <xsl:text> || </xsl:text>
	  <xsl:element name="h:a">
	    <xsl:attribute name="href"><xsl:text>./</xsl:text></xsl:attribute>
	  all files</xsl:element>
	  ]
	</h:p>
	<h:h1>
	  <xsl:value-of
	      select="/mei/meihead/filedesc/titlestmt/title[@type='main']"/><xsl:text> </xsl:text>
	</h:h1>
      </h:body>
    </h:html>
  </xsl:template>
</xsl:transform>

<!--

$Log: render_object.xsl,v $
Revision 1.2  2010/02/09 13:40:15  slu
a whole lot of modifications and additions

Revision 1.1  2010/02/09 08:42:57  slu
new files

Revision 1.1  2010/02/01 10:17:15  slu
no comments

Revision 1.4  2010/01/14 14:20:31  slu
adding links to the user interface

Revision 1.3  2010/01/06 10:35:35  slu
storing away the modifications

Revision 1.2  2010/01/04 15:34:45  slu
no comments


-->
