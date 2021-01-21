<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  exclude-result-prefixes="#all" version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:hgv="HGV"
  xmlns:papy="Papyrillio"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:my="http://local"
  xmlns:fm="http://www.filemaker.com/fmpxmlresult" xmlns:date="http://exslt.org/dates-and-times"
  xmlns:common="http://exslt.org/common"
  xmlns="http://www.tei-c.org/ns/1.0">
  
  <!-- 

    TEST
    
    HGV_meta_EpiDoc/HGV10/9099.xml (STD)
    HGV_meta_EpiDoc/HGV21/20190.xml (UNBEKANNT)
    HGV_meta_EpiDoc/HGV42/41114.xml (BZW)
    HGV_meta_EpiDoc/HGV6/5832.xml (ODER - gleiche Region)
    HGV_meta_EpiDoc/HGV65/64449.xml (UNBEKANNT / BEI / CERT)
    HGV_meta_EpiDoc/HGV8/7322.xml (STD)
    HGV_meta_EpiDoc/HGV81/80407.xml (UNBEKANNT - spezial)
    HGV_meta_EpiDoc/HGV9/8898.xml (ODER - verschiedene Regionen)
    HGV_meta_EpiDoc/HGV1/734.xml (UNBEKANNT - (Gau unbekannt))
    
  -->

  <xsl:variable name="ancientRegions" as="element()">
    <hgv:ancientRegions>
      <hgv:ancientRegion key="Aegyptus" de="Ägypten" />
    </hgv:ancientRegions>
  </xsl:variable>

  <xsl:variable name="nome-doc">
    <xsl:sequence select="document($fileNomeList)"/>
  </xsl:variable>

  <xsl:variable name="place-refs">
    <xsl:sequence select="document($placeRef)/papy:data/papy:place"/>
  </xsl:variable>

  <xsl:function name="hgv:is-uncertain">
    <xsl:param name="who-me"/>
    <xsl:if test="contains($who-me, '?') or matches($who-me, ', .+$')">
      <xsl:value-of select="true()" />
    </xsl:if>
  </xsl:function>
  
  <xsl:function name="hgv:sanitize">
    <xsl:param name="poo"/>
    <xsl:value-of select="normalize-space(replace(replace($poo, '(\(\?\)|\?|, $)', ''), ' ,', ','))" />
  </xsl:function>
  
  <xsl:function name="hgv:is-nome">
    <xsl:param name="test"/>
    <xsl:if test="$nome-doc//name = hgv:sanitize(hgv:get-head($test))">
      <xsl:value-of select="true()" />
    </xsl:if>
  </xsl:function>

  <xsl:function name="hgv:get-head">
    <xsl:param name="list"/>
    <xsl:choose>
      <xsl:when test="contains($list, ',')">
          <xsl:value-of select="normalize-space(substring-before($list, ','))" />
      </xsl:when>
      <xsl:otherwise>
          <xsl:value-of select="normalize-space($list)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template name="provenance">
    <xsl:param name="raw" select="'unbekannt'" />

    <xsl:if test="$raw != 'unbekannt'">
      
      <xsl:variable name="findspotUnknown" as="xs:boolean">
        <xsl:choose>
          <xsl:when test="starts-with($raw, 'unbekannt ') or contains($raw, ' (Gau unbekannt)')">
            <xsl:value-of select="true()" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="false()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="special" select="replace($raw, '^Theben \?\)$', 'Theben (?)')" />
      <xsl:variable name="special" select="replace($special, '^(Maoza\??).+$', '$1 (Arabia)')" />
      <xsl:variable name="special" select="replace($special, '^Theben \[Thmon\( \) \?\]$', 'Thmon() (?) (Theben)')" />
      <xsl:variable name="special" select="replace($special, '^Hermopolites \(wohl Hermopolis\)$', 'Hermopolis (?) (Hermopolites)')" />
      <xsl:variable name="special" select="replace($special, '^unbekannt \(Meameris bei Naukratis\?\)$', 'Meameris (?) (bei Naukratis)')" />
      <xsl:variable name="special" select="replace($special, '^bei (.+)', '(bei $1)')" />
      <xsl:variable name="special" select="replace($special, ' bei ([^S].+)', '(bei $1)')" />
      <xsl:variable name="special" select="replace($special, '(; Fundort: Arsinoites)', '')" />
      <xsl:variable name="special" select="replace($special, '\)\)', ')')" />

      <xsl:variable name="Ort" select="replace(replace(replace(translate(translate($special, '}', ')'), '`', ''), 'unbekannt \(wohl ([^\(\)]+)\)', '$1 (?)'), ' /', ','), '\?\?\?', '?')" />
      
      <provenance type="located">
        <xsl:choose>
          <xsl:when test="contains($Ort, ' oder ') and not(contains($Ort, ' oder Umgebung '))">
            <xsl:variable name="split" select="tokenize(replace($Ort, ' oder ', ', '), ',')"/>
            <xsl:for-each select="$split">
              <xsl:variable name="number" select="position()"/>
              <p> <!-- alternatives for location ad @xml:id and @exclude -->
                <xsl:attribute name="xml:id" select="concat('geog_', position())"/>
                <xsl:variable name="exclude">
                  <xsl:for-each select="1 to count($split)">
                    <xsl:if test=". != $number">
                      <xsl:value-of select="concat('#geog_', ., ' ')" />
                    </xsl:if>
                  </xsl:for-each>
                </xsl:variable>
                <xsl:attribute name="exclude" select="normalize-space($exclude)" />
                <xsl:call-template name="place">
                  <xsl:with-param name="Ort" select="normalize-space(.)" />
                </xsl:call-template>
              </p>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <p><!-- only one location -->
              <xsl:call-template name="place">
                <xsl:with-param name="Ort" select="$Ort" />
              </xsl:call-template>
            </p>
          </xsl:otherwise>
        </xsl:choose>
      </provenance>
      
      <xsl:if test="$findspotUnknown">
        <provenance type="found">
          <p>
            <placeName>unbekannt</placeName>
          </p>
        </provenance>
      </xsl:if>

    </xsl:if>
  </xsl:template>
  
  <xsl:template name="place">
    <xsl:param name="Ort" />
      <xsl:variable name="nome">
        <xsl:if test="not(matches($Ort, '(Theben| bzw\. )'))">
          <xsl:choose>
            <xsl:when test="matches($Ort, '\((wohl |bzw\. )?([^\(\)\?=][^\(\)\?]+)+(\??)\)')">
              <xsl:analyze-string select="$Ort" regex="\((wohl |bzw\. )?([^\(\)\?=][^\(\)\?]+)+(\??)\)">
                <xsl:matching-substring>  
                  <xsl:if test="hgv:is-nome(regex-group(2)) = true()">
                    <xsl:value-of select="normalize-space(regex-group(2))"/>
                    <xsl:value-of select="normalize-space(regex-group(3))"/>
                    <xsl:value-of select="', '"/>
                  </xsl:if>
                </xsl:matching-substring>
              </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="hgv:is-nome($Ort) = true()">
              <xsl:value-of select="$Ort" />
            </xsl:when>
          </xsl:choose>
        </xsl:if>
      </xsl:variable>

      <xsl:variable name="ancientRegion">
          <xsl:choose>
            <xsl:when test="contains($Ort, 'Theben')">
              <xsl:text>Ägypten</xsl:text>
            </xsl:when>
            <xsl:when test="not(matches($Ort, '(\(bei | bzw\. )'))">
              <xsl:analyze-string select="$Ort" regex="\((wohl |bzw\. )?([^\(\)\?=][^\(\)\?]+)+(\??)\)">
                <xsl:matching-substring>
                  <xsl:if test="not(hgv:is-nome(regex-group(2)) = true())">
                    <xsl:value-of select="normalize-space(regex-group(2))"/>
                    <xsl:value-of select="normalize-space(regex-group(3))"/>
                    <xsl:value-of select="', '"/>
                  </xsl:if>
                </xsl:matching-substring>
              </xsl:analyze-string>
            </xsl:when>
          </xsl:choose>
      </xsl:variable>

      <xsl:variable name="ancientFindspot">
        <xsl:choose>
          <xsl:when test="matches($Ort, '(Theben| bzw\. )')">
            <xsl:value-of select="normalize-space($Ort)"/>
          </xsl:when>
          <xsl:when test="contains($Ort, '(bei ')">
            <xsl:value-of select="substring-before(substring-after($Ort, '(bei '), ')')" />
          </xsl:when>
          <xsl:when test="not(starts-with($Ort, 'unbekannt '))">
            <xsl:variable name="plain" select="replace($Ort, '\([^\(\)\?=][^\(\)\?]+[^\(\)]*\)', '')" />
            <xsl:if test="not(hgv:is-nome($plain) = true())">
              <xsl:value-of select="normalize-space($plain)"/>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="nomeAlternative">
         <xsl:if test="not(matches($Ort, '(Theben| bzw\. )'))">
           <xsl:analyze-string select="$Ort" regex="\(=([^\(\)]+)\)">
              <xsl:matching-substring>
                <xsl:if test="hgv:is-nome(regex-group(1)) = true()">
                  <xsl:value-of select="normalize-space(regex-group(1))"/>
                </xsl:if>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:if>
      </xsl:variable>
      
      <xsl:variable name="modernFindspot">
         <xsl:if test="not(matches($Ort, '(Theben| bzw\. )'))">
           <xsl:if test="contains($Ort, '(bei ')">
             <xsl:value-of select="substring-before($Ort, '(bei ')" />
           </xsl:if>
         </xsl:if>
      </xsl:variable>
      
      <xsl:variable name="ancientFindspotOffset">
        <xsl:if test="not(matches($Ort, '(Theben| bzw\. )'))">
          <xsl:if test="contains($Ort, '(bei ')">bei</xsl:if>
        </xsl:if>
      </xsl:variable>

