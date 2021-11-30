# xWalk

## CSV

### ⚙ setup


* You need…
  * GIT
  * Java / Saxon (net.sf.saxon.Transform and net.sf.saxon.Query)

Clone project from [xWalk repository](git@github.com:Edelweiss/xWalk.git) on github

* inside xWalk’s project folder create a new directory named `data` and therein an idp.data folder with a hierarchical order reflecting host (e.g. papyri or edelweiss) and branch (e.g. master and xwalk) (`~/projects/xWalk/data/idp.data`)
  * `idp.data`
    * `papyri`
      * `master` (papyri’s master branch of the ipd.data repository)
      * `xwalk` (papyri’s xwalk branch of the ipd.data repository)
  * HGV FileMaker dumps that are to be xWalked also go to the project’s `data` folder (`~/projects/xWalk/data/HGV.xml`)


needs a soft link to the xslt folder of the [papyX](https://github.com/Edelweiss/papyX) project in the root directory


```bash
cd xWalk
ln -s ~/projects/papyX/xslt papyX
mkdir data
cd data
ln -s ~/data/idp.data

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
