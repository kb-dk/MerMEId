<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.music-encoding.org/ns/mei" 
	xmlns:m="http://www.music-encoding.org/ns/mei" 
	xmlns:t="http://www.tei-c.org/ns/1.0"
	xmlns:xl="http://www.w3.org/1999/xlink"
	xmlns:exsl="http://exslt.org/common"
	xmlns:dyn="http://exslt.org/dynamic"
	extension-element-prefixes="dyn exsl"
	exclude-result-prefixes="xsl m t"
	version="1.0">
	
	<xsl:output method="xml"
		encoding="UTF-8"
		omit-xml-declaration="yes" />
	<xsl:strip-space elements="*" />
	<xsl:variable name="empty_doc" select="document('/editor/forms/mei/model/empty_doc.xml')" />
	
	<xsl:template match="m:mei">
		<!-- make a copy with an extra header from the empty model document -->
		<xsl:variable name="janus">
			<mei xmlns="http://www.music-encoding.org/ns/mei"
				xmlns:xl="http://www.w3.org/1999/xlink">
				<xsl:copy-of select="@*"/>
				<xsl:copy-of select="$empty_doc/m:mei/m:meiHead"/>
				<xsl:copy-of select="@*|*"/>
			</mei>
		</xsl:variable>
		<xsl:variable name="second_run">
			<!-- make it a nodeset and start copying from model -->
			<xsl:apply-templates select="exsl:node-set($janus)" mode="second_run"/>
		</xsl:variable>
		<!-- output after second run:
			<xsl:copy-of select="exsl:node-set($second_run)"/>-->
		
		<!-- final run: convert formatted text to escaped HTML -->
		<xsl:apply-templates select="exsl:node-set($second_run)" mode="mei2html"/>
	</xsl:template>
	
	<xsl:template match="m:mei" mode="second_run">
		<!-- transform original header and remove the temporary model header -->
		<mei xmlns="http://www.music-encoding.org/ns/mei"
			xmlns:xl="http://www.w3.org/1999/xlink">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="m:meiHead[2]" mode="header"/>
			<xsl:apply-templates select="m:music"/>
		</mei>
	</xsl:template>
	

	<!-- the actual copying from the model header to the data header -->
	<xsl:template match="*" mode="header">
		<!-- build an xpath string to locate the corresponding node in the model header -->
		<xsl:variable name="path"><xsl:for-each 
			select="ancestor-or-self::*">/<xsl:if 
				test="namespace-uri()='http://www.music-encoding.org/ns/mei'">m:</xsl:if><xsl:if 
					test="namespace-uri()='http://www.tei-c.org/ns/1.0'">t:</xsl:if><xsl:value-of 
						select="name()"/><xsl:if test="local-name()='meiHead'">[1]</xsl:if></xsl:for-each>
		</xsl:variable>
		<xsl:element name="{name()}" namespace="{namespace-uri()}">
			<xsl:copy-of select="@*"/>
			<xsl:variable name="model" select="dyn:evaluate($path)"/>
			<xsl:variable name="data_node" select="."/>
			<!-- Add all missing empty attributes. Ignores non-empty attributes in the model in order not to inject unwanted data -->
			<xsl:for-each select="$model/@*[.='']">
				<xsl:variable name="this_att" select="local-name()"/>
				<xsl:if test="not($data_node/@*[local-name()=$this_att])"><xsl:attribute name="{name()}"/></xsl:if>
			</xsl:for-each>
			<xsl:choose>
				<!-- component expressions need special treatment -->
				<xsl:when test="local-name()='componentGrp'">
					<xsl:apply-templates mode="component"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates mode="header"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>    
	
	<xsl:template match="t:ref" mode="header">
		<!-- TEI bibl elements are not included in the empty model, so special handling is needed -->
		<xsl:element name="ref" namespace="{namespace-uri()}">
			<xsl:copy-of select="@*"/>
			<xsl:if test="not(@target)"><xsl:attribute name="target"/></xsl:if>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<!-- special case: expressions may occur nested in data, but not in the empty model -->
	<xsl:template match="*" mode="component">
		<!-- build an xpath string to locate the corresponding node in the model header -->
		<xsl:variable name="complete_path"><xsl:for-each 
			select="ancestor-or-self::*">/<xsl:if 
				test="namespace-uri()='http://www.music-encoding.org/ns/mei'">m:</xsl:if><xsl:if 
					test="namespace-uri()='http://www.tei-c.org/ns/1.0'">t:</xsl:if><xsl:value-of 
						select="name()"/></xsl:for-each>
		</xsl:variable>
		<!-- always copy from the model's top-level expression -->
		<xsl:variable 
			name="path">/m:mei/m:meiHead[1]/m:workDesc/m:work/m:expressionList/m:expression/<xsl:call-template name="substring-after-last">
				<xsl:with-param name="string" select="$complete_path"/>
				<xsl:with-param name="delimiter" select="'m:expression/'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:element name="{name()}" namespace="{namespace-uri()}">
			<xsl:copy-of select="@*"/>
			<xsl:variable name="model" select="dyn:evaluate($path)"/>
			<xsl:variable name="data_node" select="."/>
			<!-- Add all missing empty attributes.  -->
			<xsl:for-each select="$model/@*">
				<xsl:variable name="this_att" select="local-name()"/>
				<xsl:if test="not($data_node/@*[local-name()=$this_att])"><xsl:attribute name="{name()}"/></xsl:if>
			</xsl:for-each>
			<xsl:apply-templates mode="component"/>
		</xsl:element>
	</xsl:template>    
	
	<xsl:template name="substring-after-last">
		<xsl:param name="string" />
		<xsl:param name="delimiter" />
		<xsl:choose>
			<xsl:when test="contains($string, $delimiter)">
				<xsl:call-template name="substring-after-last">
					<xsl:with-param name="string"
						select="substring-after($string, $delimiter)" />
					<xsl:with-param name="delimiter" select="$delimiter" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$string" /></xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	
	
	<!-- MEI -> HTML -->
	<xsl:template match="m:lb" mode="mei2html">
		&lt;br/&gt;
	</xsl:template> 
	<xsl:template match="m:rend[@fontweight = 'bold']" mode="mei2html">
		&lt;b&gt;
		<xsl:apply-templates mode="mei2html"/>
		&lt;/b&gt;
	</xsl:template>
	<xsl:template match="m:rend[@fontstyle = 'ital']" mode="mei2html">
		&lt;i&gt;
		<xsl:apply-templates mode="mei2html"/>
		&lt;/i&gt;
	</xsl:template>
	<xsl:template match="m:rend[@rend = 'underline']" mode="mei2html">
		&lt;u&gt;
		<xsl:apply-templates mode="mei2html"/>
		&lt;/u&gt;
	</xsl:template>
	<xsl:template match="m:rend[@rend = 'sub']" mode="mei2html">
		&lt;sub&gt;
		<xsl:apply-templates mode="mei2html"/>
		&lt;/sub&gt;
	</xsl:template>
	<xsl:template match="m:rend[@rend = 'sup']" mode="mei2html">
		&lt;sup&gt;
		<xsl:apply-templates mode="mei2html"/>
		&lt;/sup&gt;
	</xsl:template>
	<xsl:template match="m:rend[@fontfam or @fontsize or @color]" mode="mei2html">
		<xsl:variable name="atts">
			<xsl:if test="@fontfam">
				<xsl:value-of select="concat('font-family:',@fontfam,';')"/>
			</xsl:if>
			<xsl:if test="@fontsize">
				<xsl:value-of select="concat('font-size:',@fontsize,';')"/>
			</xsl:if>
			<xsl:if test="@color">
				<xsl:value-of select="concat('color:',@color,';')"/>
			</xsl:if>
		</xsl:variable>
		&lt;span style="<xsl:value-of select="$atts"/>"&gt;
		<xsl:apply-templates mode="mei2html"/>
		&lt;/span&gt;
	</xsl:template>
	<!--
		<xsl:template match="m:persName|m:corpName|m:name|m:ptr|m:address|m:bibl|m:date|m:geogName|m:title|m:quote" mode="mei2html">
		<xsl:variable name="atts">
		<xsl:for-each select="@*">
		<xsl:value-of select="concat(name(),'(',.,')')"/>
		</xsl:for-each>
		</xsl:variable>
		&lt;span title="mei:<xsl:value-of select="name()"/>" 
		class="<xsl:value-of select="concat('atts[',string-join($atts,','),']')"/>"
		style="background-color: #e5e5e5;"&gt;
		<xsl:apply-templates mode="mei2html"/>
		&lt;/span&gt;
		</xsl:template>
	-->
	<xsl:template match="m:ref[@target]" mode="mei2html">
		&lt;a src="<xsl:value-of select="@target"/>" target="<xsl:value-of select="@xl:show"/>" title="<xsl:value-of select="@xl:title"/>"&gt;
		<xsl:apply-templates mode="mei2html"/>
		&lt;/a&gt;
	</xsl:template>
	<xsl:template match="m:rend[@halign]" mode="mei2html">
		&lt;div style="text-align:<xsl:value-of select="@halign"/>;"&gt;
		<xsl:apply-templates mode="mei2html"/>
		&lt;/div&gt;
	</xsl:template>
	<xsl:template match="m:list" mode="mei2html">
		<xsl:choose>
			<xsl:when test="@form = 'simple'">
				&lt;ul&gt;
				<xsl:for-each select="m:li">
					&lt;li&gt;
					<xsl:apply-templates mode="mei2html"/>
					&lt;/li&gt;
				</xsl:for-each>
				&lt;/ul&gt;
			</xsl:when>
			<xsl:when test="@form = 'ordered'">
				&lt;ol&gt;
				<xsl:for-each select="m:li">
					&lt;li&gt;
					<xsl:apply-templates mode="mei2html"/>
					&lt;/li&gt;
				</xsl:for-each>
				&lt;/ol&gt;
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="m:fig[./graphic]" mode="mei2html">
		&lt;img src="<xsl:value-of select="./graphic/@target"/>"/&gt;
	</xsl:template> 
	<!-- END MEI -> HTML -->
	
	<xsl:template match="@*|node()" mode="mei2html">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="mei2html"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:transform>
