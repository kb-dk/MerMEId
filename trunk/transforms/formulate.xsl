<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:h="http://www.w3.org/1999/xhtml" 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:x="http://www.w3.org/2002/xforms" 
  xmlns:xf="http://www.w3.org/2002/xforms"
  xmlns:xxforms="http://orbeon.org/oxf/xml/xforms"
  xmlns:t="http://www.tei-c.org/ns/1.0" 
  xmlns:ev="http://www.w3.org/2001/xml-events"
  exclude-result-prefixes="x" version="1.0">

  <!--

  Adjusts a XForm for creating a form for editing an existing object
  Author: Sigfrid Lundberg (slu@kb.dk)
  $Revision: 1.12 $ last modified $Date: 2011/05/18 13:04:09 $ by $Author: slu $
  -->

  <xsl:param name="read_xml_file" select="'mods99042030.xml'"/>
  <xsl:param name="save_xml_file" select="'mods99042030.xml'"/>
  <xsl:param name="empty_xml_file" select="'mods99042030.xml'"/>
  <xsl:param name="repository" select="'http:/storage/list_files.xq'"/>
  <xsl:param name="host_port" select="''"/>

  <xsl:param name="save_method" select="'put'"/>

  <xsl:output indent="yes" encoding="UTF-8"/>

  <xsl:template match="/">
    <!--xsl:processing-instruction name="xml-stylesheet">
      href="/orbeon_editor/xsltforms/xsltforms.xsl" type="text/xsl"
    </xsl:processing-instruction>

    <xsl:processing-instruction name="xsltforms-options">
      debug="yes"
    </xsl:processing-instruction-->

    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="html">

    <h:html xmlns:xf="http://www.w3.org/2002/xforms" xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:m="http://www.loc.gov/mods/v3" xmlns:ev="http://www.w3.org/2001/xml-events"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <xsl:apply-templates/>
    </h:html>
  </xsl:template>

  <xsl:template match="x:model">

    <xf:model>

      <xf:instance xmlns="http://www.music-encoding.org/ns/mei" id="data-instance"
        src="{$read_xml_file}"/>

      <xf:instance xmlns="http://www.music-encoding.org/ns/mei" id="empty-instance"
        src="{$empty_xml_file}"/>

      <xf:submission id="read-from-file" method="get" action="{$read_xml_file}" replace="instance"
        instance="data-instance"/>

      <!--  <xf:submission id="save-to-file" method="{$save_method}" action="{$save_xml_file}"
      replace="all" instance="data-instance"/> -->
      <xf:submission id="save-to-file" method="{$save_method}" action="{$save_xml_file}"
        instance="data-instance" replace="instance" validate="false" relevant="false" 
        xxforms:calculate="false">
      </xf:submission>
      
      <!-- instances providing pre-defined data -->
      <xf:instance xmlns="http://www.tei-c.org/ns/1.0" id="bibl-type-instance"
        src="{$host_port}/editor/forms/mei/model/bibl_reference_types.xml"/>
      
      <xf:instance xmlns="http://www.tei-c.org/ns/1.0" id="bibliography-instance"
        src="{$host_port}/editor/forms/mei/model/standard_bibliography.xml"/>

      <xf:instance xmlns="http://www.music-encoding.org/ns/mei" id="instrumentation-instance"
        src="{$host_port}/editor/forms/mei/model/standard_instrumentation.xml"/>

      <xf:instance xmlns="http://www.music-encoding.org/ns/mei" id="keywords-instance"
        src="{$host_port}/editor/forms/mei/model/keywords.xml"/>
      
      <xf:instance xmlns="http://www.music-encoding.org/ns/mei" id="languages-instance"
        src="{$host_port}/editor/forms/mei/model/languages.xml"/>
            
      <xf:instance xmlns="http://www.music-encoding.org/ns/mei" id="relators-instance"
        src="{$host_port}/editor/forms/mei/model/relators.xml"/>

      <!-- "onload" xforms actions -->
      <xf:action ev:event="xforms-ready">
        <!-- automatically add change entry in revisionDesc -->
        <xf:action if="instance('data-instance')/m:meihead/m:revisiondesc/m:change[last()]/m:date!=''">
          <xf:insert 
            nodeset="instance('data-instance')/m:meihead/m:revisiondesc/m:change" 
            at="last()" 
            position="after" 
            origin="instance('empty-instance')/m:meihead/m:revisiondesc/m:change"/>
          <xf:setvalue ref="instance('data-instance')/m:meihead/m:revisiondesc/m:change[last()]/m:date" value="substring-before(now(), 'T')"/>
        </xf:action>
        <xf:action if="instance('data-instance')/m:meihead/m:revisiondesc/m:change[last()]/m:date=''">
          <xf:setvalue ref="instance('data-instance')/m:meihead/m:revisiondesc/m:change[last()]/m:date" value="substring-before(now(), 'T')"/>
        </xf:action>
      </xf:action>      
      
    </xf:model>
    
  </xsl:template>

  <xsl:template match="//h:p[@class='menu']">
    <p id="view_menu">
      <xsl:element name="xf:submit">
        <xsl:attribute name="submission">save-to-file</xsl:attribute>
        <xsl:attribute name="appearance">minimal</xsl:attribute>
        <xsl:attribute name="title">Save</xsl:attribute>
        <xsl:element name="xf:label">
          <xsl:element name="h:img">
            <xsl:attribute name="src">http:/editor/images/save.gif</xsl:attribute>
            <xsl:attribute name="alt">Save file</xsl:attribute>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <xsl:text>  </xsl:text>

      <xsl:element name="a">
        <xsl:attribute name="href">
          <xsl:value-of select="concat('http:/editor/scripts/get-exist.cgi?file=',
				        $save_xml_file)"/>
        </xsl:attribute>
        <xsl:attribute name="target">html_view</xsl:attribute>
        <xsl:attribute name="title">View as HTML</xsl:attribute>
        <xsl:element name="h:img">
          <xsl:attribute name="src">http:/editor/images/html.gif</xsl:attribute>
          <xsl:attribute name="alt">HTML</xsl:attribute>
          <xsl:attribute name="border">0</xsl:attribute>
        </xsl:element>
      </xsl:element>
      <xsl:text>  </xsl:text>

      <xsl:element name="a">
        <xsl:attribute name="href">
          <xsl:value-of select="$save_xml_file"/>
        </xsl:attribute>
        <xsl:attribute name="target">xml_view</xsl:attribute>
        <xsl:attribute name="title">View XML data</xsl:attribute>
        <xsl:element name="h:img">
          <xsl:attribute name="src">http:/editor/images/xml.gif</xsl:attribute>
          <xsl:attribute name="alt">XML</xsl:attribute>
          <xsl:attribute name="border">0</xsl:attribute>
        </xsl:element>
      </xsl:element>
      <xsl:text>  </xsl:text>
      
      <xsl:element name="a">
        <xsl:attribute name="href">http:/storage/list_files.xq</xsl:attribute>
        <xsl:attribute name="title">Close editor and return to file list</xsl:attribute>
        <xsl:element name="h:img">
          <xsl:attribute name="src">http:/editor/images/home.gif</xsl:attribute>
          <xsl:attribute name="alt">Return to file list</xsl:attribute>
          <xsl:attribute name="border">0</xsl:attribute>
        </xsl:element>
      </xsl:element>
      
    </p>
  </xsl:template>


  <!-- edit buttons -->
  <xsl:template match="h:span[@class='editmenu']/xf:trigger">
    <xsl:variable name="node" select="h:span[@class='node']"/>
    <xsl:variable name="index" select="h:span[@class='index']"/>
    <xsl:variable name="model" select="h:span[@class='model']"/>
    <xsl:if test="contains(@class,'up') or contains(@class,'all')">
      <xsl:call-template name="trigger_up">
        <xsl:with-param name="node" select="$node"/>
        <xsl:with-param name="index" select="$index"/>
        <xsl:with-param name="model" select="$model"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="contains(@class,'down') or contains(@class,'all')">
      <xsl:call-template name="trigger_down">
        <xsl:with-param name="node" select="$node"/>
        <xsl:with-param name="index" select="$index"/>
        <xsl:with-param name="model" select="$model"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="contains(@class,'copy') or contains(@class,'all')">
      <xsl:call-template name="trigger_copy">
        <xsl:with-param name="node" select="$node"/>
        <xsl:with-param name="index" select="$index"/>
        <xsl:with-param name="model" select="$model"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="contains(@class,'add') or contains(@class,'all')">
      <xsl:call-template name="trigger_add">
        <xsl:with-param name="node" select="$node"/>
        <xsl:with-param name="index" select="$index"/>
        <xsl:with-param name="model" select="$model"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="contains(@class,'delete') or contains(@class,'all')">
      <xsl:call-template name="trigger_delete">
        <xsl:with-param name="node" select="$node"/>
        <xsl:with-param name="index" select="$index"/>
        <xsl:with-param name="model" select="$model"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="trigger_up">
    <xsl:param name="node"/>
    <xsl:param name="index"/>
    <xsl:param name="model"/>
    <xf:group>
      <xsl:attribute name="ref">.[empty(preceding-sibling::<xsl:value-of select="$node"/>)]</xsl:attribute>
      <h:img src="http:/editor/images/arrow_up_disabled.gif" class="button_patch"/>
    </xf:group>
    <xf:trigger appearance="minimal">
      <xsl:attribute name="ref">.[exists(preceding-sibling::<xsl:value-of select="$node"/>)]</xsl:attribute>
      <xf:label>
        <h:img src="http:/editor/images/arrow_up.gif" alt="Up" title="Move up"/>
      </xf:label>
      <xf:insert context="parent::node()" ev:event="DOMActivate">
        <xsl:attribute name="origin"><xsl:value-of select="$node"/>[index('<xsl:value-of select="$index"/>')]</xsl:attribute>
        <xsl:attribute name="nodeset"><xsl:value-of select="$node"/>[index('<xsl:value-of select="$index"/>')-2]</xsl:attribute>
      </xf:insert>
      <xf:delete ev:event="DOMActivate">
        <xsl:attribute name="nodeset">../<xsl:value-of select="$node"/></xsl:attribute>
        <xsl:attribute name="at">index('<xsl:value-of select="$index"/>')+2</xsl:attribute>
      </xf:delete>
    </xf:trigger>
  </xsl:template>

  <xsl:template name="trigger_down">
    <xsl:param name="node"/>
    <xsl:param name="index"/>
    <xsl:param name="model"/>
    <xf:group>
      <xsl:attribute name="ref">.[empty(following-sibling::<xsl:value-of select="$node"/>)]</xsl:attribute>
      <h:img src="http:/editor/images/arrow_down_disabled.gif" class="button_patch"/>
    </xf:group>
    <xf:trigger appearance="minimal">
      <xsl:attribute name="ref">.[exists(following-sibling::<xsl:value-of select="$node"/>)]</xsl:attribute>
      <xf:label class="">
        <h:img src="http:/editor/images/arrow_down.gif" alt="Down" title="Move down"/>
      </xf:label>
      <xf:insert context="parent::node()" ev:event="DOMActivate">
        <xsl:attribute name="origin"><xsl:value-of select="$node"/>[index('<xsl:value-of select="$index"/>')]</xsl:attribute>
        <xsl:attribute name="nodeset"><xsl:value-of select="$node"/>[index('<xsl:value-of select="$index"/>')+1]</xsl:attribute>
      </xf:insert>  
      <xf:delete ev:event="DOMActivate">
        <xsl:attribute name="nodeset">../<xsl:value-of select="$node"/></xsl:attribute>
        <xsl:attribute name="at">index('<xsl:value-of select="$index"/>')-2</xsl:attribute>
      </xf:delete>
    </xf:trigger>
  </xsl:template>
  
  <xsl:template name="trigger_copy">
    <xsl:param name="node"/>
    <xsl:param name="index"/>
    <xsl:param name="model"/>
    <xf:trigger appearance="minimal">
      <xf:label>
        <h:img src="http:/editor/images/copy.gif" alt="Copy" title="Duplicate row"/>
      </xf:label>
      <xf:insert context="parent::node()" ev:event="DOMActivate">
        <xsl:attribute name="origin"><xsl:value-of select="$node"/>[index('<xsl:value-of select="$index"/>')]</xsl:attribute>
        <xsl:attribute name="nodeset"><xsl:value-of select="$node"/>[index('<xsl:value-of select="$index"/>')]</xsl:attribute>
      </xf:insert>
    </xf:trigger>
  </xsl:template>
  
  <xsl:template name="trigger_delete">
    <xsl:param name="node"/>
    <xsl:param name="index"/>
    <xsl:param name="model"/>
    <xf:group>
      <xsl:attribute name="ref">../<xsl:value-of select="$node"/>[last()=1]</xsl:attribute>
      <h:img src="http:/editor/images/remove_disabled.gif" class="button_patch"/>
    </xf:group>
    <xf:trigger appearance="minimal">
      <xsl:attribute name="ref">../<xsl:value-of select="$node"/>[last()&gt;1]</xsl:attribute>
      <xf:label>
        <h:img src="http:/editor/images/remove.gif" alt="Delete" title="Delete row"/>
      </xf:label>
      <xf:delete ev:event="DOMActivate">
        <xsl:attribute name="nodeset">../<xsl:value-of select="$node"/></xsl:attribute>
        <xsl:attribute name="at">index('<xsl:value-of select="$index"/>')</xsl:attribute>
      </xf:delete>
    </xf:trigger>
  </xsl:template>

  <xsl:template name="trigger_add">
    <xsl:param name="node"/>
    <xsl:param name="index"/>
    <xsl:param name="model"/>
    <xf:trigger appearance="minimal">
      <xf:label>
        <h:img src="http:/editor/images/add.gif" alt="Add" title="Add row"/>
      </xf:label>
      <xf:insert context="parent::node()" ev:event="DOMActivate">
        <xsl:attribute name="origin"><xsl:value-of select="$model"/></xsl:attribute>
        <xsl:attribute name="nodeset"><xsl:value-of select="$node"/>[index('<xsl:value-of select="$index"/>')]</xsl:attribute>
      </xf:insert>
    </xf:trigger>
  </xsl:template>
  <!-- end edit buttons -->

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>


</xsl:transform>
