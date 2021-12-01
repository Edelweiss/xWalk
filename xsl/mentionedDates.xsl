<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:papy="Papyrillio"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:my="http://local"
  xmlns:fm="http://www.filemaker.com/fmpxmlresult" xmlns:date="http://exslt.org/dates-and-times"
  xmlns:common="http://exslt.org/common"
  xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0">

<!-- 

functions
  papy:make-iso-date(christ, year, month, day)

templates
  parse-mentioned-dates(mentioned-dates, date-id) # split by ; and ,
  parse-day-alternatives(reference,raw, date-id)  # scan for multiple days
  bake-mentioned-date(reference,raw, date-id)     # write TEI:item, TEI:ref, TEI:certainty (for date-type) 
  parse-date(raw)
-->

<xsl:function name="papy:make-iso-date"><!-- returns an iso-like date format, e.g. »-0138-07-21« -->
  <xsl:param name="christ"/><!-- calendar era BC or AD, designated by their German equivalents »v.Chr.« or »n.Chr.« -->
  <xsl:param name="year"/><!-- number, e.g. »138« -->
  <xsl:param name="month"/><!-- abbreviated German month name, e.g. »Jul.« -->
  <xsl:param name="day"/><!-- ordinal number with a trailing dot, e.g. »21.« -->

  <xsl:variable name="months" select="'Jan.', 'Febr.', 'März', 'Apr.', 'Mai', 'Juni', 'Juli', 'Aug.', 'Sept.', 'Okt.', 'Nov.', 'Dez.'"/>

  <xsl:variable name="year-iso" select="normalize-space($year)" />
  <xsl:variable name="month-iso" select="index-of($months, normalize-space($month))" />
  <xsl:variable name="day-iso" select="normalize-space(translate($day, '.', ''))" />  

  <xsl:if test="number($year-iso)">
    <xsl:if test="contains($christ, 'v.Chr.') or contains($christ, 'v. Chr.')">
      <xsl:value-of select="'-'" />
    </xsl:if>
    <xsl:number value="$year-iso" format="0001"/>
    <xsl:if test="number($month-iso)">
      <xsl:text>-</xsl:text>
      <xsl:number value="$month-iso" format="01"/>
      <xsl:if test="number($day-iso)">
        <xsl:text>-</xsl:text>
        <xsl:number value="$day-iso" format="01"/>
      </xsl:if>
    </xsl:if>
  </xsl:if>

</xsl:function>

