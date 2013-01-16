#!/bin/sh

export CLASSPATH=`ls target/filter-1.0-SNAPSHOT/WEB-INF/lib/*jar | perl -ne 'chomp; print "$_:";' | sed 's/:$//'`


javadoc \
    -sourcepath src/main/java/ \
    -d          apidoc  \
    -link       http://hc.apache.org/httpclient-3.x/apidocs/ \
    -link       http://docs.oracle.com/javase/6/docs/api/ \
    -link       http://docs.oracle.com/javaee/6/api/ \
    -link       http://logging.apache.org/log4j/1.2/apidocs/ \
    -header     "MerMEId editor package" \
    -doctitle   "xml_store filter application" \
    dk.kb.mermeid.filter
