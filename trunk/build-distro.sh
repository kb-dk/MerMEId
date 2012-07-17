#!/bin/sh

rm mermeid.tar.bz2
rm -rf MerMEId ; mkdir MerMEId

tar cvf - `find . -type f -print | grep -v MerMEId | grep -v svn | grep -v cms `  | (cd MerMEId ; tar xvf - )

tar jcvf mermeid.tar.bz2 MerMEId