<xsl:template name="papy:parse-mentioned-dates">
  <xsl:param name="mentioned-dates" /> <!-- mentioned dates string from HGV Filemaker database to be parsed -->
  <xsl:param name="date-id" /> <!-- X, Y, Z -->  

  <xsl:choose>
    <xsl:when test="$mentioned-dates = 'Zur Datierung vgl. BL X, S. 259.'">
      <item><note type="annotation">Zur Datierung vgl. BL X, S. 259</note></item>
    </xsl:when>
    <xsl:when test="string(normalize-space(.)) and not(contains(., 'Regierungsjahr')) and not(contains(., 'Indiktion')) and not(contains(., 'Ind.'))">
  
        <!-- split by »;« -->
        <xsl:for-each select="tokenize($mentioned-dates, ';')">
  
            <!-- get everything infront of the »:« -->
            <xsl:variable name="reference" select="normalize-space(substring-before(., ':'))" />
            <xsl:variable name="date-part">
              <xsl:choose>
                <xsl:when test="contains(., ':')">
                  <xsl:value-of select="normalize-space(substring-after(., ':'))" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="normalize-space(.)" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            
            <xsl:variable name="special_case" select="replace($date-part, '230/231-234/235', '230 - 235')" />
            <xsl:variable name="bis_zum" select="replace($special_case, '\(\?\) bis zum', '-')" />
            
            <!-- convert each »oder« that is used for separation of individual dates into »,« (grasp day follows year) -->
            <xsl:variable name="mask_date_alternatives" select="replace($bis_zum, '(\d+) (oder|und) (\d+\.)', '$1, $3')" />

            <!-- mask each »,« that is not used for separation of individual dates -->
  
            <xsl:variable name="mask_day_alternatives_oder" select="replace($mask_date_alternatives, '(\d+\.) oder (\d+\.)', '$1|$2')" />
            <xsl:variable name="mask_day_alternatives" select="replace($mask_day_alternatives_oder, '(\d+\.), ?', '$1|')" />
            <xsl:variable name="mask_day_alternatives2" select="replace($mask_day_alternatives, ' ?\((\d+\.)\)', '|$1')" />
            <xsl:variable name="mask_day_alternatives3" select="replace($mask_day_alternatives2, '(\d+\.) oder ', '$1|')" />
            <xsl:variable name="mask_day_alternatives4" select="replace($mask_day_alternatives3, '(\d+\.) und ', '$1|')" />
            <xsl:variable name="mask_makedonian_month" select="replace($mask_day_alternatives4, '(Dios|Apellaios|Audynaios|Peritios|Dystros|Xanthikos|Xandikos|Artemisios|Daisios|Panemos|Loos|Gorpiaios|Hyperberetaios)(,)', '$1')" />
  <!--punkt><xsl:value-of select="." /></punkt>
  <reference><xsl:value-of select="$reference" /></reference>
  <test><xsl:value-of select="normalize-space(substring-after(., ':'))" /></test>
  <mask_day_alternatives><xsl:value-of select="$mask_day_alternatives" /></mask_day_alternatives>
  <mask_day_alternatives2><xsl:value-of select="$mask_day_alternatives2" /></mask_day_alternatives2>
  <mask_day_alternatives3><xsl:value-of select="$mask_day_alternatives3" /></mask_day_alternatives3>
  <mask_day_alternatives4><xsl:value-of select="$mask_day_alternatives4" /></mask_day_alternatives4>
  <mask_makedonian_month><xsl:value-of select="$mask_makedonian_month" /></mask_makedonian_month-->
            <xsl:variable name="mask_parentheses">
              <xsl:analyze-string select="$mask_makedonian_month" regex="([^\(\)]+)?(\()([^\(\)]+)?(\))([^\(\)]+)?">          
                <xsl:matching-substring>
                  <xsl:value-of select="regex-group(1)"/>
                  <xsl:value-of select="regex-group(2)"/>
                  <xsl:value-of select="replace(regex-group(3), '([^,]+),', '$1|')"/>
                  <xsl:value-of select="regex-group(4)"/>
                  <xsl:value-of select="regex-group(5)"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
              </xsl:analyze-string>
            </xsl:variable>
  <!--test><xsl:value-of select="$mask_parentheses" /></test-->
            <!-- split by »,« -->
            <xsl:for-each select="tokenize($mask_parentheses, ',')">  
              <xsl:call-template name="parse-day-alternatives">
                <xsl:with-param name="reference" select="$reference" />
                <xsl:with-param name="raw" select="." />
                <xsl:with-param name="date-id" select="$date-id" />
              </xsl:call-template>
            </xsl:for-each>
            
        </xsl:for-each>
  
    </xsl:when>
      </xsl:choose>

</xsl:template>

