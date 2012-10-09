<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet     
    xmlns="http://www.music-encoding.org/ns/mei" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xl="http://www.w3.org/1999/xlink" 
    xmlns:m="http://www.music-encoding.org/ns/mei" 
    xmlns:t="http://www.tei-c.org/ns/1.0" 
    exclude-result-prefixes="m xsl"
    version="2.0">
    
    <xsl:template match="@*|*">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="m:instrVoice">
        <instrVoice>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="@code='' or not(@code)">
                <xsl:variable name="code">
                    <xsl:call-template name="findCode">
                        <xsl:with-param name="input"><xsl:value-of select="."/></xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:if test="$code!=''">
                    <xsl:attribute name="code"><xsl:value-of select="$code"/></xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:value-of select="."/>
        </instrVoice>
    </xsl:template>
        
    <xsl:template name="findCode">
        <xsl:param name="input"/>
        <xsl:if test="contains($input,'cor.')">ba</xsl:if>
        <xsl:if test="contains($input,'tr.') or contains($input,'trp.') or contains($input,'trumpet')">bb</xsl:if>
        <xsl:if test="contains($input,'crnt.')">bc</xsl:if>
        <xsl:if test="contains($input,'trb.') or contains($input,'trombon')">bd</xsl:if>
        <xsl:if test="contains($input,'tb.') or contains($input,'tuba')">be</xsl:if>
        <xsl:if test="contains($input,'SATB') or contains($input,'SSAATTBB')">ca</xsl:if>
        <xsl:if test="$input='SA' or $input='SSA' or $input='SSAA' or $input='SAA'">cb</xsl:if>
        <xsl:if test="$input='TB' or $input='TTB' or $input='TTBB' or $input='TBB'">cc</xsl:if>
        <xsl:if test="contains($input,'pno.') or contains($input,'piano')">ka</xsl:if>
        <xsl:if test="contains($input,'org.') or contains($input,'organ')">kb</xsl:if>
        <xsl:if test="contains($input,'cemb.') or contains($input,'cembalo')">kc</xsl:if>
        <xsl:if test="contains($input,'b.c.') or contains($input,'bc.') or contains($input,'continuo')">ke</xsl:if>
        <xsl:if test="contains($input,'orch.') or contains($input,'orchestra')">oa</xsl:if>
        <xsl:if test="contains($input,'str.') or contains($input,'strings') or contains($input,'str4tet')">oc</xsl:if>
        <xsl:if test="contains($input,'brass')">of</xsl:if>
        <xsl:if test="contains($input,'timp.') or contains($input,'timpani')">pa</xsl:if>
        <xsl:if test="contains($input,'xyl')">pb</xsl:if>
        <xsl:if test="contains($input,'tamb') or contains($input,'flute')">pd</xsl:if>
        <xsl:if test="contains($input,'perc')">pn</xsl:if>
        <xsl:if test="contains($input,'ptti')">pz</xsl:if>
        <xsl:if test="contains($input,'vl.') or contains($input,'violin')">sa</xsl:if>
        <xsl:if test="contains($input,'vla.') or contains($input,'va.') or contains($input,'viola')">sb</xsl:if>
        <xsl:if test="contains($input,'vlc.') or contains($input,'vc.') or contains($input,'cello')">sc</xsl:if>
        <xsl:if test="contains($input,'cb.') or contains($input,'basso')">sd</xsl:if>
        <xsl:if test="contains($input,'arp.') or contains($input,'arpa')">wa</xsl:if>
        <xsl:if test="contains($input,'S.') or contains($input,'soprano')">va</xsl:if>
        <xsl:if test="contains($input,'Mez')">vb</xsl:if>
        <xsl:if test="contains($input,'A.')">vc</xsl:if>
        <xsl:if test="contains($input,'T.')">vd</xsl:if>
        <xsl:if test="contains($input,'Bar.')">ve</xsl:if>
        <xsl:if test="contains($input,'B.')">vf</xsl:if>
        <xsl:if test="contains($input,'v.') or contains($input,'voice')">vn</xsl:if>
        <xsl:if test="contains($input,'fl.') or contains($input,'flute')">wa</xsl:if>
        <xsl:if test="contains($input,'ob.') or contains($input,'obo')">wb</xsl:if>
        <xsl:if test="contains($input,'cl.') or contains($input,'clarinet')">wc</xsl:if>
        <xsl:if test="contains($input,'fg.') or contains($input,'bassoon') or contains($input,'fagot')">wd</xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
