#!/bin/bash

pushd $WORKDIR
./load_exist.pl --user admin --password 'ourpassword' --host-port localhost:8080 --load . --context /exist/rest/db/dcm --suffix xml,xq,xqm,css,xsl
popd
