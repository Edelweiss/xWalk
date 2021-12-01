<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  exclude-result-prefixes="#all" version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:hgv="HGV"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:my="http://local"
  xmlns:fm="http://www.filemaker.com/fmpxmlresult" xmlns:date="http://exslt.org/dates-and-times"
  xmlns:common="http://exslt.org/common"
  xmlns="http://www.tei-c.org/ns/1.0">

<!-- 

templates
  full-date(Jh, Jh2, J, J2, M, M2, T, T2, Erg, Erg2, unsicher, ChronMax, ChronMin, date-print, context, date-id)

needs global.xsl !!!

-->

  <xsl:variable name="year-qualifiers" as="element()">
    <hgv:qualifiers>
      <hgv:qualifier hgv:key="Anfang"            hgv:min="1" hgv:max="3" />       
      <hgv:qualifier hgv:key="1. Hälfte"         hgv:min="1" hgv:max="6" />
      <hgv:qualifier hgv:key="1. Hälfte - Mitte" hgv:min="4" hgv:max="6" /> <!-- 0 Filemaker record sets -->      
      <hgv:qualifier hgv:key="Mitte"             hgv:min="4" hgv:max="9" />
      <hgv:qualifier hgv:key="Mitte - 2. Hälfte" hgv:min="7" hgv:max="9" /> <!-- 0 Filemaker record sets -->
      <hgv:qualifier hgv:key="2. Hälfte"         hgv:min="7" hgv:max="12" />
      <hgv:qualifier hgv:key="Ende"              hgv:min="10" hgv:max="12" />

      <hgv:qualifier hgv:key="Spätwinter"        hgv:min="1" hgv:max="2" /> <!-- 0 Filemaker record sets -->
      <hgv:qualifier hgv:key="Frühjahr"          hgv:min="2" hgv:max="4" />
      <hgv:qualifier hgv:key="Sommer"            hgv:min="5" hgv:max="8" />
      <hgv:qualifier hgv:key="Herbst"            hgv:min="9" hgv:max="11" /> <!-- 0 Filemaker record sets -->
      <hgv:qualifier hgv:key="Frühwinter"        hgv:min="11" hgv:max="12" /> <!-- 0 Filemaker record sets -->
    </hgv:qualifiers>
  </xsl:variable>

  <xsl:variable name="month-qualifiers" as="element()">
    <hgv:qualifiers>
      <hgv:qualifier hgv:key="Anfang"            hgv:min="1" hgv:max="10" /> <!-- just 1 Filemaker record set -->
      <hgv:qualifier hgv:key="Mitte"             hgv:min="11" hgv:max="20" /> <!-- 0 Filemaker record sets -->
      <hgv:qualifier hgv:key="Ende"              hgv:min="21" hgv:max="28/29/30/31" /> <!-- 0 Filemaker record sets -->
    </hgv:qualifiers>
  </xsl:variable>

  <xsl:template name="full-date">
    <xsl:param name="Jh"/>           <!-- century -->
    <xsl:param name="Jh2"/>
    <xsl:param name="J"/>            <!-- year -->
    <xsl:param name="J2"/>
    <xsl:param name="M"/>            <!-- month -->
    <xsl:param name="M2"/>
    <xsl:param name="T"/>            <!-- day -->
    <xsl:param name="T2"/>
    <xsl:param name="Erg"/>          <!-- degree of fuzzyness such as »ca.« -->
    <xsl:param name="Erg2"/>
    <xsl:param name="unsicher"/>     <!-- uncertainty -->
    <xsl:param name="ChronMaximum"/> <!-- maximum year -->
    <xsl:param name="ChronMinimum"/> <!-- minimum year -->
    <xsl:param name="date-print"/>   <!-- HGV format string -->
    <xsl:param name="context"/>      <!-- type of date, i.e. »origin« or »mentioned« -->
    <xsl:param name="date-id" />     <!-- »X«, »Y« or »Z« -->

    <xsl:variable name="ca" select="contains($Erg, 'ca')" /> <!-- boolean value for »ca.« -->
    <xsl:variable name="ca2" select="contains($Erg2, 'ca')" />

    <xsl:variable name="offset"> <!-- offset type (»vor« or »nach«) or empty -->
      <xsl:analyze-string regex="(vor|nach)( +\(\?\))?" select="$Erg" flags="i">
        <xsl:matching-substring>
          <xsl:value-of select="normalize-space(.)" />
        </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    
    <xsl:variable name="offset2">
      <xsl:analyze-string regex="(vor|nach)( +\(\?\))?" select="$Erg2" flags="i">
        <xsl:matching-substring>
          <xsl:value-of select="normalize-space(.)" />
        </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    
    <xsl:variable name="vague">
      <xsl:analyze-string regex="(Mitte - 2\. Hälfte|Anfang|1\. Hälfte|Mitte|2\. Hälfte|Ende|Frühjahr|Sommer)( +\(\?\))?" select="$Erg" flags="i">
        <xsl:matching-substring>
          <xsl:value-of select="normalize-space(.)" />
        </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    
    <xsl:variable name="vague2">
      <xsl:analyze-string regex="(Mitte - 2\. Hälfte|Anfang|1\. Hälfte|Mitte|2\. Hälfte|Ende|Frühjahr|Sommer)( +\(\?\))?" select="$Erg2" flags="i">
        <xsl:matching-substring>
          <xsl:value-of select="normalize-space(.)" />
        </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    
    <xsl:variable name="qualifier" select="normalize-space(replace($vague, ' \(\?\)', ''))" />
    <xsl:variable name="qualifier2" select="normalize-space(replace($vague2, ' \(\?\)', ''))" />

    <xsl:variable name="year">
      <xsl:choose>
        <xsl:when test="string($J)">
          <xsl:value-of select="format-number(number(translate($J, ' ', '')), '0000')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="false()" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="month">
      <xsl:choose>
        <xsl:when test="string($M)">
          <xsl:value-of select="format-number(number(translate($M, ' ', '')), '00')" />
        </xsl:when>
        <xsl:when test="string($J) and string($qualifier)">
          <xsl:value-of select="string(format-number(number($year-qualifiers/hgv:qualifier[@hgv:key = $qualifier]/@hgv:min), '00'))" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="false()" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="day">
      <xsl:choose>
        <xsl:when test="string($T)">
          <xsl:value-of select="format-number(number(translate($T, ' ', '')), '00')" />
        </xsl:when>
        <xsl:when test="string($M) and string($qualifier)">
          <xsl:value-of select="string(format-number(number($month-qualifiers/hgv:qualifier[@hgv:key = $qualifier]/@hgv:min), '00'))" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="false()" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="year2">
      <xsl:choose>
        <xsl:when test="string($J2)">
          <xsl:value-of select="format-number(number(translate($J2, ' ', '')), '0000')" />
        </xsl:when>
        <xsl:when test="string($M2)">
          <xsl:value-of select="$year" />
        </xsl:when>
        <xsl:when test="string($T2)">
          <xsl:value-of select="$year" />
        </xsl:when>
        <xsl:when test="string($J) and string($qualifier)">
          <xsl:value-of select="$year" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="false()" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="month2">
      <xsl:choose>
        <xsl:when test="string($M2)">
          <xsl:value-of select="format-number(number(translate($M2, ' ', '')), '00')" />
        </xsl:when>
        <xsl:when test="string($J2) and string($qualifier2)">
          <xsl:value-of select="string(format-number(number($year-qualifiers/hgv:qualifier[@hgv:key = $qualifier2]/@hgv:max), '00'))" />
        </xsl:when>
        <xsl:when test="string($T2)">
          <xsl:value-of select="$month" />
        </xsl:when>
        <xsl:when test="string($J) and string($qualifier)">
          <xsl:choose>
            <xsl:when test="string($M)">
              <xsl:value-of select="$month" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="string(format-number(number($year-qualifiers/hgv:qualifier[@hgv:key = $qualifier]/@hgv:max), '00'))" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="false()" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="day2">
      <xsl:choose>
        <xsl:when test="string($T2)">
          <xsl:value-of select="format-number(number(translate($T2, ' ', '')), '00')" />
        </xsl:when>
        <xsl:when test="string($M2) and string($qualifier2)">
          <xsl:value-of select="string(format-number(number($month-qualifiers/hgv:qualifier[@hgv:key = $qualifier2]/@hgv:max), '00'))" />
        </xsl:when>
        <xsl:when test="string($M) and string($qualifier)">
          <xsl:value-of select="string(format-number(number($month-qualifiers/hgv:qualifier[@hgv:key = $qualifier]/@hgv:max), '00'))" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="false()" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="date-element"> <!-- name of the TEI element to be used, »origDate« or »date« -->
      <xsl:choose>
        <xsl:when test="$context = 'origin'">
          <xsl:value-of select="'origDate'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'date'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:element name="{$date-element}">

      <xsl:if test="$context = 'mentioned'">
        <xsl:attribute name="type">mentioned</xsl:attribute>
      </xsl:if>
      <xsl:if test="$context = 'origin' and string($date-id)">
        <xsl:attribute name="xml:id">dateAlternative<xsl:value-of select="$date-id" /></xsl:attribute>
      </xsl:if>
      
      <!-- @when / @notBefore / @notAfter -->

      <xsl:choose>

        <xsl:when test="contains($Erg, 'unbekannt')"/>

        <xsl:when test="string($Jh)">    
          <!--xsl:attribute name="type" select="'Jh'" /-->
          <xsl:choose>
            <xsl:when test="contains($Erg, 'vor') and string($ChronMinimum)">
              <xsl:call-template name="att-jmt">
                <xsl:with-param name="ATT" select="'notAfter'"/>
                <xsl:with-param name="J" select="format-number(number($ChronMinimum), '0000')"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($Erg, 'nach') and string($ChronMaximum)">
              <xsl:call-template name="att-jmt">
                <xsl:with-param name="ATT" select="'notBefore'"/>
                <xsl:with-param name="J" select="format-number(number($ChronMaximum), '0000')"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="string($ChronMinimum)">
                <xsl:call-template name="att-jmt">
                  <xsl:with-param name="ATT" select="'notBefore'"/>
                  <xsl:with-param name="J" select="format-number(number($ChronMinimum), '0000')"/>
                </xsl:call-template>
              </xsl:if>
              <xsl:if test="string($ChronMaximum)">
                <xsl:call-template name="att-jmt">
                  <xsl:with-param name="ATT" select="'notAfter'"/>
                  <xsl:with-param name="J" select="format-number(number($ChronMaximum), '0000')"/>
                </xsl:call-template>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <xsl:when test="string($J2) or string($M2) or string($T2) or string($qualifier)">
          <!--xsl:attribute name="type" select="concat(concat(concat('J2/M2/T2',$year),$month),$day)" /-->          
          <xsl:call-template name="att-jmt">
            <xsl:with-param name="ATT" select="'notBefore'"/>
            <xsl:with-param name="J" select="$year"/>
            <xsl:with-param name="M" select="$month"/>
            <xsl:with-param name="T" select="$day"/>
          </xsl:call-template>
          <xsl:call-template name="att-jmt">
            <xsl:with-param name="ATT" select="'notAfter'"/>
            <xsl:with-param name="J" select="$year2"/>
            <xsl:with-param name="M" select="$month2"/>
            <xsl:with-param name="T" select="$day2"/>
          </xsl:call-template>
        </xsl:when>
        
        <xsl:otherwise>
          <!--xsl:attribute name="type" select="'otherwise'" /-->
          <xsl:variable name="date-attribute-type">
            <xsl:choose>
              <xsl:when test="contains($Erg, 'nach')">notBefore</xsl:when>
              <xsl:when test="contains($Erg, 'vor')">notAfter</xsl:when>
              <xsl:otherwise>when</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:call-template name="att-jmt">
            <xsl:with-param name="ATT" select="$date-attribute-type"/>
            <xsl:with-param name="J" select="$year"/>
            <xsl:with-param name="M" select="$month"/>
            <xsl:with-param name="T" select="$day"/>
          </xsl:call-template>
        </xsl:otherwise>

      </xsl:choose>
      
      <!-- uncertainty global -->

      <xsl:if test="contains($unsicher, '?')">
        <xsl:attribute name="cert" select="'low'" />
      </xsl:if>

      <!-- precision -->
      
      <xsl:variable name="precision-low">
        <xsl:choose>
          <xsl:when test="string($Jh)">
            <xsl:value-of select="true()" />
          </xsl:when>
          <xsl:when test="string($qualifier)">
            <xsl:value-of select="true()" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="false()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="precision-low2">
        <xsl:choose>
          <xsl:when test="string($Jh)">
            <xsl:value-of select="true()" />
          </xsl:when>
          <xsl:when test="string($qualifier2)">
            <xsl:value-of select="true()" />
          </xsl:when>
          <xsl:when test="string($qualifier) and not(string($J2)) and not(string($M2)) and not(string($T2))">
            <xsl:value-of select="$precision-low" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="false()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="precision-medium">
        <xsl:choose>
          <xsl:when test="$ca">
            <xsl:value-of select="true()" />
          </xsl:when>
          <xsl:when test="contains($vague, '?')">
            <xsl:value-of select="true()" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="false()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="precision-medium2">
        <xsl:choose>
          <xsl:when test="$ca2">
            <xsl:value-of select="true()" />
          </xsl:when>
          <xsl:when test="contains($vague2, '?')">
            <xsl:value-of select="true()" />
          </xsl:when>
          <xsl:when test="string($qualifier) and not(string($J2)) and not(string($M2)) and not(string($T2))">
            <xsl:value-of select="$precision-medium" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="false()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="precision">
        <xsl:choose>
          <xsl:when test="$precision-low = true() and $precision-medium = true()">
            <xsl:value-of select="0.1" />
          </xsl:when>
          <xsl:when test="$precision-low = true()">
            <xsl:value-of select="0.3" />
          </xsl:when>
          <xsl:when test="$precision-medium = true()">
            <xsl:value-of select="0.5" />
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="precision2">
        <xsl:choose>
          <xsl:when test="$precision-low2 = true() and $precision-medium2 = true()">
            <xsl:value-of select="0.1" />
          </xsl:when>
          <xsl:when test="$precision-low2 = true()">
            <xsl:value-of select="0.3" />
          </xsl:when>
          <xsl:when test="$precision-medium2 = true()">
            <xsl:value-of select="0.5" />
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="precision-attribute">
        <xsl:choose>
          <xsl:when test="string($precision) and ($precision = $precision2)">
            <xsl:value-of select="$precision" />
          </xsl:when>
          <xsl:when test="string($precision) and not(string($qualifier) or string($J2) or string($M2) or string($T2))">
            <xsl:value-of select="$precision" />
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      
      <!--xsl:attribute name="tt">
        <xsl:text>[</xsl:text>
          <xsl:value-of select="$precision-low"/>
          <xsl:text>|</xsl:text>
          <xsl:value-of select="$precision-medium"/>
          <xsl:text>|</xsl:text>
          <xsl:value-of select="$precision"/>
          <xsl:text> + </xsl:text>
          <xsl:value-of select="$precision-low2"/>
          <xsl:text>|</xsl:text>
          <xsl:value-of select="$precision-medium2"/>
          <xsl:text>|</xsl:text>
          <xsl:value-of select="$precision2"/>
          <xsl:text> = </xsl:text>
          <xsl:value-of select="$precision-attribute"/>
          <xsl:text>]</xsl:text>
      </xsl:attribute-->
      
      <xsl:choose>
        <xsl:when test="string($precision-attribute)">
            <xsl:choose>
              <xsl:when test="$precision-attribute != '0.1'">
                <xsl:attribute name="precision" select="replace(replace($precision-attribute, '0.3', 'low'), '0.5', 'medium')" />
              </xsl:when>
              <xsl:when test="$precision-attribute = '0.1'">
                <precision degree="0.1" />
              </xsl:when>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="string($precision)">
            <xsl:choose>
              <xsl:when test="$precision = '0.3'">
                <precision match="../@notBefore" />
              </xsl:when>
              <xsl:otherwise>
                <precision match="../@notBefore" degree="{$precision}" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
          <xsl:if test="string($precision2)">
            <xsl:choose>
              <xsl:when test="$precision2 = '0.3'">
                <precision match="../@notAfter" />
              </xsl:when>
              <xsl:otherwise>
                <precision match="../@notAfter" degree="{$precision2}" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:otherwise>
        
      </xsl:choose>
    
      <!-- uncertainty special -->

      <xsl:variable name="attributeNumberOne">
        <xsl:choose>
          <xsl:when test="string($qualifier) or string($Jh) or string($J2) or string($M2) or string($T2)">notBefore</xsl:when>
          <xsl:otherwise>
             <xsl:choose>
              <xsl:when test="contains($Erg, 'nach')">notBefore</xsl:when>
              <xsl:when test="contains($Erg, 'vor')">notAfter</xsl:when>
              <xsl:otherwise>when</xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="contains($unsicher, 'Jahr')">
        <certainty locus="value" match="../year-from-date(@{$attributeNumberOne})" />
      </xsl:if>
      <xsl:if test="contains($unsicher, 'Jahre')">
        <certainty locus="value" match="../year-from-date(@notAfter)" />
      </xsl:if>
      <xsl:if test="contains($unsicher, 'Monat')">
        <certainty locus="value" match="../month-from-date(@{$attributeNumberOne})" />
      </xsl:if>
      <xsl:if test="contains($unsicher, 'Monate')">
        <certainty locus="value" match="../month-from-date(@notAfter)" />
      </xsl:if>
      <xsl:if test="contains($unsicher, 'Tag')">
        <certainty locus="value" match="../day-from-date(@{$attributeNumberOne})" />
      </xsl:if>
      <xsl:if test="contains($unsicher, 'Tage')">
        <certainty locus="value" match="../day-from-date(@notAfter)" />
      </xsl:if>

      <!-- HGV format -->
      <xsl:analyze-string select="normalize-space($date-print)" regex="(nach|vor)( \(\?\))?">
        <xsl:matching-substring>
          <xsl:variable name="offset-type">
            <xsl:choose>
              <xsl:when test="contains(., 'vor')">before</xsl:when>
              <xsl:when test="contains(., 'nach')">after</xsl:when>
              <xsl:otherwise>never</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="offset-position">
            <xsl:choose>
              <xsl:when test="position() = 1">1</xsl:when>
              <xsl:otherwise>2</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <offset>
            <xsl:attribute name="type" select="$offset-type" />
            <xsl:attribute name="n" select="$offset-position" />
            <xsl:value-of select="." />
          </offset>
          <xsl:if test="contains(., '?')">
            <certainty locus="value" match="../offset[@type='{$offset-type}']" />
          </xsl:if>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:value-of select="." />
        </xsl:non-matching-substring>
      </xsl:analyze-string>

      <xsl:if test="$context = 'mentioned' and string($date-id)">
        <certainty locus="value" given="#dateAlternative{$date-id}" degree="1" />
      </xsl:if>

    </xsl:element>
    
  </xsl:template>
  
</xsl:stylesheet>