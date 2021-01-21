import module namespace functx = "http://www.functx.com" at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace papy = "Papyrillio";
declare option saxon:output "method=xml";
declare option saxon:output "indent=yes";

declare variable $hgvMetaEpiDoc as xs:string external;

(: java -Xms512m -Xmx1536m net.sf.saxon.Query -q:../getPlaceRef.xql > data/placeRef.xml hgvMetaEpiDoc=/Users/Admin/idp.data/master/HGV_meta_EpiDoc :)

let $newline := '&#13;&#10;'
return <data xmlns="Papyrillio">{
  for $placeName in functx:distinct-nodes(collection(concat($hgvMetaEpiDoc, "?select=*.xml;recurse=yes"))/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:provenance/tei:p/tei:placeName[@ref])
  order by $placeName/text()
  return <place type="{$placeName/@type}" ref="{$placeName/@ref}" name="{$placeName/text()}">{string($placeName)}</place>
}</data>