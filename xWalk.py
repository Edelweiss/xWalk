#!/usr/bin/env python

import os, sys, logging

def xWalk():
    execute('java -Xms512m -Xmx1536m net.sf.saxon.Query -q:xql/getHgvId.xql > data/hgvId.xml hgvMetaEpiDoc=../data/master/HGV_meta_EpiDoc')
    execute('java -Xms512m -Xmx1536m net.sf.saxon.Query -q:xql/getPlaceRef.xql > data/placeRef.xml hgvMetaEpiDoc=../data/master/HGV_meta_EpiDoc')
    print '---------------- Updating HGV ids and places refs complete ----------------'

    execute('rm -fr ' + PATH['SPLIT'])
    execute('rm -fr ' + PATH['INTER'])
    print '---------------- Clearing complete ----------------'

    execute('mkdir ' + PATH['SPLIT'])
    execute('mkdir ' + PATH['INTER'])
    execute('java -Xms512m -Xmx1536m net.sf.saxon.Transform -xsl:xsl/divide.xsl -o:' + PATH['SPLIT_OUTPUT'] + ' -s:' + PATH['INPUT'] + ' hgvMetaEpiDoc=../data/master/HGV_meta_EpiDoc')
    print '---------------- Splitting complete ----------------'

    for f in os.listdir(PATH['SPLIT']):
        if not os.path.isdir(f) and not '.svn' in f and not '.git' in f:
            inFile = PATH['SPLIT'] + '/' + f # e.g. data/split/HGV27.xml
            execute('java -Xmx1023m net.sf.saxon.Transform -o:data/intermediate/' + f + ' -s:' + inFile + ' -xsl:' + PATH['XSLT'] + ' process=' + PROCESS)
    print '---------------- EpiDoc conversion complete ----------------'    

def execute(command):
    print '>> ' + command
    os.system(command)

PROCESS = 'all'
OK = 1
PATH = {
  'XSLT'         : 'xsl/converter.xsl',
  'SPLIT'        : 'data/split',
  'INTER'        : 'data/intermediate',
  'INPUT'        : 'data/HGV.xml',
  'SPLIT_OUTPUT' : 'data/split/zzz.xml',
}

if len(sys.argv) > 1:
  if sys.argv[1] == 'new':
    PROCESS = 'new'
  elif sys.argv[1] == 'modified':
    PROCESS = 'modified'
  else:
    OK = 0

if OK:
  xWalk()
else:
  print 'xWalk.py [new|modified|all] (defaults to all)'
