import module namespace functx = "http://www.functx.com" at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace papy = "Papyrillio";
declare option saxon:output "method=xml";
declare option saxon:output "indent=yes";

declare variable $hgvMetaEpiDoc as xs:string external;

(: java -Xms512m -Xmx1536m net.sf.saxon.Query -q:xql/getPlaceRef_html.xql > html/placeRef.html hgvMetaEpiDoc=../data/idp.data/papyri/master/HGV_meta_EpiDoc :)

let $newline := '&#13;&#10;'
return
<html lang="de">
<head>
  <meta charset="utf-8"/>
  <title>Places</title>

</head>
<body><h1>Places and Places</h1><p>{format-date(current-date(), "[D1].[M1].[Y0001]")}</p>{
  for $placeName in collection(concat($hgvMetaEpiDoc, "/?select=*.xml;recurse=yes"))/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:provenance/tei:p/tei:placeName[@ref]
  let $groupKey := concat($placeName/@type, $placeName/@subtype)
  group by $groupKey
  order by $groupKey
  return
    (element h2 { concat($placeName[1]/@type, " ", $placeName[1]/@subtype) },
    element ul {
      for $place in $placeName
        group by $place
        order by $place
        return element li {string($place[1])}
    })
}</body>
</html>