

[MerMEId](../README.md) | [Source code](./README.md) | [Install](INSTALL.md) | [Using Docker](USING_DOCKER.md)

# Or six steps towards a MerMEId of you own using Docker 

This is only partly an alternative to the usual [installation](INSTALL.md) procedure.

1. [Ensure that you have eXist DB and Orbeon FORMS](#1-ensure-that-you-have-exist-db-and-orbeon-forms)
2. [Configure Form and Database](#2-configure-form-and-database)
3. [Build MerMEId](#3-build-mermeid)
4. [Configure Apache](#4-configure-apache)
5. [Make docker image](#5-make-docker-image)
6. [Install database](#6-install-database)
7. [Final checks](#7-final-checks)

## 1. Ensure that you have eXist DB and Orbeon FORMS

* orbeon.war [see INSTALL.md](INSTALL.md#4-install-orbeon)
* exist.war [see INSTALL.md](INSTALL.md#3-install-exist-db)

During traditional installation they should go to your application
server/servlet container. Using Docker, you just put them into
[./trunk/other-wars](./other-wars) and the rest is catered for by the
scripting.

## 2. Configure Form and Database

* [Configure MerMEId Form](INSTALL.md#5-configure-mermeid-form)
* [Configure eXist database](INSTALL.md#6-configure-database)

Here you have to choose the password of the eXist DB. You will need
that later. The configuration is identical. 

## 3. Build MerMEId

For example

```
 ant -Dwebapp.instance=docker

```
## 4. Configure Apache

Please take a look at the sections 

* "Setting up Apache2 as a daemon" and 
* "note that editor is the one only Apache2 user"

in the [Dockerfile](./Dockerfile)

It isn't necessary to modify the code there to run MerMEId, but you
must do so if you want to have more than one editor user, or if you
want change the security settings. [See INSTALL.md](./INSTALL.md#more-httpd).
    						
## 5. Make docker image

If you are a seasoned Docker user you might want to review the
[Dockerfile](./Dockerfile) before building. One thing you might want
to uncomment the section about sshd. It can be nice to be able to log
on to the container.

Now you should be able to everything in one go by running the shell
script. It does a little more than just running a docker build.

[./build-docker-image.sh](./trunk/build-docker-image.sh)
    						
If your docker behaves like mine, it would be possible to run it using

```
 docker run --name mermeid   <docker image ID>

```    						

and everything will run on a local IP 172.17.0.2. The eXist dashboard should be on

http://172.17.0.2:8080/exist/apps/dashboard/index.html

Here you should set the password for the admin user of the
database.[You have already decided that. See
above](#2-configure-form-and-database). There is a paragraph on this in the [INSTALL.md](INSTALL.md#exist-db-password)


There is one area of the container's file system which is persistent,
namely the Tomcat webapps area. Note

```
VOLUME ["${CATALINA_HOME}/webapps"]

```

Inside Docker, this evaluates to /usr/local/tomcat/webapps. The way
Docker works by default, the volumes used will be found in

```
/var/lib/docker/volumes/

``` 

on your server. Inside there will be very long directory names (64
bytes long). **If you ensure that Docker's volumes directory is under backup,
you should be safe.**

### Check

List directory of the docker volumes

```
ls -l /var/lib/docker/volumes/*/_data/ 

```

should give something like

```
drwxr-xr-x 12 root root      4096 okt 24 11:38 editor
-rw-rw-r--  1 root root  15763888 okt 24 11:36 editor.war
drwxr-xr-x  7 root root      4096 okt 24 11:38 exist
-rw-r--r--  1 root root 132149935 okt 22 11:06 exist.war
drwxr-xr-x  5 root root      4096 okt 24 11:39 orbeon
-rw-r--r--  1 root root  63168129 okt 24 11:37 orbeon.war

```

## 6. Install database

```
 ant upload -Dwebapp.instance=docker -Dhostport=172.17.0.2:8080

```

See also [Install database](INSTALL.md#8-install-database)

## 7. Final check

Follow the [final checks in INSTALL.md](INSTALL.md#final-checks)