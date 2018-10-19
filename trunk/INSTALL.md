
[MerMEId](../README.md) | [Source code](./README.md) | [Installation overview ](INSTALL.md)

# Nine steps towards a MerMEId of you own

Since everything is running inside portable standard server software
products, MerMEId should be portable. However, we have never installed
it on anything but Linux systems and all scripts used to maintain it
depend on having /bin/sh and /usr/bin/perl etc.

1. [Install Apache HTTPD](#1-install-apache-httpd)
2. [Install Apache Tomcat](#2-install-apache-tomcat)
3. [Install eXist DB](#3-install-exist-db)
4. [Install Orbeon](#4-install-orbeon)
5. [Configure MerMEId Form](#5-configure-mermeid-form)
6. [Configure database](#6-configure-database)
7. [Build MerMEId](#7-build-mermeid)
8. [Install database](#8-install-database)
9. [Install form in Orbeon](#9-install-form-in-orbeon)

The old manual
[mermeid/INSTALL.html](https://rawgit.com/Det-Kongelige-Bibliotek/MerMEId/master/trunk/mermeid/INSTALL.html)
is about to be deprecated

## 1. Install Apache HTTPD
## 2. Install Apache Tomcat

MerMEId consists of software components residing in an Apache
Tomcat. The components are working intimately together, in an URI
space orchestrated by Apache HTTPD. These are the easy ones (you
should be able to use what comes with your operating system)

* Java 8
* Apache Tomcat 8
* A modern Apache HTTPD (like 2.4 or better)
* Java build tool Apache Ant (something like version 1.10.*)
* PERL scripting language (v5.26.*)

Install these using you yum or apt-get or whatever. If your Linux is
recent, that will do. You shouldn't need to look at my proposed
versions. Configure HTTPD and Tomcat the standard ways, the former
should run on port 80, and the latter on 8080. In the following I will
refer to your server as example.org. 

### Check

* http://example.org:80 should tell you something about httpd
* http://example.org:8080 should tell you something about tomcat

Complete this by copying the file
[apache-httpd/conf-devel.conf]/(apache-httpd/conf-devel.conf) to where
your httpd has its virtual host configurations and restart HTTPD.

(On Ubuntu this is /etc/apache2/sites-enabled/, on Red Hat/Cent OS it is
/etc/httpd/conf.d/)

## 3. Install eXist DB

There are two components that less likely to come with your OS, Orbeon
and eXist DB.

Use a recent stable release of [eXist DB](http://exist-db.org/) xml
database, e.g., use [4.4.0](https://bintray.com/existdb/releases/exist/4.4.0/view) or
better

We install the standard eXist and then build an
[exist.war](https://exist-db.org/exist/apps/doc/exist-building).

Copy the exist.war to the tomcat webapps directory

### Check

* http://example.org:8080/exist/ should give you eXist DB Dashboard.

While you're at it, remember to set password for eXist DB admin
user. If you don't do it someone out there will use it for purposes
you don't like. **OK?**

## 4. Install Orbeon

[Orbeon FORMS Community Edition
(CE)](https://www.orbeon.com/download). We are still using the fairly
old version 4.9, but you should be able to get an orbeon.war ready to
install in the tomcat.

Copy orbeon.war to the tomcat webapps directory.

## 5. Configure MerMEId Form

You will find a file in [local_config](./local_config/), named
[mermeid_configuration.xml_distro](./local_config/mermeid_configuration.xml_distro), the beginning of which looks somewhat like

```
  <document_root>storage/dcm/</document_root>
  <exist_dir>storage/</exist_dir>
  <orbeon_dir>http://example.org/orbeon/xforms-jsp/mei-form/</orbeon_dir>
  <form_home>http://example.org/editor/forms/mei/</form_home>
  <crud_home>http://localhost/filter/dcm/</crud_home>
  <library_crud_home>http://example.org/filter/library/</library_crud_home>
  <rism_crud_home>http://example.org/filter/rism_sigla/</rism_crud_home>
  <server_name>http://example.org/</server_name>
```

The MerMEId form and Orbeon need to know where to find different
stuff. Your tasks is to copy that file to a name given by your local
configuration. Like mymermeid. And replace example.org with the name
of your server.

When you are done there should be a file called mermeid_configuration.xml_mymermeid in local_config

## 6. Configure database

You will find a file in [local_config](./local_config/), named
[login.xqm_distro](./local_config/login.xqm_distro) which contains
code used for logging in before doing sensitive operations in the
database. The function looks like

```
declare function login:function() as xs:boolean
{
  let $lgin := xdb:login("/db", "user", "secretpassword")
  return $lgin
};
```

The database needs to know the user's ID (which is admin) and the "secretpassword"
Your tasks is to copy the login.xqm_distro to login.xqm_mymermeid and replace "user" with "admin" and secretpassword with whatever you chose when you installed eXist DB ([see above](#3-install-exist-db))

When you are done there should be a file called login.xqm_mymermeid in local_config


## 7. Build MerMEId




## 8. Install database

* http://example.org:8080/exist/rest/db/mermeid/ should (thanks to the configuration of HTTPD above) give the same content as http://example.org/storage/

## 9. Install form in Orbeon

