<?xml version="1.0" encoding="UTF-8"?>

<!-- 
Conversion of MEI metadata to HTML using XSLT 1.0

Author: 
Sigfrid Lundberg (slu@kb.dk)
The Royal Library, Copenhagen

Last modified 2011-08-25
-->

<xsl:stylesheet 
    version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:m="http://www.music-encoding.org/ns/mei" 
    xmlns:t="http://www.tei-c.org/ns/1.0" 
    xmlns:xl="http://www.w3.org/1999/xlink" 
    xmlns:foo="http://www.kb.dk"	
    exclude-result-prefixes="m xsl foo">

  <xsl:import href="http://disdev-01.kb.dk/editor/transforms/mei/mei_to_html.xsl" />

  <xsl:output method="xml" encoding="UTF-8"/>

  <xsl:template match="m:mei" xml:space="default">
    <div xmlns="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="make_html_body" />
    </div>
  </xsl:template>


</xsl:stylesheet>
