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

    <!--

java -Xms512m -Xmx1536m net.sf.saxon.Transform -l -o:HGV.xml -it:FODS -xsl:xsl/xWalk.xsl HGV=data/HGV.fods > xWalk 2>&1

-->
    <xsl:include href="../papyX/helper.xsl"/>
    <xsl:include href="global.xsl"/>
    <xsl:output method="xml" media-type="text/xml" />

    <xsl:param name="FODS_TABLE" select="'HGV'"/>
    <xsl:param name="FODS_DOCUMENT" select="'../data/HGV.fods'"/>
    <xsl:param name="MODE" select="'new'"/> <!-- new/modified/all -->
    <xsl:variable name="HGV" select="doc($FODS_DOCUMENT)"/>
    <xsl:variable name="INDEX">
        <list>
            <xsl:for-each select="$HGV//table:table[@table:name=$FODS_TABLE]/table:table-row[1]/table:table-cell">
                <item column="{position()}" name="{normalize-space(.)}"/>
            </xsl:for-each>
        </list>
    </xsl:variable>
    <xsl:variable name="DATA">
        <table>
            <xsl:for-each select="$HGV//table:table[@table:name=$FODS_TABLE]/table:table-row[position() &gt; 1]">
                <row>
                    <xsl:for-each select="table:table-cell">
                        <xsl:variable name="summedUpPosition" select="position() + sum(preceding-sibling::table:table-cell/@table:number-columns-repeated) - count(preceding-sibling::table:table-cell[number(@table:number-columns-repeated) &gt; 1])"/>
                        <xsl:variable name="value" select="normalize-space(.)"/>
                        <cell name="{$INDEX//tei:item[@column = $summedUpPosition]/@name}">
                            <xsl:value-of select="$value"/>
                        </cell>
                        <xsl:if test="number(@table:number-columns-repeated) &gt; 1">
                            <xsl:for-each select="papy:range(2, @table:number-columns-repeated)">
                                <xsl:variable name="subsequent" select="position()"/>
                                <cell name="{$INDEX//tei:item[@column = $summedUpPosition + $subsequent]/@name}">
                                    <xsl:value-of select="$value"/>
                                </cell>
                            </xsl:for-each>
                        </xsl:if>
                    </xsl:for-each>
                </row>
            </xsl:for-each>
        </table>
    </xsl:variable>
    <!-- HGV ids that already exist in idp.data -->
    <xsl:variable name="hgv-ids">
        <xsl:sequence select="document($hgvId)/hgv:data/hgv:id"/>
    </xsl:variable>
    
    <xsl:template name="FODS">
        <xsl:message select="$INDEX"></xsl:message>
        <xsl:message select="$DATA"></xsl:message>
        <xsl:for-each-group select="$DATA//tei:row" group-by="concat(tei:cell[@name='tm'], tei:cell[@name='texLett'])">
            <xsl:message select="current-grouping-key()"></xsl:message>
            <xsl:message select="count(current-group())"></xsl:message>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template name="index">
    </xsl:template>
</xsl:stylesheet>