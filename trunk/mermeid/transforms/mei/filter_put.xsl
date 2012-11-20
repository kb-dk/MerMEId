<?xml version="1.0" encoding="UTF-8" ?>
<!-- 
  Filter for cleaning MEI data when saving from MerMEId 
  
  Axel Teich Geertinger & Sigfrid Lundberg
  Danish Centre for Music Publication
  The Royal Library, Copenhagen
  
  HTML to MEI conversion by Johannes Kepper
-->
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.music-encoding.org/ns/mei" 
  xmlns:m="http://www.music-encoding.org/ns/mei" 
  xmlns:xl="http://www.w3.org/1999/xlink"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns:h="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  exclude-result-prefixes="xsl m t exsl"
  version="1.0">

  <xsl:param name="user" select="''"/>
  
  <xsl:output method="xml"
    encoding="UTF-8"
    omit-xml-declaration="yes" 
    indent="yes"/>
  <xsl:strip-space elements="*" />
  <xsl:strip-space elements="node"/>
  
  <xsl:template match="/">
    <xsl:variable name="new_doc">
      <xsl:apply-templates select="*" mode="convertEntities"/>
    </xsl:variable>
    <!--<xsl:copy-of select="$new_doc"/>-->
    <xsl:apply-templates select="exsl:node-set($new_doc)" mode="html2mei"/>
  </xsl:template>
  
  
  <!-- CLEANING UP MEI -->
  
  <!-- Generate a value for empty @xml:id -->
  <xsl:template match="@xml:id[.='']">
    <xsl:variable name="generated_id" select="generate-id()"/>
    <xsl:variable name="no_of_nodes" select="count(//*)"/>
    <xsl:attribute name="xml:id">
      <xsl:value-of select="concat(name(..),'_',$no_of_nodes,$generated_id)"/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- Remove empty attributes -->
  <xsl:template match="m:identifier/@type|@unit|@pname|@accid|@mode|@count|@sym|@code|@solo|
    @n|@evidence|@target|@targettype|
    @notbefore|@notafter|@reg|@isodate|@startdate|@enddate|@notAfter-iso|@notBefore-iso|@when-iso|
    @xml:lang">
    <xsl:if test="normalize-space(.)">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>    
  
  <!-- Remove empty elements -->
  <xsl:template match="m:castList[not(*)]"/>
  
  <!-- delete duplicate language definitions (fixes an xforms problem) -->
  <xsl:template match="m:mei/m:meiHead/m:workDesc/m:work/m:langUsage/m:language[. = preceding-sibling::m:language]"/>

  <!-- END CLEANING -->
  
  
  <!-- Entity conversion -->    
  <xsl:template match="@*|*" mode="convertEntities">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="convertEntities"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="text()" mode="convertEntities" priority="1">
    <xsl:call-template name="replace_nodes">
      <xsl:with-param name="text" select="."/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="replace_nodes">
    <xsl:param name="text"/>
    <xsl:choose>
      <xsl:when test="contains($text,'&lt;') and contains(substring-after($text,'&lt;'),'&gt;')">
        <xsl:copy-of select="substring-before($text,'&lt;')"/>
        <xsl:variable name="element_and_attr">
          <xsl:value-of select="substring-before(substring-after($text,'&lt;'),'&gt;')"/>
        </xsl:variable>
        <xsl:variable name="element">
          <xsl:choose>
            <xsl:when test="contains($element_and_attr,' ')">
              <xsl:value-of select="substring-before($element_and_attr,' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="contains($element_and_attr,'/')">
                  <xsl:value-of select="substring-before($element_and_attr,'/')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$element_and_attr"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="attributes">
          <xsl:if test="contains($element_and_attr,' ')">
            <xsl:value-of select="substring-after($element_and_attr,' ')"/>
          </xsl:if>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="contains($text,concat('&lt;/',$element,'&gt;'))">
            <xsl:variable name="begin" select="concat('&lt;',$element_and_attr,'&gt;')"/>
            <xsl:variable name="end"   select="concat('&lt;/',$element,'&gt;')"/>
            <!-- nodes are assumed to be HTML, hence the HTML namespace -->
            <xsl:element name="{$element}" namespace="http://www.w3.org/1999/xhtml">
              <xsl:call-template name="addAttributes">
                <xsl:with-param name="attrString" select="$attributes"/>
              </xsl:call-template>
              <xsl:call-template name="replace_nodes">
                <xsl:with-param name="text" select="substring-before(substring-after($text,$begin),$end)"/>
              </xsl:call-template>
            </xsl:element>
            <xsl:call-template name="replace_nodes">
              <xsl:with-param name="text" select="substring-after($text,$end)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <!-- No end element. Something like &lt;br/&gt;, &lt;br&gt; or &lt;img src=""/&gt; assumed -->                        
            <xsl:element name="{$element}" namespace="http://www.w3.org/1999/xhtml">
              <xsl:call-template name="addAttributes">
                <xsl:with-param name="attrString" select="$attributes"/>
              </xsl:call-template>
            </xsl:element>
            <xsl:call-template name="replace_nodes">
              <xsl:with-param name="text" select="substring-after($text,'&gt;')"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="addAttributes">
    <xsl:param name="attrString"/>
    <xsl:variable name="thisAttrPart1" select="normalize-space(substring-before($attrString,'&#34;'))"/>
    <xsl:variable name="thisAttrPart2" select="substring-before(substring-after($attrString,concat($thisAttrPart1,'&#34;')),'&#34;')"/>
    <xsl:variable name="attrName" select="substring-before($thisAttrPart1,'=')"/>
    <xsl:variable name="remainder" select="substring-after(substring-after($attrString,$thisAttrPart2),'&#34;')"/>
    <xsl:if test="$attrName">
      <xsl:attribute name="{$attrName}"><xsl:value-of 
        select="concat(substring-after($thisAttrPart1,'&#34;'),$thisAttrPart2)"/></xsl:attribute>
      <xsl:if test="normalize-space($remainder)!='' and normalize-space($remainder)!='/'">
        <xsl:call-template name="addAttributes">
          <xsl:with-param name="attrString" select="$remainder"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  <!-- End entity conversion -->    
  
  <!-- HTML -> MEI -->
  <xsl:template match="h:p"><xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei"><xsl:apply-templates select="@*|node()"/></xsl:element></xsl:template>
  <xsl:template match="h:br"><xsl:element name="lb" namespace="http://www.music-encoding.org/ns/mei"><xsl:apply-templates select="node()"/></xsl:element></xsl:template>
  <xsl:template match="h:b|h:strong"><xsl:element name="rend" namespace="http://www.music-encoding.org/ns/mei"><xsl:attribute name="fontweight">bold</xsl:attribute><xsl:apply-templates select="node()"/></xsl:element></xsl:template>
  <xsl:template match="h:i|h:em"><xsl:element name="rend" namespace="http://www.music-encoding.org/ns/mei"><xsl:attribute name="fontstyle">ital</xsl:attribute><xsl:apply-templates select="node()"/></xsl:element></xsl:template>
  <xsl:template match="h:u"><xsl:element name="rend" namespace="http://www.music-encoding.org/ns/mei"><xsl:attribute name="rend">underline</xsl:attribute><xsl:apply-templates select="node()"/></xsl:element></xsl:template>
  <xsl:template match="h:sub"><xsl:element name="rend" namespace="http://www.music-encoding.org/ns/mei"><xsl:attribute name="rend">sub</xsl:attribute><xsl:apply-templates select="node()"/></xsl:element></xsl:template>
  <xsl:template match="h:sup"><xsl:element name="rend" namespace="http://www.music-encoding.org/ns/mei"><xsl:attribute name="rend">sup</xsl:attribute><xsl:apply-templates select="node()"/></xsl:element></xsl:template>
  <xsl:template match="h:span">
    <xsl:choose>
      <!-- <span title="mei:persName" class="mei:atts[authority(GND),authURI(http://example.com)]">Gade</span> -->
      <xsl:when test="contains(@title,'mei:')">
        <xsl:variable name="tagName" select="substring-after(@title,'mei:')"/>
        <xsl:variable name="atts">
          <xsl:call-template name="tokenize">
            <xsl:with-param name="str" select="substring-before(substring-after(@class,'mei:atts['),']')"/>
            <xsl:with-param name="splitString" select="','"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:element name="{$tagName}" namespace="http://www.music-encoding.org/ns/mei">
          <xsl:for-each select="exsl:node-set($atts)/*">
            <xsl:variable name="attName" select="substring-before(.,'(')"/>
            <xsl:attribute name="{$attName}">
              <xsl:value-of select="substring-before(substring-after(.,'('),')')"/>
            </xsl:attribute>
          </xsl:for-each>
          <xsl:apply-templates select="node()"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="rend" namespace="http://www.music-encoding.org/ns/mei">
          <xsl:if test="contains(@style, 'font-family')">
            <xsl:attribute name="fontfam"><xsl:value-of select="normalize-space(substring-before(substring-after(@style,'font-family:'),';'))"/></xsl:attribute>
          </xsl:if>
          <xsl:if test="contains(@style, 'font-size')">
            <xsl:attribute name="fontsize"><xsl:value-of select="normalize-space(substring-before(substring-after(@style,'font-size:'),';'))"/></xsl:attribute>
          </xsl:if>
          <xsl:if test="contains(@style, 'color')">
            <xsl:attribute name="color"><xsl:value-of select="normalize-space(substring-before(substring-after(@style,'color:'),';'))"/></xsl:attribute>
          </xsl:if>
          <xsl:apply-templates select="node()"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="h:a">
    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:attribute name="target"><xsl:value-of select="@href"/></xsl:attribute>
      <xsl:attribute name="xl:show"><xsl:value-of select="@target"/></xsl:attribute>
      <xsl:attribute name="xl:title"><xsl:value-of select="@title"/></xsl:attribute>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="h:div[contains(@style,'text-align')]"><xsl:element name="rend" namespace="http://www.music-encoding.org/ns/mei"><xsl:attribute name="halign"><xsl:value-of select="substring-before(substring-after(@style,'text-align:'),';')"/></xsl:attribute><xsl:apply-templates select="node() | @*"/></xsl:element></xsl:template>
  <xsl:template match="h:ul">
    <xsl:element name="list" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:attribute name="form">simple</xsl:attribute>
      <xsl:for-each select="h:li"><xsl:element name="li" namespace="http://www.music-encoding.org/ns/mei"><xsl:apply-templates select="node() | @*"/></xsl:element></xsl:for-each>
    </xsl:element>
  </xsl:template>
  <xsl:template match="h:ol">
    <xsl:element name="list" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:attribute name="form">ordered</xsl:attribute>
      <xsl:for-each select="h:li"><xsl:element name="li" namespace="http://www.music-encoding.org/ns/mei"><xsl:apply-templates select="node() | @*"/></xsl:element></xsl:for-each>
    </xsl:element>
  </xsl:template>
  <xsl:template match="h:img">
    <xsl:element name="fig" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:element name="graphic">
        <xsl:attribute name="target"><xsl:value-of select="@src"/></xsl:attribute>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <!-- end HTML -> MEI -->
  
  <!-- utilities -->
  <xsl:template name="tokenize">
    <xsl:param name="str" select="."/>
    <xsl:param name="splitString" select="' '"/>
    <xsl:choose>
      <xsl:when test="contains($str,$splitString)">
        <token>
          <xsl:value-of select="substring-before($str,$splitString)"/>
        </token>
        <xsl:call-template name="tokenize">
          <xsl:with-param name="str"
            select="substring-after($str,$splitString)"/>
          <xsl:with-param name="splitString" select="$splitString"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <token><xsl:value-of select="$str"/></token>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- end utilities -->


  <xsl:template match="m:revisionDesc" mode="convertEntities">
    <xsl:if test="$user">
      <xsl:element name="revisionDesc">
	<xsl:for-each select="m:change">
	  <xsl:choose>
	    <xsl:when test="position()&lt;last()">
	      <xsl:apply-templates select="."/>
	    </xsl:when>
	    <xsl:otherwise>
	      <change>
		<xsl:copy-of select="@*"/>
		<respStmt>
		  <persName>
		    <xsl:value-of select="$user"/>
		  </persName>
		</respStmt>
		<changeDesc>
		  <p>
		    <xsl:value-of select="m:changeDesc/m:p"/>
		  </p>
		</changeDesc>
		<date>
		  <xsl:value-of select="m:date"/>
		</date>
	      </change>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:for-each>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  
 <xsl:template match="@*|node()" mode="html2mei">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  

</xsl:transform>
