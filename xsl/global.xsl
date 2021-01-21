<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: converter.xsl 3624 2011-04-11 11:37:15Z clanz $ -->
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:hgv="HGV"
  xmlns:my="http://local"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fm="http://www.filemaker.com/fmpxmlresult"
  xmlns="http://www.tei-c.org/ns/1.0">

<!-- 

functions
  my:space-remove(string)
  my:field-pos(doc, field-name)
  my:format-num(num-val, for-num)
  my:norm-num(num-val)
  my:dir(cur-dir, cur-rec)

variables
  languages
  amp

templates
  att-jmt(ATT, J, M, T, J2, M2, T2)

-->
  <!-- parameters -->
  <xsl:param name="process" select="'all'" as="xs:string"/> <!-- new, modified or all -->
  <xsl:param name="fileRepository" select="'../data/master'"  as="xs:string"/> <!-- path to readonly idp.data repository OXYGEN!!! -->
  <xsl:param name="fileMentionedDates" select="'../data/master/HGV_metadata/XML_dump/MentionedDates.xml'"  as="xs:string"/> <!-- mentioned dates lookup file -->
  <xsl:param name="fileNomeList" select="'../data/master/HGV_metadata/XML_dump/nomeList.xml'"  as="xs:string"/> <!-- nome list lookup file -->
  <xsl:param name="outputPath" select="'../xwalk/HGV_meta_EpiDoc'"  as="xs:string"/> <!-- output path on server -->
  <xsl:param name="placeRef" select="'../data/placeRef.xml'"  as="xs:string"/>
  <xsl:param name="hgvId" select="'../data/hgvId.xml'"  as="xs:string"/>

  <!-- functions -->
  <xsl:function name="my:space-remove">
    <xsl:param name="string"/>
    <xsl:value-of select="translate($string, ' ', '')"/>
  </xsl:function>

  <!-- Gets the position of the field in the file to be used on the COL below -->
  <xsl:function name="my:field-pos" as="xs:integer">
    <xsl:param name="doc"/>
    <xsl:param name="field-name"/>

    <xsl:value-of
      select="count($doc/fm:FMPXMLRESULT/fm:METADATA/fm:FIELD
      [@NAME = $field-name]/preceding-sibling::fm:FIELD) + 1"
    />
  </xsl:function>

  <!-- Formats a number with leading 0s defined by the parameter -->
  <xsl:function name="my:format-num">
    <xsl:param name="num-val" as="xs:integer"/>
    <xsl:param name="for-num"/>

    <xsl:choose>
      <xsl:when test="$for-num = '2'">
        <xsl:number value="$num-val" format="01"/>
      </xsl:when>
      <xsl:when test="$for-num = '4'">
        <xsl:number value="$num-val" format="0001"/>
      </xsl:when>
    </xsl:choose>
  </xsl:function>

  <!-- Normalizes data so that only numbers are left -->
  <xsl:function name="my:norm-num">
    <xsl:param name="num-val"/>

    <xsl:analyze-string select="$num-val" regex="([^\d]*)(\d+)([^\d]*)">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(2)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:function>

  <!-- Defines sub-directory of output -->
  <xsl:function name="my:dir">
    <xsl:param name="cur-dir"/>
    <xsl:param name="cur-rec"/>

    <xsl:text>HGV</xsl:text>
    <xsl:value-of select="ceiling($cur-rec div 1000)"/>
  </xsl:function>
  
  <!-- variables -->
  
  <!-- Languages used -->
  <xsl:variable name="languages" as="element()">
    <hgv:languages>
      <hgv:language hgv:iso="fr" hgv:de="Französisch" hgv:en="French" />
      <hgv:language hgv:iso="en" hgv:de="Englisch"    hgv:en="English" />
      <hgv:language hgv:iso="de" hgv:de="Deutsch"     hgv:en="German" />
      <hgv:language hgv:iso="it" hgv:de="Italienisch" hgv:en="Italian" />
      <hgv:language hgv:iso="es" hgv:de="Spanisch"    hgv:en="Spanish" />
      <hgv:language hgv:iso="la" hgv:de="Latein"      hgv:en="Latin" />
      <hgv:language hgv:iso="el" hgv:de="Griechisch"  hgv:en="Greek" />
    </hgv:languages>
  </xsl:variable>

  <!-- amper's and -->
  <xsl:variable name="amp">
    <xsl:text disable-output-escaping="yes">
      <![CDATA[&]]>
    </xsl:text>
  </xsl:variable>
  
  <!-- templates -->
  <xsl:template name="att-jmt">
    <xsl:param name="ATT"/>
    <xsl:param name="J"/>
    <xsl:param name="M"/>
    <xsl:param name="T"/>
    <xsl:param name="J2"/>
    <xsl:param name="M2"/>
    <xsl:param name="T2"/>

    <xsl:if test="matches($J, '^-?\d{4}$') or matches($J2, '^-?\d{4}$')">
      <xsl:attribute name="{$ATT}">
        
        <xsl:choose>
          <xsl:when test="string($J2)">
            <xsl:value-of select="$J2"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$J"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:if test="matches($M, '^\d{2}$') or matches($M2, '^\d{2}$')">
          <xsl:text>-</xsl:text>
          <xsl:choose>
            <xsl:when test="string($M2)">
              <xsl:value-of select="$M2"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$M"/>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:if test="matches($T, '^\d{2}$') or matches($T2, '^\d{2}$')">
            <xsl:text>-</xsl:text>
            <xsl:choose>
              <xsl:when test="string($T2)">
                <xsl:value-of select="$T2"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$T"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:if>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>



</xsl:stylesheet>
