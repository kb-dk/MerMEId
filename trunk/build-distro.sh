#!/bin/sh

#
# A shell script that builds the distribution or installation package
# 
# ./build-distro.sh -f distro \
#                   -m distro  \
#
# -f is the filter config file to be used
# -m is the mermeid config file to be used
#
# The strings distro, dev and test can currently be used, it is the last part
# of the file names in the local_config directory.
#

while getopts "f:m:" flag
do
  case $flag in
    f) F_FILE=$OPTARG; export F_FILE ;;
    m) M_FILE=$OPTARG; export M_FILE ;;
  esac
done

echo "We are about to build a $F_FILE filter and $M_FILE MerMEId"

if  [ ! -f "local_config/http_filter.xml_$F_FILE" ] || [ ! -f "local_config/mermeid_configuration.xml_$M_FILE" ] ; then  
    echo "No valid configuration"
    echo "usage: build-distro.sh -f filterconfiguration -m formconfiguration "
    exit 1
fi

rm mermeid.tar.bz2
rm -rf MerMEId ; mkdir MerMEId

cp "local_config/http_filter.xml_$F_FILE" filter/src/main/resources/http_filter.xml 
(cd filter ; ./run_java_doc.sh)
(cd filter ; ~/mvnsh/bin/mvn install)
cp filter/target/filter-1.0-SNAPSHOT.war MerMEId/filter.war
(cd filter ; ~/mvnsh/bin/mvn clean)

# We find everything, and greps away what we shouldn't distribute,
# beginning with ourselves

tar cf - `find . -type f -print | \
    grep -v build-distro.sh | \
    grep -v MerMEId | \
    grep -v ebook | \
    grep -v svn | \
    grep -v local_config | \
    grep -v cms `  | (cd MerMEId ; tar xvf - )


cp "local_config/mermeid_configuration.xml_$M_FILE" \
    MerMEId/mermeid/forms/mei/mermeid_configuration.xml

cp "local_config/standard_bibliography.xml_$M_FILE" \
    MerMEId/xqueries/library/standard_bibliography.xml


(cd MerMEId/mermeid ; jar cf ../editor.war .)
tar jcvf mermeid.tar.bz2 MerMEId

#
# $Id$
#




