#!/bin/sh

START=`pwd`

if [ -d "$START/build" ]
then
    rm -rf $START/build
fi

# Create the WAR files we need
# Starting with going for XSLT 1.0 in eXist

mkdir -p "$START/build/exist"
cd "$START/build/exist"
jar xf "$START/other-wars/exist.war"
cp "$START/other-wars/exist-conf.xml" WEB-INF/conf.xml
jar cf "$START/build/exist.war" .

# Then adjusting orbeon to our needs, including deploying our 
# xinclude capable preprocessor inside orbeon jsp area

mkdir -p "$START/build/orbeon/xforms-jsp/mei-form/"
mkdir -p "$START/build/orbeon/WEB-INF/resources/config/"
cd "$START/build/orbeon"
jar xf "$START/other-wars/orbeon.war"
cp "$START/orbeon/mei_form.jsp" xforms-jsp/mei-form/index.jsp
cp "$START/orbeon/properties-local.xml" WEB-INF/resources/config/
jar cf "$START/build/orbeon.war" .

cd $START

docker build -f Dockerfile .


