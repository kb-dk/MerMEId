<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns="http://www.music-encoding.org/ns/mei" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xl="http://www.w3.org/1999/xlink" 
    xmlns:m="http://www.music-encoding.org/ns/mei" 
    xmlns:t="http://www.tei-c.org/ns/1.0" 
    exclude-result-prefixes="m xsl">
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes" xml:space="default"/>
    <xsl:strip-space elements="*"/>
        
    <xsl:template match="@*|*">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="m:mei">
        <mei>
            <xsl:attribute name="meiversion">2012</xsl:attribute>
            <xsl:if test="count(@xml:id)=0">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="concat('mei_',generate-id())"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*|node()"/>
        </mei>
    </xsl:template>

    <xsl:template match="m:meihead">
        <meiHead>
            <xsl:apply-templates select="m:filedesc/m:pubstmt/m:identifier"/>
            <xsl:apply-templates/>
        </meiHead>
    </xsl:template>   

    <xsl:template match="m:filedesc">
        <fileDesc>
            <titleStmt>
                <!-- titles are moved to <work> -->
                <title/>
            </titleStmt>
            <xsl:apply-templates select="m:pubstmt"/>
            <seriesStmt>
                <title/>
                <!-- put in file context identifiers here (= the MerMEId collection) -->
                <seriesStmt label="File collection">
                    <title/>
                    <identifier><xsl:value-of select="normalize-space(//m:encodingdesc/m:projectdesc/m:p/m:list[@n='use'])"/></identifier>
                </seriesStmt>
            </seriesStmt>
            <xsl:apply-templates select="m:notesstmt"/>
            <xsl:apply-templates select="m:sourcedesc"/>
        </fileDesc>
    </xsl:template>   

    <xsl:template match="m:filedesc/m:titlestmt">
        <titleStmt>
            <xsl:apply-templates select="m:title[@type='main']"/>
            <xsl:apply-templates select="m:title[@type='alternative']"/>
            <title xml:lang="en" type="uniform"/>
            <title xml:lang="en" type="original"/>
            <xsl:apply-templates select="*[name(.)='title' and not(@type='main' or @type='alternative')]"/>            
            <title xml:lang="en" type="text_source"/>
            <xsl:apply-templates select="*[name(.)!='title']"/>            
        </titleStmt>
    </xsl:template>   

    <xsl:template match="m:titlestmt">
        <titleStmt>
            <xsl:apply-templates/>
        </titleStmt>
    </xsl:template>   
    
    <xsl:template match="m:filedesc/m:pubstmt">
        <pubStmt>
            <!-- work identifiers moved to <altId> -->
            <xsl:apply-templates select="@*|*[name(.)!='identifier']"/>
        </pubStmt>
    </xsl:template>   
    
    <xsl:template match="m:pubstmt">
        <pubStmt>
            <xsl:apply-templates/>
            <xsl:if test="name(..)='source'">
                <identifier analog="RISM"/>
            </xsl:if>
        </pubStmt>
    </xsl:template>   
    
    <xsl:template match="m:filedesc/m:pubstmt/m:respstmt">
        <respStmt>
            <!-- add DCM info -->
            <corpName>
                <abbr>DCM</abbr>
                <expan>Danish Centre for Music Publication</expan>
                <address>
              <addrLine>The Royal Library</addrLine>
              <addrLine>Søren Kierkegaards Plads 1</addrLine>
              <addrLine>P.O. Box 2149</addrLine>
              <addrLine>DK - 1016 Copenhagen K</addrLine>
              <addrLine><ptr target="http://www.kb.dk/dcm" xl:title="WWW"/></addrLine>
              <addrLine><ptr target="mailto://foa-dcm@kb.dk" xl:title="E-mail"/></addrLine>
            </address>                        
            </corpName>
            <!-- add names of editors involved -->
            <xsl:variable name="collection" select="normalize-space(//m:encodingdesc/m:projectdesc/m:p/m:list[@n='use'])"></xsl:variable>
            <xsl:choose>
                <xsl:when test="$collection='CNW'">
                    <persName role="editor">Niels Bo Foltmann</persName>
                    <persName role="editor">Axel Teich Geertinger</persName>	
                    <persName role="editor">Peter Hauge</persName>
                    <persName role="editor">Niels Krabbe</persName>
                    <persName role="editor">Elly Bruunshuus Petersen</persName>
                </xsl:when>
                <xsl:when test="$collection='GW'">
                    <persName role="editor">Niels Bo Foltmann</persName>
                    <persName role="editor">Axel Teich Geertinger</persName>
                    <persName role="editor">Anne Ørbæk Jensen</persName>
                </xsl:when>
                <xsl:when test="$collection='HartW'">
                    <persName role="editor">Inger Sørensen</persName>
                </xsl:when>
                <xsl:when test="$collection='SchM'">
                    <persName role="editor">Peter Hauge</persName>
                </xsl:when>
                <xsl:when test="$collection='test'">
                    <persName role="editor">Axel Teich Geertinger</persName>
                </xsl:when>
            </xsl:choose>
        </respStmt>
    </xsl:template>   
    
    <xsl:template match="m:respstmt">
        <respStmt>
            <xsl:apply-templates/>
        </respStmt>
    </xsl:template>   
        
    <xsl:template match="m:availability">
        <!-- caution: <availability> is deleted! -->
    </xsl:template>   

    <xsl:template match="m:persname|t:persName">
            <xsl:choose>
                <xsl:when test="@type='soloist' and .=''">
                    <!-- delete empty soloist persnames ('soloist' not a MARC relator) -->                
                </xsl:when>
                <xsl:when test="@type='dedicatee' and .=''">
                    <!-- delete empty dedicatee persnames -->                
                </xsl:when>
                <xsl:otherwise>
                    <persName role="">
                        <!-- change @type to @role -->
                        <xsl:if test="@type and not(@role)">
                            <xsl:choose>
                                <xsl:when test="@type='text_author'">
                                    <xsl:attribute name="role">author</xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="role">
                                        <xsl:value-of select="translate(@type,'_',' ')"/>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                        <!-- create @role if neither @type nor @role exists -->
                        <xsl:if test="not(@type) and not(@role)">
                            <xsl:attribute name="role"/>
                        </xsl:if>
                        <xsl:copy-of select="@*[name(.)!='type']"/>
                        <xsl:apply-templates/>
                    </persName>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>   

    <xsl:template match="m:corpname">
        <corpName>
            <!-- change @type to @role -->
            <xsl:if test="@type">
                <xsl:attribute name="role">
                    <xsl:value-of select="@type"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="@*[name(.)!='type']"/>
            <xsl:apply-templates/>
        </corpName>
    </xsl:template>   

    <xsl:template match="m:geogname">
        <geogName>
            <!-- change @type to @role -->
            <xsl:if test="@type">
                <xsl:attribute name="role">
                    <xsl:value-of select="@type"/>
                </xsl:attribute> 
            </xsl:if>
            <xsl:copy-of select="@*[name(.)!='type']"/>
            <xsl:apply-templates/>
        </geogName>
    </xsl:template>   
    
    <xsl:template match="m:encodingdesc">
        <encodingDesc>
            <appInfo>
                <application version="0.1">
                    <name>MerMEId</name>
                </application>
            </appInfo>
            <xsl:apply-templates select="@*|*"/>
        </encodingDesc>
    </xsl:template>

    <xsl:template match="m:sourcedesc">
        <sourceDesc>
            <xsl:apply-templates/>
        </sourceDesc>
    </xsl:template>

    <xsl:template match="m:source">
        <xsl:variable name="source_id">
	  <xsl:value-of select="concat('source_',generate-id(.))"/>
	</xsl:variable>
        <source>
            <xsl:attribute name="analog">frbr:manifestation</xsl:attribute>
            <xsl:attribute name="xml:id"><xsl:value-of select="$source_id"/></xsl:attribute>
            <xsl:apply-templates select="@*|m:titlestmt|m:pubstmt[1]"/> <!-- only put the first pubStmt here -->
            <physDesc>
                <!-- <physloc>, <provenance> and <handlist> are moved to <item> -->
                <xsl:apply-templates select="@*|m:physdesc/*[name()!='physloc' and name()!='provenance' and name()!='handlist']"/>
            </physDesc>
            <xsl:apply-templates select="m:notesstmt|m:classification"/>
            <!-- add item level -->
            <itemList>
                <item> 
                    <titleStmt>
                        <title/>
                    </titleStmt>
                    <pubStmt>
                        <date/>
                    </pubStmt>
                    <physDesc>
                        <condition/>
                        <xsl:apply-templates select="m:physdesc/m:physloc"/>
                        <xsl:apply-templates select="m:physdesc/m:provenance"/>
                        <extent unit="pages"/>
                        <dimensions unit="cm"/>
                        <xsl:apply-templates select="m:physdesc/m:handlist"/>
                        <physMedium/>
                    </physDesc>
                    <notesStmt>
                        <annot type="source_description"/>
                        <annot type="links">
                            <ptr target="" mimetype="" xl:title=""/>
                        </annot>
                    </notesStmt>
                    <componentGrp>
                        <item>
                            <titleStmt>
                                <title></title>
                            </titleStmt>
                            <pubStmt>
                                <date/>
                            </pubStmt>
                            <physDesc>
                                <condition/>
                                <titlePage>
                                    <p/>
                                </titlePage>
                                <physLoc>
                                    <repository>
                                        <corpName/>
                                        <identifier/>
                                        <identifier analog="RISM"/>
                                        <ptr target="" xl:title="Library record" mimetype=""/>
                                        <ptr target="" xl:title="Facsimile" mimetype=""/>
                                    </repository>
                                </physLoc>
                                <provenance>
                                    <eventList>
                                        <event>
                                            <title/>
                                            <date/>
                                            <geogName role=""/>
                                            <corpName role=""/>
                                            <persName role=""/>
                                        </event>
                                    </eventList>
                                </provenance>
                                <extent unit="pages"/>
                                <dimensions unit="cm"/>
                                <handList>
                                    <hand medium="" initial="false"/>
                                </handList>
                                <watermark>
                                    <ptr target="" xl:title="" mimetype=""/>
                                </watermark>
                                <physMedium/>
                            </physDesc>
                            <notesStmt>
                                <annot type="source_description"/>
                                <annot type="links">
                                    <ptr target="" mimetype="" xl:title=""/>
                                </annot>
                            </notesStmt>
                        </item>                
                    </componentGrp>
                </item> 
            </itemList>
            <relationList>
                <relation rel="isEmbodimentOf" target="#expression_id1"/>
            </relationList>
        </source>
        <xsl:if test="count(m:pubstmt)&gt;1">
            <xsl:apply-templates select="m:pubstmt[position()!=1]" mode="reprints">
                <xsl:with-param name="source_id" select="$source_id"/>
            </xsl:apply-templates>
        </xsl:if>        
    </xsl:template>

    <xsl:template match="m:pubstmt" mode="reprints">
        <xsl:param name="source_id"/>
        <source analog="frbr:manifestation">
            <titleStmt>
                <title/>
                <respStmt>
                    <persName role=""/>
                </respStmt>
            </titleStmt>
            <xsl:apply-templates select="."/>
            <notesStmt>
                <annot type="source_description"/>                     
            </notesStmt>
            <relationList>
                <relation rel="isReproductionOf">
                    <xsl:attribute name="target"><xsl:value-of select="$source_id"/></xsl:attribute>
                </relation>
            </relationList>
        </source>        
    </xsl:template>


    <xsl:template match="m:repository/m:identifier">
        <xsl:apply-templates select="@*"/>
        <xsl:choose>
            <xsl:when test="contains(.,'[')">
                <!-- put CNU Source references in [] (like "[CNU Source A]")into their own <identifier> -->
                <identifier>
                    <xsl:value-of select="normalize-space(substring-before(.,'['))"/>
                </identifier>
                <xsl:variable name="remainingString">
                    <xsl:value-of select="substring-before(substring-after(.,'['),']')"/>
                </xsl:variable>
                <xsl:if test="$remainingString!=''">
                    <identifier>
                        <xsl:choose>
                            <xsl:when test="contains($remainingString,'ource')">
                                <xsl:attribute name="analog"><xsl:value-of
                                        select="substring-before($remainingString,'ource')"/>ource</xsl:attribute>
                                <xsl:value-of select="normalize-space(substring-after($remainingString,'ource'))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring-before($remainingString,']')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </identifier>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <identifier>
                    <xsl:value-of select="."/>
                </identifier>
            </xsl:otherwise>
        </xsl:choose>
        <identifier analog="RISM"/>
    </xsl:template>
    
    <xsl:template match="m:provenance/m:eventlist/m:event">
        <event>
            <title><xsl:value-of select="."/></title>
            <!-- move dates from <event> to <date> -->
            <date>
                <xsl:variable name="notbefore" select="normalize-space(@notbefore)"/>
                <xsl:variable name="notafter" select="normalize-space(@notafter)"/>
                <xsl:choose>
                    <xsl:when test="$notbefore!='' and $notbefore=$notafter">
                        <xsl:choose>
                            <xsl:when test="$notbefore castable as xs:date">
                                <xsl:attribute name="reg"><xsl:value-of select="$notbefore"/></xsl:attribute>
                                <xsl:attribute name="notbefore" select="''"/>
                                <xsl:attribute name="notafter" select="''"/>
                            </xsl:when>
                            <xsl:when test="$notbefore castable as xs:integer and string-length($notbefore)=4">
                                <xsl:attribute name="notbefore" select="xs:date(concat($notbefore,'-01-01'))"/>
                                <xsl:attribute name="notafter" select="xs:date(concat($notafter,'-12-31'))"/>
                                <xsl:attribute name="reg" select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="notbefore" select="''"/>
                                <xsl:attribute name="notafter" select="''"/>
                                <xsl:attribute name="reg" select="''"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:value-of select="$notbefore"></xsl:value-of>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$notbefore castable as xs:date">
                                <xsl:attribute name="notbefore"><xsl:value-of select="$notbefore"/></xsl:attribute>
                            </xsl:when>
                            <xsl:when test="$notbefore castable as xs:integer and string-length($notbefore)=4">
                                <xsl:attribute name="notbefore" select="xs:date(concat($notbefore,'-01-01'))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="notbefore" select="''"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="$notafter castable as xs:date">
                                <xsl:attribute name="notafter"><xsl:value-of select="$notafter"/></xsl:attribute>
                            </xsl:when>
                            <xsl:when test="$notafter castable as xs:integer and string-length($notafter)=4">
                                <xsl:attribute name="notafter" select="xs:date(concat($notafter,'-12-31'))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="notafter" select="''"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:attribute name="reg" select="''"/>
                        <xsl:variable name="date_value">
                            <xsl:value-of select="$notbefore"/>
                            <xsl:if test="$notbefore!='' and $notafter!=''"> - </xsl:if>
                            <xsl:value-of select="$notafter"/> 
                        </xsl:variable>
                        <xsl:value-of select="$date_value"/>
                    </xsl:otherwise>
                </xsl:choose>
            </date>
            <geogName role=""/>
            <corpName role=""/>
            <persName role=""/>
        </event>                        
    </xsl:template>

    <xsl:template match="m:physdesc">
        <physDesc>
            <condition/>
            <xsl:apply-templates/>
        </physDesc>
    </xsl:template>
    
    <xsl:template match="@unit">
        <!-- change spaces to underscore -->
        <xsl:attribute name="unit">
            <xsl:value-of select="translate(normalize-space(.),' ','_')"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="m:titlepage">
        <titlePage label="Title page">
            <xsl:apply-templates/>
        </titlePage>
    </xsl:template>
    
    <xsl:template match="m:physloc">
        <physLoc>
            <xsl:apply-templates select="@*|*"/>
        </physLoc>
    </xsl:template>
    
    <xsl:template match="m:respository">
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="m:corpname"/>
        <xsl:apply-templates select="m:identifier"/>
        <!-- add RISM identifier -->
        <identifier analog="RISM"/>
        <xsl:apply-templates select="m:extptr"/>
    </xsl:template>

    <xsl:template match="m:physmedium">
        <!-- add <watermark> -->
        <watermark>
            <ptr/>
        </watermark>
        <physMedium>
            <xsl:apply-templates/>
        </physMedium>
    </xsl:template>
    
    <xsl:template match="m:handlist">
        <handList>
            <xsl:apply-templates/>
        </handList>
    </xsl:template>
    
    <xsl:template match="m:projectdesc">
        <projectDesc>
            <p>Metadata created using MerMEId 0.1.</p>
            <xsl:apply-templates/>
        </projectDesc>        
    </xsl:template>
    
    <!-- file context moves to <seriesStmt> -->
    <xsl:template match="m:projectdesc/m:p[m:list/@n='use']"/>

    <xsl:template match="m:notesstmt">
        <notesStmt>
            <xsl:apply-templates select="@*|*"/>
        </notesStmt>
    </xsl:template>   
    
    <xsl:template match="m:filedesc/m:notesstmt">
        <notesStmt>
            <xsl:apply-templates select="@*|*[@type!='general_description' and @type!='links']"/>
            <!-- add private notes if missing -->
            <xsl:if test="not(m:annot[@type='private_notes']) and not(m:annot[@type='private_notes']='')">
                <annot type="private_notes"/>
            </xsl:if>
            <!-- move bibliography from <front> to meiHead/fileDesc/notesStmt -->
            <annot type="bibliography">
                <!-- add primary bibliography if missing -->
                <xsl:if test="not(//m:music/m:front/t:div[t:head='Bibliography']/t:listBibl[@type='primary'])">
                    <listBibl type="primary" xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="xml:id">
                            <xsl:value-of select="concat('listBibl_primary_',generate-id(.))"/>
                        </xsl:attribute>
                        <bibl type="Letter">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="concat('bibl_',generate-id(.))"/>
                            </xsl:attribute>
                            <author/>
                            <name role="recipient"/>
                            <date/>
                            <geogName/>
                            <msIdentifier>
                                <repository/>
                                <idno/>
                            </msIdentifier>
                            <note/>
                            <ref target=""/>
                            <ref type="editions">
                                <bibl>
                                    <title type="short_title"/>
                                    <biblScope/>
                                </bibl>
                            </ref>
                        </bibl>
                    </listBibl>
                </xsl:if>
                <xsl:apply-templates select="//m:music/m:front/t:div[t:head='Bibliography']/t:listBibl"/>
                <!-- add bibliography containing documentary material -->
                <xsl:if test="not(//m:music/m:front/t:div[t:head='Bibliography']/t:listBibl[@type='documentation'])">
                    <listBibl type="documentation" xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="xml:id">
                            <xsl:value-of select="concat('listBibl_documentary_',generate-id(.))"/>
                        </xsl:attribute>
                        <bibl type="Concert_programme">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="concat('bibl_',generate-id(.))"/>
                            </xsl:attribute>
                            <date/>
                            <title/>
                            <geogName/>
                            <msIdentifier>
                                <repository/>
                                <idno/>
                            </msIdentifier>
                            <note/>
                            <ref target=""/>
                        </bibl>
                    </listBibl>                
                </xsl:if>
            </annot>
        </notesStmt>
    </xsl:template>   

    <xsl:template match="m:filedesc/m:notesstmt" mode="work">
        <xsl:apply-templates select="m:annot[@type='general_description']"/>
        <xsl:apply-templates select="m:annot[@type='links']"/>
    </xsl:template>   
    
    
    <xsl:template match="m:music/m:front/t:div[t:head='Bibliography']/t:listBibl">
        <listBibl xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:if test="not(@xml:id)">
                <xsl:attribute name="xml:id">
		  <xsl:value-of select="concat('listBibl_secondary_',
					generate-id(.))"/>
		</xsl:attribute>
            </xsl:if>
            <!-- add @type "secondary" to existing bibliography if missing -->
            <xsl:if test="not(@type)">
                <xsl:attribute name="type">secondary</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*|*"/>
        </listBibl>
    </xsl:template>
    
    <xsl:template match="m:langusage">
        <langUsage>
            <xsl:apply-templates select="*"/>
        </langUsage>
    </xsl:template>   

    <xsl:template match="m:classification/m:keywords">
        <termList>
            <xsl:apply-templates select="m:term"/>
            <xsl:if test="not(m:term[@classcode='DcmCompletenessClass'])">
                <term classcode="DcmCompletenessClass"/>
            </xsl:if>
        </termList>
    </xsl:template>

    <xsl:template match="m:classification/m:keywords" mode="work">
        <termList>
            <xsl:apply-templates select="m:term"/>
        </termList>
    </xsl:template>
    
    <xsl:template match="m:classcode">
        <classCode authURI="http://www.kb.dk/dcm">
            <xsl:apply-templates select="@*|*"/>
        </classCode>
    </xsl:template>    
    
    <xsl:template match="m:classcode/@xml:id[.='DcmStageClass']">
        <xsl:attribute name="xml:id">DcmStateClass</xsl:attribute>
    </xsl:template>
    
    <xsl:template match="m:term">
        <term>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="translate(.,'_',' ')"/>
        </term>
    </xsl:template>
    
    <xsl:template match="m:term/@classcode[.='DcmStageClass']">
        <xsl:attribute name="classcode">DcmStateClass</xsl:attribute>
    </xsl:template>
    
    <xsl:template match="m:profiledesc/m:creation/m:p[@type='note']">
        <p><xsl:apply-templates/></p>
    </xsl:template>
    
    <xsl:template match="m:profiledesc">
        <xsl:variable name="num_subworks" select="count(//m:music/m:body/m:mdiv)"/>
        <xsl:variable name="num_movements" select="count(//m:music/m:body/m:mdiv/m:score/m:section)"></xsl:variable>
        <workDesc>
            <work analog="frbr:work">
                <xsl:apply-templates select="//m:meihead/m:filedesc/m:titlestmt"/>
                <history>
                    <creation>
                        <xsl:apply-templates select="m:creation/m:p/m:date"/>
                        <geogName/>
                    </creation>
                    <xsl:apply-templates select="m:creation/m:p[@type='note']"/>
                    <eventList type="history">
                        <event>
                            <title/>
                            <date/>
                            <geogName role=""/>
                            <corpName role=""/>
                            <persName role=""/>
                        </event>
                    </eventList>
                    <eventList type="performances">
                        <xsl:apply-templates select="m:eventlist/m:event"/>
                    </eventList>
                </history>
                <xsl:apply-templates select="m:langusage"/>
                <notesStmt>
                    <xsl:apply-templates select="//m:meihead/m:filedesc/m:notesstmt" mode="work"/>
                </notesStmt>
                <classification>
                    <xsl:apply-templates select="m:classification/m:classcode"/>
                    <xsl:if test="not(m:classification/m:classcode[@xml:id='DcmCompletenessClass'])">
                        <classCode authURI="http://www.kb.dk/dcm" xml:id="DcmCompletenessClass"/>
                    </xsl:if>
                    <xsl:apply-templates select="m:classification/m:keywords" mode="work"/>
                </classification>
                <expressionList>
                    <expression analog="frbr:expression" xml:id="expression_id1">
                        <xsl:attribute name="n" select="@n"/>
                        <titleStmt>
                            <!-- show movement-level title at this level if there is only one movement -->
                            <xsl:choose>
                                <xsl:when test="$num_movements=1">
                                    <xsl:apply-templates select="//m:music/m:body/m:mdiv/m:score/m:section/m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:title"/>
                                </xsl:when>
                                <xsl:otherwise><title xml:lang="en"/></xsl:otherwise>
                            </xsl:choose>
                            <respStmt>
                                <xsl:choose>
                                    <xsl:when test="$num_movements=1 and //m:music/m:body/m:mdiv/m:score/m:section/m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:persname">
                                        <xsl:apply-templates select="//m:music/m:body/m:mdiv/m:score/m:section/m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:persname"/>
                                    </xsl:when>
                                    <xsl:otherwise><persName role=""/></xsl:otherwise>
                                </xsl:choose>
                            </respStmt>
                        </titleStmt>
                        <history>
                            <creation>
                                <date/>
                                <geogName/>
                            </creation>
                            <p/>
                            <eventList type="history">
                                <event>
                                    <title/>
                                    <date/>
                                    <geogName role=""/>
                                    <corpName role=""/>
                                    <persName role=""/>
                                    <bibl label="documentation"/>
                                </event>
                            </eventList>
                            <eventList type="performances">
                                <event>
                                    <title/>
                                    <date/>
                                    <geogName role="venue"/>
                                    <geogName role="place"/>
                                    <corpName role="ensemble"/>
                                    <persName role="conductor"/>
                                    <persName role="soloist"/>                                    
                                    <persName role=""/>
                                    <bibl label="documentation"/>
                                    <listBibl type="reviews" xmlns="http://www.tei-c.org/ns/1.0">
                                        <bibl type="Journal_article">
                                            <author/>
                                            <date/>
                                            <title level="a"/>
                                            <title level="j"/>
                                            <editor/>
                                            <biblScope type="vol"/>
                                            <biblScope type="issue"/>
                                            <biblScope type="pp"/>
                                            <pubPlace/>
                                            <publisher/>
                                            <ref/>
                                        </bibl>
                                    </listBibl>
                                </event>
                            </eventList>
                        </history>
                        <xsl:choose>
                            <!-- insert main key at top level only if there is no more than one "sub-work" -->
                            <xsl:when test="$num_subworks=1">
                                <xsl:apply-templates
                                    select="//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='metadata']/m:scoredef"
                                    mode="key"/>
                            </xsl:when>
                            <xsl:otherwise><key pname="" accid="" mode=""/></xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                            <!-- insert tempo and metre at this level if there is only one movement -->
                            <xsl:when test="$num_movements=1">
                                <xsl:apply-templates select="//m:music/m:body/m:mdiv/m:score/m:section/m:app/m:rdg[@type='metadata']" mode="TempoMeter"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <tempo/>
                                <meter meter.count="" meter.unit="" meter.sym=""/>
                            </xsl:otherwise>
                        </xsl:choose>                        
                        <perfMedium analog="marc:048">
                            <!-- list instrumentation at top level if there is no more than one work component OR if instrumentation is indicated on first component only-->
                            <xsl:choose>
                                <!-- if only 1 work component: -->
                                <xsl:when test="$num_subworks=1">
                                    <!-- show instrumentation if non-empty -->
                                    <xsl:if	test="count(//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))])>0">
                                        <xsl:apply-templates select="//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp" mode="instruments"/>
                                    </xsl:if>
                                </xsl:when>
                                <!-- if more than one component (i.e. there are sub-works): -->
                                <xsl:otherwise>
                                    <!-- show instrumentation if first components' instrumentation is non-empty -->				
                                    <xsl:if test="count(//m:music/m:body/m:mdiv[1]/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))])>0">
                                        <!-- AND it is the only component with instrumentation -->
                                        <xsl:if	test="count(//m:music/m:body/m:mdiv[m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))]])=1">
                                            <xsl:apply-templates select="//m:music/m:body/m:mdiv[1]/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp" mode="instruments"/>
                                        </xsl:if>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>		
                        </perfMedium>
                        <classification>
                            <termList>
                                <term/>
                            </termList>
                        </classification>
                        <castList>
                            <!-- list cast at top level if there is no more than one work component OR if instrumentation is indicated on first component only-->
                            <xsl:choose>
                                <!-- if only 1 work component: -->
                                <!-- show cast if non-empty -->
                                <xsl:when test="$num_subworks=1 and
                                    count(//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp[contains(concat(@label.full,@label.abbr),'aracter')]/m:staffdef[normalize-space(concat(@label.full,@label.abbr))])>0">
                                    <xsl:apply-templates select="//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp[contains(concat(@label.full,@label.abbr),'aracter')]" mode="castList"/>
                                </xsl:when>
                                <!-- if more than one component (i.e. there are sub-works): -->
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <!-- show cast list if first components' cast list is non-empty -->
                                        <!-- AND it is the only component having a cast list -->
                                        <xsl:when test="count(//m:music/m:body/m:mdiv[1]/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp[contains(concat(@label.full,@label.abbr),'aracter')]/m:staffdef[normalize-space(concat(@label.full,@label.abbr))])>0 
                                            and count(//m:music/m:body/m:mdiv[m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp[contains(concat(@label.full,@label.abbr),'aracter')]/m:staffdef[normalize-space(concat(@label.full,@label.abbr))]])=1">
                                            <xsl:apply-templates select="//m:music/m:body/m:mdiv[1]/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp[contains(concat(@label.full,@label.abbr),'aracter')]" mode="castList"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <castItem>
                                                <role>
                                                    <ref target="">
                                                        <name xml:lang="en"/>  
                                                    </ref>
                                                </role>
                                                <roleDesc xml:lang="en"/>
                                            </castItem>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>		
                        </castList>
                        <incip>     
                            <xsl:choose>
                                <xsl:when test="$num_movements=1">
                                    <xsl:apply-templates select="//m:music/m:body/m:mdiv/m:score/m:section/m:app/m:rdg[@type='incipit']/m:div[@type='text_incipit']"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <incipText xml:lang="en">
                                        <p/>
                                    </incipText>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:choose>
                                <xsl:when test="$num_movements=1">
                                    <xsl:apply-templates select="//m:music/m:body/m:mdiv/m:score/m:section/m:app/m:rdg[@type='incipit']/m:annot[@type='links']/m:extptr"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <graphic target="" xl:title="" targettype="lowres"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <score/>
                        </incip>
                        <componentGrp>
                            <xsl:if test="$num_movements&gt;1 or $num_subworks&gt;1">
                                <xsl:choose>
                                    <xsl:when test="count(//m:music/m:body/m:mdiv/m:score)=1">
                                        <!-- if only one "sub-work" mdiv, treat the sections in it as component expressions, i.e. movements -->
                                        <xsl:apply-templates select="//m:music/m:body/m:mdiv/m:score/m:section"
                                            mode="expression"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- if more than one "sub-work" mdiv, treat each one as a component expression -->
                                        <xsl:apply-templates select="//m:music/m:body/m:mdiv/m:score" mode="expression"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:if>
                        </componentGrp>
                        <relationList>
                            <relation rel="hasReproduction" label="Edited score" targettype="edited_score">
                                <xsl:attribute name="target">
                                    <xsl:if test="count(//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='edited_score'])=1">
                                        <xsl:value-of select="//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='edited_score']/m:annot/m:extptr/@xl:href"/>
                                    </xsl:if>
                                </xsl:attribute>
                            </relation>
                        </relationList>
                    </expression>
                </expressionList>
            </work>
        </workDesc>
    </xsl:template>   
    
    <xsl:template match="m:eventlist">
        <eventList>
            <xsl:apply-templates/>
        </eventList>
    </xsl:template>
    
    <xsl:template match="m:profiledesc/m:eventlist/m:event">
        <event>
            <xsl:apply-templates select="*[name(.)!='bibl']"/>
            <listBibl type="reviews" xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:if test="not(@xml:id)">
                    <xsl:attribute name="xml:id">
		      <xsl:value-of select="concat('listBibl_',
					    generate-id(.))"/>
		    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates select="t:bibl"/>
            </listBibl>
        </event>
    </xsl:template>
    
    <xsl:template match="m:event">
        <event>
            <xsl:apply-templates select="@*|*"/>
            <listBibl type="documentation" xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:if test="not(@xml:id)">
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="concat('listBibl_',generate-id(.))"/>
                    </xsl:attribute>
                </xsl:if>
                <bibl/>
            </listBibl>
        </event>
    </xsl:template>
    
    <xsl:template match="m:app/m:rdg[@type='metadata']" mode="TempoMeter">
        <tempo><xsl:value-of select="m:tempo"/></tempo>
        <meter meter.count="" meter.unit="" meter.sym="">
            <xsl:if test="m:scoredef/@meter.count!=''">
                <xsl:attribute name="meter.count"><xsl:value-of select="m:scoredef/@meter.count"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="m:scoredef/@meter.unit!=''">
                <xsl:attribute name="meter.unit"><xsl:value-of select="m:scoredef/@meter.unit"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="m:scoredef/@meter.sym!=''">
                <xsl:attribute name="meter.sym"><xsl:value-of select="m:scoredef/@meter.sym"/></xsl:attribute>
            </xsl:if>
        </meter>
    </xsl:template>
    
    <xsl:template match="m:scoredef" mode="key">
        <key pname="" accid="" mode="">
            <xsl:if test="@key.pname!=''">
                <xsl:attribute name="pname"><xsl:value-of select="@key.pname"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="@key.accid!=''">
                <xsl:attribute name="accid"><xsl:value-of select="@key.accid"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="@key.mode!=''">
                <xsl:attribute name="mode"><xsl:value-of select="@key.mode"/></xsl:attribute>
            </xsl:if>
        </key>        
    </xsl:template>

    <xsl:template match="m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp" mode="instruments">
        <xsl:choose>
            <xsl:when test="count(m:staffgrp[contains(@label.full,'Basic')]/m:staffdef[normalize-space(concat(@label.abbr,' ',@label.full))!=''])&gt;2">
                <!-- if more than two basic instruments, make them an ensemble -->
                <ensemble>
                    <instrVoice reg="on"/>
                    <xsl:apply-templates select="m:staffgrp[contains(@label.full,'Basic')]/m:staffdef[normalize-space(concat(@label.abbr,' ',@label.full))!='']" mode="performer"/>
                </ensemble>
            </xsl:when>
            <xsl:otherwise>
                <!-- else just list performer(s) -->
                <xsl:apply-templates select="m:staffgrp[contains(@label.full,'Basic')]/m:staffdef[normalize-space(concat(@label.abbr,' ',@label.full))!='']" mode="performer"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="m:staffgrp[contains(@label.full,'Choir')]/m:staffdef[normalize-space(concat(@label.abbr,' ',@label.full))!='']" mode="choirs"/>
        <xsl:apply-templates select="m:staffgrp[contains(@label.full,'Soloists')]/m:staffdef[normalize-space(concat(@label.abbr,' ',@label.full))!='']" mode="performer"/>
    </xsl:template>    
    
    <xsl:template match="m:staffdef" mode="performer">
        <performer>
            <xsl:apply-templates select="." mode="instrVoice"/>
        </performer>
    </xsl:template>

    <xsl:template match="m:staffdef" mode="choirs">
        <ensemble>
            <instrVoice reg="cn">Choir</instrVoice> 
            <xsl:apply-templates select="." mode="performer"/>
        </ensemble>
    </xsl:template>
    
    <xsl:template match="m:staffdef" mode="instrVoice">
            <instrVoice reg="">
                <xsl:choose>
                    <xsl:when test="contains(parent::node()/@label.full,'Soloists')">
                        <xsl:attribute name="solo">true</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="solo">false</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="contains(parent::node()/@label.full,'Choir')">
                    <xsl:attribute name="reg">cn</xsl:attribute>
                </xsl:if>
                <xsl:variable name="instrString" select="normalize-space(concat(@label.abbr,' ',@label.full))"/>
                <xsl:variable name="instrCount">
                    <xsl:call-template name="instrNumber">
                        <xsl:with-param name="input" select="$instrString"></xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>    
                <xsl:attribute name="count">
                    <xsl:choose>
                        <xsl:when test="$instrCount!=''"><xsl:value-of select="$instrCount"/></xsl:when>
                        <xsl:otherwise>1</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:call-template name="instrName">
                    <xsl:with-param name="input" select="$instrString"></xsl:with-param>
                </xsl:call-template>
            </instrVoice>
    </xsl:template>
    
    <xsl:template name="instrNumber">
        <xsl:param name="input"/>
        <xsl:if test="translate(substring($input,1,1),'0123456789','')!=substring($input,1,1)">
            <xsl:value-of select="substring($input,1,1)"/>
            <xsl:variable name="remainingString" select="substring($input,2,string-length($input)-1)"/>
            <xsl:call-template name="instrNumber">
                <xsl:with-param name="input" select="$remainingString"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="instrName">
        <xsl:param name="input"/>
        <xsl:choose>
            <xsl:when test="translate(substring($input,1,1),'0123456789','')!=substring($input,1,1)">
                <xsl:call-template name="instrName">
                    <xsl:with-param name="input" select="substring($input,2,string-length($input)-1)"/>
                </xsl:call-template>                
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="normalize-space($input)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="m:staffdef" mode="castList">
        <castItem>
            <role>
                <ref>
                    <name xml:lang="en"><xsl:value-of select="normalize-space(concat(@label.abbr,' ',@label.full))"/></name>  
                </ref>
            </role>
            <roleDesc xml:lang="en"/>
        </castItem>        
    </xsl:template>

    <xsl:template match="m:score|m:section" mode="expression">
        <xsl:variable name="num_subworks" select="count(//m:music/m:body/m:mdiv)"/>
        <xsl:variable name="num_movements" select="count(//m:music/m:body/m:mdiv/m:score/m:section)"></xsl:variable>
        <!-- match movements -->
        <expression  analog="frbr:expression">
            <xsl:attribute name="n"><xsl:value-of select="@n"/></xsl:attribute>
            <titleStmt>
                <xsl:choose>
                    <xsl:when test="$num_movements&gt;1">
                        <xsl:apply-templates select="m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:title"/>
                    </xsl:when>
                    <xsl:otherwise><title xml:lang="en"/></xsl:otherwise>
                </xsl:choose>
                <respStmt>
                    <xsl:choose>
                        <xsl:when test="$num_movements&gt;1">
                            <xsl:apply-templates select="m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:persname"/>
                        </xsl:when>
                        <xsl:otherwise><persName role=""/></xsl:otherwise>
                    </xsl:choose>
                </respStmt>
            </titleStmt>
            <xsl:choose>
                <!-- insert main key at this level if there is more than one "sub-work" or movements-->
                <xsl:when test="$num_subworks&gt;1 or $num_movements&gt;1">
                    <xsl:apply-templates select="m:app/m:rdg[@type='metadata']/m:scoredef" mode="key"/>
                </xsl:when>
                <xsl:otherwise><key pname="" accid="" mode=""/></xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <!-- insert tempo and metre at this level if there is more than one movement -->
                <xsl:when test="$num_movements&gt;1">
                    <xsl:apply-templates select="m:app/m:rdg[@type='metadata']" mode="TempoMeter"/>
                </xsl:when>
                <xsl:otherwise>
                    <tempo/>
                    <meter meter.count="" meter.unit="" meter.sym=""/>
                </xsl:otherwise>
            </xsl:choose>                        
            <perfMedium analog="marc:048">
                <!-- show instrumentation at sub-work level if: 1) more than one sub-work -->
                <xsl:if test="$num_subworks&gt;1">
                    <!-- AND 2) if indicated in any other than the first -->				
                    <xsl:if test="count(//m:music/m:body/m:mdiv[1]/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))]) 
                        != count(//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))])">
                        <!-- AND 3) this component's instrumentation is indicated -->
                        <xsl:if	test="count(m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))])>0">
                            <xsl:apply-templates select="m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp" mode="instruments"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:if>		
            </perfMedium>                          
            <castList>
                <xsl:choose>                
                    <!-- show castItems at sub-work level if: 1) more than one sub-work -->
                    <!-- AND 2) if indicated in any other than the first -->
                    <!-- AND 3) this component's instrumentation is indicated -->
                    <xsl:when test="$num_subworks&gt;1 and 
                        count(//m:music/m:body/m:mdiv[1]/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))]) 
                        != count(//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))]) and 
                        count(m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))])>0">
                        <xsl:apply-templates select="m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp[@label.full='Characters']/m:staffdef" mode="castList"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <castItem>
                            <role/>              
                        </castItem>
                    </xsl:otherwise>
                </xsl:choose>
            </castList>                        
            <incip>     
                <xsl:choose>
                    <xsl:when test="$num_movements&gt;1">
                        <xsl:apply-templates select="m:app/m:rdg[@type='incipit']/m:div[@type='text_incipit']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <incipText xml:lang="en">
                            <p/>
                        </incipText>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="$num_movements&gt;1">
                        <xsl:apply-templates select="m:app/m:rdg[@type='incipit']/m:annot[@type='links']/m:extptr"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <graphic target="" xl:title="" targettype="lowres"/>
                    </xsl:otherwise>
                </xsl:choose>
                <score/>
            </incip>
            <componentGrp>
                <!-- dig one expression level deeper if we are at sub-work level (i.e. if context is m:score) -->
                <xsl:apply-templates select="m:section" mode="expression"/>
            </componentGrp>
            <relationList>
                <relation rel="hasReproduction" label="Score" targettype="edited_score">
                    <xsl:attribute name="target"/>
                    <xsl:if test="count(//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='edited_score'])&gt;1 or name(node())='section'">
                        <xsl:if test="m:app/m:rdg[@type='edited_score']/m:annot/m:extptr/@xl:href!=''">
                            <xsl:attribute name="target">
                                <xsl:value-of select="m:app/m:rdg[@type='edited_score']/m:annot/m:extptr/@xl:href"/>
                            </xsl:attribute>
                        </xsl:if>
                    </xsl:if>
                </relation> 
            </relationList>
        </expression>
    </xsl:template>

    <xsl:template match="m:app/m:rdg[@type='incipit']/m:div[@type='text_incipit']">
        <incipText>
            <xsl:apply-templates/>
        </incipText>
    </xsl:template>

    <xsl:template match="m:app/m:rdg[@type='incipit']/m:annot[@type='links']/m:extptr">
        <graphic>
            <xsl:attribute name="targettype"><xsl:value-of select="@targettype"/></xsl:attribute>
            <xsl:if test="@xl:href!=''">
                <xsl:attribute name="target"><xsl:value-of select="@xl:href"/></xsl:attribute>
            </xsl:if>                    
        </graphic> 
    </xsl:template>
    
    <xsl:template name="t:bibl">
        <xsl:apply-templates select="@*|*"/>
    </xsl:template>

    <xsl:template match="t:bibl/@type">
            <xsl:choose>
                <xsl:when test=".='Journal Article' or .='Journal article'">
                    <xsl:attribute name="type">Journal_article</xsl:attribute>
                </xsl:when>
                <xsl:when test=".='Diary Entry' or .='Diary entry'">
                    <xsl:attribute name="type">Diary_entry</xsl:attribute>
                </xsl:when>
                <xsl:when test=".='Article in Book' or .='Article in book'">
                    <xsl:attribute name="type">Article_in_book</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="type"><xsl:value-of select="."/></xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>
    
    <xsl:template match="t:biblScope/@type">
        <xsl:choose>
            <xsl:when test=".='pages'">
                <xsl:attribute name="type">pp</xsl:attribute>
            </xsl:when>
            <xsl:when test=".='volume'">
                <xsl:attribute name="type">vol</xsl:attribute>
            </xsl:when>
            <xsl:when test=".='number'">
                <xsl:attribute name="type">issue</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy><xsl:value-of select="."/></xsl:copy>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>
    
    <xsl:template match="m:filedesc/m:pubstmt/m:identifier">
        <altId>
            <xsl:attribute name="analog"><xsl:value-of select="@type"/></xsl:attribute>
            <xsl:value-of select="."/>
        </altId>
    </xsl:template>

    <xsl:template match="m:revisiondesc">
        <revisionDesc>
            <xsl:apply-templates/>
        </revisionDesc>
    </xsl:template>    
    
    <xsl:template match="m:changedesc">
        <changeDesc>
            <xsl:apply-templates/>
        </changeDesc>
    </xsl:template>    
        
    <xsl:template match="m:extptr">
        <ptr>
            <!-- rename attributes -->
            <xsl:copy-of select="@*[name()!='xl:href' and name()!='targettype']"/>
            <xsl:attribute name="target"><xsl:value-of select="@xl:href"/></xsl:attribute>
            <xsl:attribute name="xl:title"><xsl:value-of 
                select="concat(translate(substring(@targettype,1,1), 'abcdefghijklmnopqrstuvwxyzæøå', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅ'), 
                substring(@targettype, 2))"/></xsl:attribute>
        </ptr>
    </xsl:template>
    
    <xsl:template match="m:date">
        <xsl:apply-templates select="." mode="regularize">
            <xsl:with-param name="reg">reg</xsl:with-param>
            <xsl:with-param name="notbefore">notbefore</xsl:with-param>
            <xsl:with-param name="notafter">notafter</xsl:with-param>
            <xsl:with-param name="namespace">http://www.music-encoding.org/ns/mei</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="t:date">
        <xsl:apply-templates select="." mode="regularize">
            <xsl:with-param name="reg">when-iso</xsl:with-param>
            <xsl:with-param name="notbefore">notBefore-iso</xsl:with-param>
            <xsl:with-param name="notafter">notAfter-iso</xsl:with-param>
            <xsl:with-param name="namespace">http://www.tei-c.org/ns/1.0</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="m:date|t:date" mode="regularize">
        <xsl:param name="reg"/>
        <xsl:param name="notbefore"/>
        <xsl:param name="notafter"/>
        <xsl:param name="namespace"/>
        <xsl:element name="date" namespace="{$namespace}">
            <xsl:variable name="datestring" select="."/>
            <!-- try to fill in @reg or @notbefore/@notafter -->
            <xsl:choose>
                <xsl:when test="$datestring castable as xs:date">
                    <xsl:attribute name="{$reg}"><xsl:value-of select="."/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="datepieces" select="tokenize(normalize-space($datestring),'-')"/>
                    <xsl:variable name="days_in_month" select="(31,28,31,30,31,30,31,31,30,31,30,31)"/>
                    <xsl:if test="$datepieces[1] castable as xs:integer and string-length($datepieces[1])=4 and not(exists($datepieces[4]))">
                            <!-- first part may be a year, and no more than three components; go on trying -->
                            <xsl:choose>
                                <xsl:when test="$datepieces[3]">
                                    <!-- three components -->
                                    <xsl:choose>
                                        <xsl:when test="$datepieces[2] castable as xs:integer and string-length($datepieces[2])=2 and xs:integer($datepieces[2])&lt;13">
                                            <!-- second part castable as month -->
                                            <xsl:choose>
                                                <xsl:when test="$datepieces[3]='??'">
                                                    <!-- YYYY-MM-??: use one month -->
                                                    <xsl:attribute name="{$notbefore}" select="xs:date(concat($datepieces[1],'-',$datepieces[2],'-01'))"/>
                                                    <xsl:attribute name="{$notafter}" select="xs:date(concat($datepieces[1],'-',$datepieces[2],'-',$days_in_month[xs:integer($datepieces[2])]))"/>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:if test="$datepieces[2]='??'">
                                                <!-- YYYY-??-??: use one year -->
                                                <xsl:attribute name="{$notbefore}" select="xs:date(concat($datepieces[1],'-01-01'))"/>
                                                <xsl:attribute name="{$notafter}" select="xs:date(concat($datepieces[1],'-12-31'))"/>
                                            </xsl:if>
                                        </xsl:otherwise>
                                    </xsl:choose>                                    
                                </xsl:when>
                                <xsl:when test="$datepieces[2]">
                                    <!-- two components -->                                  
                                    <xsl:choose>
                                        <xsl:when test="$datepieces[2] castable as xs:integer and string-length($datepieces[2])=4">
                                            <!-- YYYY-YYYY: use year range -->
                                            <xsl:attribute name="{$notbefore}" select="xs:date(concat($datepieces[1],'-01-01'))"/>
                                            <xsl:attribute name="{$notafter}" select="xs:date(concat($datepieces[2],'-12-31'))"/>
                                        </xsl:when>
                                        <xsl:when test="$datepieces[2] castable as xs:integer and string-length($datepieces[2])=2">
                                            <xsl:if test="xs:integer(substring($datepieces[1],3,2)) &lt; xs:integer($datepieces[2])">
                                                <!-- YYYY-YY: use year range -->
                                                <xsl:attribute name="{$notbefore}" select="xs:date(concat($datepieces[1],'-01-01'))"/>
                                                <xsl:attribute name="{$notafter}" select="xs:date(concat(substring($datepieces[1],1,2),$datepieces[2],'-12-31'))"/>
                                            </xsl:if>
                                        </xsl:when>
                                    </xsl:choose>                      
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="number($datepieces[1]) and string-length(normalize-space($datepieces[1]))=4">
                                            <!-- YYYY: use one year -->
                                            <xsl:attribute name="{$notbefore}" select="xs:date(concat(normalize-space($datepieces[1]),'-01-01'))"/>
                                            <xsl:attribute name="{$notafter}" select="xs:date(concat(normalize-space($datepieces[1]),'-12-31'))"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="{$notbefore}" select="''"/>
                                            <xsl:attribute name="{$notafter}" select="''"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>                    
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    
    <!-- CAUTION! DELETES ALL CONTENTS IN <music>! -->
    <xsl:template match="m:music">
        <music/>
    </xsl:template>
        
</xsl:stylesheet>

 