<!--nome><xsl:value-of select="$nome"/></nome>
<ancientRegion><xsl:value-of select="$ancientRegion"/></ancientRegion>
<ancientFindspot><xsl:value-of select="$ancientFindspot"/></ancientFindspot>
<modernFindspot><xsl:value-of select="$modernFindspot"/></modernFindspot-->

      <xsl:if test="string($ancientFindspot)">
        <xsl:if test="string($ancientFindspotOffset)">
          <offset>bei</offset>
        </xsl:if>
        <placeName type="ancient">
          <xsl:if test="hgv:is-uncertain($ancientFindspot)">
            <xsl:attribute name="cert">low</xsl:attribute>
          </xsl:if>
          <xsl:variable name="place" select="hgv:sanitize($ancientFindspot)" />
          <xsl:call-template name="ref"><xsl:with-param name="place" select="$place" /></xsl:call-template>
          <xsl:value-of select="$place"/>
        </placeName>
      </xsl:if>

      <xsl:if test="string($modernFindspot)">
        <placeName type="modern">
          <xsl:if test="hgv:is-uncertain($modernFindspot)">
            <xsl:attribute name="cert">low</xsl:attribute>
          </xsl:if>
          <xsl:variable name="place" select="hgv:sanitize($modernFindspot)" />
          <xsl:call-template name="ref"><xsl:with-param name="place" select="$place" /></xsl:call-template>
          <xsl:value-of select="$place"/>
        </placeName>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="string($nome)">
          <placeName type="ancient" subtype="nome">
            <xsl:if test="hgv:is-uncertain($nome) = true()">
              <xsl:attribute name="cert">low</xsl:attribute>
            </xsl:if>
            <xsl:variable name="place">
              <xsl:value-of select="hgv:sanitize($nome)" />
              <xsl:if test="string($nomeAlternative)">
                <xsl:value-of select="' (= '" />
                <xsl:value-of select="$ancientRegion" />
                <xsl:value-of select="')'" />
              </xsl:if>
            </xsl:variable>
            <xsl:call-template name="ref"><xsl:with-param name="place" select="$place" /></xsl:call-template>
            <xsl:value-of select="$place"/>
          </placeName>
          <placeName type="ancient" subtype="region">
            <xsl:call-template name="ref"><xsl:with-param name="place" select="'Ägypten'" /></xsl:call-template>
            <xsl:text>Ägypten</xsl:text>
          </placeName>
        </xsl:when>
        <xsl:when test="string($ancientRegion)">
          <placeName type="ancient" subtype="region">
            <xsl:if test="hgv:is-uncertain($ancientRegion)">
              <xsl:attribute name="cert">low</xsl:attribute>
            </xsl:if>
            <xsl:if test="$ancientRegions/hgv:ancientRegion[@de=$ancientRegion]">
              <xsl:attribute name="key"><xsl:value-of select="$ancientRegions/hgv:ancientRegion[@de=$ancientRegion]/@key" /></xsl:attribute>
            </xsl:if>
            <xsl:variable name="place" select="hgv:sanitize($ancientRegion)" />
            <xsl:call-template name="ref"><xsl:with-param name="place" select="$place" /></xsl:call-template>
            <xsl:value-of select="$place"/>
          </placeName>
        </xsl:when>
      </xsl:choose>

  </xsl:template>
  
  <xsl:template name="ref">
    <xsl:param name="place" />
    <xsl:variable name="ref" select="string($place-refs//papy:place[text()=$place][@ref][1]/@ref)" />
    <xsl:if test="$ref">
      <xsl:attribute name="ref"><xsl:value-of select="$ref"/></xsl:attribute>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>