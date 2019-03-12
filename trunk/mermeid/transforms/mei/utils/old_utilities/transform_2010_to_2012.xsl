<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns="http://www.music-encoding.org/ns/mei" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xl="http://www.w3.org/1999/xlink"
    xmlns:m="http://www.music-encoding.org/ns/mei" xmlns:t="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="m t xsl xs">

    <!-- 
    Transformation from MEI 2010 to MEI 2012 metadata.
    Caution: This transform is made specifically for transforming metadata created using 
    the 2010 version of MerMEId. Metadata from other applications may or may not 
    be successfully transformed with it. 
    Be aware, for instance, that this transform deletes all contents in <music>.

    Sigfrid Lundberg (slu@kb.dk) 
    & Axel Teich Geertinger (atge@kb.dk)
    Danish Centre for Music Editing
    The Royal Library 
    Copenhagen 2012    
    -->

    <xsl:output method="xml" encoding="UTF-8" indent="yes" xml:space="default"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="@*|*">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="m:mei">
        <mei xmlns:xl="http://www.w3.org/1999/xlink">
            <xsl:attribute name="meiversion">2012</xsl:attribute>
            <xsl:if test="count(@xml:id)=0">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="concat('mei_',generate-id(.))"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*|node()"/>
        </mei>
    </xsl:template>

    <xsl:template match="m:meihead">
        <meiHead>
            <xsl:apply-templates/>
        </meiHead>
    </xsl:template>

    <xsl:template match="m:filedesc">
        <fileDesc>
            <titleStmt>
                <!-- titles are moved to <work>; a copy of the first non-empty title is kept here, though -->
                <xsl:element name="title">
                    <xsl:attribute name="xml:lang">
                        <xsl:value-of select="m:titlestmt/m:title[text()][1]/@xml:lang"/>
                    </xsl:attribute>
                    <xsl:value-of select="m:titlestmt/m:title[text()][1]"/>
                </xsl:element>
            </titleStmt>
            <xsl:apply-templates select="m:pubstmt"/>
            <seriesStmt>
                <title>
                    <xsl:if test="normalize-space(//m:encodingdesc/m:projectdesc/m:p/m:list[@n='use'])='CNW'">
                        <xsl:text>Carl Nielsen Works</xsl:text>
                    </xsl:if>
                </title>
                <!-- put in file context identifiers here (= the MerMEId collection) -->
                <identifier type="file_collection">
                    <xsl:value-of select="normalize-space(//m:encodingdesc/m:projectdesc/m:p/m:list[@n='use'])"/>
                </identifier>
            </seriesStmt>
            <xsl:apply-templates select="m:notesstmt"/>
            <xsl:apply-templates select="m:sourcedesc"/>
        </fileDesc>
    </xsl:template>

    <xsl:template match="m:filedesc/m:titlestmt">
        <titleStmt>
            <xsl:apply-templates/>
        </titleStmt>
    </xsl:template>

    <xsl:template match="m:titlestmt">
        <titleStmt>
            <xsl:apply-templates/>
        </titleStmt>
    </xsl:template>

    <xsl:template match="m:filedesc/m:titlestmt/m:title">
        <xsl:choose>
            <xsl:when test="not(normalize-space(.)) and @type!='main'">
                <!-- delete empty titles except the main title -->
            </xsl:when>
            <xsl:otherwise>
                <title>
                    <xsl:choose>
                        <xsl:when test="@type='main'">
                            <!-- remove the 'main' type attribute -->
                            <xsl:apply-templates select="@*[name()!='type']"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="@*"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="."/>
                </title>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="m:filedesc/m:pubstmt">
        <pubStmt>
            <xsl:apply-templates select="@*"/>
            <!-- work identifiers moved to <altId> -->
            <xsl:apply-templates select="*[name(.)!='identifier']"/>
            <availability>
                <acqSource/>
                <accessRestrict/>
                <useRestrict/>
            </availability>
        </pubStmt>
    </xsl:template>

    <xsl:template match="m:pubstmt">
        <pubStmt>
            <xsl:apply-templates/>
        </pubStmt>
    </xsl:template>

    <xsl:template match="m:filedesc/m:pubstmt/m:respstmt">
        <respStmt>
            <!-- add DCM info -->
            <resp>Publisher</resp>
            <corpName>
                <abbr>DCM</abbr>
                <expan>Danish Centre for Music Editing</expan>
                <address>
              <addrLine>The Royal Library</addrLine>
              <addrLine>Søren Kierkegaards Plads 1</addrLine>
              <addrLine>P.O. Box 2149</addrLine>
              <addrLine>DK - 1016 Copenhagen K</addrLine>
              <addrLine><ptr target="http://www.kb.dk/dcm" label="WWW"/></addrLine>
              <addrLine><ptr target="mailto://foa-dcm@kb.dk" label="E-mail"/></addrLine>
            </address>
            </corpName>
            <!-- add names of editors involved -->
            <xsl:variable name="collection"
                select="normalize-space(//m:encodingdesc/m:projectdesc/m:p/m:list[@n='use'])"/>
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
        <xsl:choose>
            <xsl:when test="*[local-name()!='corpname']">
                <respStmt>
                    <xsl:apply-templates/>
                </respStmt>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="m:corpname"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="m:availability">
        <!-- caution: <availability> is being overwritten! -->
    </xsl:template>

    <xsl:template match="m:persname">
        <xsl:choose>
            <xsl:when test=".=''">
                <!-- delete empty persnames -->
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

    <xsl:template match="m:respstmt/m:corpname">
        <publisher>
            <xsl:copy-of select="@*[name(.)!='type']"/>
            <xsl:apply-templates/>
        </publisher>
    </xsl:template>
    
    <xsl:template match="m:corpname[name(..)!='respstmt' and name(..)!='repository']">
        <corpName>
            <xsl:copy-of select="@*[name()!='type']"/>
            <xsl:if test="@type">
                <xsl:attribute name="role"><xsl:value-of select="@type"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </corpName>
    </xsl:template>

    <xsl:template match="m:pubstmt/m:geogname">
        <pubPlace>
            <xsl:copy-of select="@*[name(.)!='type']"/>
            <xsl:apply-templates/>
        </pubPlace>
    </xsl:template>

    <xsl:template match="*[local-name()!='pubstmt']/m:geogname">
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
                    <ptr target="http://www.kb.dk/en/kb/nb/mta/dcm/projekter/mermeid.html"
                        label="MerMEId project home page"/>
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
            <xsl:attribute name="xml:id">
                <xsl:value-of select="$source_id"/>
            </xsl:attribute>
            <xsl:for-each select="m:physdesc/m:physloc/m:repository/m:identifier[contains(.,'[')]">
                <!-- put "CNU source xxx" identifiers here -->
                <!-- cut out CNU Source references in [] (like "[CNU Source A]") and put them into their own <identifier> -->
                <xsl:variable name="remainingString">
                    <xsl:value-of select="substring-before(substring-after(.,'['),']')"/>
                </xsl:variable>
                <xsl:if test="$remainingString!=''">
                    <identifier>
                        <xsl:choose>
                            <xsl:when test="contains($remainingString,'ource')">
                                <xsl:attribute name="type"><xsl:value-of
                                        select="substring-before($remainingString,'ource')"/>ource</xsl:attribute>
                                <xsl:variable name="identifier"
                                    select="normalize-space(substring-after($remainingString,'ource'))"/>
                                <xsl:choose>
                                    <xsl:when test="contains($identifier,'&lt;b&gt;')">
                                        <xsl:value-of
                                            select="substring-before(substring-after($identifier,'&lt;b&gt;'),'&lt;/b&gt;')"
                                        />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$identifier"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring-before($remainingString,']')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </identifier>
                </xsl:if>
            </xsl:for-each>
            <xsl:apply-templates select="@*|m:titlestmt|m:pubstmt[1]"/>
            <!-- only put the first pubStmt here -->
            <physDesc>
                <!-- <physloc>, <provenance> and <handlist> are moved to <item> -->
                <xsl:apply-templates
                    select="@*|m:physdesc/*[name()!='physloc' and name()!='provenance' and name()!='handlist']"/>
                <plateNum>
                    <xsl:value-of select="m:pubstmt/m:identifier[@type='plate_no']"/>
                </plateNum>
            </physDesc>
            <xsl:apply-templates select="m:notesstmt|m:classification"/>
            <!-- add item level -->
            <xsl:if test="m:physdesc/m:physloc//text() or m:physdesc/m:provenance//text() or m:physdesc/m:handlist//text()">
            <itemList>
                <item>
                    <physDesc>
                        <xsl:apply-templates select="m:physdesc/m:provenance"/>
                        <xsl:apply-templates select="m:physdesc/m:handlist"/>
                        <physMedium/>
                    </physDesc>
                    <xsl:apply-templates select="m:physdesc/m:physloc"/>
                </item>
            </itemList>
            </xsl:if>
            <relationList>
                <relation rel="isEmbodimentOf" target="#expression_1"/>
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
                <respStmt/>
            </titleStmt>
            <xsl:apply-templates select="."/>
            <physDesc>
                <plateNum>
                    <xsl:value-of select="m:identifier[@type='plate_no']"/>
                </plateNum>
            </physDesc>
            <relationList>
                <relation rel="isReproductionOf">
                    <xsl:attribute name="target">#<xsl:value-of select="$source_id"/></xsl:attribute>
                </relation>
            </relationList>
        </source>
    </xsl:template>

    <!-- Plate numbers are moved to <physDesc>  -->
    <xsl:template match="m:pubstmt/m:identifier[@type='plate_no']"/>


    <xsl:template match="m:provenance/m:eventlist/m:event">
        <event>
            <!-- move date attributes from <event> to <date> -->
            <date>
                <xsl:variable name="notbefore" select="normalize-space(@notbefore)"/>
                <xsl:variable name="notafter" select="normalize-space(@notafter)"/>
                <xsl:choose>
                    <xsl:when test="$notbefore!='' and $notbefore=$notafter">
                        <xsl:choose>
                            <xsl:when test="$notbefore castable as xs:date">
                                <xsl:attribute name="isodate">
                                    <xsl:value-of select="$notbefore"/>
                                </xsl:attribute>
                                <xsl:attribute name="notbefore" select="''"/>
                                <xsl:attribute name="notafter" select="''"/>
                            </xsl:when>
                            <xsl:when test="$notbefore castable as xs:integer and string-length($notbefore)=4">
                                <xsl:attribute name="notbefore" select="xs:date(concat($notbefore,'-01-01'))"/>
                                <xsl:attribute name="notafter" select="xs:date(concat($notafter,'-12-31'))"/>
                                <xsl:attribute name="isodate" select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="notbefore" select="''"/>
                                <xsl:attribute name="notafter" select="''"/>
                                <xsl:attribute name="isodate" select="''"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:value-of select="$notbefore"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$notbefore castable as xs:date">
                                <xsl:attribute name="notbefore">
                                    <xsl:value-of select="$notbefore"/>
                                </xsl:attribute>
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
                                <xsl:attribute name="notafter">
                                    <xsl:value-of select="$notafter"/>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:when test="$notafter castable as xs:integer and string-length($notafter)=4">
                                <xsl:attribute name="notafter" select="xs:date(concat($notafter,'-12-31'))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="notafter" select="''"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:attribute name="isodate" select="''"/>
                        <xsl:variable name="date_value">
                            <xsl:value-of select="$notbefore"/>
                            <xsl:if test="$notbefore!='' and $notafter!=''"> - </xsl:if>
                            <xsl:value-of select="$notafter"/>
                        </xsl:variable>
                        <xsl:value-of select="$date_value"/>
                    </xsl:otherwise>
                </xsl:choose>
            </date>
            <p><xsl:value-of select="."/></p>
        </event>
    </xsl:template>

    <xsl:template match="m:physdesc">
        <physDesc>
            <xsl:apply-templates select="*[name()!='physLoc']"/>
        </physDesc>
        <xsl:apply-templates select="m:physLoc"/>
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

    <xsl:template match="m:repository">
        <repository>
            <xsl:apply-templates select="@*|*[local-name()!='identifier' and local-name()!='extptr']"/>
            <xsl:apply-templates select="m:extptr"/>
        </repository>
        <!-- move shelf mark out of <repository> -->
        <xsl:apply-templates select="m:identifier"/>
    </xsl:template>

    <xsl:template match="m:repository/m:identifier">
        <!-- Some CNW-specfic cleaning; probably doesn't do any harm in other contexts -->
        <xsl:apply-templates select="@*"/>
        <xsl:choose>
            <xsl:when test="contains(.,'[')">
                <!-- put CNU Source references in [] (like "[CNU Source A]")into their own <identifier> -->
                <identifier>
                    <xsl:value-of select="normalize-space(substring-before(.,'['))"/>
                </identifier>
            </xsl:when>
            <xsl:otherwise>
                <identifier>
                    <xsl:value-of select="."/>
                </identifier>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="m:repository/m:corpname">
            <!-- try to distiguish RISM sigla from written-out archive names -->
            <xsl:choose>
                <xsl:when test="matches(.,'[A-Z]{1,3}-[A-Z]{1,3}[a-z]*')">
                    <identifier authority="RISM" authURI="http://www.rism.info"><xsl:value-of select="."/></identifier>
                </xsl:when>
                <xsl:otherwise>
                    <corpName><xsl:value-of select="."/></corpName>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>
    
    <xsl:template match="m:physmedium">
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
        </notesStmt>
    </xsl:template>

    <xsl:template match="m:filedesc/m:notesstmt" mode="work">
        <xsl:apply-templates select="m:annot[@type='general_description']"/>
        <xsl:apply-templates select="m:annot[@type='links']"/>
    </xsl:template>

    <xsl:template match="m:music/m:front/t:div[t:head='Bibliography']/t:listBibl">
        <biblList>
            <xsl:if test="not(@xml:id)">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="concat('biblList_',generate-id(.))"/>
                    <xsl:number level="any" count="//node()"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*[name()!='type']"/>
            <xsl:choose>
                <xsl:when test="not(@type) or contains(@type,'econdary')">
                    <head>Bibliography</head>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="contains(@type,'rimary')">
                            <head>Primary texts</head>
                        </xsl:when>
                        <xsl:when test="contains(@type,'ocument')">
                            <head>Documentation</head>
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="t:bibl[*//text()]"/>
        </biblList>
    </xsl:template>

    <xsl:template match="m:langusage">
        <langUsage>
            <xsl:for-each select="m:language">
                <!-- delete unused language declarations except english -->
                <xsl:if test="@xml:id=//@xml:lang or @xml:id='en'">
                    <xsl:apply-templates select="."/>
                </xsl:if>
            </xsl:for-each>
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
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="m:profiledesc">
        <xsl:variable name="num_subworks" select="count(//m:music/m:body/m:mdiv)"/>
        <xsl:variable name="num_movements" select="count(//m:music/m:body/m:mdiv/m:score/m:section)"/>
        <workDesc>
            <work analog="frbr:work">
                <xsl:apply-templates select="//m:meihead/m:filedesc/m:pubstmt/m:identifier"/>
                <xsl:apply-templates select="//m:meihead/m:filedesc/m:titlestmt"/>
                <history>
                    <creation>
                        <xsl:apply-templates select="m:creation/m:p/m:date"/>
                        <geogName/>
                    </creation>
                    <xsl:apply-templates select="m:creation/m:p[@type='note']"/>
                </history>

                <xsl:apply-templates select="m:langusage"/>

                <!-- move bibliographies from <front> to <work> -->
                <xsl:apply-templates select="//m:music/m:front/t:div[t:head='Bibliography']/t:listBibl"/>

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
                    <expression analog="frbr:expression" xml:id="expression_1">
                        <xsl:attribute name="n" select="@n"/>
                        <titleStmt>
                            <!-- show movement-level title at this level if there is only one movement -->
                            <xsl:choose>
                                <xsl:when test="$num_movements=1">
                                    <xsl:apply-templates
                                        select="//m:music/m:body/m:mdiv/m:score/m:section/m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:title"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <title xml:lang="en"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <respStmt>
                                <xsl:choose>
                                    <xsl:when
                                        test="$num_movements=1 and //m:music/m:body/m:mdiv/m:score/m:section/m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:persname">
                                        <xsl:apply-templates
                                            select="//m:music/m:body/m:mdiv/m:score/m:section/m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:persname"
                                        />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <persName role=""/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </respStmt>
                        </titleStmt>
                        <incip>
                            <incipText>
                                <xsl:choose>
                                    <xsl:when
                                        test="$num_movements=1 and //m:music/m:body/m:mdiv/m:score/m:section/m:app/m:rdg[@type='incipit']/m:div[@type='text_incipit']/m:p">
                                        <xsl:apply-templates
                                            select="//m:music/m:body/m:mdiv/m:score/m:section/m:app/m:rdg[@type='incipit']/m:div[@type='text_incipit']/m:p"
                                        />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <p xml:lang="en"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </incipText>
                            <xsl:choose>
                                <xsl:when
                                    test="$num_movements=1 and //m:music/m:body/m:mdiv/m:score/m:section/m:app/m:rdg[@type='incipit']/m:annot[@type='links']/m:extptr">
                                    <xsl:apply-templates
                                        select="//m:music/m:body/m:mdiv/m:score/m:section/m:app/m:rdg[@type='incipit']/m:annot[@type='links']/m:extptr"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <graphic target="" label="" targettype="lowres"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <score/>
                        </incip>
                        <xsl:choose>
                            <!-- insert main key at top level only if there is no more than one "sub-work" -->
                            <xsl:when test="$num_subworks=1">
                                <xsl:apply-templates
                                    select="//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='metadata']/m:scoredef"
                                    mode="key"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <key pname="" accid="" mode=""/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                            <!-- insert tempo and metre at this level if there is only one movement -->
                            <xsl:when test="$num_movements=1">
                                <xsl:apply-templates
                                    select="//m:music/m:body/m:mdiv/m:score/m:section/m:app/m:rdg[@type='metadata']"
                                    mode="TempoMeter"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <tempo/>
                                <meter/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <history>
                            <creation>
                                <date/>
                                <geogName/>
                            </creation>
                            <p/>
                            <eventList type="performances">
                                <xsl:apply-templates select="m:eventlist/m:event"/>
                            </eventList>
                        </history>
                        <perfMedium analog="marc:048">
                            <castList>
                                <!-- list cast at top level if there is no more than one work component OR if instrumentation is indicated on first component only-->
                                <xsl:choose>
                                    <!-- if only 1 work component: -->
                                    <!-- show cast if non-empty -->
                                    <xsl:when
                                        test="$num_subworks=1 and
                                        count(//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp[contains(concat(@label.full,@label.abbr),'aracter')]/m:staffdef[normalize-space(concat(@label.full,@label.abbr))])>0">
                                        <xsl:apply-templates
                                            select="//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp[contains(concat(@label.full,@label.abbr),'aracter')]"
                                            mode="castList"/>
                                    </xsl:when>
                                    <!-- if more than one component (i.e. there are sub-works): -->
                                    <xsl:otherwise>
                                        <!-- show cast list if first components' cast list is non-empty -->
                                        <!-- AND it is the only component having a cast list -->
                                        <xsl:if
                                            test="count(//m:music/m:body/m:mdiv[1]/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp[contains(concat(@label.full,@label.abbr),'aracter')]/m:staffdef[normalize-space(concat(@label.full,@label.abbr))])>0 
                                            and count(//m:music/m:body/m:mdiv[m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp[contains(concat(@label.full,@label.abbr),'aracter')]/m:staffdef[normalize-space(concat(@label.full,@label.abbr))]])=1">
                                            <xsl:apply-templates
                                                select="//m:music/m:body/m:mdiv[1]/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp[contains(concat(@label.full,@label.abbr),'aracter')]"
                                                mode="castList"/>
                                        </xsl:if>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </castList>
                            <instrumentation>
                                <!-- list instrumentation at top level if there is no more than one work component OR if instrumentation is indicated on first component only-->
                                <xsl:choose>
                                    <!-- if only 1 work component: -->
                                    <xsl:when test="$num_subworks=1">
                                        <!-- show instrumentation if non-empty -->
                                        <xsl:if
                                            test="count(//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))])>0">
                                            <xsl:apply-templates
                                                select="//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp"
                                                mode="instruments"/>
                                        </xsl:if>
                                    </xsl:when>
                                    <!-- if more than one component (i.e. there are sub-works): -->
                                    <xsl:otherwise>
                                        <!-- show instrumentation if first components' instrumentation is non-empty -->
                                        <xsl:if
                                            test="count(//m:music/m:body/m:mdiv[1]/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))])>0">
                                            <!-- AND it is the only component with instrumentation -->
                                            <xsl:if
                                                test="count(//m:music/m:body/m:mdiv[m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))]])=1">
                                                <xsl:apply-templates
                                                    select="//m:music/m:body/m:mdiv[1]/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp"
                                                    mode="instruments"/>
                                            </xsl:if>
                                        </xsl:if>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </instrumentation>
                        </perfMedium>
                        <classification>
                            <termList>
                                <term/>
                            </termList>
                        </classification>
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
                                        <xsl:apply-templates select="//m:music/m:body/m:mdiv/m:score" mode="expression"
                                        />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:if>
                        </componentGrp>
                        <xsl:if test="count(//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='edited_score'])=1">
                            <relationList>
                                <relation rel="hasReproduction" label="Edited score" targettype="edited_score">
                                    <xsl:attribute name="target">
                                        <xsl:value-of
                                            select="//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='edited_score']/m:annot/m:extptr/@xl:href"
                                        />
                                    </xsl:attribute>
                                </relation>
                            </relationList>
                        </xsl:if>
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
            <xsl:apply-templates select="*[name(.)!='bibl' and name(.)!='title']"/>
            <xsl:choose>
                <xsl:when test="m:title='Other performance'">
                    <!-- delete "Other performance" titles -->
                </xsl:when>
                <xsl:when test="m:title='First performance'">
                    <xsl:choose>
                        <xsl:when test="*[name(.)!='title']//text()">
                            <p><xsl:value-of select="m:title"/>.</p>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- delete "First performance" titles if no other data on the event -->
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <p><xsl:value-of select="m:title"/></p>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="t:bibl[*//text()]">
                <biblList>
                    <xsl:if test="not(@xml:id)">
                        <xsl:attribute name="xml:id">
                            <xsl:value-of select="concat('biblList_',generate-id(.))"/>
                            <xsl:number level="any" count="//node()"/>
                        </xsl:attribute>
                    </xsl:if>
                    <head>Reviews</head>
                    <xsl:apply-templates select="t:bibl"/>
                </biblList>
            </xsl:if>
        </event>
    </xsl:template>

    <xsl:template match="m:app/m:rdg[@type='metadata']" mode="TempoMeter">
        <tempo>
            <xsl:value-of select="m:tempo"/>
        </tempo>
        <meter>
            <xsl:if test="m:scoredef/@meter.count!=''">
                <xsl:attribute name="count">
                    <xsl:value-of select="m:scoredef/@meter.count"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="m:scoredef/@meter.unit!=''">
                <xsl:attribute name="unit">
                    <xsl:value-of select="m:scoredef/@meter.unit"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="m:scoredef/@meter.sym!=''">
                <xsl:attribute name="sym">
                    <xsl:value-of select="m:scoredef/@meter.sym"/>
                </xsl:attribute>
            </xsl:if>
        </meter>
    </xsl:template>

    <xsl:template match="m:scoredef" mode="key">
        <key pname="" accid="" mode="">
            <xsl:if test="@key.pname!=''">
                <xsl:attribute name="pname">
                    <xsl:value-of select="@key.pname"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@key.accid!=''">
                <xsl:attribute name="accid">
                    <xsl:value-of select="@key.accid"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@key.mode!=''">
                <xsl:attribute name="mode">
                    <xsl:value-of select="@key.mode"/>
                </xsl:attribute>
            </xsl:if>
        </key>
    </xsl:template>

    <xsl:template match="m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp" mode="instruments">
        <xsl:choose>
            <xsl:when
                test="count(m:staffgrp[contains(@label.full,'Basic')]/m:staffdef[normalize-space(concat(@label.abbr,' ',@label.full))!=''])&gt;2">
                <!-- if more than two basic instruments, make them a group -->
                <instrVoiceGrp code="on">
                    <head/>
                    <xsl:apply-templates
                        select="m:staffgrp[contains(@label.full,'Basic')]/m:staffdef[normalize-space(concat(@label.abbr,' ',@label.full))!='']"
                        mode="instrVoice"/>
                </instrVoiceGrp>
            </xsl:when>
            <xsl:otherwise>
                <!-- else just list performer(s) -->
                <xsl:apply-templates
                    select="m:staffgrp[contains(@label.full,'Basic')]/m:staffdef[normalize-space(concat(@label.abbr,' ',@label.full))!='']"
                    mode="instrVoice"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates
            select="m:staffgrp[contains(@label.full,'Choir')]/m:staffdef[normalize-space(concat(@label.abbr,' ',@label.full))!='']"
            mode="choirs"/>
        <xsl:apply-templates
            select="m:staffgrp[contains(@label.full,'Soloists')]/m:staffdef[normalize-space(concat(@label.abbr,' ',@label.full))!='']"
            mode="instrVoice"/>
    </xsl:template>

    <xsl:template match="m:staffdef" mode="choirs">
        <instrVoiceGrp code="cn">
            <head>Choir</head>
            <xsl:apply-templates select="." mode="instrVoice"/>
        </instrVoiceGrp>
    </xsl:template>

    <xsl:template match="m:staffdef" mode="instrVoice">
        <instrVoice>
            <xsl:choose>
                <xsl:when test="contains(parent::node()/@label.full,'Soloists')">
                    <xsl:attribute name="solo">true</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="solo">false</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="contains(parent::node()/@label.full,'Choir')">
                <xsl:attribute name="code">cn</xsl:attribute>
            </xsl:if>
            <xsl:variable name="instrString" select="normalize-space(concat(@label.abbr,' ',@label.full))"/>
            <xsl:variable name="instrCount">
                <xsl:call-template name="instrNumber">
                    <xsl:with-param name="input" select="$instrString"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:attribute name="count">
                <xsl:choose>
                    <xsl:when test="$instrCount!=''">
                        <xsl:value-of select="$instrCount"/>
                    </xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:call-template name="instrName">
                <xsl:with-param name="input" select="$instrString"/>
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
            <instrVoice/>
            <role>
                <name xml:lang="en">
                    <xsl:value-of select="normalize-space(concat(@label.abbr,' ',@label.full))"/>
                </name>
            </role>
            <roleDesc xml:lang="en"/>
        </castItem>
    </xsl:template>

    <xsl:template match="m:score|m:section" mode="expression">
        <xsl:variable name="num_subworks" select="count(//m:music/m:body/m:mdiv)"/>
        <xsl:variable name="num_movements" select="count(//m:music/m:body/m:mdiv/m:score/m:section)"/>
        <!-- match movements -->
        <expression analog="frbr:expression">
            <xsl:attribute name="n">
                <xsl:value-of select="@n"/>
            </xsl:attribute>
            <titleStmt>
                <xsl:choose>
                    <xsl:when test="$num_movements&gt;1">
                        <xsl:apply-templates select="m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <title xml:lang="en"/>
                    </xsl:otherwise>
                </xsl:choose>
                <respStmt>
                    <xsl:choose>
                        <xsl:when test="$num_movements&gt;1">
                            <xsl:apply-templates select="m:app/m:rdg[@type='metadata']/m:scoredef/m:pghead1/m:persname"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <persName role=""/>
                        </xsl:otherwise>
                    </xsl:choose>
                </respStmt>
            </titleStmt>
            <incip>
                <incipText>
                    <xsl:choose>
                        <xsl:when test="m:app/m:rdg[@type='incipit']/m:div[@type='text_incipit']/m:p">
                            <xsl:apply-templates select="m:app/m:rdg[@type='incipit']/m:div[@type='text_incipit']/m:p"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <p xml:lang="en"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </incipText>
                <xsl:choose>
                    <xsl:when test="m:app/m:rdg[@type='incipit']/m:annot[@type='links']/m:extptr">
                        <xsl:apply-templates select="m:app/m:rdg[@type='incipit']/m:annot[@type='links']/m:extptr"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <graphic target="" label="" targettype="lowres"/>
                    </xsl:otherwise>
                </xsl:choose>
                <score/>
            </incip>      
            <xsl:choose>
                <!-- insert main key at this level if there is more than one "sub-work" or movements-->
                <xsl:when test="$num_subworks&gt;1 or $num_movements&gt;1">
                    <xsl:apply-templates select="m:app/m:rdg[@type='metadata']/m:scoredef" mode="key"/>
                </xsl:when>
                <xsl:otherwise>
                    <key pname="" accid="" mode=""/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <!-- insert tempo and metre at this level if there is more than one movement -->
                <xsl:when test="$num_movements&gt;1">
                    <xsl:apply-templates select="m:app/m:rdg[@type='metadata']" mode="TempoMeter"/>
                </xsl:when>
                <xsl:otherwise>
                    <tempo/>
                    <meter/>
                </xsl:otherwise>
            </xsl:choose>
            <perfMedium analog="marc:048">
                <castList>
                    <!-- show castItems at sub-work level if: 1) more than one sub-work -->
                    <!-- AND 2) if indicated in any other than the first -->
                    <!-- AND 3) this component's instrumentation is indicated -->
                    <xsl:if
                        test="$num_subworks&gt;1 and 
                        count(//m:music/m:body/m:mdiv[1]/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))]) 
                        != count(//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))]) and 
                        count(m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))])>0">
                        <xsl:apply-templates
                            select="m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp[@label.full='Characters']/m:staffdef"
                            mode="castList"/>
                    </xsl:if>
                </castList>
                <instrumentation>
                    <!-- show instrumentation at sub-work level if: 1) more than one sub-work -->
                    <xsl:if test="$num_subworks&gt;1">
                        <!-- AND 2) if indicated in any other than the first -->
                        <xsl:if
                            test="count(//m:music/m:body/m:mdiv[1]/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))]) 
                            != count(//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))])">
                            <!-- AND 3) this component's instrumentation is indicated -->
                            <xsl:if
                                test="count(m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp/m:staffgrp/m:staffdef[normalize-space(concat(@label.full,@label.abbr))])>0">
                                <xsl:apply-templates select="m:app/m:rdg[@type='metadata']/m:scoredef/m:staffgrp"
                                    mode="instruments"/>
                            </xsl:if>
                        </xsl:if>
                    </xsl:if>
                </instrumentation>
            </perfMedium>
            <componentGrp>
                <!-- dig one expression level deeper if we are at sub-work level (i.e. if context is m:score) -->
                <xsl:apply-templates select="m:section" mode="expression"/>
            </componentGrp>
            <xsl:if
                test="(count(//m:music/m:body/m:mdiv/m:score/m:app/m:rdg[@type='edited_score'])&gt;1 
                or name(node())='section')
                and m:app/m:rdg[@type='edited_score']/m:annot/m:extptr/@xl:href!=''">
            <relationList>
                <relation rel="hasReproduction" label="Score" targettype="edited_score">
                    <xsl:attribute name="target"><xsl:value-of select="m:app/m:rdg[@type='edited_score']/m:annot/m:extptr/@xl:href"></xsl:value-of></xsl:attribute>
                </relation>
            </relationList>
                </xsl:if>
        </expression>
    </xsl:template>

    <xsl:template match="m:app/m:rdg[@type='incipit']/m:annot[@type='links']/m:extptr">
        <graphic>
            <xsl:attribute name="targettype">
                <xsl:value-of select="@targettype"/>
            </xsl:attribute>
            <xsl:if test="@xl:href!=''">
                <xsl:attribute name="target">
                    <xsl:value-of select="@xl:href"/>
                </xsl:attribute>
            </xsl:if>
        </graphic>
    </xsl:template>


    <!-- translate <TEI:listBibl> to MEI namespace -->

    <xsl:template match="t:bibl">
        <bibl>
            <xsl:copy-of select="@*[name(.)!='type']"/>
            <xsl:choose>
                <xsl:when test="contains(@type,'etter')">
                    <genre>letter</genre>
                </xsl:when>
                <xsl:when test="contains(@type,'iary')">
                    <genre>diary entry</genre>
                </xsl:when>
                <xsl:when test="contains(@type,'ournal')">
                    <genre>article</genre>
                    <genre>journal</genre>
                </xsl:when>
                <xsl:when test="contains(@type,'ewspaper')">
                    <genre>article</genre>
                    <genre>newspaper</genre>
                </xsl:when>
                <xsl:when test="contains(@type,'rticle in')">
                    <genre>article</genre>
                    <genre>book</genre>
                </xsl:when>
                <xsl:when test="contains(@type,'resource')">
                    <genre>web site</genre>
                </xsl:when>
                <xsl:when test="contains(@type,'rogramme')">
                    <genre>concert programme</genre>
                </xsl:when>
                <xsl:when test="contains(@type,'onograph')">
                    <genre>book</genre>
                </xsl:when>
                <xsl:otherwise>
                    <genre>
                        <xsl:value-of select="translate(@type,'_',' ')"/>
                    </genre>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="t:author|t:name|t:editor|t:title"/>
            <xsl:choose>
                <xsl:when test="contains(@type,'etter') or contains(@type,'iary')">
                    <creation>
                        <xsl:apply-templates select="t:date"/>
                        <xsl:apply-templates select="t:geogName"/>
                    </creation>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="t:date/text() or t:publisher/text() or t:pubPlace/text()">
                        <imprint>
                            <xsl:apply-templates select="t:date"/>
                            <xsl:apply-templates select="t:pubPlace"/>
                            <xsl:apply-templates select="t:publisher"/>
                        </imprint>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="t:biblScope|t:msIdentifier|t:note|t:ref"/>
        </bibl>
    </xsl:template>

    <xsl:template match="t:author">
        <creator>
            <xsl:apply-templates/>
        </creator>
    </xsl:template>

    <xsl:template match="t:name[@role='recipient']">
        <recipient>
            <xsl:apply-templates/>
        </recipient>
    </xsl:template>

    <xsl:template match="t:editor">
        <xsl:if test="text()">
            <editor>
                <xsl:apply-templates/>
            </editor>
        </xsl:if>
    </xsl:template>

    <xsl:template match="t:msIdentifier">
        <physLoc>
            <repository>
                <!-- try to distiguish RISM sigla from written-out archive names -->
                <xsl:choose>
                    <xsl:when test="matches(t:repository,'[A-Z]{1,3}-[A-Z]{1,3}[a-z]*') and string-length(t:repository) &lt; 10">
                        <identifier authority="RISM" authURI="http://www.rism.info/"><xsl:apply-templates select="t:repository"/></identifier>
                    </xsl:when>
                    <xsl:otherwise>
                        <corpName><xsl:apply-templates select="t:repository"/></corpName>
                    </xsl:otherwise>
                </xsl:choose>
            </repository>
            <identifier>
                <xsl:value-of select="t:idno"/>
            </identifier>
        </physLoc>
    </xsl:template>

    <xsl:template match="t:note">
        <xsl:if test="text()">
            <annot>
                <xsl:apply-templates/>
            </annot>
        </xsl:if>
    </xsl:template>

    <xsl:template match="t:ref">
        <xsl:if test="@target!=''">
            <ptr>
                <xsl:attribute name="target" select="@target"/>
            </ptr>
        </xsl:if>
    </xsl:template>

    <xsl:template match="t:ref[@type='editions' and //text()]">
        <xsl:for-each select="t:bibl">
            <relatedItem rel="host">
                <bibl>
                    <title>
                        <xsl:value-of select="t:title"/>
                    </title>
                    <xsl:apply-templates select="t:biblScope"/>
                </bibl>
            </relatedItem>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="t:biblScope">
        <biblScope>
            <xsl:choose>
                <xsl:when test="@type='pages' or @type='pp'">
                    <xsl:attribute name="unit">page</xsl:attribute>
                </xsl:when>
                <xsl:when test="@type='volume'">
                    <xsl:attribute name="unit">vol</xsl:attribute>
                </xsl:when>
                <xsl:when test="@type='number'">
                    <xsl:attribute name="unit">issue</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="@type!=''">
                        <xsl:attribute name="unit">
                            <xsl:value-of select="@type"/>
                        </xsl:attribute>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </biblScope>
    </xsl:template>

    <xsl:template match="t:repository">
        <!-- some CNW-specific replacements ... -->
        <xsl:choose>
            <xsl:when test="contains(.,'DK-K ')">
                <xsl:value-of select="concat(substring-after(.,'DK-K '),', Copenhagen')"/>
            </xsl:when>
            <xsl:when test="contains(.,'DK-O ')">
                <xsl:value-of select="concat(substring-after(.,'DK-O '),', Odense')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="t:*">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <!-- end changing namespace -->

    <xsl:template match="m:filedesc/m:pubstmt/m:identifier">
        <identifier>
            <xsl:attribute name="type">
                <xsl:value-of select="@type"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>

    <xsl:template match="m:revisiondesc">
        <revisionDesc>
            <xsl:apply-templates/>
            <!-- Add a record of the conversion to revisionDesc -->
            <change>
                <xsl:attribute name="isodate"><xsl:value-of 
                    select="format-date(current-date(),'[Y]-[M02]-[D02]')"/></xsl:attribute>
                <xsl:attribute name="resp">MerMEId</xsl:attribute>
                <xsl:variable name="generated_id" select="generate-id()"/>
                <xsl:variable name="no_of_nodes" select="count(//*)"/>
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="concat('change_',$no_of_nodes,$generated_id)"/>
                </xsl:attribute>
                <changeDesc>
                    <p>Automated conversion from MEI 2010 to MEI 2012</p>
                </changeDesc>
            </change>
        </revisionDesc>
    </xsl:template>

    <xsl:template match="m:change">
        <change>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="isodate" select="m:date"/>
            <xsl:attribute name="resp" select="m:respstmt/m:persname"/>
            <xsl:apply-templates select="m:changedesc"/>
        </change>
    </xsl:template>

    <xsl:template match="m:changedesc">
        <changeDesc>
            <xsl:apply-templates/>
        </changeDesc>
    </xsl:template>

    <xsl:template match="m:extptr">
        <xsl:if test="normalize-space(@target) or normalize-space(@xl:href)">
            <ptr>
                <!-- rename attributes -->
                <xsl:copy-of select="@*[name()!='xl:href' and name()!='xl:title' and name()!='targettype']"/>
                <xsl:attribute name="target">
                    <xsl:value-of select="@xl:href"/>
                </xsl:attribute>
                <xsl:attribute name="label">
                    <xsl:choose>
                        <xsl:when test="@xl:title and @xl:title!=''">
                            <xsl:value-of
                                select="concat(translate(substring(@xl:title,1,1), 'abcdefghijklmnopqrstuvwxyzæøå', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅ'), 
                                substring(@xl:title, 2))"/>
                        </xsl:when>
                        <xsl:when test="@targettype and @targettype!=''">
                            <xsl:value-of
                                select="concat(translate(substring(@targettype,1,1), 'abcdefghijklmnopqrstuvwxyzæøå', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅ'), 
                                substring(@targettype, 2))"/>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:attribute>
            </ptr>
        </xsl:if>
    </xsl:template>
    

    <xsl:template match="m:date|t:date">
        <!-- TEI dates are moved to MEI namespace -->
        <date>
            <xsl:variable name="datestring" select="."/>
            <!-- try to fill in @isodate or @notbefore/@notafter -->
            <xsl:choose>
                <xsl:when test="$datestring castable as xs:date">
                    <xsl:attribute name="isodate">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="datepieces" select="tokenize(normalize-space($datestring),'-')"/>
                    <xsl:variable name="days_in_month" select="(31,28,31,30,31,30,31,31,30,31,30,31)"/>
                    <xsl:if
                        test="$datepieces[1] castable as xs:integer and string-length($datepieces[1])=4 and not(exists($datepieces[4]))">
                        <!-- first part may be a year, and no more than three components; go on trying -->
                        <xsl:choose>
                            <xsl:when test="$datepieces[3]">
                                <!-- three components -->
                                <xsl:choose>
                                    <xsl:when
                                        test="$datepieces[2] castable as xs:integer and string-length($datepieces[2])=2 and xs:integer($datepieces[2])&lt;13">
                                        <!-- second part castable as month -->
                                        <xsl:choose>
                                            <xsl:when test="$datepieces[3]='??'">
                                                <!-- YYYY-MM-??: one month -->
                                                <xsl:attribute name="isodate"
                                                    select="concat($datepieces[1],'-',$datepieces[2])"/>
                                                <!--
                                                    <xsl:attribute name="{$notbefore}" select="xs:date(concat($datepieces[1],'-',$datepieces[2],'-01'))"/>
                                                    <xsl:attribute name="{$notafter}" select="xs:date(concat($datepieces[1],'-',$datepieces[2],'-',$days_in_month[xs:integer($datepieces[2])]))"/>
                                                    -->
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:if test="$datepieces[2]='??'">
                                            <!-- YYYY-??-??: one year -->
                                            <xsl:attribute name="isodate" select="$datepieces[1]"/>
                                            <!-- 
                                                <xsl:attribute name="{$notbefore}" select="xs:date(concat($datepieces[1],'-01-01'))"/>
                                                <xsl:attribute name="{$notafter}" select="xs:date(concat($datepieces[1],'-12-31'))"/>
                                                -->
                                        </xsl:if>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$datepieces[2]">
                                <!-- two components -->
                                <xsl:choose>
                                    <xsl:when
                                        test="$datepieces[2] castable as xs:integer and string-length($datepieces[2])=4">
                                        <!-- YYYY-YYYY: use year range -->
                                        <xsl:attribute name="notbefore" select="$datepieces[1]"/>
                                        <xsl:attribute name="notafter" select="$datepieces[2]"/>
                                        <!--
                                            <xsl:attribute name="{$notbefore}" select="xs:date(concat($datepieces[1],'-01-01'))"/>
                                            <xsl:attribute name="{$notafter}" select="xs:date(concat($datepieces[2],'-12-31'))"/>
                                            -->
                                    </xsl:when>
                                    <xsl:when
                                        test="$datepieces[2] castable as xs:integer and string-length($datepieces[2])=2">
                                        <xsl:if
                                            test="xs:integer(substring($datepieces[1],3,2)) &lt; xs:integer($datepieces[2])">
                                            <!-- YYYY-YY: use year range -->
                                            <xsl:attribute name="notbefore" select="$datepieces[1]"/>
                                            <xsl:attribute name="notafter"
                                                select="concat(substring($datepieces[1],1,2),$datepieces[2])"/>
                                            <!--
                                                <xsl:attribute name="{$notbefore}" select="xs:date(concat($datepieces[1],'-01-01'))"/>
                                                <xsl:attribute name="{$notafter}" select="xs:date(concat(substring($datepieces[1],1,2),$datepieces[2],'-12-31'))"/>
                                                -->
                                        </xsl:if>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when
                                        test="number($datepieces[1]) and string-length(normalize-space($datepieces[1]))=4">
                                        <!-- YYYY: use one year -->
                                        <xsl:attribute name="isodate" select="normalize-space($datepieces[1])"/>
                                        <!--
                                            <xsl:attribute name="{$notbefore}" select="xs:date(concat(normalize-space($datepieces[1]),'-01-01'))"/>
                                            <xsl:attribute name="{$notafter}" select="xs:date(concat(normalize-space($datepieces[1]),'-12-31'))"/>
                                            -->
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="notbefore" select="''"/>
                                        <xsl:attribute name="notafter" select="''"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="."/>
        </date>
    </xsl:template>
    
    <!-- avoid double escaping ampersands -->
    <xsl:template match="text()[contains(.,'amp;amp;')]">
        <xsl:call-template name="amp">
            <xsl:with-param name="string" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="amp">
        <xsl:param name="string"/>
        <xsl:value-of select="substring-before($string,'amp;amp;')"/>amp;<xsl:call-template 
            name="amp">
            <xsl:with-param name="string" select="substring-after(.,'amp;amp;')"/>
        </xsl:call-template>
    </xsl:template>

    <!-- CAUTION! THIS DELETES ALL CONTENTS IN <music>! -->
    <xsl:template match="m:music">
        <music/>
    </xsl:template>

</xsl:stylesheet>
