FROM  openjdk:8-jre

MAINTAINER Sigfrid Lundberg (slu@kb.dk)

# Environment

ENV TOMCAT_RELEASE=7  \
    TOMCAT_VERSION=7.0.69 \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    CATALINA_HOME=/usr/local/tomcat \
    PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:$CATALINA_HOME/bin:$PATH \
    CLASSPATH=/usr/share/java \
    HOME=/root \
    WORKDIR=/root/build/ \
    SYS=demo \
    JAVA_OPTS="-Xmx4096m" 

# Install runit 

RUN touch /etc/inittab

RUN apt-get update \
    && apt-get clean \
    && apt-get install -y runit \
    && mkdir -p /etc/service/tomcat 

COPY tomcat-run /etc/service/tomcat/run
RUN  chmod +x /etc/service/tomcat/run 

# Install Java 8 JDK, utilities and Tomcat

RUN apt-get remove --purge -y openjdk-8-jre-headless \
    && apt-get update \
    && apt-get clean \
    && apt-get upgrade -y \
    && apt-get install -y openjdk-8-jdk-headless tar wget apache2 sudo unzip vim git ant tzdata perl libwww-perl authbind libapache2-mod-jk \
    && apt-get clean

RUN cd /usr/local \
    && wget http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_RELEASE}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && tar -xzvf apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && rm -rf apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && mv apache-tomcat-${TOMCAT_VERSION} tomcat

# First you need to build MerMEId using ant, then this will work

RUN mkdir ${WORKDIR}/
RUN ls -l ${WORKDIR}/
COPY xqueries ${WORKDIR}
RUN ls -l ${WORKDIR}/
COPY filter/filter.war mermeid/editor.war ${CATALINA_HOME}/webapps/

# You have to build eXist DB yourself.

COPY other-wars/exist.war  other-wars/orbeon.war ${CATALINA_HOME}/webapps/

COPY runit-bootstrap /usr/sbin/runit-bootstrap
RUN chmod +x /usr/sbin/runit-bootstrap

CMD /usr/sbin/runit-bootstrap
# CMD ["runsvdir  -P /etc/service/"]

EXPOSE 8080








