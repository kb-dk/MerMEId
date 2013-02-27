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

export D_PATH='.'
export TAR='.'

if [ -d distro_tar ]; then
    rm -rf distro_tar
fi

if [ -d build_dir ]; then
    rm -rf build_dir
fi

rm "$TAR/mermeid.tar.bz2"

while getopts "f:m:d:t:" flag
do
  case $flag in
    f) F_FILE=$OPTARG; export F_FILE ;;
    m) M_FILE=$OPTARG; export M_FILE ;;
    d) D_PATH=$OPTARG; export D_PATH ;;
    t) TAR=$OPTARG; export TAR ;;
  esac
done

echo "We are about to build a $F_FILE filter and $M_FILE MerMEId in $D_PATH"

if [ ! -d "$TAR" ]; then
    mkdir -p $TAR
fi

#
# When we make the demo site, we also want to build the distro.  We build it
# in build_dir and store the content build it in distro_tar
#

if  [ ! -f "local_config/http_filter.xml_$F_FILE" ] || [ ! -f "local_config/mermeid_configuration.xml_$M_FILE" ] ; then  
    echo "No valid configuration"
    echo "usage: build-distro.sh -f filterconfiguration -m formconfiguration "
    exit 1
fi

if  [ "$M_FILE" = "demo" ]; then  
    ./build-distro.sh -m distro -f distro -d build_dir -t distro_tar
fi

mkdir -p "$D_PATH"
mkdir -p "$D_PATH/MerMEId"
mkdir -p "$TAR"

echo "I'm in"
echo `pwd`

cp "local_config/http_filter.xml_$F_FILE" filter/src/main/resources/http_filter.xml 
(cd filter ; ~/mvnsh/bin/mvn install)
(cd filter ; ./run_java_doc.sh)
cp filter/target/filter-1.0-SNAPSHOT.war "$D_PATH/MerMEId/filter.war"
(cd filter ; ~/mvnsh/bin/mvn clean)

# We find everything, and greps away what we shouldn't distribute,
# beginning with ourselves

echo "Collecting stuff in $D_PATH/MerMEId"

if  [ "$M_FILE" = "distro" ]; then  
    egrep_string="local_config/.*(demo|dev|prod|test)"
else
    egrep_string="local_config/.*distro"
fi

tar cv - `find . -type f -print | \
    grep  -v ebook | \
    grep  -v svn | \
    grep  -v distro_tar  | \
    grep  -v build_dir | \
    egrep -v "$egrep_string" | \
    grep  -v MerMEId | \
    grep  -v cms `  | (cd "$D_PATH/MerMEId" ; tar xvf - )

cp "local_config/mermeid_configuration.xml_$M_FILE" \
    "$D_PATH/MerMEId/mermeid/forms/mei/mermeid_configuration.xml"

cp "local_config/standard_bibliography.xml_$M_FILE" \
    "$D_PATH/MerMEId/xqueries/library/standard_bibliography.xml"

export CWDTAR=`pwd`/$TAR
(cd $D_PATH ; tar jcvf $CWDTAR/mermeid.tar.bz2 MerMEId)

#
# If we are building the demo, we actually started by building the distro
# (because it should be distributed through the demo. Sorry about this. We now
# copy the distro into the demo.
#
if  [ "$M_FILE" = "demo" ]; then  
    cp distro_tar/mermeid.tar.bz2 $D_PATH/MerMEId/mermeid
fi
(cd "$D_PATH/MerMEId/mermeid" ; jar cf ../editor.war .)

#
# $Id$
#




