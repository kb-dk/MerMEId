FROM phusion/baseimage:0.10.0

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

RUN apt-get update \
    && apt-get clean \
    && apt-get upgrade -y \
    && apt-get install -y openjdk-8-jdk-headless tar wget apache2 sudo unzip vim git ant tzdata perl libwww-perl authbind libapache2-mod-jk \
    && apt-get clean

# Enable sshd
RUN rm -f /etc/service/sshd/down
COPY id_rsa.pub /tmp/your_key.pub
RUN cat /tmp/your_key.pub >> /root/.ssh/authorized_keys && rm -f /tmp/your_key.pub

# Setting up Apache2 as a daemon

RUN mkdir /etc/service/apache2
COPY docker-daemons/apache2.sh /etc/service/apache2/run
RUN chmod +x /etc/service/apache2/run

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