<xsl:template name="parse-day-alternatives">
  <xsl:param name="reference" /> <!-- e.g. Z. 10 - 11 -->
  <xsl:param name="raw" />       <!-- e.g. 10.|20.|27.|29.|30. Mai 158 v. Chr. (vgl. BL X| 3) (Jahr| Monat und Tag unsicher) -->
  <xsl:param name="date-id" />   <!-- X, Y, Z -->
  
  <xsl:variable name="day-alternatives">
    <xsl:choose>
      <xsl:when test="contains($raw, '-')">
        <xsl:analyze-string select="substring-before($raw, '-')" regex="\d+\. ?\|?">          
          <xsl:matching-substring>
            <xsl:value-of select="." />
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:when>
      <xsl:otherwise>
        <xsl:analyze-string select="$raw" regex="\d+\. ?\|?">          
          <xsl:matching-substring>
            <xsl:value-of select="." />
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="day-alternatives2">
    <xsl-if test="contains($raw, '-')">
      <xsl:analyze-string select="substring-after($raw, '-')" regex="\d+\. ?\|?">          
        <xsl:matching-substring>
          <xsl:value-of select="." />
        </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl-if>
  </xsl:variable>

  <xsl:variable name="day-a" select="normalize-space($day-alternatives)" />
  <xsl:variable name="day-a2" select="normalize-space($day-alternatives2)" />
  
  <xsl:variable name="from-replace" select="replace($day-a, '(\||\.)', '\\$1')" />
  <xsl:variable name="to-replace" select="replace($day-a2, '(\||\.)', '\\$1')" />
  
  <!--raw><xsl:value-of select="$raw" /></raw>
  <day-alternatives><xsl:value-of select="$day-alternatives" /></day-alternatives>
  <day-alternatives><xsl:value-of select="$day-alternatives2" /></day-alternatives>
  <day-a><xsl:value-of select="$day-a" /></day-a>
  <day-a><xsl:value-of select="$day-a2" /></day-a-->

  <xsl:choose>
    <xsl:when test="string($day-a) and string($day-a2)">
      <xsl:for-each select="tokenize($day-a, '\|')">
        <xsl:variable name="from-day" select="." />
        <xsl:for-each select="tokenize($day-a2, '\|')">
          <xsl:variable name="to-day" select="." />

          <xsl:variable name="hack" select="replace(replace($raw, $from-replace, $from-day), $to-replace, $to-day)" />
          
          <!--replace><xsl:value-of select="$from-replace" /></replace>
          <replace><xsl:value-of select="$to-replace" /></replace>
          <x><xsl:value-of select="$from-day" /> - <xsl:value-of select="$to-day" /> = <xsl:value-of select="$hack" /></x-->
          
          <xsl:call-template name="bake-mentioned-date">
            <xsl:with-param name="reference" select="$reference" />
            <xsl:with-param name="raw" select="$hack" />
            <xsl:with-param name="date-id" select="$date-id" />
          </xsl:call-template>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:when>
    
    <xsl:when test="string($day-a)">
      <xsl:for-each select="tokenize($day-a, '\|')">
          <xsl:variable name="hack" select="replace($raw, $from-replace, .)" />
          <xsl:call-template name="bake-mentioned-date">
            <xsl:with-param name="reference" select="$reference" />
            <xsl:with-param name="raw" select="$hack" />
            <xsl:with-param name="date-id" select="$date-id" />
          </xsl:call-template>
      </xsl:for-each>
    </xsl:when>
      
    <xsl:when test="string($day-a2)">
      <xsl:for-each select="tokenize($day-a2, '\|')">
          <xsl:variable name="hack" select="replace($raw, $to-replace, .)" />
          <xsl:call-template name="bake-mentioned-date">
            <xsl:with-param name="reference" select="$reference" />
            <xsl:with-param name="raw" select="$hack" />
            <xsl:with-param name="date-id" select="$date-id" />
          </xsl:call-template>
      </xsl:for-each>
    </xsl:when>
    
    <xsl:otherwise>
      <xsl:call-template name="bake-mentioned-date">
        <xsl:with-param name="reference" select="$reference" />
        <xsl:with-param name="raw" select="$raw" />
        <xsl:with-param name="date-id" select="$date-id" />
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<xsl:template name="bake-mentioned-date">
  <xsl:param name="reference" /> <!-- e.g. Z. 10 - 11 -->
  <xsl:param name="raw" />       <!-- e.g. 10.|20.|27.|29.|30. Mai 158 v. Chr. (vgl. BL X| 3) (Jahr| Monat und Tag unsicher) -->
  <xsl:param name="date-id" />   <!-- X, Y, Z -->
  
  <item>
    <!-- reference -->
    <xsl:if test="string($reference)">
      <ref><xsl:value-of select="$reference" /></ref>
    </xsl:if>

    <!-- date -->
    <xsl:call-template name="parse-date">
      <xsl:with-param name="raw" select="$raw" />
      <xsl:with-param name="date-id" select="$date-id" />
    </xsl:call-template>
    
  </item>
</xsl:template>

