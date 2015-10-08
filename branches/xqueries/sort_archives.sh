#!/bin/sh

XSL="../sort-archives.xsl"
cd $*
FILES=`find . -name '*xml' -print`
for f in $FILES
do
    cp $f $f.bak
    xsltproc $XSL $f.bak > $f 
done
