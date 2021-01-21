<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id$ -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:my="http://local"
  xmlns:fm="http://www.filemaker.com/fmpxmlresult" xmlns:date="http://exslt.org/dates-and-times"
  exclude-result-prefixes="#all" version="2.0">

  <!-- parameters -->
  <xsl:param name="splitDirectory" select="'.'" as="xs:string"/> <!-- where the split files go -->

  <!-- Current doc -->
  <xsl:variable name="doc">
    <xsl:sequence select="/"/>
  </xsl:variable>

  <xsl:variable name="TM_Nr-pos" as="xs:integer">
    <xsl:value-of select="my:field-pos($doc, 'TM_Nr.')"/>
  </xsl:variable>

  <xsl:variable name="texLett-pos" as="xs:integer">
    <xsl:value-of select="my:field-pos($doc, 'texLett')"/>
  </xsl:variable>

  <xsl:variable name="dup-id" as="element()">
    <dup-id>
      <xsl:for-each-group select="//fm:FMPXMLRESULT/fm:RESULTSET/fm:ROW"
        group-by="concat(fm:COL[$TM_Nr-pos]/fm:DATA[1], fm:COL[$texLett-pos]/fm:DATA[1])">
        <xsl:if test="count(current-group()) > 1">
          <xsl:for-each select="current-group()">
            <item id="{@RECORDID}"/>
          </xsl:for-each>
        </xsl:if>
      </xsl:for-each-group>
    </dup-id>
  </xsl:variable>

  <!-- Gets the position of the field in the file to be used on the COL below -->
  <xsl:function name="my:field-pos" as="xs:integer">
    <xsl:param name="doc"/>
    <xsl:param name="field-name"/>

    <xsl:value-of
      select="count($doc/fm:FMPXMLRESULT/fm:METADATA/fm:FIELD
      [@NAME = $field-name]/preceding-sibling::fm:FIELD) + 1"
    />
  </xsl:function>

  <xsl:template match="/">
    <xsl:variable name="last-rec" as="xs:integer">
      <xsl:value-of
        select="ceiling(/fm:FMPXMLRESULT/fm:RESULTSET/fm:ROW[position() = last()]/@RECORDID div 1000)"
      />
    </xsl:variable>

    <!-- Single records -->
    <xsl:for-each select="1 to $last-rec">
      <xsl:variable name="cur-num" select="."/>
      <xsl:variable name="top-num" select="$cur-num * 1000"/>
      <xsl:variable name="low-num" select="$top-num - 999"/>

      <xsl:result-document href="{$splitDirectory}/HGV{$cur-num}.xml" method="xml">
        <FMPXMLRESULT xmlns="http://www.filemaker.com/fmpxmlresult" n="HGV{$cur-num}">
          <xsl:copy-of select="$doc/fm:FMPXMLRESULT/fm:METADATA"/>

          <RESULTSET>
            <xsl:for-each select="$doc/fm:FMPXMLRESULT/fm:RESULTSET/fm:ROW">
              <xsl:variable name="cur-r-id" select="@RECORDID"/>
              <xsl:if
                test="$cur-r-id >= $low-num and $top-num >= $cur-r-id and not($cur-r-id = $dup-id//item/@id)">
                <xsl:copy-of select="."/>
              </xsl:if>
            </xsl:for-each>
          </RESULTSET>
        </FMPXMLRESULT>
      </xsl:result-document>
    </xsl:for-each>

    <!-- Duplicate records -->
    <xsl:result-document href="{$splitDirectory}/HGVduplicates.xml">
      <FMPXMLRESULT xmlns="http://www.filemaker.com/fmpxmlresult" n="HGVdup">
        <xsl:copy-of select="//fm:FMPXMLRESULT/fm:METADATA"/>
        <RESULTSET>
          <xsl:for-each-group select="//fm:FMPXMLRESULT/fm:RESULTSET/fm:ROW"
            group-by="concat(fm:COL[$TM_Nr-pos]/fm:DATA[1], fm:COL[$texLett-pos]/fm:DATA[1])">

            <!--<xsl:result-document href="HGVduplicates{@RECORDID}.xml">
          <FMPXMLRESULT xmlns="http://www.filemaker.com/fmpxmlresult">
            <xsl:copy-of select="//fm:FMPXMLRESULT/fm:METADATA"/>
            <RESULTSET>-->
            <xsl:if test="count(current-group()) > 1">
              <xsl:for-each select="current-group()">
                <xsl:copy-of select="."/>
              </xsl:for-each>
            </xsl:if>
            <!--</RESULTSET>
          </FMPXMLRESULT>
        </xsl:result-document>-->
          </xsl:for-each-group>
        </RESULTSET>
      </FMPXMLRESULT>
    </xsl:result-document>
  </xsl:template>

</xsl:stylesheet>
