# xWalk

## CSV

### ⚙ setup

needs a soft link to the xslt folder of the [papyX](https://github.com/Edelweiss/papyX) project in the root directory


```bash
cd xWalk
ln -s ~/projects/papyX/xslt papyX
```

## invoke script

update git repositories XXXX

```bash
git fetch
git merge
```

get HGV ids, get geo refs, call transformation script

```bash
java -Xms512m -Xmx1536m net.sf.saxon.Query -q:xql/getHgvId.xql > data/hgvId.xml hgvMetaEpiDoc=../data/master/HGV_meta_EpiDoc
java -Xms512m -Xmx1536m net.sf.saxon.Query -q:xql/getPlaceRef.xql > data/placeRef.xml hgvMetaEpiDoc=../data/master/HGV_meta_EpiDoc
java -Xms512m -Xmx1536m net.sf.saxon.Transform -l -o:HGV.xml -it:FODS -xsl:xsl/xWalk.xsl HGV=data/HGV.fods
```
