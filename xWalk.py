#!/usr/bin/env python

import os, sys, logging

## --- run() preparations and ignition of recursion

def run():
    #execute('java -Xms512m -Xmx1536m net.sf.saxon.Query -q:xql/getHgvId.xql > data/hgvId.xml hgvMetaEpiDoc=../data/master/HGV_meta_EpiDoc')
    #execute('java -Xms512m -Xmx1536m net.sf.saxon.Query -q:xql/getPlaceRef.xql > data/placeRef.xml hgvMetaEpiDoc=../data/master/HGV_meta_EpiDoc')
    #print '---------------- Updating HGV ids and places refs complete ----------------'

    #execute('rm -fr ' + PATH['SPLIT'])
    #print '---------------- Clearing complete ----------------'

    #execute('mkdir ' + PATH['SPLIT'])
    #execute('java -Xms512m -Xmx1536m net.sf.saxon.Transform -xsl:xsl/divide.xsl -o:' + PATH['SPLIT_OUTPUT'] + ' -s:' + PATH['INPUT'] + ' hgvMetaEpiDoc=../data/master/HGV_meta_EpiDoc')
    #print '---------------- Splitting complete ----------------'

    walk(PATH['SPLIT'], PATH['CLEAN_OUTPUT'], 'xsl/converter.xsl')
    print '---------------- EpiDoc conversion complete ----------------'

## --- walk() recursively walks through a folder and calls do() on each file excluding .svn folders. With XSLT

def walk(inDir, outDir, xslt):

    if not os.path.isdir(outDir):
        os.mkdir(outDir, 0776)

    inDir = prune_trailing_slash(inDir)
    outDir = prune_trailing_slash(outDir)

    for f in os.listdir(inDir):
        inFile = inDir + '/' + f # e.g. data/split/HGV27.xml
        outFile = outDir + '/' + f # e.g. data/xwalk/HGV_meta_EpiDoc/HGV27.xml

        if not os.path.isdir(f) and not '.svn' in f and not '.git' in f:
            do(inFile, outFile, outDir, xslt)
        #elif os.path.isdir(f):
        #    walk(inFile, outFile, xslt)

## --- do() applies a xslt to a file. level = how many levels to go up to find lib (saxon)

def do(inFile, outFile, outDir, xslt):
    #execute('java -jar -Xmx1023m ' + levels + 'lib/saxon9.jar -o ' + outFile + ' ' + inFile + ' ' + xslt + ' process=' + PROCESS)
    execute('java -Xmx1023m net.sf.saxon.Transform -o:' + outFile + ' -s:' + inFile + ' -xsl:' + xslt + ' process=' + PROCESS)
    #execute('java -jar -Xmx1023m ' + levels + 'lib/saxon9ee.jar -o:' + outFile + ' -s:' + inFile + ' -xsl:' + xslt + ' process=' + PROCESS)
    #execute('java -Xmx1023m net.sf.saxon.Transform -o:' + outFile + ' -s:' + inFile + ' -xsl:' + xslt + ' process=' + PROCESS)

def execute(command):
    print '>> ' + command
    os.system(command)

def prune_trailing_slash(path):
    if path[len(path) - 1] == '/' or path[len(path) - 1] == '\\':
        path = path[:len(path)-1]
    return path

#def is_regular(file):
#    if not os.path.isdir(file) and not '.svn' in file and not '.git' in file:
#        return 1
#    else:
#        return 0


PROCESS = 'all'
OK = 1
PATH = {
  'SPLIT'        : 'data/split',
  'INPUT'        : 'data/HGV.xml',
  'SPLIT_OUTPUT' : 'data/split/zzz.xml',
  'CLEAN_OUTPUT' : 'data/xwalk/HGV_meta_EpiDoc'
}

if len(sys.argv) > 1:
  if sys.argv[1] == 'new':
    PROCESS = 'new'
  elif sys.argv[1] == 'modified':
    PROCESS = 'modified'
  else:
    OK = 0

if OK:
  run()
else:
  print 'xWalk.py [new|modified|all] (defaults to all)'