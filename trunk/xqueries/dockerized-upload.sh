#!/bin/sh

XQ=/root/build
SECRETPASSWORD=secretpassword

if [ -d "$XQ" ]
then
    cd $XQ
    ./load_exist.pl --user admin --password $SECRETPASSWORD --suffix xconf              --load . --context /exist/rest/db/ --host-port localhost:8080 --target system/config/db/dcm/
    ./load_exist.pl --user admin --password $SECRETPASSWORD --suffix xml,xq,xqm,xsl,css --load . --context /exist/rest/db/ --host-port localhost:8080 
    GET http://admin:$SECRETPASSWORD@localhost:8080/exist/rest/db/xchmod.xq
fi
