<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  exclude-result-prefixes="#all" version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:hgv="HGV"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:my="http://local"
  xmlns:fm="http://www.filemaker.com/fmpxmlresult" xmlns:date="http://exslt.org/dates-and-times"
  xmlns:common="http://exslt.org/common"
  xmlns="http://www.tei-c.org/ns/1.0">


  <xsl:template name="publication">

    <xsl:param  name="Publikation" /> <!-- title level s: *BGU* 1 2 -->
    <xsl:param  name="Band" />        <!-- volume: BGU *1* 2 -->
    <xsl:param  name="ZusBand" />     <!-- fascicle: A, B, C, .1, .2, ... -->
    <xsl:param  name="Nummer" />      <!-- numbers: BGU 1 *2* -->
    <xsl:param  name="Seite" />       <!-- side: R, V, *R, *V, Verso, Außen-, Innen-, Fleisch-, Haarseite -->
    <xsl:param  name="zusatzlich" />  <!-- pages, parts, lines(, columns) -->

    <bibl type="publication" subtype="principal">
      <title level="s" type="abbreviated">
        <xsl:value-of select="$Publikation"/>
      </title>
      <xsl:if test="string($Band)">
        <biblScope type="volume">
          <xsl:value-of select="$Band"/>
        </biblScope>
      </xsl:if>
      <xsl:if test="string($ZusBand)">
        <biblScope type="fascicle">
          <xsl:value-of select="$ZusBand"/>
        </biblScope>
      </xsl:if>
      <xsl:if test="string($Nummer)">
        <biblScope type="numbers">
          <xsl:value-of select="$Nummer"/>
        </biblScope>
      </xsl:if>
      <xsl:if test="string($Seite)">
        <biblScope type="side">
          <xsl:value-of select="$Seite"/>
        </biblScope>
      </xsl:if>
      
      <xsl:if test="string($zusatzlich)">
        <!--xsl:for-each select="tokenize(translate($zusatzlich, '()', ','), ',')"-->
        
        
        <xsl:for-each select="tokenize(replace($zusatzlich, '\(', ',('), ',')">
          <xsl:variable name="cur-token" select="normalize-space(.)"/>
          <xsl:if test="string($cur-token)">
            <xsl:element name="biblScope">
              
              <!-- @type -->
              <xsl:choose>
                <xsl:when test="starts-with($cur-token, 'Z.') or starts-with($cur-token, '(Z.')">
                  <xsl:attribute name="type">lines</xsl:attribute>
                </xsl:when>
                <xsl:when test="starts-with($cur-token, 'S.') or starts-with($cur-token, '(S.')">
                  <xsl:attribute name="type">pages</xsl:attribute>
                </xsl:when>
                <xsl:when test="starts-with($cur-token, 'Fragment') or starts-with($cur-token, 'Fr.')">
                  <xsl:attribute name="type">fragments</xsl:attribute>
                </xsl:when>
                <xsl:when test="starts-with($cur-token, 'Fol.')">
                  <xsl:attribute name="type">folio</xsl:attribute>
                </xsl:when>
                <xsl:when test="matches($cur-token, '^[iI]nv\.')">
                  <xsl:attribute name="type">inventory</xsl:attribute>
                </xsl:when>
                <xsl:when test="starts-with($cur-token, 'Nr.')">
                  <xsl:attribute name="type">number</xsl:attribute>
                </xsl:when>
                <xsl:when test="starts-with($cur-token, 'Kol.')">
                  <xsl:attribute name="type">columns</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="type">generic</xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
              
              <!-- value -->
              <xsl:value-of select="$cur-token"/>

            </xsl:element>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </bibl>

  </xsl:template>

</xsl:stylesheet>