<xsl:template name="parse-date">
  <xsl:param name="raw" />
  <xsl:param name="date-id" />
  
  <!--raw><xsl:value-of select="$raw" /></raw-->

  <xsl:variable name="comment">
    <xsl:variable name="comment1">
      <xsl:analyze-string select="normalize-space($raw)" regex="^([^0-9]+)(.+\))?(Jan\.|Febr\.|März|Apr\.|Mai|Juni|Juli|Aug\.|Sept\.|Okt\.|Nov\.|Dez\.)?( .*\d.*)">
        <xsl:matching-substring>
          <xsl:value-of select="regex-group(1)" />
          <xsl:value-of select="regex-group(2)" />
        </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    <xsl:value-of select="normalize-space(replace(replace($comment1, '\|', ', '), '\.([^ ,C])', '. $1'))" /> <!-- remask -->
  </xsl:variable>
  
  <xsl:variable name="annotation">
    <xsl:variable name="annotation1">
      <xsl:choose>
        <xsl:when test="contains($raw, '(vgl.')">
          <xsl:value-of select="concat('vgl.', substring-before(substring-after($raw, 'vgl.'), ')'))" />
        </xsl:when>
        <xsl:when test="matches($raw, '.+\d .+(Bearbeitungsvermerk|Zeile unbekannt|vgl. BL I\| S. 13|BL I\| S. 81|Abschrift eines Dokuments\| Teil|Vgl. ZPE 42\| 1981|jedes Jahr einzeln|amtliche Anweisung|amtlicher Vermerk|vgl. ZPE 17\| 1975, S. 289)')">
          <xsl:value-of select="replace($raw, '^.+(Bearbeitungsvermerk|Zeile unbekannt|vgl. BL I\| S. 13|BL I\| S. 81|Abschrift eines Dokuments\| Teil|Vgl. ZPE 42\| 1981|jedes Jahr einzeln|amtliche Anweisung|amtlicher Vermerk|vgl. ZPE 17\| 1975, S. 289).+$', '$1')" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="normalize-space(replace(replace($annotation1, '\|', ', '), '\.([^ ,C])', '. $1'))" /> <!-- remask -->
  </xsl:variable>

  <xsl:variable name="certainty-global">
    <xsl:choose>
      <xsl:when test="matches($raw, '\(\?\) *$')">
        <xsl:value-of select="true()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="uncertainty" select="substring-before(substring-after($raw, '('), ' unsicher)')" />
  
  <xsl:variable name="date">
    <xsl:variable name="date1" select="normalize-space(replace($raw, '(ca\.|\(.*[A-Za-z].*\))', ''))" />
    <xsl:choose>
      <xsl:when test="ends-with($date1, '.') and not(matches($date1, '(v\. ?Chr\.|n\. ?Chr\.|Jan\.|Febr\.|März|Apr\.|Mai|Juni|Juli|Aug\.|Sept\.|Okt\.|Nov\.|Dez\.)$'))">
        <xsl:value-of select="replace($date1, '\.$', '')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$date1" />
      </xsl:otherwise >
    </xsl:choose>    
  </xsl:variable>
  
  <!--date><xsl:value-of select="$date" /></date-->

  <xsl:variable name="f">
    <xsl:choose>
      <xsl:when test="contains($date, '-')">
        <xsl:value-of select="substring-before($date, '-')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$date" />
      </xsl:otherwise >
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="t" select="substring-after($date, '-')" />

  <xsl:variable name="fd"> <!-- from day -->
    <xsl:analyze-string select="$f" regex="(\d{{1,2}}\.)">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)" />
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
     
  <xsl:variable name="fd.cert">
    <xsl:analyze-string select="$f" regex="\d{{1,2}}\. *(\(\?\))">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)" />
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
  
  <xsl:variable name="fm"> <!-- from month -->
    <xsl:analyze-string select="$f" regex="(Jan\.|Febr\.|März|Apr\.|Mai|Juni|Juli|Aug\.|Sept\.|Okt\.|Nov\.|Dez\.)">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)" />
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
  
  <xsl:variable name="fm.cert">
    <xsl:analyze-string select="$f" regex="(Jan\.|Febr\.|März|Apr\.|Mai|Juni|Juli|Aug\.|Sept\.|Okt\.|Nov\.|Dez\.) *(\(\?\))">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(2)" />
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
  
  <xsl:variable name="fy"> <!-- from year -->
    <xsl:analyze-string select="$f" regex="(\d{{1,4}})([^\.0-9]|$)">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)" />
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
  
  <xsl:variable name="fc"> <!-- from christ -->
    <xsl:analyze-string select="$f" regex="(v\. ?Chr\.|n\. ?Chr\.)">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)" />
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>

  <xsl:variable name="td"> <!-- to day -->
    <xsl:analyze-string select="$t" regex="(\d{{1,2}}\.)">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)" />
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
     
  <xsl:variable name="td.cert">
    <xsl:analyze-string select="$t" regex="\d{{1,2}}\. *(\(\?\))">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)" />
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
  
  <xsl:variable name="tm"> <!-- to month -->
    <xsl:analyze-string select="$t" regex="(Jan\.|Febr\.|März|Apr\.|Mai|Juni|Juli|Aug\.|Sept\.|Okt\.|Nov\.|Dez\.)">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)" />
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
  
  <xsl:variable name="tm.cert">
    <xsl:analyze-string select="$t" regex="(Jan\.|Febr\.|März|Apr\.|Mai|Juni|Juli|Aug\.|Sept\.|Okt\.|Nov\.|Dez\.) *(\(\?\))">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(2)" />
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
  
  <xsl:variable name="ty"> <!-- to year -->
    <xsl:analyze-string select="$t" regex="(\d{{1,4}})([^\.0-9]|$)">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)" />
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
  
  <xsl:variable name="tc"> <!-- to christ -->
    <xsl:analyze-string select="$t" regex="(v\. ?Chr\.|n\. ?Chr\.)">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)" />
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>

  <xsl:variable name="christ">
    <xsl:choose>
      <xsl:when test="string-length($fc) > 0">
        <xsl:value-of select="$fc" />
      </xsl:when>
      <xsl:when test="string-length($tc) > 0">
        <xsl:value-of select="$tc" />
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="year">
    <xsl:choose>
      <xsl:when test="string-length($fy) > 0">
        <xsl:value-of select="$fy" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$ty" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="month">
    <xsl:choose>
      <xsl:when test="string-length($fm) > 0">
        <xsl:value-of select="$fm" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$tm" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="day">
    <xsl:choose>
      <xsl:when test="string-length($fd) > 0">
        <xsl:value-of select="$fd" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$td" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="uncertainty-month">
    <xsl:choose>
      <xsl:when test="string-length($fm.cert) > 0">
        <xsl:value-of select="true()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="year2" select="$ty" />
  <xsl:variable name="month2" select="$tm" />
  <xsl:variable name="day2" select="$td" />
  <xsl:variable name="christ2" select="$tc" />

  <xsl:variable name="iso-date" select="papy:make-iso-date($christ, $year, $month, $day)" />
  <xsl:variable name="iso-date2" select="papy:make-iso-date($christ2, $year2, $month2, $day2)" />
  <xsl:variable name="date-types">
    <xsl:choose>
      <xsl:when test="$iso-date and $iso-date2">
        <xsl:value-of select="'notBefore,notAfter'" />
      </xsl:when>
      <xsl:when test="$iso-date">
        <xsl:value-of select="'when'" />
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <!-- note 1 / comment -->

  <xsl:if test="string($comment)">
    <note type="comment">
      <xsl:value-of select="$comment" />
    </note>
  </xsl:if>
  
  <!-- date -->
  
  <xsl:if test="exists($iso-date)">
    <date type="mentioned">
      
      <!-- attributes @when, @notBefore, @notAfter -->
      
      <xsl:choose>
        <xsl:when test="$iso-date and $iso-date2">
          <xsl:attribute name="notBefore" select="$iso-date" />
          <xsl:attribute name="notAfter" select="$iso-date2" />
        </xsl:when>
        <xsl:when test="$iso-date">
          <xsl:attribute name="when" select="$iso-date" />
        </xsl:when>
      </xsl:choose>
      
      <!-- attribute @cert and special certainties -->
  
      <xsl:choose>
        <xsl:when test="$certainty-global = true()">
          <xsl:attribute name="cert" select="'low'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="tokenize($date-types, ',')">
            <xsl:if test="contains($uncertainty, 'Tag')">
              <certainty match="../day-from-date(@{.})" locus="value" />
            </xsl:if>
            <xsl:if test="contains($uncertainty, 'Monat')">
              <certainty match="../month-from-date(@{.})" locus="value" />
            </xsl:if>
            <xsl:if test="contains($uncertainty, 'Jahr')">
              <certainty match="../year-from-date(@{.})" locus="value" />
            </xsl:if>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
      
      <!-- set certainty according to MehrfachKennung / date id, i.e. X, Y, Z -->
      <xsl:if test="string($date-id)">
        <certainty locus="value" given="#dateAlternative{$date-id}" degree="1"/>
      </xsl:if>
  
      <!-- HGV format -->

      <xsl:variable name="hgv-format-without-comment" select="normalize-space(substring-after(replace(replace(replace($raw, '([^brgtvz])\.$', '$1'), '\|', ', '), '\.([^ ,C])', '. $1'), $comment))" /> <!-- remask and remove comment -->
      <xsl:variable name="hgv-format-without-annotation">
        <xsl:choose>
          <xsl:when test="string($annotation)">
            <xsl:value-of select="normalize-space(replace($hgv-format-without-comment, '\((vgl\.[^\)]+|Bearbeitungsvermerk|Zeile unbekannt|vgl. BL I, S. 13|BL I, S. 81|Abschrift eines Dokuments, Teil|Vgl. ZPE 42, 1981|jedes Jahr einzeln|amtliche Anweisung|amtlicher Vermerk|vgl. ZPE 17, 1975, S. 289)\)', ''))" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$hgv-format-without-comment" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable> <!-- remove annotation -->
      
      <xsl:value-of select="$hgv-format-without-annotation" />
    </date>
    
    <!-- note 2 / annotation -->
      
    <xsl:if test="string($annotation)">
      <note type="annotation"><xsl:value-of select="$annotation" /></note>
    </xsl:if>
    
  </xsl:if>

</xsl:template>

</xsl:stylesheet>