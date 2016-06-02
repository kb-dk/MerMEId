<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.music-encoding.org/ns/mei" 
  xmlns:m="http://www.music-encoding.org/ns/mei" 
  xmlns:xl="http://www.w3.org/1999/xlink"
  xmlns:zs="http://www.loc.gov/zing/srw/"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:dcm="http://www.kb.dk/dcm"
  exclude-result-prefixes="xsl m zs marc xl"
  version="1.0">

<!--
  
  Filter out records containing RISM sigla and sort them according to country.
  The intended input file is the complete list of RISM institutions and names: rism_ks.xml 
  (included in https://opac.rism.info/fileadmin/user_upload/lod/update/rismAllMARCXML.zip 
  which is retrievable at https://opac.rism.info/index.php?id=8&L=0).
  For use with MerMEId, the output should be split into sections by country and saved as separate files
  named A.xml, AFG.xml etc.

  /Axel Geertinger, DCM 2016
  
-->
  
  
  <xsl:output method="xml"
    encoding="UTF-8"
    omit-xml-declaration="yes" 
    indent="yes"/>
  
  <xsl:strip-space elements="*" /> 
  
  <xsl:template match="/">
    <xsl:comment> For use with MerMEId, save each country section as a separate file as indicated </xsl:comment>
    <xsl:text>
      
    </xsl:text>
    <rismSigla xmlns="http://www.kb.dk/dcm">
      <xsl:for-each select="/marc:collection/marc:record[marc:datafield[@tag='040']/marc:subfield[@code='a']/text()[contains(.,'-')]]">
        <xsl:sort select="marc:datafield[@tag='040']/marc:subfield[@code='a']"/>
        <xsl:variable name="country" select="substring-before(marc:datafield[@tag='040']/marc:subfield[@code='a']/text(),'-')"/>
        <xsl:variable name="searchfor" select="concat($country,'-')"/>
        <xsl:if test="count(preceding::*/marc:datafield[@tag='040']/marc:subfield[@code='a'][substring-before(.,'-')=$country])=0">
          <xsl:text>
   </xsl:text>
          <xsl:comment> File name: <xsl:value-of select="$country"/>.xml </xsl:comment>
          <collection xmlns="http://www.loc.gov/MARC21/slim">
            <xsl:for-each select="/marc:collection/marc:record[substring(marc:datafield[@tag='040']/marc:subfield[@code='a']/text(),1,string-length($searchfor))=$searchfor]">
              <xsl:sort select="marc:datafield[@tag='040']/marc:subfield[@code='a']"/>
              <record>
                <xsl:apply-templates/>
              </record>
            </xsl:for-each>
          </collection>
          <xsl:text>
          
        </xsl:text>
        </xsl:if>
        
      </xsl:for-each>        
    </rismSigla>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:transform>
