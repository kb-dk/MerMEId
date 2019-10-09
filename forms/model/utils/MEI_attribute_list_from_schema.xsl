<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet 
    xmlns:rng="http://relaxng.org/ns/structure/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    version="1.0"
    exclude-result-prefixes="rng xsl">
    
    <xsl:output xml:space="default" indent="yes"/>
    
    <!-- Produces a list of elements and their attributes from relax RNG schema -->
    
    <xsl:template match="/">
        <elements xmlns:xlink="http://www.w3.org/1999/xlink">
            <xsl:apply-templates select="descendant::rng:element"/>
        </elements>
    </xsl:template>
    
    <xsl:template match="rng:element[@name and not(contains(parent::*/@name,'svg_'))]">
        <xsl:text>
        </xsl:text>
        <xsl:element name="{@name}">
            <xsl:apply-templates select="rng:ref[contains(@name,'att.') or contains(@name,'attlist')]"/>
            <xsl:apply-templates select="descendant::rng:attribute"/>            
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="rng:ref[@name]">
        <xsl:variable name="defName"><xsl:value-of select="@name"/></xsl:variable>
        <xsl:apply-templates select="/*/rng:define[@name=$defName]"/>
    </xsl:template>
    
    <xsl:template match="rng:define">
        <xsl:apply-templates select="rng:ref[contains(@name,'att.') or contains(@name,'attlist')]"/>
        <xsl:apply-templates select="descendant::rng:attribute"/>
    </xsl:template>
    
    <xsl:template match="rng:attribute[@name]">
        <xsl:attribute name="{@name}"/>
    </xsl:template>
    
</xsl:stylesheet>