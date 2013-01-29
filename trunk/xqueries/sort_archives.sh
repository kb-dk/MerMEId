#!/bin/sh

cd $*
FILES=`find . -name '*xml' -print`
for f in $FILES
do
    cp $f $f.bak
done
