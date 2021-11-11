<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:hgv="HGV"
  xmlns:papy="Papyrillio"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns:fm="http://www.filemaker.com/fmpxmlresult"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.xsltfunctions.com/"
  xmlns:functx="http://www.functx.com"
  xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
  xmlns="http://www.tei-c.org/ns/1.0">

  <xsl:output indent="yes" method="xml" />
  
  <xsl:template name="papy:origPlace">
    <xsl:param name="provenanceType"/>
    <xsl:param name="placeName"/>
    <xsl:param name="nome"/>
    <xsl:param name="province"/>
    <xsl:param name="region"/>
    <origPlace>
      <xsl:value-of select="$placeName"/>
      <xsl:if test="string($nome) or string($province) or (string($region) and $region != 'Egypt')">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="$nome"/>
        <xsl:if test="string($province)">
          <xsl:if test="string($nome)">
            <xsl:text>, </xsl:text>
          </xsl:if>
          <xsl:value-of select="$province"/>
        </xsl:if>
        <xsl:if test="string($region) and $region != 'Egypt'">
          <xsl:if test="string($nome) or string($province)">
            <xsl:text>, </xsl:text>
          </xsl:if>
          <xsl:value-of select="$region"/>
        </xsl:if>
        <xsl:text>)</xsl:text>
      </xsl:if>
    </origPlace>
  </xsl:template>

</xsl:stylesheet>
