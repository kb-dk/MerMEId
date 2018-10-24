

[MerMEId](../README.md) | [Source code](./README.md) | [Install](INSTALL.md)

# Or five steps towards a MerMEId of you own using Docker 

This is only partly an alternative to the usual [installation](INSTALL.md) procedure.

1. [Ensure that you have eXist DB and Orbeon FORMS](#1-ensure-that-you-have-exist-db-and-orbeon-forms)
2. [Configure Form and Database](#2-configure-form-and-database)
3. [Build MerMEId](#3-build-mermeid)
4. [Make docker image](#4-make-docker-image)
5. [Install database](#5-install-database)

## 1. Ensure that you have eXist DB and Orbeon FORMS

* [orbeon.war see INSTALL.md](INSTALL.md#4-install-orbeon)
* [exist.war see INSTALL.md](INSTALL.md#3-install-exist-db)

They should be put into [./trunk/other-wars](./other-wars)

## 2. Configure Form and Database

* [Configure MerMEId Form](INSTALL.md#5-configure-mermeid-form)
* [Configure eXist database](INSTALL.md#6-configure-database)

Here you have to decide about the password of the eXist DB, which you will need later.

## 3. Build MerMEId

For example

ant -Dwebapp.instance=docker
    						
## 4. Make docker image
 
Now you should be able to everything in one go by running the shell script

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

## 5. Install database

See [Install database](INSTALL.md#8-install-database)
