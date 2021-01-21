<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:hgv="HGV"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:my="http://local"
  xmlns:fm="http://www.filemaker.com/fmpxmlresult" xmlns:date="http://exslt.org/dates-and-times"
  xmlns:common="http://exslt.org/common"
  xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0">

<!-- 

templates
  md-date-tests(file-id)
  J-test(J-val)
  MT-test(MT-val)
  att-nB-nA(chronMin, chronMax)
  date-creation(J, J2, M, M2, T, T2, Jh, Erg, ChronMaximum, ChronMinimum, date-print)

functions
  my:compare-id (cur-id)
  my:md-cur-range (cur-id)

global variables 
  md-doc (idp.data/master/HGV_metadata/XML_dump/MentionedDates.xml)
  md-id (/hgv:md-ids/hgv:md-id)
  
needs global.xsl !!!

-->

  <!-- MentionedDates.xml path is relative to epiduke/code/ -->
  <xsl:variable name="md-doc">
    <xsl:sequence select="document($fileMentionedDates)"/>
  </xsl:variable>

  <!-- Creates a list of unique texId+texLett in mentionedDate.xml -->
  <xsl:variable name="md-id" as="element()">
    <!-- Value of TM_Nr -->
    <xsl:variable name="md-TM_Nr" as="xs:integer">
      <xsl:value-of select="my:field-pos($md-doc, 'texID')"/><!-- 1, 2, 3, ...322569 -->
    </xsl:variable>
    <!-- Value of texLett -->
    <xsl:variable name="md-texLett" as="xs:integer">
      <xsl:value-of select="my:field-pos($md-doc, 'texLett')"/><!-- a,b,c,...zzz -->
    </xsl:variable>

    <hgv:md-ids>
      <xsl:for-each-group select="$md-doc//fm:RESULTSET/fm:ROW"
        group-by="normalize-space(concat(normalize-space(fm:COL[$md-TM_Nr]/fm:DATA[1]), normalize-space(fm:COL[$md-texLett]/fm:DATA[1])))">

        <xsl:variable name="md-file-id">
          <xsl:value-of
            select="normalize-space(concat(normalize-space(fm:COL[$md-TM_Nr]/fm:DATA[1]), normalize-space(fm:COL[$md-texLett]/fm:DATA[1])))"
          />
        </xsl:variable>

        <hgv:md-id hgv:id="{$md-file-id}">
          <xsl:for-each select="current-group()">
            <xsl:value-of select="position()"/>
            <xsl:text>-</xsl:text>
          </xsl:for-each>
        </hgv:md-id>
      </xsl:for-each-group>
    </hgv:md-ids>
  </xsl:variable>

  <!-- Compares the two ids to see if it is in MentionedDates.xml -->
  <xsl:function name="my:compare-id">
    <xsl:param name="cur-id"/>
    <xsl:for-each select="$md-id/hgv:md-id[@hgv:id = $cur-id]">
      <xsl:text>true</xsl:text>
    </xsl:for-each>
  </xsl:function>

  <!-- Retrieves all zusätzlich and date for the current TM_Nr+texLett -->
  <xsl:function name="my:md-cur-range" as="element()">
    <xsl:param name="cur-id"/>
    <xsl:variable name="md-TM_Nr" as="xs:integer">
      <xsl:value-of select="my:field-pos($md-doc, 'texID')"/>
    </xsl:variable>
    <xsl:variable name="md-texLett" as="xs:integer">
      <xsl:value-of select="my:field-pos($md-doc, 'texLett')"/>
    </xsl:variable>
    <hgv:list>
      <xsl:for-each-group select="$md-doc//fm:RESULTSET/fm:ROW"
        group-by="normalize-space(concat(normalize-space(fm:COL[$md-TM_Nr]/fm:DATA[1]), normalize-space(fm:COL[$md-texLett]/fm:DATA[1])))">

        <xsl:variable name="md-file-id">
          <xsl:value-of
            select="normalize-space(concat(normalize-space(fm:COL[$md-TM_Nr]/fm:DATA[1]), normalize-space(fm:COL[$md-texLett]/fm:DATA[1])))"
          />
        </xsl:variable>

        <xsl:if test="$md-file-id = $cur-id">
          <xsl:for-each select="current-group()">
            <hgv:item>
              <hgv:datierung>
                <xsl:value-of select="fm:COL[my:field-pos($md-doc, 'Datierung')]/fm:DATA[1]"/>
              </hgv:datierung>
              <hgv:zusatzlich> <!-- used for Zeile -->
                <xsl:value-of select="fm:COL[my:field-pos($md-doc, 'zusätzlich')]/fm:DATA[1]"/>
              </hgv:zusatzlich>
              <hgv:J>
                <xsl:value-of
                  select="my:space-remove(fm:COL[my:field-pos($md-doc, 'J')]/fm:DATA[1])"/>
              </hgv:J>
              <hgv:J2>
                <xsl:value-of
                  select="my:space-remove(fm:COL[my:field-pos($md-doc, 'J2')]/fm:DATA[1])"/>
              </hgv:J2>
              <hgv:M>
                <xsl:value-of
                  select="my:space-remove(fm:COL[my:field-pos($md-doc, 'M')]/fm:DATA[1])"/>
              </hgv:M>
              <hgv:M2>
                <xsl:value-of
                  select="my:space-remove(fm:COL[my:field-pos($md-doc, 'M2')]/fm:DATA[1])"/>
              </hgv:M2>
              <hgv:T>
                <xsl:value-of
                  select="my:space-remove(fm:COL[my:field-pos($md-doc, 'T')]/fm:DATA[1])"/>
              </hgv:T>
              <hgv:T2>
                <xsl:value-of
                  select="my:space-remove(fm:COL[my:field-pos($md-doc, 'T2')]/fm:DATA[1])"/>
              </hgv:T2>
              <hgv:erg><!-- ca. (#4 data records) / vor (#5 data records) -->
                <xsl:value-of select="fm:COL[my:field-pos($md-doc, 'Erg')]/fm:DATA[1]"/>
              </hgv:erg>
              <hgv:MehrfachKennung>
                <xsl:value-of select="fm:COL[my:field-pos($md-doc, 'MehrfachKennung')]/fm:DATA[1]"/>
              </hgv:MehrfachKennung>
              <hgv:TexIDLang>
                <xsl:value-of select="fm:COL[my:field-pos($md-doc, 'TexIDlang')]/fm:DATA[1]"/>
              </hgv:TexIDLang>
              <hgv:ErwaehnteDaten>
                <xsl:value-of select="normalize-space(fm:COL[my:field-pos($md-doc, 'Erwähnte Daten')]/fm:DATA[1])"/>
              </hgv:ErwaehnteDaten>
              <hgv:unsicher>
                <xsl:value-of select="fm:COL[my:field-pos($md-doc, 'unsicher:')]/fm:DATA[1]"/>
              </hgv:unsicher>
            </hgv:item>
          </xsl:for-each>
        </xsl:if>
      </xsl:for-each-group>
    </hgv:list>
  </xsl:function>

  <xsl:template name="md-date-tests">
    <xsl:param name="file-id"/>
    
    
    <!-- Context of element generated in my:md-cur-range function above -->
    <list>
      <xsl:for-each select="my:md-cur-range($file-id)/hgv:item">
        <item>
          
          <!-- ref -->          
          <ref>
            <xsl:value-of select="hgv:zusatzlich"/>
          </ref>

          <!-- note #1 / comment -->
          <xsl:variable name="datierung-blank" select="normalize-space(replace(hgv:datierung, ' \([^\(\)]+\)', ''))" />
          <xsl:variable name="comment">
            <if test="contains(hgv:ErwaehnteDaten, concat(' ', $datierung-blank))">
              <xsl:value-of select="normalize-space(replace(substring-before(hgv:ErwaehnteDaten, $datierung-blank), '^.+[\.:;]([^:]+)$', '$1'))" />
            </if>
          </xsl:variable>

          <xsl:if test="string($comment) and matches($comment, '([a-z][a-z][a-z][a-z][a-z][a-z]|ca\.|Daten|nach|vor|wohl|AeDv|Ende|entweder|vom)')">
            <xsl:if test="not(matches($comment, '(Jan\.|Febr\.|März|Apr\.|Mai|Juni|Juli|Aug\.|Sept\.|Okt\.|Nov\.|Dez\.)'))">
              <note type="comment"><xsl:value-of select="$comment" /></note>
            </xsl:if>
          </xsl:if>

          <!-- date -->
          <xsl:call-template name="date-creation">
            <xsl:with-param name="J">
              <xsl:call-template name="J-test">
                <xsl:with-param name="J-val" select="hgv:J"/>
              </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="M">
              <xsl:call-template name="MT-test">
                <xsl:with-param name="MT-val" select="hgv:M"/>
              </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="T">
              <xsl:call-template name="MT-test">
                <xsl:with-param name="MT-val" select="hgv:T"/>
              </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="J2">
              <xsl:call-template name="J-test">
                <xsl:with-param name="J-val" select="hgv:J2"/>
              </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="M2">
              <xsl:call-template name="MT-test">
                <xsl:with-param name="MT-val" select="hgv:M2"/>
              </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="T2">
              <xsl:call-template name="MT-test">
                <xsl:with-param name="MT-val" select="hgv:T2"/>
              </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="Erg" select="hgv:erg"/>
            <xsl:with-param name="date-print" select="hgv:datierung"/>
            <xsl:with-param name="unsicher" select="hgv:unsicher"/>
          </xsl:call-template>
          
          <!-- note #2 / annotation -->

          <xsl:variable name="annotation">
            <xsl:variable name="annotation1" select="substring-after(normalize-space(hgv:ErwaehnteDaten), hgv:datierung)" />
            
            <xsl:variable name="annotation2">
              <xsl:if test="string($annotation1)">
                <xsl:choose>
                  <xsl:when test="contains($annotation1, ';')">
                    <xsl:value-of select="normalize-space(substring-before($annotation1, ';'))" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="normalize-space($annotation1)" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:if>
            </xsl:variable>
            
            <xsl:if test="string($annotation2)">
              <xsl:choose>
                <xsl:when test="starts-with($annotation2, '(vgl.')">
                  <xsl:value-of select="substring-before(substring-after($annotation2, '('), ')')" />
                </xsl:when>
                <xsl:when test="matches($annotation2, '(Bearbeitungsvermerk|Zeile unbekannt|vgl. BL I, S. 13|BL I, S. 81|Abschrift eines Dokuments, Teil|Vgl. ZPE 42, 1981|jedes Jahr einzeln|amtliche Anweisung|amtlicher Vermerk)')">
                  <xsl:value-of select="replace($annotation2, '^.+(Bearbeitungsvermerk|Zeile unbekannt|vgl. BL I, S. 13|BL I, S. 81|Abschrift eines Dokuments, Teil|Vgl. ZPE 42, 1981|jedes Jahr einzeln|amtliche Anweisung|amtlicher Vermerk|vgl. ZPE 17, 1975, S. 289).+$', '$1')" />
                </xsl:when>
              </xsl:choose>
            </xsl:if>

          </xsl:variable>

          <xsl:if test="string($annotation)">
            <note type="annotation"><xsl:value-of select="$annotation" /></note>
          </xsl:if>

        </item>
      </xsl:for-each>
    </list>
  </xsl:template>

  <xsl:template name="date-creation">
    <xsl:param name="J"/>
    <xsl:param name="J2"/>
    <xsl:param name="M"/>
    <xsl:param name="M2"/>
    <xsl:param name="T"/>
    <xsl:param name="T2"/>
    <xsl:param name="Jh"/>             <!-- century -->
    <xsl:param name="Erg"/>            <!-- degree of fuzzyness such as »ca.« -->
    <xsl:param name="ChronMaximum"/>   <!-- maximum year -->
    <xsl:param name="ChronMinimum"/>   <!-- minimum year -->
    <xsl:param name="date-print"/>     <!-- HGV format string -->
    <xsl:param name="unsicher"/>       <!-- uncertainty for year, month and day or global uncertainty -->

    <xsl:variable name="date-id" select="substring-after(hgv:TexIDLang, ' ')" /> <!-- »X«, »Y« or »Z« -->

    <date type="mentioned">

      <!--xsl:if test="contains($Erg, 'ca.')">
        <xsl:attribute name="precision">
          <xsl:text>low</xsl:text>
        </xsl:attribute>
      </xsl:if-->

      <!-- gloabl uncertainty -->
      
      <xsl:if test="contains($unsicher, '?')">
        <xsl:attribute name="cert">
          <xsl:text>low</xsl:text>
        </xsl:attribute>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="string($J2) or string($M2) or string($T2)">

          <xsl:call-template name="att-jmt">
            <xsl:with-param name="ATT" select="'notBefore'"/>
            <xsl:with-param name="J" select="$J"/>
            <xsl:with-param name="M" select="$M"/>
            <xsl:with-param name="T" select="$T"/>
          </xsl:call-template>

          <xsl:call-template name="att-jmt">
            <xsl:with-param name="ATT" select="'notAfter'"/>
            <xsl:with-param name="J" select="$J"/>
            <xsl:with-param name="M" select="$M"/>
            <xsl:with-param name="T" select="$T"/>
            <xsl:with-param name="J2" select="$J2"/>
            <xsl:with-param name="M2" select="$M2"/>
            <xsl:with-param name="T2" select="$T2"/>
          </xsl:call-template>

        </xsl:when>

        <xsl:when test="contains($Erg, 'nach')">
          <xsl:call-template name="att-jmt">
            <xsl:with-param name="ATT" select="'notBefore'"/>
            <xsl:with-param name="J">
              <xsl:choose>
                <xsl:when test="string($Jh)">
                  <xsl:value-of select="$ChronMaximum"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$J"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="M" select="$M"/>
            <xsl:with-param name="T" select="$T"/>
          </xsl:call-template>
        </xsl:when>

        <xsl:when test="contains($Erg, 'vor')">
          <xsl:call-template name="att-jmt">
            <xsl:with-param name="ATT" select="'notAfter'"/>
            <xsl:with-param name="J">
              <xsl:choose>
                <xsl:when test="string($Jh)">
                  <xsl:value-of select="$ChronMinimum"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$J"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="M" select="$M"/>
            <xsl:with-param name="T" select="$T"/>
          </xsl:call-template>
        </xsl:when>

        <xsl:when test="string($J)">
          <xsl:call-template name="att-jmt">
            <xsl:with-param name="ATT" select="'when'"/>
            <xsl:with-param name="J" select="$J"/>
            <xsl:with-param name="M" select="$M"/>
            <xsl:with-param name="T" select="$T"/>
          </xsl:call-template>
        </xsl:when>

        <xsl:when test="string($Jh)">
          <xsl:call-template name="att-nB-nA">
            <xsl:with-param name="chron-min" select="$ChronMinimum"/>
            <xsl:with-param name="chron-max" select="$ChronMaximum"/>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>

      <!-- HGV formatted date string -->

      <xsl:value-of select="$date-print"/>

      <!-- certainties -->
      
      <xsl:if test="string($unsicher) and not(contains($unsicher, '?'))">

          <xsl:variable name="date-types">
            <xsl:choose>
              <xsl:when test="string($J2) or string($M2) or string($T2)">
                <xsl:text>notBefore,notAfter</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="contains($Erg, 'vor')">
                    <xsl:text>notAfter</xsl:text>
                  </xsl:when>
                  <xsl:when test="contains($Erg, 'nach')">
                    <xsl:text>notBefore</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>when</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          
          <xsl:variable name="uncertainty-types">
            <xsl:if test="contains($unsicher, 'Jahr')"><xsl:text>year,</xsl:text></xsl:if>
            <xsl:if test="contains($unsicher, 'Monat')"><xsl:text>month,</xsl:text></xsl:if>
            <xsl:if test="contains($unsicher, 'Tag')"><xsl:text>day</xsl:text></xsl:if>
          </xsl:variable>
          
          <xsl:for-each select="tokenize($date-types, ',')">
            <xsl:variable name="date-type" select="normalize-space(.)" />
            <xsl:for-each select="tokenize($uncertainty-types, ',')">
              <xsl:variable name="uncertainty-type" select="normalize-space(.)" />
              <xsl:if test="string($date-type) and string($uncertainty-type)">
                <certainty locus="value" match="../date/{$uncertainty-type}-from-date(@{$date-type})" />
              </xsl:if>
            </xsl:for-each>
          </xsl:for-each>
            
      </xsl:if>

      <xsl:if test="string($date-id)">
        <certainty locus="value" given="#dateAlternative{$date-id}" degree="1" />
      </xsl:if>
    </date>

  </xsl:template>

  <!-- Create padding for year, month and date -->

  <xsl:template name="J-test">
    <xsl:param name="J-val"/>
    <xsl:if test="string(normalize-space($J-val))">
      <xsl:if test="starts-with(normalize-space($J-val), '-')">
        <xsl:text>-</xsl:text>
      </xsl:if>
      <xsl:value-of select="my:format-num(my:norm-num($J-val), '4')"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="MT-test">
    <xsl:param name="MT-val"/>
    <xsl:if test="string(normalize-space($MT-val))">
      <xsl:value-of select="my:format-num(my:norm-num($MT-val), '2')"/>
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

</xsl:stylesheet>