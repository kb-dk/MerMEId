#!/bin/sh

#
# Before building a distribution we need a very clean start
#

# edit this, in case you don't have maven in your path, but installed
# somewhere nonstandard
export PATH="$HOME/mvnsh/bin/":$PATH

#############
# No configurations below
#

if [ -d distro_tar ]; then
    rm -rf distro_tar
fi

if [ -d build_dir ]; then
    rm -rf build_dir
fi

rm -rf MerMEId mermeid.tar.bz2
ant clean

