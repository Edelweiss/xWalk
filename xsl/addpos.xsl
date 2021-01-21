<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fm="http://www.filemaker.com/fmpxmlresult" 
  version="1.0" exclude-result-prefixes="fm">
  
  <xsl:output method="xml" />
  
  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="fm:FIELD">
    <xsl:copy>
      <xsl:attribute name="pos">
        <xsl:number count="fm:FIELD" from="fm:METADATA"/>
      </xsl:attribute>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template match="fm:COL">
    <xsl:copy>
      <xsl:attribute name="pos">
        <xsl:number count="fm:COL" from="fm:ROW"/>
      </xsl:attribute>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
