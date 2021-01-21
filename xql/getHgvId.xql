declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace hgv = "HGV";
declare option saxon:output "method=xml";
declare option saxon:output "indent=yes";

declare variable $hgvMetaEpiDoc as xs:string external;

(: java -Xms512m -Xmx1536m net.sf.saxon.Query -q:../getHgvId.xql > data/hgvId.xml hgvMetaEpiDoc=/Users/Admin/idp.data/master/HGV_meta_EpiDoc :)

<data xmlns="HGV">{
for $doc in collection(concat($hgvMetaEpiDoc, "?select=*.xml;recurse=yes"))
let $id := $doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='filename']
let $file := replace(document-uri($doc), '^.+(HGV\d+/\d+[a-z]*\.xml)$', '$1')
return <id file="{$file}">{data($id)}</id>
}</data>