<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet     
    xmlns="http://www.music-encoding.org/ns/mei" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xl="http://www.w3.org/1999/xlink" 
    xmlns:m="http://www.music-encoding.org/ns/mei" 
    xmlns:t="http://www.tei-c.org/ns/1.0" 
    exclude-result-prefixes="m xsl"
    xmlns:uuid="java:java.util.UUID"
    version="2.0">
    
    <xsl:template match="@*|*">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="m:work|m:expression|m:source|m:item|m:event|m:change|m:ensemble|m:performer|m:castItem">
        <xsl:variable name="element_name" select="local-name()"/>
        <xsl:element name="{$element_name}">
            <xsl:if test="not(@xml:id)">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="concat($element_name,'_',generate-id(.))"/><xsl:number level="any" count="//node()" />
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="t:listBibl">
      <xsl:element name="listBibl" namespace="http://www.tei-c.org/ns/1.0"> 
	<xsl:apply-templates select="@*"/>
	<xsl:attribute name="xml:id">
	  <xsl:value-of select="concat('listBibl_',uuid:randomUUID())"/><xsl:number level="any"  count="//node()" />
	</xsl:attribute>
	<xsl:apply-templates select="node()"/>
      </xsl:element>
    </xsl:template>
        
    <xsl:template match="t:bibl">
        <xsl:variable name="element_name" select="local-name()"/>
        <xsl:element name="{$element_name}" namespace="http://www.tei-c.org/ns/1.0"> 
	  <xsl:apply-templates select="@*"/>
	  <xsl:attribute name="xml:id">
	    <xsl:value-of select="concat($element_name,'_',generate-id(.))"/><xsl:number level="any"  count="//node()" />
	  </xsl:attribute>
	  <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>
