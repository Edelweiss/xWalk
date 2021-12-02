#!/bin/sh

# get parameters
mode="all"
if [ $# -gt 0 ]
then
mode="$*"
fi

echo 'Update git repositories...'
# update date idp.data master
#cd data/idp.data/papyri/master
#git fetch
#git merge papyri/master
#git status

# update date idp.data xWalk
#cd ../xwalk
#git clean -fd
#git checkout .
#git fetch
#git merge papyri/xwalk
#git merge papyri/master
#git push papyri xwalk_papy:xwalk
#git status
echo '................'

# fetch hgv id
echo 'Fetch HGV ids...'
#java -Xms512m -Xmx1536m net.sf.saxon.Query -q:xql/getHgvId.xql > data/hgvId.xml hgvMetaEpiDoc=../data/idp.data/papyri/master/HGV_meta_EpiDoc
echo '................'

# fetch geo refs
echo 'Fetch geo references...'
#java -Xms512m -Xmx1536m net.sf.saxon.Query -q:xql/getPlaceRef.xql > data/placeRef.xml hgvMetaEpiDoc=../data/idp.data/papyri/master/HGV_meta_EpiDoc
echo '................'

# run xWalk
echo "Xwalk $mode data to EpiDoc..."
java -Xms512m -Xmx1536m net.sf.saxon.Transform -l -o:data/HGV.xml -it:FODS -xsl:xsl/xWalk.xsl PROCESS=$mode
echo '................'

exit 0
