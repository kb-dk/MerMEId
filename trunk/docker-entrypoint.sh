#!/bin/sh

ls -l $CATALINA_HOME/bin/
$CATALINA_HOME/bin/catalina.sh start
export ME=`hostname`
echo hostname = ${ME}
echo `host ${ME}`
ping localhost -c 3
ping ${ME} -c 3
cat /usr/local/tomcat/conf/server.xml

lwp-request -m GET http://${ME}:8080/
cd $WORKDIR
./load_exist.pl --user admin  --host-port localhost:8080 --load . --context /exist/rest/db/dcm --suffix xml,xq,xqm,css,xsl
