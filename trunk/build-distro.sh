#!/bin/sh

# A shell script that builds the distribution or installation package
# 
# ./build-distro.sh -f distro \
#                   -m distro  \
#
# -f is the filter config file to be used
# -m is the mermeid config file to be used
#

while getopts "f:m:" flag
do
  case $flag in
    f) F_FILE=$OPTARG; export F_FILE ;;
    m) M_FILE=$OPTARG; export M_FILE ;;
  esac
done

echo "We are about to build a $F_FILE filter and $M_FILE MerMEId"

if [ -f "local_config/http_filter.xml_$F_FILE" && -f "local_config/mermeid_configuration.xml_$M_FILE" ] ; then
    echo "No valid configuration"
    exit 1
fi

rm mermeid.tar.bz2
rm -rf MerMEId ; mkdir MerMEId

tar cf - `find . -type f -print | \
    grep -v MerMEId | \
    grep -v svn | \
    grep -v local_config | \
    grep -v cms `  | (cd MerMEId ; tar xvf - )


(cd MerMEId/mermeid ; jar cf ../editor.war .)
tar jcvf mermeid.tar.bz2 MerMEId

#
# $Id$
#




