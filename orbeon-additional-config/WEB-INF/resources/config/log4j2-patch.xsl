<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:variable name="orbeon_log4j2" select="doc('./log4j2.xml')"/>
    
    <xsl:template match="Appenders">
        <Appenders>
            <Console name="STDOUT">
                <PatternLayout pattern="%d{DATE} [%t] %-5p (%F [%M]:%L) - %m %n"/>
            </Console>
            <xsl:apply-templates select="(node()|comment())[not(self::Console)]"/>
            <xsl:apply-templates select="$orbeon_log4j2/Configuration/Appenders/(node()|comment())[not(self::Console)]"/>
        </Appenders>    
    </xsl:template>
    
    <xsl:template match="Loggers">
        <Loggers>
            <xsl:apply-templates select="$orbeon_log4j2/Configuration/Loggers/(node()|comment())[not(self::Root)]"/>            
            <xsl:apply-templates select="(node()|comment())[not(self::Root)]"/>
            <Root level="info">
                <AppenderRef ref="exist.core"/>
            </Root>
            <!--Root level="debug">
                <AppenderRef ref="STDOUT"/>
            </Root-->
        </Loggers>    
    </xsl:template>
    
    <xsl:template match="@*|node()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()|comment()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>