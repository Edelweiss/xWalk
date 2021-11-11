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
  <xsl:include href="geo.xsl"/>
  <xsl:include href="origDate.xsl"/>
  <xsl:include href="global.xsl"/>
  
  <xsl:template name="papy:hgvEpidoc">
    <xsl:param name="hgv"/>
    <xsl:param name="data"/>
    <xsl:param name="originalRevisionDesc"/>
    <!--xsl:processing-instruction name="oxygen ">
          RNGSchema="http://www.stoa.org/epidoc/schema/latest/tei-epidoc.rng" type="xml" </xsl:processing-instruction-->
    <xsl:processing-instruction name="xml-model ">
           href="http://www.stoa.org/epidoc/schema/8.13/tei-epidoc.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0" </xsl:processing-instruction>
    <TEI xml:id="hgv{$hgv}">
      <teiHeader>
        <fileDesc>
          <titleStmt>
            <title>
              <xsl:value-of select="$data[1]//tei:cell[@name='original_title']"/>
            </title>
          </titleStmt>
          <publicationStmt>
            <idno type="filename">
              <xsl:value-of select="$hgv"/>
            </idno>
            <idno type="TM">
              <xsl:value-of select="replace($hgv, '[^\d]+', '')"/>
            </idno>
            <idno type="ddb-filename">
              <xsl:value-of select="$data[1]//tei:cell[@name='ddb_ser_idp']"/>
              <xsl:text>.</xsl:text>
              <xsl:if test="string($data[1]//tei:cell[@name='ddb_vol'])">
                <xsl:value-of select="$data[1]//tei:cell[@name='ddb_vol']"/>
                <xsl:text>.</xsl:text>
              </xsl:if>
              <xsl:value-of select="$data[1]//tei:cell[@name='ddb_doc']"/>
            </idno>
            <idno type="ddb-hybrid">
              <xsl:value-of select="$data[1]//tei:cell[@name='ddb_ser_idp']"/>
              <xsl:text>;</xsl:text>
              <xsl:value-of select="$data[1]//tei:cell[@name='ddb_vol']"/>
              <xsl:text>;</xsl:text>
              <xsl:value-of select="$data[1]//tei:cell[@name='ddb_doc']"/>
            </idno>
          </publicationStmt>
          <sourceDesc>
            <msDesc>
              <msIdentifier>
                <xsl:choose>
                  <xsl:when test="string($data[1]//tei:cell[@name='place']) or string($data[1]//tei:cell[@name='collection']) or string($data[1]//tei:cell[@name='inv_no'])">
                    <xsl:if test="string($data[1]//tei:cell[@name='place'])">
                      <placeName>
                        <settlement><xsl:value-of select="$data[1]//tei:cell[@name='place']"/></settlement>
                      </placeName>
                    </xsl:if>
                    <xsl:if test="string($data[1]//tei:cell[@name='collection'])">
                      <collection><xsl:value-of select="$data[1]//tei:cell[@name='collection']"/></collection>
                    </xsl:if>
                    <xsl:if test="string($data[1]//tei:cell[@name='inv_no'])">
                      <idno type="invNo"><xsl:value-of select="$data[1]//tei:cell[@name='inv_no']"/></idno>
                    </xsl:if>
                  </xsl:when>
                  <xsl:otherwise>
                    <placeName><settlement><xsl:text>unbekannt</xsl:text></settlement></placeName>                    
                  </xsl:otherwise>
                </xsl:choose>
              </msIdentifier>
              <physDesc>
                <objectDesc>
                  <supportDesc>
                    <support>
                      <material>
                        <xsl:value-of select="$data[1]//tei:cell[@name='material']"/>
                      </material>
                    </support>
                  </supportDesc>
                </objectDesc>
              </physDesc>
              <history>
                <origin>
                  <xsl:call-template name="papy:origPlace">
                    <xsl:with-param name="provenanceType" select="$data[1]//tei:cell[@name='provenance_type']"/>
                    <xsl:with-param name="placeName" select="$data[1]//tei:cell[@name='place_name']"/>
                    <xsl:with-param name="nome" select="$data[1]//tei:cell[@name='nome']"/>
                    <xsl:with-param name="province" select="$data[1]//tei:cell[@name='province']"/>
                    <xsl:with-param name="region" select="$data[1]//tei:cell[@name='region']"/>
                  </xsl:call-template>
                  <xsl:for-each select="$data">
                    <xsl:variable name="record" select="."/>
                    <!--xsl:call-template name="date-tests"/--> <!-- cl: Datum XYZ -->
                    <xsl:call-template name="full-date">
                      <xsl:with-param name="J">
                        <xsl:call-template name="J-test">
                          <xsl:with-param name="J-val" select="$record//tei:cell[@name='year_1']"/>
                        </xsl:call-template>
                      </xsl:with-param>
                      <xsl:with-param name="M">
                        <xsl:call-template name="MT-test">
                          <xsl:with-param name="MT-val" select="$record//tei:cell[@name='month_1']"/>
                        </xsl:call-template>
                      </xsl:with-param>
                      <xsl:with-param name="T">
                        <xsl:call-template name="MT-test">
                          <xsl:with-param name="MT-val" select="$record//tei:cell[@name='day_1']"/>
                        </xsl:call-template>
                      </xsl:with-param>
                      <xsl:with-param name="J2">
                        <xsl:call-template name="J-test">
                          <xsl:with-param name="J-val" select="$record//tei:cell[@name='year_2']"/>
                        </xsl:call-template>
                      </xsl:with-param>
                      <xsl:with-param name="M2">
                        <xsl:call-template name="MT-test">
                          <xsl:with-param name="MT-val" select="$record//tei:cell[@name='month_1']"/>
                        </xsl:call-template>
                      </xsl:with-param>
                      <xsl:with-param name="T2">
                        <xsl:call-template name="MT-test">
                          <xsl:with-param name="MT-val" select="$record//tei:cell[@name='day_1']"/>
                        </xsl:call-template>
                      </xsl:with-param>
                      <xsl:with-param name="Erg" select="$record//tei:cell[@name='extra_1']"/>
                      <xsl:with-param name="Erg2" select="$record//tei:cell[@name='extra_2']"/>
                      <xsl:with-param name="Jh" select="$record//tei:cell[@name='century_1']"/>
                      <xsl:with-param name="Jh2" select="$record//tei:cell[@name='century_2']"/>
                      <xsl:with-param name="ChronMaximum">
                        <xsl:variable name="maxTemp" select="$record//tei:cell[@name='chron_maximum']"/>
                        <xsl:if test="string(papy:norm-num($maxTemp))">
                          <xsl:call-template name="J-test">
                            <xsl:with-param name="J-val" select="$maxTemp"/>
                          </xsl:call-template>
                        </xsl:if>
                      </xsl:with-param>
                      <xsl:with-param name="ChronMinimum">
                        <xsl:variable name="minTemp" select="$record//tei:cell[@name='chron_minimum']"/>
                        <xsl:if test="string(papy:norm-num($minTemp))">
                          <xsl:call-template name="J-test">
                            <xsl:with-param name="J-val" select="$minTemp"/>
                          </xsl:call-template>
                        </xsl:if>
                      </xsl:with-param>
                      <xsl:with-param name="date-print" select="$record//tei:cell[@name='date_1']"/>
                      <xsl:with-param name="unsicher" select="$record//tei:cell[@name='uncertain']"/>
                      <xsl:with-param name="context" select="'origin'"/>
                      <xsl:with-param name="date-id" select="$record//tei:cell[@name='multiple_letter']"/>
                      
                    </xsl:call-template>
                  </xsl:for-each>
                </origin>
                <!--xsl:call-template name="provenance">
              <xsl:with-param name="raw" select="$data[1]//tei:cell[@name='provenance']"/>
            </xsl:call-template--> <!-- cl: Ort -->
              </history>
            </msDesc>
          </sourceDesc>
        </fileDesc>
        <encodingDesc>
          <p>This file encoded to comply with EpiDoc Guidelines and Schema version 8 <ref>http://www.stoa.org/epidoc/gl/5/</ref></p>
        </encodingDesc>
        <profileDesc>
          <langUsage>
            <language ident="fr">Französisch</language>
            <language ident="en">Englisch</language>
            <language ident="de">Deutsch</language>
            <language ident="it">Italienisch</language>
            <language ident="es">Spanisch</language>
            <language ident="la">Latein</language>
            <language ident="el">Griechisch</language>
          </langUsage>
          <xsl:variable name="content" select="$data[1]//tei:cell[@name='content']"/>
          <xsl:if test="string($content)">
            <textClass>
              <keywords scheme="hgv">
                <xsl:for-each select="tokenize($content, ', ?')">
                  <term><xsl:value-of select="normalize-space(.)"/></term>
                </xsl:for-each>
              </keywords>
            </textClass>
          </xsl:if>
        </profileDesc>
        <revisionDesc>
          <xsl:choose>
            <xsl:when test="$originalRevisionDesc">
              <xsl:copy-of select="$originalRevisionDesc/tei:change"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="papy:changeLog">
                <xsl:with-param name="date" select="$data[1]//tei:cell[@name='created']"/>
                <xsl:with-param name="log" select="'Record created'"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:call-template name="papy:changeLog">
            <xsl:with-param name="date" select="format-date(current-date(), '[D01].[M01].[Y0001]')"/>
            <xsl:with-param name="log" select="'Xwalked to EpiDoc XML'"/>
          </xsl:call-template>
        </revisionDesc>
      </teiHeader>
      <text>
        <body>
          <xsl:variable name="notes" select="$data[1]//tei:cell[@name='notes']"/>
          <xsl:if test="string($notes)">
            <div type="commentary" subtype="general">
              <p>
                <xsl:value-of select="$notes"/>
              </p>
            </div>
          </xsl:if>
          <!--xsl:variable name="mentionedDates" select="$data[1]//tei:cell[@name='mentioned_dates']"/-->
        </body>
      </text>
    </TEI>
  </xsl:template>
  
  <xsl:template name="J-test">
    <xsl:param name="J-val"/>
    <xsl:if test="string(normalize-space($J-val))">
      <xsl:if test="starts-with(normalize-space($J-val), '-')">
        <xsl:text>-</xsl:text>
      </xsl:if>
      <xsl:value-of select="papy:format-num(papy:norm-num($J-val), '4')"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="MT-test">
    <xsl:param name="MT-val"/>
    <xsl:if test="string(normalize-space($MT-val))">
      <xsl:value-of select="papy:format-num(papy:norm-num($MT-val), '2')"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="att-nB-nA">
    <xsl:param name="chron-min"/>
    <xsl:param name="chron-max"/>
    
    <xsl:if test="matches($chron-min, '-?\d{4}(-\d{2}(-\d{2})?)?')">
      <xsl:attribute name="notBefore">
        <xsl:value-of select="$chron-min"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="matches($chron-max, '-?\d{4}(-\d{2}(-\d{2})?)?')">
      <xsl:attribute name="notAfter">
        <xsl:value-of select="$chron-max"/>
      </xsl:attribute>
    </xsl:if>
    
  </xsl:template>

  <xsl:template name="papy:changeLog">
    <xsl:param name="date"/>
    <xsl:param name="log"/>
    <xsl:if test="matches($date, '^\d{2}.\d{2}.\d{4}')">
      <change who="HGV">
        <xsl:attribute name="when">
          <xsl:value-of select="substring($date, 7 ,4)"/>
          <xsl:text>-</xsl:text>
          <xsl:value-of select="substring($date, 4, 2)"/>
          <xsl:text>-</xsl:text>
          <xsl:value-of select="substring($date, 1, 2)"/>
        </xsl:attribute>
        <xsl:value-of select="$log"/>
      </change>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>