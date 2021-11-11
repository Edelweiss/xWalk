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

    <xsl:include href="epidoc.xsl"/>
    <xsl:output method="xml" media-type="text/xml" />

    <!-- parameters -->

    <xsl:param name="fileRepository" select="'../data/master'"  as="xs:string"/> <!-- path to readonly idp.data repository OXYGEN!!! -->
    <xsl:param name="fileMentionedDates" select="'../data/master/HGV_metadata/XML_dump/MentionedDates.xml'"  as="xs:string"/> <!-- mentioned dates lookup file -->
    <xsl:param name="fileNomeList" select="'../data/master/HGV_metadata/XML_dump/nomeList.xml'"  as="xs:string"/> <!-- nome list lookup file -->
    <xsl:param name="outputPath" select="'../xwalk/HGV_meta_EpiDoc'"  as="xs:string"/> <!-- output path on server -->
    <xsl:param name="placeRef" select="'../data/placeRef.xml'"  as="xs:string"/>
    <xsl:param name="hgvId" select="'../data/hgvId.xml'"  as="xs:string"/>


    <xsl:param name="PROCESS" select="'all'"/> <!-- new|modified|all -->
    <xsl:param name="IDP_MASTER" select="'../data/master'"/>
    <xsl:param name="FODS_TABLE" select="'hgv'"/>
    <xsl:param name="FODS_DOCUMENT" select="'../data/HGV.fods'"/>
    <xsl:param name="HEADER_LINE" select="3"/>
    <xsl:param name="DATA_LINE" select="5"/>

    <xsl:variable name="HGV" select="doc($FODS_DOCUMENT)"/>
    <xsl:variable name="INDEX">
        <list>
            <xsl:for-each select="$HGV//table:table[@table:name=$FODS_TABLE]/table:table-row[$HEADER_LINE]/table:table-cell">
                <xsl:if test="string(.)">
                    <item column="{position() + sum(preceding-sibling::table:table-cell/@table:number-columns-repeated) - count(preceding-sibling::table:table-cell[number(@table:number-columns-repeated) &gt; 1])}" name="{normalize-space(.)}"/>
                </xsl:if>
            </xsl:for-each>
        </list>
    </xsl:variable>
    <xsl:variable name="DATA">
        <table>
            <xsl:for-each select="$HGV//table:table[@table:name=$FODS_TABLE]/table:table-row[position() &gt;= $DATA_LINE]">
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
        <xsl:for-each select="$INDEX//tei:item">
            <xsl:message select="concat(@column, '    ', @name)"/>
        </xsl:for-each>
        <!--xsl:message select="$DATA"/-->
        <xsl:for-each-group select="$DATA//tei:row" group-by="tei:cell[@name='hgv_id']">
            <xsl:variable name="hgv" select="current-grouping-key()"/>
            <xsl:variable name="idAlreadyExists" select="$hgv-ids/hgv:id[text() = $hgv]/@file" />
            <xsl:if test="matches($hgv, '^\d+[a-z]*[XYZ]?$')">
                <xsl:if test="($PROCESS = 'all') or ($PROCESS = 'new' and not($idAlreadyExists)) or ($PROCESS = 'modified' and $idAlreadyExists)">

                    <xsl:variable name="outputFile" select="concat('../data/xwalk/', papy:hgvFilePath($hgv))"/>
                    
                    
                    <xsl:message select="concat($hgv, ' / ', if($idAlreadyExists)then 'modified' else 'new')"></xsl:message>
                    <xsl:message select="$outputFile"></xsl:message>
                    <xsl:message select="count(current-group())"></xsl:message>
                    <!--xsl:result-document href="{$outputFile}">
                    
                </xsl:result-document-->
                    <xsl:call-template name="papy:hgvEpidoc">
                        <xsl:with-param name="hgv" select="$hgv"/>
                        <xsl:with-param name="data" select="current-group()"/>
                        <xsl:with-param name="originalRevisionDesc" select="if ($idAlreadyExists) then doc(concat($IDP_MASTER, '/HGV_meta_EpiDoc/', $idAlreadyExists))//tei:revisionDesc else () "/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template name="index">
    </xsl:template>
</xsl:stylesheet>