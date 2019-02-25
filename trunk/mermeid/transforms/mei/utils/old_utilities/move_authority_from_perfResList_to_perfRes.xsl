<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.music-encoding.org/ns/mei"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:m="http://www.music-encoding.org/ns/mei"
    xmlns:xl="http://www.w3.org/1999/xlink" 
    xmlns:date="http://exslt.org/dates-and-times"
    version="1.0" 
    exclude-result-prefixes="m xsl xl date">

    <!--  
        Move @authority and @authURI values from <perfResList> to <perfRes>.
        This allows @codedval values to be interpreted unambiguously when switching from one
        code standard to another (for instance, from MARC to UNIMARC).     
        DCM, July 2017
    -->
    
    
    <xsl:output indent="yes" xml:space="default" method="xml" encoding="UTF-8"
        omit-xml-declaration="yes"/>
    
    
    <!-- keep authority information only if element has a @codedval --> 
    <xsl:template match="m:perfMedium[@analog='marc:048'] |
        m:perfResList[not(@codedval) and (@authority or @authURI)] | 
        m:perfRes[not(@codedval) and (@authority or @authURI)]">
        <xsl:copy>
            <xsl:apply-templates select="@*[not(name()='analog' or name()='authority' or name()='authURI')] | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- add ancestor's authority references to each instrumentation element having a @codedval -->
    <xsl:template match="m:perfResList[@codedval and not(@authority or @authURI)][ancestor::m:perfResList/@auhority or 
        ancestor::m:perfResList/@authURI or ancestor::m:perfMedium[@analog='marc:048']] | 
        m:perfRes[@codedval and not(@authority or @authURI)][ancestor::m:perfResList/@authority or 
        ancestor::m:perfResList/@authURI or ancestor::m:perfMedium[@analog='marc:048']]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <!-- use ancestor's @authority an @authURI if possible -->
                <xsl:when test="ancestor::m:perfResList/@auhority or ancestor::m:perfResList/@authURI">
                    <xsl:attribute name="authority"><xsl:value-of select="ancestor::m:perfResList[@authority][1]/@authority"/></xsl:attribute>
                    <xsl:attribute name="authURI"><xsl:value-of select="ancestor::m:perfResList[@authURI][1]/@authURI"/></xsl:attribute>
                </xsl:when>
                <!-- otherwise rely on <perfMedium>'s @analog='marc:048'  -->
                <xsl:otherwise>
                    <xsl:attribute name="authority">MARC</xsl:attribute>
                    <xsl:attribute name="authURI">https://www.loc.gov/standards/valuelist/marcmusperf.html</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Add a record of the changes to revisionDesc if any changes were made -->
    <xsl:template match="m:revisionDesc[
         //m:perfMedium[@analog='marc:048'] |
         //m:perfResList[not(@codedval) and (@authority or @authURI)] | 
         //m:perfRes[not(@codedval) and (@authority or @authURI)] |
         //m:perfResList[@codedval and not(@authority or @authURI)][ancestor::m:perfResList/@auhority or 
         ancestor::m:perfResList/@authURI or ancestor::m:perfMedium[@analog='marc:048']] | 
         //m:perfRes[@codedval and not(@authority or @authURI)][ancestor::m:perfResList/@authority or 
         ancestor::m:perfResList/@authURI or ancestor::m:perfMedium[@analog='marc:048']]
        ]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <change>
                <xsl:attribute name="isodate"><xsl:value-of select="concat(substring-before(date:date-time(),'+'),'Z')"/></xsl:attribute>
                <xsl:variable name="generated_id" select="generate-id()"/>
                <xsl:variable name="no_of_nodes" select="count(//*)"/>
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="concat('change_',$no_of_nodes,$generated_id)"/>
                </xsl:attribute>
                <respStmt>
                    <resp>MerMEId</resp>
                </respStmt>
                <changeDesc>
                    <p>Instrumentation authority references updated</p>
                </changeDesc>
            </change>
        </xsl:copy>
    </xsl:template>
        
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
