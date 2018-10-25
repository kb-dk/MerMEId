

[MerMEId](../README.md) | [Source code](./README.md) | [Install](INSTALL.md) | [Using Docker](USING_DOCKER.md)

# Or six steps towards a MerMEId of you own using Docker 

This is only partly an alternative to the usual [installation](INSTALL.md) procedure.

1. [Ensure that you have eXist DB and Orbeon FORMS](#1-ensure-that-you-have-exist-db-and-orbeon-forms)
2. [Configure Form and Database](#2-configure-form-and-database)
3. [Build MerMEId](#3-build-mermeid)
4. [Configure Apache](#4-configure-apache)
5. [Make docker image](#5-make-docker-image)
6. [Install database](#6-install-database)

Then you can [make the final checks](INSTALL.md#final-checks)

## 1. Ensure that you have eXist DB and Orbeon FORMS

* [orbeon.war see INSTALL.md](INSTALL.md#4-install-orbeon)
* [exist.war see INSTALL.md](INSTALL.md#3-install-exist-db)

They should be put into [./trunk/other-wars](./other-wars)

## 2. Configure Form and Database

* [Configure MerMEId Form](INSTALL.md#5-configure-mermeid-form)
* [Configure eXist database](INSTALL.md#6-configure-database)

Here you have to choose the password of the eXist DB. You will need
that later.

## 3. Build MerMEId

For example

```
 ant -Dwebapp.instance=docker

```
## 4. Configure Apache

Please note the sections "Setting up Apache2 as a daemon" and "note
that editor is the one only Apache2 user"

It isn't necessary to modify the code there, but you must do so if you
want to have more than one editor user, or change the security
settings. [See INSTALL.md](./INSTALL.md#more-httpd).
    						
## 5. Make docker image
 
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
above](#configure-form-and-database). There is a paragraph on this in the [INSTALL.md](INSTALL.md#exist-db-password)

## 6. Install database

```
 ant upload -Dwebapp.instance=docker -Dhostport=172.17.0.2:8080

```

See also [Install database](INSTALL.md#8-install-database)
