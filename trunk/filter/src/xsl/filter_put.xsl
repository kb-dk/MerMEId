<xsl:transform xmlns="http://www.music-encoding.org/ns/mei" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xl="http://www.w3.org/1999/xlink" 
  xmlns:h="http://www.w3.org/1999/xhtml" 
  xmlns:m="http://www.music-encoding.org/ns/mei" 
  xmlns:local="urn:my-stuff" 
  xmlns:dcm="http://www.kb.dk/dcm" 
  exclude-result-prefixes="xsl m h dcm xl local" 
  version="3.0">

<!-- 
  Filter for cleaning MEI data when saving from MerMEId 
  
  Axel Teich Geertinger & Sigfrid Lundberg
  Danish Centre for Music Editing
  Royal Danish Library, Copenhagen
  
  2010-2019
  
  HTML to MEI conversion by Johannes Kepper

-->

  <xsl:param name="user" select="''"/>
  <xsl:param name="target" select="''"/>

  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>

  <xsl:key name="ids" match="*[@xml:id]" use="@xml:id"/>

  <xsl:strip-space elements="*"/>


  <xsl:variable name="settings" select="document('/editor/forms/mei/mermeid_configuration.xml')"/>
 

  <xsl:template match="/">
    <xsl:variable name="new_doc">
      <xsl:apply-templates select="*" mode="convertEntities"/>
    </xsl:variable>
    <xsl:apply-templates select="$new_doc" mode="html2mei"/>
  </xsl:template>

  <xsl:template match="m:music">
    <xsl:element name="music" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:choose>
        <!-- If no new content has been uploaded into <music>, reinstate the original content from the database. -->
        <xsl:when test="string-length($target)&gt;0 and not(m:body/*)">
          <xsl:apply-templates select="document($target)/m:mei/m:music/*"/>
        </xsl:when>
        <!-- Otherwise keep the uploaded encoding, overwriting any existing music data. -->
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  

  <!-- CLEANING UP MEI -->

  <!-- Generate a value for empty @xml:id -->
  <xsl:template match="@xml:id[.='']">
    <xsl:call-template name="fill_in_id"/>
  </xsl:template>

  <xsl:template name="make_id_if_absent">
    <xsl:if test="not(@xml:id and (string-length(@xml:id) &gt; 0))">
      <xsl:call-template name="fill_in_id"/>
    </xsl:if>
  </xsl:template>


  <xsl:template name="fill_in_id">
    <xsl:variable name="generated_id" select="generate-id()"/>
    <xsl:variable name="no_of_nodes" select="count(//*)"/>
    <xsl:attribute name="xml:id">
      <xsl:value-of select="concat(name(.),'_',$no_of_nodes,$generated_id)"/>
    </xsl:attribute>
  </xsl:template>

  <!-- Change duplicate IDs -->
  <xsl:template match="*[@xml:id and count(key('ids', @xml:id)) &gt; 1]">
    <xsl:variable name="duplicateID" select="@xml:id"/>
    <xsl:element name="{name()}">
      <xsl:apply-templates select="@*"/>
      <!-- Append a number to the ID according to its number of occurrence -->
      <xsl:variable name="newval">
        <xsl:choose>
          <xsl:when test="substring(@xml:id,1,1)='_'">
            <!-- add element name if xml:id seems to be something like '_13' -->
            <xsl:value-of select="concat(name(),@xml:id)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@xml:id"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:attribute name="xml:id">
        <xsl:value-of select="concat($newval,'_',count(preceding::*[@xml:id=$duplicateID]))"/>
      </xsl:attribute>
      <!-- To log changes: -->
      <!--<xsl:comment>Duplicate ID (<xsl:value-of select="$duplicateID"/>) changed</xsl:comment>-->
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>

  <!-- Add xml:id to certain elements if missing -->
  <xsl:template match="m:expression | m:item | m:bibl | m:perfRes | m:perfResList | m:castItem">
    <!-- Test if perfResList is like old instrumentation -->
    <xsl:element name="{name()}" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="make_id_if_absent"/>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>


  <!-- Remove empty attributes -->
  <xsl:template match="@accid|@auth|@auth-uri|@cert|@codedval|@count|@enddate|@evidence|     
    @isodate|@mode|@n|@notafter|@notbefore|@pname|@reg|@resp|     
    @solo|@startdate|@sym|@target|@targettype|@type|@unit|@xml:lang">
    <xsl:if test="normalize-space(.)">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>


  <!-- Remove empty elements -->
  <xsl:template match="m:castItem[not(//text())]"/>
  <xsl:template match="m:castList[not(*)]"/>
  <xsl:template match="m:eventList[not(*)]"/>
  <xsl:template match="m:incipCode[not(text())]"/>
  <xsl:template match="m:notesStmt[not(*)]"/>
  <xsl:template match="m:provenance[not(* or //text())]"/>
  <xsl:template match="m:rend[not(* or //text())]"/>
  <xsl:template match="m:mei/m:meiHead//m:score[not(*)]"/>
  <xsl:template match="m:titlePage[not(*)]"/>
  
  
  <!-- Clean up double-escaped ampersands (&amp;) -->
  <xsl:template match="text()[contains(.,'&amp;amp;')]">
    <xsl:call-template name="cleanup_amp">
      <xsl:with-param name="string" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="cleanup_amp">
    <xsl:param name="string"/>
    <xsl:variable name="remainder" select="substring-after($string,'&amp;amp;')"/>
    <xsl:value-of select="substring-before($string,'&amp;amp;')"/>&amp;<xsl:choose>
      <xsl:when test="contains($remainder,'&amp;amp;')">
                <xsl:call-template name="cleanup_amp">
          <xsl:with-param name="string" select="$remainder"/>
                </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
                <xsl:value-of select="$remainder"/>
            </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Trying to convert &nbsp; to &#160; ... -->
  <xsl:template match="text()[contains(.,'&amp;nbsp;')]">
    <xsl:call-template name="cleanup_nbsp">
      <xsl:with-param name="string" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="cleanup_nbsp">
    <xsl:param name="string"/>
    <xsl:variable name="remainder" select="substring-after($string,'&amp;nbsp;')"/>
    <xsl:value-of select="substring-before($string,'&amp;nbsp;')"/>&#160;<xsl:choose>
      <xsl:when test="contains($remainder,'&amp;nbsp;')">
        <xsl:call-template name="cleanup_nbsp">
          <xsl:with-param name="string" select="$remainder"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$remainder"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Delete duplicate language definitions (fixes an xforms problem) -->
  <xsl:template match="m:mei/m:meiHead/m:workList/m:work/m:langUsage/m:language[. = preceding-sibling::m:language]"/>

  <!-- Remove <rend> elements without any rendition information or empty -->
  <xsl:template match="m:rend">
    <xsl:choose>
      <xsl:when test="count(@*[local-name(.)!='xml:id'])&gt;0 and (* or text())">
        <!-- contains relevant attributes and content; just copy it -->
        <xsl:element name="rend" namespace="http://www.music-encoding.org/ns/mei">
          <xsl:apply-templates select="@*"/>
          <xsl:apply-templates select="node()"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <!-- no qualifying attributes or no content; omit <rend> -->
        <xsl:apply-templates select="node()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Ensure correct order of elements -->

  <xsl:template match="m:biblList">
    <xsl:element name="biblList" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="make_id_if_absent"/>
      <xsl:apply-templates select="m:head"/>
      <xsl:apply-templates select="m:bibl"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="m:source">
    <xsl:element name="source" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="make_id_if_absent"/>
      <xsl:apply-templates select="m:identifier"/>
      <xsl:apply-templates select="m:titleStmt"/>
      <xsl:apply-templates select="m:editionStmt"/>
      <xsl:apply-templates select="m:pubStmt"/>
      <xsl:apply-templates select="m:physDesc"/>
      <xsl:apply-templates select="m:physLoc"/>
      <xsl:apply-templates select="m:seriesStmt"/>
      <xsl:apply-templates select="m:contents"/>
      <xsl:apply-templates select="m:langUsage"/>
      <xsl:apply-templates select="m:notesStmt"/>
      <xsl:apply-templates select="m:classification"/>
      <xsl:apply-templates select="m:itemList"/>
      <xsl:apply-templates select="m:componentList"/>
      <xsl:apply-templates select="m:relationList"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="m:work">
    <xsl:element name="work" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="make_id_if_absent"/>
      <xsl:apply-templates select="m:identifier"/>
      <xsl:apply-templates select="m:titleStmt"/>
      <xsl:apply-templates select="m:incip"/>
      <xsl:apply-templates select="m:tempo"/>
      <xsl:apply-templates select="m:key"/>
      <xsl:apply-templates select="m:mensuration"/>
      <xsl:apply-templates select="m:meter"/>
      <xsl:apply-templates select="m:otherChar"/>
      <xsl:apply-templates select="m:creation"/>
      <xsl:apply-templates select="m:history"/>
      <xsl:apply-templates select="m:langUsage"/>
      <xsl:apply-templates select="m:perfMedium"/>
      <xsl:apply-templates select="m:perfDuration"/>
      <xsl:apply-templates select="m:extent"/>
      <xsl:apply-templates select="m:audience"/>
      <xsl:apply-templates select="m:contents"/>
      <xsl:apply-templates select="m:context"/>
      <xsl:apply-templates select="m:biblList"/>
      <xsl:apply-templates select="m:notesStmt"/>
      <xsl:apply-templates select="m:classification"/>
      <xsl:apply-templates select="m:expressionList"/>
      <xsl:apply-templates select="m:componentList"/>
      <xsl:apply-templates select="m:relationList"/>
    </xsl:element>
  </xsl:template>


  <xsl:template match="m:expression">
    <xsl:element name="expression" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="make_id_if_absent"/>
      <xsl:apply-templates select="m:identifier"/>
      <xsl:apply-templates select="m:titleStmt"/>
      <xsl:apply-templates select="m:incip"/>
      <xsl:apply-templates select="m:tempo"/>
      <xsl:apply-templates select="m:key"/>
      <xsl:apply-templates select="m:mensuration"/>
      <xsl:apply-templates select="m:meter"/>
      <xsl:apply-templates select="m:otherChar"/>
      <xsl:apply-templates select="m:creation"/>
      <xsl:apply-templates select="m:history"/>
      <xsl:apply-templates select="m:perfMedium"/>
      <xsl:apply-templates select="m:perfDuration"/>
      <xsl:apply-templates select="m:extent"/>
      <xsl:apply-templates select="m:audience"/>
      <xsl:apply-templates select="m:contents"/>
      <xsl:apply-templates select="m:context"/>
      <xsl:apply-templates select="m:biblList"/>
      <xsl:apply-templates select="m:notesStmt"/>
      <xsl:apply-templates select="m:classification"/>
      <xsl:apply-templates select="m:expressionList"/>
      <xsl:apply-templates select="m:componentList"/>
      <xsl:apply-templates select="m:relationList"/>
    </xsl:element>
  </xsl:template>
  

  <!-- END CLEANING -->


  <!-- Convert entities to nodes -->
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
            <xsl:variable name="end" select="concat('&lt;/',$element,'&gt;')"/>
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
            <!-- No end element. Something like <br/>, <br> or <img src=""/> assumed -->
            <xsl:if test="string-length($element) &gt; 0">
              <xsl:element name="{$element}" namespace="http://www.w3.org/1999/xhtml">
                <xsl:call-template name="addAttributes">
                  <xsl:with-param name="attrString" select="$attributes"/>
                </xsl:call-template>
              </xsl:element>
            </xsl:if>
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
      <xsl:attribute name="{$attrName}">
        <xsl:value-of select="$thisAttrPart2"/>
      </xsl:attribute>
      <xsl:if test="normalize-space($remainder)!='' and normalize-space($remainder)!='/'">
        <xsl:call-template name="addAttributes">
          <xsl:with-param name="attrString" select="$remainder"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- End entity conversion -->

  <!-- HTML -> MEI -->

  <!-- Strip off any temporary <p> wrappers for TinyMCE -->
  <xsl:template match="m:p[@n='MerMEId_temporary_wrapper']">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="h:p">
    <xsl:choose>
      <xsl:when test="not(normalize-space(.) or *)"><!-- filter away empty paragraphs --></xsl:when>
      <!-- Some text-containing elements don't allow <p>; convert any <p> elements created by tinyMCE 
           to line breaks where necessary -->
      <xsl:when test="name(..)='physMedium' or name(..)='watermark' or name(..)='condition' or name(..)='desc'">
        <xsl:apply-templates select="node()"/>
        <xsl:if test="normalize-space(following-sibling::*//text())">
          <!-- Don't add a line break after the last paragraph -->
          <xsl:element name="lb" namespace="http://www.music-encoding.org/ns/mei"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
          <xsl:apply-templates select="@*"/>
          <!--<xsl:call-template name="make_id_if_absent"/>-->
          <xsl:apply-templates select="node()"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="h:br">
    <!-- For some reason, the RTE editor sometimes adds a line break at the end of the edited contents. Removing it here -->
    <xsl:if test="following-sibling::node() or normalize-space(following-sibling::text())">
      <xsl:element name="lb" namespace="http://www.music-encoding.org/ns/mei"/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="h:b|h:strong">
    <xsl:element name="rend" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:attribute name="fontweight">bold</xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="h:i|h:em">
    <xsl:element name="rend" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:attribute name="fontstyle">italic</xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="h:u|h:span[@style='text-decoration: underline;']">
    <xsl:element name="rend" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:attribute name="rend">underline</xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="h:sub">
    <xsl:element name="rend" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:attribute name="rend">sub</xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="h:sup">
    <xsl:element name="rend" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:attribute name="rend">sup</xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="h:span">
    <xsl:choose>
      <xsl:when test="contains(@title,'mei:')">
        <!-- Translate encodings like this to MEI: <span title="mei:persName" class="mei:atts[authURI(http://www.viaf.org),codedval(12345))]">Niels Gade</span> -->
        <xsl:variable name="tagName" select="substring-after(@title,'mei:')"/>
        <xsl:variable name="atts">
          <xsl:call-template name="tokenize">
            <xsl:with-param name="str" select="substring-before(substring-after(@class,'mei:atts['),']')"/>
            <xsl:with-param name="splitString" select="','"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:element name="{$tagName}" namespace="http://www.music-encoding.org/ns/mei">
          <xsl:for-each select="$atts/*">
            <xsl:variable name="attName" select="substring-before(.,'(')"/>
            <xsl:attribute name="{$attName}">
              <xsl:value-of select="substring-before(substring-after(.,'('),')')"/>
            </xsl:attribute>
          </xsl:for-each>
          <xsl:apply-templates select="node()"/>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains(@class,'dblunderline')">
        <xsl:element name="rend" namespace="http://www.music-encoding.org/ns/mei">
          <xsl:attribute name="rend">underline(2)</xsl:attribute>
          <xsl:apply-templates select="node()"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="rend" namespace="http://www.music-encoding.org/ns/mei">
          <xsl:if test="contains(@style, 'font-family')">
            <xsl:attribute name="fontfam">
              <xsl:value-of select="normalize-space(substring-before(substring-after(@style,'font-family:'),';'))"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="contains(@style, 'font-size')">
            <xsl:attribute name="fontsize">
              <xsl:value-of select="normalize-space(substring-before(substring-after(@style,'font-size:'),';'))"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="contains(@style, 'color')">
            <xsl:attribute name="color">
              <xsl:value-of select="normalize-space(substring-before(substring-after(@style,'color:'),';'))"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="contains(@style, 'text-decoration: line-through')">
            <xsl:attribute name="rend">line-through</xsl:attribute>
          </xsl:if>
          <xsl:apply-templates select="node()"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="h:a">
    <xsl:choose>
      <xsl:when test="@href">
        <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
          <xsl:attribute name="target">
            <xsl:value-of select="@href"/>
          </xsl:attribute>
          <xsl:if test="@target">
            <xsl:attribute name="xl:show">
              <xsl:choose>
                <xsl:when test="@target='_blank'">new</xsl:when>
                <xsl:when test="@target='_self'">replace</xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="@target"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@title">
            <xsl:attribute name="label">
              <xsl:value-of select="@title"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates select="node()"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="node()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="h:div[contains(@style,'text-align')] | h:p[contains(@style,'text-align')]">
    <xsl:element name="rend" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:attribute name="halign">
        <xsl:value-of select="substring-before(substring-after(@style,'text-align:'),';')"/>
      </xsl:attribute>
      <xsl:apply-templates select="node()"/>
      <xsl:call-template name="make_id_if_absent"/>
      <xsl:apply-templates select="@*"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="h:ul">
    <xsl:element name="list" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:attribute name="form">simple</xsl:attribute>
      <xsl:for-each select="h:li">
        <xsl:element name="li" namespace="http://www.music-encoding.org/ns/mei">
          <xsl:apply-templates select="node()"/>
          <xsl:call-template name="make_id_if_absent"/>
          <xsl:apply-templates select="@*"/>
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template match="h:ol">
    <xsl:element name="list" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:attribute name="form">ordered</xsl:attribute>
      <xsl:for-each select="h:li">
        <xsl:element name="li" namespace="http://www.music-encoding.org/ns/mei">
          <xsl:apply-templates select="node()"/>
          <xsl:call-template name="make_id_if_absent"/>
          <xsl:apply-templates select="@*"/>
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template match="h:img">
    <xsl:element name="fig" namespace="http://www.music-encoding.org/ns/mei">
      <xsl:element name="graphic">
        <xsl:attribute name="label">
          <xsl:value-of select="@title"/>
        </xsl:attribute>
        <xsl:attribute name="label">
          <xsl:value-of select="@alt"/>
        </xsl:attribute>
        <xsl:attribute name="target">
          <xsl:value-of select="@src"/>
        </xsl:attribute>
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
          <xsl:with-param name="str" select="substring-after($str,$splitString)"/>
          <xsl:with-param name="splitString" select="$splitString"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <token>
          <xsl:value-of select="$str"/>
        </token>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- end utilities -->

  <xsl:template match="m:revisionDesc" mode="convertEntities">
    <xsl:element name="revisionDesc">
      <xsl:variable name="penultimate" select="count(m:change)-1"/>
      <xsl:variable name="penultimateChange" select="m:change[$penultimate]"/>
      <xsl:variable name="penultimateDay" select="concat($penultimateChange/@isodate[not(contains(.,'T'))],substring-before($penultimateChange/@isodate,'T'))"/>
      <xsl:variable name="today" select="concat(m:change[last()]/@isodate[not(contains(.,'T'))],substring-before(m:change[last()]/@isodate,'T'))"/>
      <xsl:choose>
        <xsl:when test="$user">
            <xsl:choose>
              <xsl:when test="$settings/dcm:parameters/dcm:automatic_log_main_switch='true'                 
                and $penultimate &gt; 0                 
                and not(m:change[$penultimate]/m:changeDesc//text())                 
                and not(m:change[last()]//text())                 
                and $penultimateDay=$today                 
                and $penultimateChange/m:respStmt/m:resp=$user                 
                and (m:change[last()]/m:respStmt/m:resp=$user or m:change[last()]/m:respStmt/m:resp='')                 
                ">
                <!-- last entry is just a new save from the same user with no change description - just update the last timestamp -->
                <xsl:for-each select="m:change">
                  <xsl:choose>
                    <xsl:when test="position() &lt; $penultimate">
                      <xsl:apply-templates select="."/>
                    </xsl:when>
                    <xsl:when test="position() = $penultimate">
                      <change>
                        <xsl:copy-of select="@*"/>
                        <xsl:attribute name="isodate">
                          <xsl:value-of select="../m:change[last()]/@isodate"/>
                        </xsl:attribute>
                        <xsl:apply-templates select="*"/>
                      </change>
                    </xsl:when>
                    <xsl:otherwise>
                      <!-- skip the last row -->
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>  
              </xsl:when>
              <xsl:otherwise>
                <!-- just make sure to add the user name to the last entry if missing -->
                <xsl:for-each select="m:change">
                  <xsl:choose>
                    <xsl:when test="position()=last() and not(normalize-space(m:respStmt/m:name))">
                      <change>
                        <xsl:copy-of select="@*"/>
                        <xsl:call-template name="make_id_if_absent"/>
                        <respStmt>
                          <name><xsl:value-of select="$user"/></name>
                        </respStmt>
                        <xsl:apply-templates select="m:changeDesc"/>
                      </change>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:apply-templates select="."/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <!-- user unknown, just copy the change log unchanged -->
          <xsl:for-each select="m:change">
            <xsl:apply-templates select="."/>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
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