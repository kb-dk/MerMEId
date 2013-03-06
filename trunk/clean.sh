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

rm -rf build_dir distro_tar MerMEId mermeid.tar.bz2
(cd filter ; mvn clean)
