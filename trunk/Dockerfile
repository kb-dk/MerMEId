FROM phusion/baseimage:0.10.0

#
# best run using build-docker-image.sh
#

ENV TOMCAT_RELEASE=8  \
    TOMCAT_VERSION=8.0.32 \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    CATALINA_HOME=/usr/local/tomcat \
    PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:$CATALINA_HOME/bin:$PATH \
    CLASSPATH=/usr/share/java \
    HOME=/root \
    WORKDIR=/root/build/ \
    XML_STORE=/home/xml-store \
    SYS=demo \
    JAVA_OPTS="-Xmx4096m"

#
# suppose I should cut away some unused stuff here
#

RUN apt-get update \
    && apt-get clean \
    && apt-get upgrade -y \
    && apt-get install -y openjdk-8-jdk-headless tar wget apache2 sudo zip unzip vim git ant tzdata perl libwww-perl authbind libapache2-mod-jk \
    && apt-get clean \
    && a2enmod proxy_http \
    && a2enmod proxy_ajp \
    && a2enmod headers


#
# want these to be persistent
#

VOLUME ["${CATALINA_HOME}/webapps"]

RUN cd /usr/local \
    && wget http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_RELEASE}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && tar -xzvf apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && cp -rf apache-tomcat-${TOMCAT_VERSION}/* tomcat \
    && rm -rf apache-tomcat-${TOMCAT_VERSION}*

# 
# Enable sshd by uncommenting the following. Can be nice for debugging and maintenance.
#
# RUN rm -f /etc/service/sshd/down
# COPY id_rsa.pub /tmp/your_key.pub
# RUN cat /tmp/your_key.pub >> /root/.ssh/authorized_keys && rm -f /tmp/your_key.pub
#

#
# Setting up Apache2 as a daemon
#

RUN mkdir -p /etc/apache2/sites-enabled/
COPY apache-httpd/conf-devel.conf /etc/apache2/sites-enabled/conf-devel.conf

#
# note that editor is the one only Apache2 user, and s/he has password editor
# 

RUN mkdir -p ${XML_STORE} \
    && htpasswd -bc /home/xml-store/passwordfile editor editor
RUN mkdir -p /etc/service/apache2
COPY docker-daemons/apache2.sh /etc/service/apache2/run
RUN chmod +x /etc/service/apache2/run

#
# Preparing tomcat
# 

RUN mkdir /etc/service/tomcat
COPY docker-daemons/tomcat.sh /etc/service/tomcat/run
RUN chmod +x /etc/service/tomcat/run

#
# Installing all of MerMEId.
# Note that you have to build editor.war yourself,
# and that orbeon and exist has to be hacked a bit before we run this.
# see build-docker-image.sh
#
# You almost certainly want to change the passwords set in the tomcat-users.xml
#

ADD mermeid/editor.war other-wars/exist.war  build/orbeon.war  ${CATALINA_HOME}/webapps/
COPY apache-tomcat/tomcat-users.xml  ${CATALINA_HOME}/conf/tomcat-users.xml

# Use baseimage-docker's init system.

CMD ["/sbin/my_init"]

