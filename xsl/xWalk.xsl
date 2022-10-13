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

java -Xms512m -Xmx1536m net.sf.saxon.Transform -l -o:data/HGV.xml -it:FODS -xsl:xsl/xWalk.xsl PROCESS=all > xWalk 2>&1

-->
    <xsl:include href="../papyX/helper.xsl"/>
    
    <xsl:include href="epidoc.xsl"/>
    <xsl:output method="xml" media-type="text/xml" />
    
    <!-- parameters -->
    
    <!--xsl:param name="fileRepository" select="'../data/idp.data/papyri/master'"  as="xs:string"/--> <!-- path to readonly idp.data repository OXYGEN!!! -->
    <!--xsl:param name="fileMentionedDates" select="'../data/idp.data/papyri/master/HGV_metadata/XML_dump/MentionedDates.xml'"  as="xs:string"/--> <!-- mentioned dates lookup file -->
    <!--xsl:param name="outputPath" select="'../xwalk/HGV_meta_EpiDoc'"  as="xs:string"/--> <!-- output path on server -->
    
    <xsl:param name="PROCESS" select="'all'"/> <!-- new|modified|all -->
    <xsl:param name="DATA_DIRECTORY" select="'../data'"/>
    <xsl:param name="IDP_MASTER" select="concat($DATA_DIRECTORY, '/idp.data/papyri/master')"/>
    <xsl:param name="IDP_XWALK" select="concat($DATA_DIRECTORY, '/idp.data/papyri/xWalk')"/>
    <xsl:param name="FODS_DOCUMENT" select="concat($DATA_DIRECTORY, '/HGV.fods')"/>
    <xsl:param name="FODS_TABLE" select="'HGV'"/>
    
    <xsl:param name="fileNomeList" select="concat($IDP_MASTER, '/HGV_metadata/XML_dump/nomeList.xml')"  as="xs:string"/> <!-- nome list lookup file -->
    <xsl:param name="placeRef" select="'../data/placeRef.xml'"  as="xs:string"/>
    <xsl:param name="hgvId" select="'../data/hgvId.xml'"  as="xs:string"/>
    
    <xsl:variable name="HGV" select="doc($FODS_DOCUMENT)"/>
    
    <xsl:variable name="HEADER_LINE" as="xs:integer">
        <xsl:value-of select="count($HGV//table:table[@table:name=$FODS_TABLE]//table:table-cell[normalize-space(.) = 'hgv_id']/ancestor::table:table-row/preceding-sibling::table:table-row) + 1"/>
    </xsl:variable>
    
    <xsl:variable name="DATA_LINE" as="xs:integer">
        <xsl:value-of select="$HEADER_LINE + 1"/>
    </xsl:variable>
    
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
    
    <xsl:template name="TEST">
        <xsl:message select="'––––'"/>
        <xsl:message select="concat('header line:', '&#09;', $HEADER_LINE)"/>
        <xsl:message select="concat('data line:', '&#09;', $DATA_LINE)"/>
        <xsl:message select="'––––'"/>
        <xsl:for-each select="$INDEX//tei:item">
            <xsl:message select="concat(@column, '&#09;', @name)"/>
        </xsl:for-each>
        <xsl:message select="'––––'"/>
        <!--xsl:message select="$DATA"/-->
    </xsl:template>
    
    <xsl:template name="FODS">
        <xsl:call-template name="TEST"/>
        <xsl:for-each-group select="$DATA//tei:row" group-by="tei:cell[@name='hgv_id']">
            <xsl:variable name="hgv" select="current-grouping-key()"/>
            <xsl:variable name="idAlreadyExists" select="$hgv-ids/hgv:id[text() = $hgv]/@file" />
            <xsl:if test="matches($hgv, '^\d+[a-z]*[XYZ]?$')">
                <xsl:if test="($PROCESS = 'all') or ($PROCESS = 'new' and not($idAlreadyExists)) or ($PROCESS = 'modified' and $idAlreadyExists)">
                    
                    <xsl:variable name="outputFile" select="concat($IDP_XWALK, '/', papy:hgvFilePath($hgv))"/>
                    <xsl:variable name="status" select="if($idAlreadyExists)then 'modified' else 'new'"/>
                    
                    <xsl:message select="concat($hgv, ' / ', $status)"></xsl:message>
                    <xsl:message select="$outputFile"></xsl:message>
                    <xsl:message select="count(current-group())"></xsl:message>
                    <xsl:result-document href="{$outputFile}">
                        <xsl:call-template name="papy:hgvEpidoc">
                            <xsl:with-param name="hgv" select="$hgv"/>
                            <xsl:with-param name="data" select="current-group()"/>
                            <xsl:with-param name="originalRevisionDesc" select="if ($idAlreadyExists) then doc(concat($IDP_MASTER, '/HGV_meta_EpiDoc/', $idAlreadyExists))//tei:revisionDesc else () "/>
                        </xsl:call-template>
                    </xsl:result-document>
                </xsl:if>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>
</xsl:stylesheet>