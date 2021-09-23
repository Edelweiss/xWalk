<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: converter.xsl 3681 2012-01-02 14:14:59Z clanz $ -->
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:hgv="HGV"
  xmlns:papy="Papyrillio"
  xmlns:my="http://local"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fm="http://www.filemaker.com/fmpxmlresult"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0">

  <xsl:output indent="yes" method="xml" />
  <xsl:preserve-space elements="tei:placeName"/>

  <xsl:include href="global.xsl"/>
  <xsl:include href="mentionedDates.xsl"/>
  <xsl:include href="mentionedDatesFp7.xsl"/>
  <xsl:include href="origDate.xsl"/>
  <xsl:include href="origPlace.xsl"/>
  <xsl:include href="publication.xsl"/>

  <!-- Paths that may need changing -->

  <!-- Current doc -->
  <xsl:variable name="doc">
    <xsl:sequence select="/"/>
  </xsl:variable>

  <!-- HGV ids that already exist in idp.data -->
  <xsl:variable name="hgv-ids">
    <xsl:sequence select="document($hgvId)/hgv:data/hgv:id"/>
  </xsl:variable>

  <!-- Position of COL for TM_Nr and texLett -->
  <xsl:variable name="TM_Nr-pos" as="xs:integer">
    <xsl:value-of select="my:field-pos($doc, 'TM_Nr.')"/>
  </xsl:variable>

  <xsl:variable name="texLett-pos" as="xs:integer">
    <xsl:value-of select="my:field-pos($doc, 'texLett')"/>
  </xsl:variable>

  <!-- Template matching starts -->
  <!-- This is working on the smaller files that have been created by divide.xsl -->
  <xsl:template match="/">
    <xsl:variable name="cur-dir" select="//fm:FMPXMLRESULT/@n"/>

    <!-- A check list of duplicated records and their output directory-->
    <xsl:if test="$cur-dir = 'HGVdup'">
      <duplicates>
        <xsl:comment>File @id is the filemaker @RECORDID, @n is the TM number</xsl:comment>
        <xsl:for-each-group select="//fm:RESULTSET/fm:ROW"
          group-by="concat(fm:COL[$TM_Nr-pos]/fm:DATA[1], fm:COL[$texLett-pos]/fm:DATA[1])">
          <xsl:variable name="tm-id" select="normalize-space(fm:COL[$TM_Nr-pos]/fm:DATA[1])"/>
          <xsl:variable name="texLett-con" select="normalize-space(fm:COL[$texLett-pos]/fm:DATA[1])"/>

          <xsl:variable name="file-id">
            <xsl:value-of select="normalize-space(concat($tm-id, $texLett-con))"/>
          </xsl:variable>

          <!-- Ignores cases where there are no TM_Nr -->
          <xsl:if test="string($file-id)">
            <!-- Uses my:dir function above to calculate the output directory -->
            <xsl:variable name="out-dir">
              <xsl:value-of select="my:dir($cur-dir, number($tm-id))"/>
            </xsl:variable>

            <!-- Unique record and output directory -->
            <rec dir="{$out-dir}">
              <dups>
                <xsl:for-each select="current-group()">
                  <!-- Each record that has the same TM_Nr and texLett -->
                  <file n="{$tm-id}" id="{@RECORDID}"/>
                </xsl:for-each>
              </dups>
            </rec>
          </xsl:if>
        </xsl:for-each-group>
      </duplicates>
    </xsl:if>

    <!-- Outputs files of converted metadata -->
    <xsl:for-each-group select="//fm:RESULTSET/fm:ROW"
      group-by="concat(fm:COL[$TM_Nr-pos]/fm:DATA[1], fm:COL[$texLett-pos]/fm:DATA[1])">

      <xsl:variable name="tm-id" select="normalize-space(fm:COL[$TM_Nr-pos]/fm:DATA[1])"/>
      <xsl:variable name="texLett-con" select="normalize-space(fm:COL[$texLett-pos]/fm:DATA[1])"/>

      <xsl:variable name="file-id">
        <xsl:value-of select="normalize-space(concat($tm-id, $texLett-con))"/>
      </xsl:variable>

      <!-- Ignores cases where there are no TM_Nr -->
      <xsl:if test="string($file-id)">
        <!-- Uses my:dir function above to calculate the output directory -->
        <xsl:variable name="out-dir">
          <xsl:value-of select="my:dir($cur-dir, number($tm-id))"/>
        </xsl:variable>

        <xsl:call-template name="out-file">
          <xsl:with-param name="out-dir" select="$out-dir"/>
          <xsl:with-param name="file-id" select="$file-id"/>
          <xsl:with-param name="texId-con1" select="$tm-id"/>
          <xsl:with-param name="texLett-con" select="$texLett-con"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each-group>
  </xsl:template>

  <!-- Template that creates the final EpiDoc file content -->
  <xsl:template name="out-file">
    <xsl:param name="out-dir"/> <!-- e.g. »HGV10« or »HGV21« -->
    <xsl:param name="file-id"/> <!-- e.g. »9066a« or »20161« -->
    <xsl:param name="texId-con1"/> <!-- TM number, e.g. »9066« or »20161« -->
    <xsl:param name="texLett-con"/> <!-- text snippet, e.g. »a« or empty -->

    <xsl:message><xsl:value-of select="concat($outputPath, '/', $out-dir, '/', $file-id, '.xml')" /></xsl:message>

    <xsl:variable name="idAlreadyExists" select="$hgv-ids/hgv:id[text() = $file-id]/@file" />
    <xsl:variable name="originalRevisionDesc" select="if ($idAlreadyExists) then doc(concat($fileRepository, '/HGV_meta_EpiDoc/', $idAlreadyExists))//tei:revisionDesc else () " />

    <!--xsl:message><xsl:copy-of select="$idAlreadyExists" /></xsl:message>
    <xsl:message><xsl:copy-of select="$originalRevisionDesc" /></xsl:message-->

    <xsl:if test="($process = 'all') or ($process = 'new' and not($idAlreadyExists)) or ($process = 'modified' and $idAlreadyExists)">
      <xsl:message><xsl:value-of select="'TRANSFORM'" /></xsl:message>
      
      <xsl:message select="concat('–––––––– ', $outputPath, ' | ', $out-dir, ' | ', $file-id)"></xsl:message>

      <xsl:result-document href="{$outputPath}/{$out-dir}/{$file-id}.xml">
        <!--xsl:processing-instruction name="oxygen ">
          RNGSchema="http://www.stoa.org/epidoc/schema/latest/tei-epidoc.rng" type="xml" </xsl:processing-instruction-->
        <xsl:processing-instruction name="xml-model ">
           href="http://www.stoa.org/epidoc/schema/8.13/tei-epidoc.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0" </xsl:processing-instruction>
        <TEI xml:id="hgv{$file-id}">
          <!-- ddb number added to TEI/@n -->
          <!--<xsl:if test="string(normalize-space($new-n))">
            <xsl:attribute name="n" select="$new-n"/>
          </xsl:if>-->
          <teiHeader>
            <fileDesc>
              <titleStmt>
                <title>
                  <xsl:value-of select="fm:COL[my:field-pos($doc, 'Originaltitel')]/fm:DATA[1]"/>
                </title>
              </titleStmt>
              <publicationStmt>
                <idno type="filename">
                  <xsl:value-of select="$file-id"/>
                </idno>
                <!-- Current context is for-each-group of ROW by TM_Nr and texLett line 233 -->
                <xsl:for-each select="fm:COL[$TM_Nr-pos]/fm:DATA[string(.)]"><!-- cl? are there sometimes more than one fm:DATA tag for TM number? what's the meaning of this string(.)-construct -->
                  <xsl:choose>
                    <xsl:when test=". != translate($file-id,'abcdefghijklmnopqrstuvwxyz','')">
                      <idno type="TM-deprecated"><!-- cl? what are deprectated TM and HGV numbers -->
                        <xsl:value-of select="."/>
                      </idno>
                      <idno type="HGV-deprecated">
                        <xsl:value-of select="."/>
                        <xsl:if test="string($texLett-con)">
                          <xsl:value-of select="$texLett-con"/>
                        </xsl:if>
                      </idno>
                    </xsl:when>
                    <xsl:otherwise>
                      <idno type="TM">
                        <xsl:value-of select="."/>
                      </idno>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
                <xsl:variable name="ddbVol" select="fm:COL[my:field-pos($doc, 'ddbVol')]/fm:DATA"/>
                <idno type="ddb-filename">
                  <xsl:value-of select="fm:COL[my:field-pos($doc, 'ddbSerIDP')]/fm:DATA"/>
                  <xsl:text>.</xsl:text>
                  <xsl:if test="string(normalize-space($ddbVol))">
                    <xsl:value-of select="$ddbVol"/>
  
                    <xsl:text>.</xsl:text>
                  </xsl:if>
                  <xsl:value-of select="fm:COL[my:field-pos($doc, 'ddbDoc')]/fm:DATA"/>
                </idno>
                <idno type="ddb-hybrid">
                  <xsl:value-of select="fm:COL[my:field-pos($doc, 'ddbSerIDP')]/fm:DATA"/>
                  <xsl:text>;</xsl:text>
                  <xsl:if test="string(normalize-space($ddbVol))">
                    <xsl:value-of select="$ddbVol"/>
                  </xsl:if>
                  <xsl:text>;</xsl:text>
                  <xsl:value-of select="fm:COL[my:field-pos($doc, 'ddbDoc')]/fm:DATA"/>
                </idno>
              </publicationStmt>
              <sourceDesc>
                <!--<p>The contents of this document are generated from an export of HGV using IDP
                  Crosswalk module.</p>-->
                <msDesc>
                  <xsl:variable name="InvNr" select="normalize-space(fm:COL[my:field-pos($doc, 'InvNr')]/fm:DATA)"/>
                  <msIdentifier>
                    <!--placeName>
                      <settlement>Qift</settlement>
                    </placeName>
                    <collection>Archaeological storeroom</collection>
                    <idno type="invNo"><xsl:value-of select="replace($InvNr, 'Qift, Archaeological storeroom ', '')"/></idno-->
                    <xsl:choose>
                      <xsl:when test="string($InvNr)">
                        <idno type="invNo"><xsl:value-of select="$InvNr"/></idno>
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
                            <xsl:value-of select="fm:COL[my:field-pos($doc, 'Material')]/fm:DATA"/>
                          </material>
                        </support>
                      </supportDesc>
                    </objectDesc>
                  </physDesc>
                  <history>
                    <origin>
                      <origPlace><xsl:value-of select="normalize-space(fm:COL[my:field-pos($doc, 'Ort')]/fm:DATA)"/></origPlace>
                      <!-- Current context is for-each-group of ROW by TM_Nr and texLett line 255 -->
                      <xsl:for-each select="current-group()">
                          <xsl:call-template name="date-tests"/>
                      </xsl:for-each>
                    </origin>
                    <!-- outsourced the processing of provenance data to file »origPlace.xsl« -->
                    <xsl:call-template name="provenance">
                      <xsl:with-param name="raw" select="normalize-space(fm:COL[my:field-pos($doc, 'Ort')]/fm:DATA)"/>
                    </xsl:call-template>
                  </history>
                </msDesc>
              </sourceDesc>
            </fileDesc>
            <encodingDesc>
              <p>This file encoded to comply with EpiDoc Guidelines and Schema version 8
                  <ref>http://www.stoa.org/epidoc/gl/5/</ref></p>
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
              <xsl:variable name="Inhalt-text" select="fm:COL[my:field-pos($doc, 'Inhalt')]/fm:DATA"/>
              <xsl:if test="string($Inhalt-text)">
                <textClass>
                  <keywords scheme="hgv">
                    <xsl:for-each select="tokenize($Inhalt-text, ', ')"><!-- BCD: \. ? -->
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
                  <xsl:variable name="date_of_creation" select="fm:COL[my:field-pos($doc, 'eingegeben am')]/fm:DATA"/>
                  <xsl:if test="matches($date_of_creation, '^\d{2}.\d{2}.\d{4}')">
                    <change who="HGV">
                      <xsl:attribute name="when">
                        <xsl:value-of select="substring($date_of_creation,7,4)"/>
                        <xsl:text>-</xsl:text>
                        <xsl:value-of select="substring($date_of_creation,4,2)"/>
                        <xsl:text>-</xsl:text>
                        <xsl:value-of select="substring($date_of_creation,1,2)"/>
                      </xsl:attribute>
                      <xsl:text>Record created</xsl:text>
                    </change>
                  </xsl:if>
                  <change who="HGV">
                    <xsl:attribute name="when">
                      <xsl:variable name="d"
                        select="fm:COL[my:field-pos($doc, 'zul. geändert am')]/fm:DATA"/>
                      <xsl:value-of select="substring($d,7,4)"/>
                      <xsl:text>-</xsl:text>
                      <xsl:value-of select="substring($d,4,2)"/>
                      <xsl:text>-</xsl:text>
                      <xsl:value-of select="substring($d,1,2)"/>
                    </xsl:attribute>
                    <xsl:text>Record last modified</xsl:text>
                  </change>
                </xsl:otherwise>
              </xsl:choose>
              <change when="{format-date(current-date(), '[Y0001]-[M01]-[D01]')}" who="IDP">
                <xsl:text>Crosswalked to EpiDoc XML</xsl:text>
              </change>
            </revisionDesc>
          </teiHeader>

          <text>
            <body>
              <xsl:variable name="Bemer" select="fm:COL[my:field-pos($doc, 'Bemerkungen')]/fm:DATA"/>
              <xsl:if test="string($Bemer)">
                <div type="commentary" subtype="general">
                  <p>
                    <xsl:value-of select="$Bemer"/>
                  </p>
                </div>
              </xsl:if>
  
              <xsl:variable name="ErwaenhteDaten" select="fm:COL[my:field-pos($doc, 'Erwähnte Daten')]/fm:DATA"/>
              <xsl:if
                test="string(normalize-space($ErwaenhteDaten)) or (my:compare-id($file-id) = 'true' and
                not(empty(my:md-cur-range($file-id)/hgv:item)))">
  
                <div type="commentary" subtype="mentionedDates">
                  <head>Erwähnte Daten</head>
                  
                  <!-- mentioned dates preserved in their purest form -->
                  <xsl:for-each select="current-group()"> <!-- retrieve mentioned dates from current record set (X, Y, Z) -->
                    <note type="original">
                      <xsl:if test="string(fm:COL[my:field-pos($doc, 'MehrfachKennung')]/fm:DATA)">
                        <xsl:attribute name="subtype">
                          <xsl:value-of select="fm:COL[my:field-pos($doc, 'MehrfachKennung')]/fm:DATA" />
                        </xsl:attribute> 
                      </xsl:if>
                      <xsl:value-of select="fm:COL[my:field-pos($doc, 'Erwähnte Daten')]/fm:DATA" />
                    </note>
                  </xsl:for-each> 
  
                  <xsl:choose>
                    <!-- Checks MentionedDates for information -->
                    <xsl:when test="my:compare-id($file-id) = 'true'">
                      <note type="source">MentionedDates.fp7</note>
                      <xsl:call-template name="md-date-tests"> <!-- retrieve mentioned dates from MentiondDates.xml -->
                        <xsl:with-param name="file-id" select="$file-id"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                      
                      <xsl:variable name="mentionedDatesXyz">
                        <xsl:for-each select="current-group()"> <!-- concat mentioned dates from current record set (X, Y, Z) -->
                          <xsl:value-of select="fm:COL[my:field-pos($doc, 'Erwähnte Daten')]/fm:DATA" />
                        </xsl:for-each>
                      </xsl:variable>
                      
                      <note type="source">HGV.fp7</note>
                      <xsl:if test="not(contains($mentionedDatesXyz, 'Regierungsjahr')) and not(contains($mentionedDatesXyz, 'Indiktion')) and not(contains($mentionedDatesXyz, 'Ind.'))">
                        <list>
                          <xsl:for-each select="current-group()"> <!-- retrieve mentioned dates from current record set (X, Y, Z) -->
                            <xsl:call-template name="parse-mentioned-dates">
                              <xsl:with-param name="mentioned-dates" select="fm:COL[my:field-pos($doc, 'Erwähnte Daten')]/fm:DATA" />
                              <xsl:with-param name="date-id" select="substring-after(fm:COL[my:field-pos($doc, 'TexIDLang')]/fm:DATA, ' ')" />
                            </xsl:call-template>
                          </xsl:for-each>
                        </list>
                      </xsl:if>
                    </xsl:otherwise>
                  </xsl:choose>
                </div>
              </xsl:if>

              <div type="bibliography" subtype="principalEdition">
                <listBibl>
                  <!-- call to publication template which resides in publication.xsl -->
                  <xsl:call-template name="publication">
                    <xsl:with-param  name="Publikation" select="fm:COL[my:field-pos($doc, 'Publikation')]/fm:DATA" />
                    <xsl:with-param  name="Band"        select="fm:COL[my:field-pos($doc, 'Band')]/fm:DATA" />
                    <xsl:with-param  name="ZusBand"     select="fm:COL[my:field-pos($doc, 'Zus.Band')]/fm:DATA" />
                    <xsl:with-param  name="Nummer"      select="fm:COL[my:field-pos($doc, 'Nummer')]/fm:DATA" />
                    <xsl:with-param  name="Seite"       select="fm:COL[my:field-pos($doc, 'Seite')]/fm:DATA" />
                    <xsl:with-param  name="zusatzlich"  select="fm:COL[my:field-pos($doc, 'zusätzlich')]/fm:DATA" />
                  </xsl:call-template>
                  
                  <!-- Current context is for-each-group of ROW by TM_Nr and texLett line 233 -->
                  <!-- MOVED to publicationStmt -->
                  <xsl:for-each select="fm:COL[$TM_Nr-pos]/fm:DATA[string(.)]">
                    <xsl:if test="../../fm:COL[my:field-pos($doc, 'DAHT')]/fm:DATA = 'ja'">
                      <bibl>
                        <title>DAHT</title>
                        <biblScope>
                          <xsl:value-of select="."/>
                        </biblScope>
                      </bibl>
                    </xsl:if>
                    <xsl:if test="../../fm:COL[my:field-pos($doc, 'LDAB')]/fm:DATA = 'ja'">
                      <bibl>
                        <title>LDAB</title>
                        <biblScope>
                          <xsl:value-of select="."/>
                        </biblScope>
                      </bibl>
                    </xsl:if>
  
                  </xsl:for-each>
                </listBibl>
              </div>
  
              <xsl:variable name="BL" select="fm:COL[my:field-pos($doc, 'BL')]/fm:DATA"/>
              <xsl:if test="string($BL)">
                <div type="bibliography" subtype="corrections">
                  <head>BL-Einträge nach BL-Konkordanz</head>
                  <xsl:call-template name="list-bibl">
                    <xsl:with-param name="bibl-raw" select="$BL"/>
                    <xsl:with-param name="type" select="'BL'"/>
                  </xsl:call-template>
                </div>
              </xsl:if>
  
              <div type="bibliography" subtype="illustrations">
                <p>
                  <xsl:variable name="Abbildung"
                    select="fm:COL[my:field-pos($doc,'Abbildung')]/fm:DATA"/>
                  <xsl:choose>
                    <xsl:when test="$Abbildung = 'keine'">
                      <xsl:text>keine</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:for-each select="tokenize($Abbildung, ';')">
                        <bibl type="illustration">
                          <xsl:value-of select="normalize-space(.)"/>
                        </bibl>
                      </xsl:for-each>
                    </xsl:otherwise>
                  </xsl:choose>
                </p>
              </div>
  
              <xsl:variable name="A-Publik"
                select="fm:COL[my:field-pos($doc, 'Andere Publikation')]/fm:DATA"/>
              <xsl:if test="string($A-Publik)">
                <div type="bibliography" subtype="otherPublications">
                  <head>
                    <xsl:text>Andere Publikation</xsl:text>
                    <xsl:if test="contains($A-Publik, ';')">
                      <xsl:text>en</xsl:text>
                    </xsl:if>
                  </head>
                  <xsl:call-template name="list-bibl">
                    <xsl:with-param name="bibl-raw" select="$A-Publik"/>
                    <xsl:with-param name="type" select="'A-Pub'"/>
                  </xsl:call-template>
                </div>
              </xsl:if>
  
              <xsl:variable name="Ubersetz"
                select="fm:COL[my:field-pos($doc, 'Uebersetzungen')]/fm:DATA"/>
              <xsl:if test="string($Ubersetz)">
                <div type="bibliography" subtype="translations">
                  <head xml:lang="de">Übersetzungen</head>
  
                  <!-- Divides the string at »:« (mask »in:« as »_IN_«) -->
                  <xsl:variable name="langs" select="tokenize(replace($Ubersetz, 'in:', '_IN_'), ':')"/>
  
                  <xsl:for-each select="$langs">
                    <xsl:if test="not(position() = 1)">
                      <xsl:variable name="pos" select="position() - 1"/>
                      <!-- language that is currently being processed -->
                      <xsl:variable name="lang-name">
                        <xsl:for-each select="tokenize($langs[$pos], ' ')">
                          <xsl:if test="position() = last()">
                            <xsl:value-of select="."/>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:variable>
                      <xsl:variable name="lang-type" select="$languages/hgv:language[@hgv:de=$lang-name]/@hgv:iso" />
  
                      <xsl:variable name="translations">
                        <xsl:choose>
                          <xsl:when test="position() = last()">
                            <xsl:value-of select="."/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="replace(., ' [A-Za-zÄÖÜäöüß]+$', '')"/>
                          </xsl:otherwise>
                          </xsl:choose>
                      </xsl:variable>
  
                      <listBibl>
                        <!-- Attributes xml:lang -->
                        <xsl:if test="$lang-type">
                          <xsl:attribute name="xml:lang">
                            <xsl:value-of select="$lang-type"/>
                          </xsl:attribute>
                        </xsl:if>
  
                        <!-- Heading of language -->
                        <xsl:call-template name="trans-bibl">
                          <xsl:with-param name="lang-name" select="$lang-name"/>
                        </xsl:call-template>
  
                        <!-- Bibliographic content -->
                        <xsl:for-each select="tokenize(normalize-space(replace($translations, '_IN_', 'in:')), ';')"><!-- unmask »_IN_« back to »in:« -->
                          <bibl type="translations">
                            <xsl:value-of select="normalize-space(.)"/>
                          </bibl>
                        </xsl:for-each>
  
                      </listBibl>
                    </xsl:if>
                  </xsl:for-each>
                </div>
              </xsl:if>
  
              <xsl:variable name="link-pos" select="my:field-pos($doc, 'Link1FM')"/>
              <xsl:if test="string(fm:COL[$link-pos]/fm:DATA[1])">
                <div type="figure">
                  <p>
                    <xsl:for-each select="fm:COL[$link-pos]/fm:DATA">
                      <xsl:if test="string(.)">
                        <figure>
                          <graphic url="{replace(replace(., $amp, '&amp;'), ' ', '%20')}"/>
                        </figure>
                      </xsl:if>
                    </xsl:for-each>
                  </p>
                </div>
              </xsl:if>
            </body>
          </text>
        </TEI>
      </xsl:result-document>
    </xsl:if>

  </xsl:template>

  <!-- Headings of the language -->
  <xsl:template name="trans-bibl">
    <xsl:param name="lang-name"/>

    <head xml:lang="de">
      <xsl:value-of select="$lang-name"/>
      <xsl:text>:</xsl:text>
    </head>
  </xsl:template>

  <xsl:template name="list-bibl">
    <xsl:param name="bibl-raw"/>
    <xsl:param name="type"/>

      <xsl:if test="string($bibl-raw)">
        <listBibl>
          <xsl:for-each select="tokenize($bibl-raw, ';')">
            <xsl:call-template name="bibl-test">
              <xsl:with-param name="cur-bibl" select="normalize-space(.)"/>
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
          </xsl:for-each>
        </listBibl>
       </xsl:if>

  </xsl:template>

  <xsl:template name="bibl-test">
    <xsl:param name="cur-bibl"/>
    <xsl:param name="type"/>
    <xsl:choose>
      <xsl:when test="$type = 'BL'">
        <bibl type="BL">
          <biblScope type="volume">
            <xsl:value-of select="substring-before($cur-bibl, ',')"/>
          </biblScope>
          <biblScope type="pages">
            <xsl:value-of select="substring-after($cur-bibl, 'S. ')"/>
          </biblScope>
        </bibl>
      </xsl:when>
      <xsl:when test="$type = 'A-Pub'">
        <bibl type="publication" subtype="other">
          <xsl:value-of select="$cur-bibl"/>
        </bibl>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Date creation templates -->

  <xsl:template name="date-tests">

    <xsl:call-template name="full-date">
      <xsl:with-param name="J">
        <xsl:call-template name="J-test">
          <xsl:with-param name="J-val" select="my:space-remove(fm:COL[my:field-pos($doc, 'J')]/fm:DATA)"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="M">
        <xsl:call-template name="MT-test">
          <xsl:with-param name="MT-val" select="my:space-remove(fm:COL[my:field-pos($doc, 'M')]/fm:DATA)"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="T">
        <xsl:call-template name="MT-test">
          <xsl:with-param name="MT-val" select="my:space-remove(fm:COL[my:field-pos($doc, 'T')]/fm:DATA)"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="J2">
        <xsl:call-template name="J-test">
          <xsl:with-param name="J-val" select="my:space-remove(fm:COL[my:field-pos($doc, 'J2')]/fm:DATA)"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="M2">
        <xsl:call-template name="MT-test">
          <xsl:with-param name="MT-val" select="my:space-remove(fm:COL[my:field-pos($doc, 'M2')]/fm:DATA)"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="T2">
        <xsl:call-template name="MT-test">
          <xsl:with-param name="MT-val" select="my:space-remove(fm:COL[my:field-pos($doc, 'T2')]/fm:DATA)"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="Erg" select="fm:COL[my:field-pos($doc, 'Erg')]/fm:DATA"/>
      <xsl:with-param name="Erg2" select="fm:COL[my:field-pos($doc, 'Erg2')]/fm:DATA"/>
      <xsl:with-param name="Jh" select="fm:COL[my:field-pos($doc, 'Jh')]/fm:DATA"/>
      <xsl:with-param name="Jh2" select="fm:COL[my:field-pos($doc, 'Jh2')]/fm:DATA"/>
      <xsl:with-param name="ChronMaximum">
        <xsl:variable name="maxTemp" select="my:space-remove(fm:COL[my:field-pos($doc, 'ChronMaximum')]/fm:DATA)"/>
        <xsl:if test="string(my:norm-num($maxTemp))">
          <xsl:call-template name="J-test">
            <xsl:with-param name="J-val" select="$maxTemp"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:with-param>
      <xsl:with-param name="ChronMinimum">
        <xsl:variable name="minTemp" select="my:space-remove(fm:COL[my:field-pos($doc, 'ChronMinimum')]/fm:DATA)"/>
        <xsl:if test="string(my:norm-num($minTemp))">
          <xsl:call-template name="J-test">
            <xsl:with-param name="J-val" select="$minTemp"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:with-param>
      <xsl:with-param name="date-print" select="fm:COL[my:field-pos($doc, 'Datierung')]/fm:DATA"/>
      <xsl:with-param name="unsicher" select="fm:COL[my:field-pos($doc, 'unsicher:')]/fm:DATA"/>
      <xsl:with-param name="context" select="'origin'"/>
      <xsl:with-param name="date-id" select="substring-after(fm:COL[my:field-pos($doc, 'TexIDLang')]/fm:DATA, ' ')"/>
      
      <!--xsl:with-param name="date-id" select="fm:COL[my:field-pos($doc, 'MehrfachKennung')]/fm:DATA"/-->
      
    </xsl:call-template>

  </xsl:template>

</xsl:stylesheet>
