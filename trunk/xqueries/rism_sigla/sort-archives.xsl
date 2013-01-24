<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:zs="http://www.loc.gov/zing/srw/"
	       xmlns:marc="http://www.loc.gov/MARC21/slim"
	       version="1.0">


  <xsl:template match="zs:records">
    <xsl:for-each select="zs:record">
      <xsl:sort select="zs:record/zs:recordData/marc:record/marc:datafield[@tag='110']/marc:subfield[@code='g']"
		case-order="upper-first"
		data-type="text"/>
      <zs:record>
	<xsl:apply-templates />
      </zs:record>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

</xsl:transform>
