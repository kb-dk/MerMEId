#!/bin/sh

START=`pwd`

if [ -d "$START/build" ]
then
    rm -rf $START/build
fi

# deploying our xinclude capable preprocessor inside orbeon jsp area

mkdir -p "$START/build/orbeon/xforms-jsp/mei-form/"
mkdir -p "$START/build/orbeon/WEB-INF/resources/config/"
cd "$START/build/orbeon"
jar xf "$START/other-wars/orbeon.war"
cp "$START/orbeon/mei_form.jsp" xforms-jsp/mei-form/index.jsp
jar cf "$START/build/orbeon.war" .

cd $START

docker build -f Dockerfile .


