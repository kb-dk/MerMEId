#########################
# multi stage Dockerfile
# 1. set up the build environment and build the expath-package
# 2. run the eXist-db
#########################
FROM openjdk:8-jdk as builder
LABEL maintainer="Peter Stadler,Omar Siam"

ENV BUILD_HOME="/opt/builder"

# installing Apache Ant
RUN apt-get install -y --no-install-recommends apt-transport-https \
    && apt-get update \
    && apt-get install -y --no-install-recommends ant curl zip unzip patch git

# Get and setup orbeon
RUN curl -OL https://github.com/orbeon/orbeon-forms/releases/download/tag-release-2018.2.1-ce/orbeon-2018.2.1.201902072242-CE.zip
COPY orbeon-form-runner.jar /form-runner.jar
RUN unzip orbeon-*.zip && rm orbeon-*.zip && mv orbeon-* orbeon-dist &&\
    mkdir orbeon && cd orbeon && unzip ../orbeon-dist/orbeon.war &&\
    rm -rf xforms-jsp &&\
    rm -rf WEB-INF/resources/apps/context WEB-INF/resources/apps/home WEB-INF/resources/apps/sandbox-transformations\
        WEB-INF/resources/apps/xforms-[befs]* &&\
    rm -rf WEB-INF/resources/forms/orbeon/controls &&\
    rm -rf WEB-INF/resources/forms/orbeon/dmv-14  &&\
    rm -rf WEB-INF/lib/orbeon-form-builder.jar &&\
    rm -rf WEB-INF/lib/exist-*.jar &&\
    rm -rf WEB-INF/lib/slf4j-*.jar &&\
    rm -rf WEB-INF/exist-data &&\
    rm  WEB-INF/exist-conf.xml WEB-INF/jboss-scanning.xml WEB-INF/liferay-display.xml WEB-INF/portlet.xml \
        WEB-INF/jboss-web.xml WEB-INF/liferay-portlet.xml WEB-INF/sun-web.xml WEB-INF/weblogic.xml &&\
    cd /form-runner.jar && zip -u /orbeon/WEB-INF/lib/orbeon-form-runner.jar &&\
    cd .. && mkdir orbeon-xforms-filter && cd orbeon-xforms-filter && unzip ../orbeon-dist/orbeon-xforms-filter.war
COPY orbeon-web.xml.patch /
RUN cd orbeon && patch -p0 < /orbeon-web.xml.patch && rm -f WEB-INF/web.xml.orig

# now building the main App
WORKDIR ${BUILD_HOME}
COPY . .
RUN ant

#########################
# Now running the eXist-db
# and adding our freshly built xar-package
# as well as orbeon and the orbeon xforms filter
#########################
FROM existdb/existdb:5.2.0

ENV CLASSPATH=/exist/lib/exist.uber.jar:/exist/lib/orbeon-xforms-filter.jar

COPY --from=builder /opt/builder/build/*.xar ${EXIST_HOME}/autodeploy/
COPY --from=builder /orbeon ${EXIST_HOME}/etc/jetty/webapps/orbeon
COPY jetty-exist-additional-config/etc/jetty/webapps/*.xml jetty-exist-additional-config/etc/jetty/webapps/*.properties ${EXIST_HOME}/etc/jetty/webapps/
COPY jetty-exist-additional-config/etc/jetty/webapps/portal/WEB-INF/* ${EXIST_HOME}/etc/jetty/webapps/portal/WEB-INF/
COPY --from=builder /orbeon-xforms-filter/WEB-INF/lib/orbeon-xforms-filter.jar ${EXIST_HOME}/lib/
COPY jetty-exist-additional-config/etc/webapp/WEB-INF/*.xml ${EXIST_HOME}/etc/webapp/WEB-INF/
COPY orbeon-additional-config/WEB-INF/resources/config/* ${EXIST_HOME}/etc/jetty/webapps/orbeon/WEB-INF/resources/config/
RUN ["java", "-cp", "/exist/lib/exist.uber.jar", "net.sf.saxon.Transform", "-s:/exist/etc/log4j2.xml", "-xsl:/exist/etc/jetty/webapps/orbeon/WEB-INF/resources/config/log4j2-patch.xsl", "-o:/exist/etc/log4j2.xml"]