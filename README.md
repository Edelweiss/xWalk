# xWalk

## ⚙ setup

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

## ⚙ ⚙ invoke script

place FODS file in the data directory of the xWalk project and run script

* download file as CSV from Google Sheets
* open CVS with LibreOffice
* make sure the tab containing the data is called ```hgv```
* save as FODS file
* move FODS file to xWalk/data/HGV.fods
* run xWalk script ```./xWalk.sh```

```bash
./xWalk.sh new
./xWalk.sh modified
./xWalk.sh all
```
(defaults to ```all```)

The xWalk script peforms the following actions, which can also be started manually:

(1) update git repository branches papyri/master and papyri/xWalk

```bash
cd xWalk
cd data/idp.data/papyri/master
git fetch
git merge papyri/master
git status

cd ../xWalk
git clean -fd
git checkout .
git fetch
git merge papyri/xwalk
git merge papyri/master
git push papyri xwalk_papy:xwalk
git status
```

(2) get HGV ids

```bash
cd xWalk
java -Xms512m -Xmx1536m net.sf.saxon.Query -q:xql/getHgvId.xql > data/hgvId.xml hgvMetaEpiDoc=../data/idp.data/papyri/master/HGV_meta_EpiDoc
```

(3) get HGV geo refs

```bash
java -Xms512m -Xmx1536m net.sf.saxon.Query -q:xql/getPlaceRef.xql > data/placeRef.xml hgvMetaEpiDoc=../data/idp.data/papyri/master/HGV_meta_EpiDoc
```

(4) call transformation script

```bash
java -Xms512m -Xmx1536m net.sf.saxon.Transform -l -o:data/HGV.xml -it:FODS -xsl:xsl/xWalk.xsl PROCESS=new
java -Xms512m -Xmx1536m net.sf.saxon.Transform -l -o:data/HGV.xml -it:FODS -xsl:xsl/xWalk.xsl PROCESS=modified
java -Xms512m -Xmx1536m net.sf.saxon.Transform -l -o:data/HGV.xml -it:FODS -xsl:xsl/xWalk.xsl PROCESS=all
```
