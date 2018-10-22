
[MerMEId](../README.md) | [Source code](./README.md) | [Installation overview ](INSTALL.md)

# Eight steps towards a MerMEId of you own

Since everything is running inside portable standard server software
products, MerMEId itself should be portable. However, we have never
installed it on anything but Linux systems. Most scripts used to
install and maintain it depend on having ant, /bin/sh and /usr/bin/perl
etc that are common in that environment.

1. [Install Apache HTTPD](#1-install-apache-httpd)
2. [Install Apache Tomcat](#2-install-apache-tomcat)
3. [Install eXist DB](#3-install-exist-db)
4. [Install Orbeon](#4-install-orbeon)
5. [Configure MerMEId Form](#5-configure-mermeid-form)
6. [Configure database](#6-configure-database)
7. [Build MerMEId](#7-build-mermeid)
8. [Install database](#8-install-database)
9. [Final checks](#final-checks)

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

Then copy the file
[apache-httpd/conf-devel.conf]/(apache-httpd/conf-devel.conf) to where
your httpd has its virtual host configurations and restart HTTPD.

(On Ubuntu this is /etc/apache2/sites-enabled/, on Red Hat/Cent OS it is
/etc/httpd/conf.d/)

Complete this by creating a /home/xml-store directory and a
passwordfile there. This will protect the database. You can create
the passwordfile like this:

```
  mkdir /home/xml-store
  cd /home/xml-store
  htpasswd -bc passwordfile first_trusted_user magic_word
  htpasswd -b passwordfile second_trusted_user another_magic_word
  htpasswd -b passwordfile third_trusted_user yet_another_magic_word

```

### Check				

There should be a file

```
/home/xml-store/passwordfile

```
and it should be readable to the user running your Apache HTTPD

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

### eXist DB password

While you're at it, remember to set password for eXist DB admin
user. Do it under security in eXist DB Dashboard. 

If you don't do this someone out there will use your database for
purposes you may not like. **OK?**

## 4. Install Orbeon

[Orbeon FORMS Community Edition
(CE)](https://www.orbeon.com/download). We are still using the fairly
old version 4.9, but you should still be able to get an orbeon.war for
version 4.9 which ready to install in the tomcat.

Copy orbeon.war to the tomcat webapps directory. Tomcat opens war
files in its webapps area. You should by now have one directory there
called exist and another called orbeon.

In the source code [orbeon/](./orbeon) directory you will find a small
java (actually, it is a Java Server Pages file) program called
[mei_form.jsp](./orbeon/mei_form.jsp). You need to install that in
your orbeon.

Make sure that there is a directory called 

```
 <YOUR WEBAPPS directory>/orbeon/xforms-jsp/

```
Then make a directory called mei-form in there

``` 
mkdir  <YOUR WEBAPPS directory>/orbeon/xforms-jsp/mei-form

```

and then copy 

```
cp [./orbeon/mei_form.jsp](./orbeon/mei_form.jsp) <YOUR WEBAPPS directory>/orbeon/xforms-jsp/mei-form/index.jsp

```

that is, it should get a new name while copying.

### Check

* http://example.org:8080/orbeon/ should give you an orbeon start page.

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
stuff. Your tasks is to copy that file to a name suitable for your
local configuration. Like mymermeid. Then edit the file and replace
example.org with the name of your server. That is, if you don't try to
do something really complicated.

### Check

When you are done there should be a file called mermeid_configuration.xml_mymermeid in local_config

## 6. Configure database

You will find a file in [local_config](./local_config/), named
[login.xqm_distro](./local_config/login.xqm_distro) which contains
code used for logging in before doing sensitive operations in the
database. Inside it, there is a function looking like

```
declare function login:function() as xs:boolean
{
  let $lgin := xdb:login("/db", "user", "secretpassword")
  return $lgin
};

```

The database needs to know the userid (which in this case is "admin") and the
"secretpassword" 

Your tasks is to copy the login.xqm_distro to login.xqm_mymermeid and
replace "user" with "admin" and secretpassword with whatever you chose
when you installed eXist DB ([see above](#3-install-exist-db))


### Check

When you are done, there should be a file called login.xqm_mymermeid
in local_config. Keep that private, and don't share it. **OK?**

## 7. Build MerMEId

Actually, you have now already done all the hard work, and now it
remains to run a build using ant.


```
ant  -Dwebapp.instance=mymermeid

```

What ant does here isn't really a compilation, but rather it copies a
lot of files to the places they need to be for running MerMEId. Also
it creates an editor.war in the [./mermeid](./mermeid) directory.

```
cp ./mermeid/editor.war <YOUR WEBAPPS directory>/

```

### Check

* Your http://example.org/editor/ whould return a page just like http://labs.kb.dk/editor/


After you've done, you can do ant clean to make sure you leave the
source tree in pristine conditions. Note that you must build before
you install the database.


## 8. Install database

When you've build MerMEId, you must install the database. Ant is doing that for you using ant command

```
ant upload -Dwebapp.instance=mymermeid -Dhostport=localhost:8080

```

It will ask you for the admin password of eXist, the one you set when installing [eXist DB](#exist-db-password).

### Setting execute permissions for database

Note also the text appearing after each set of files having been install:

```
     [echo] Remember to make all scripts executable by retrieving:
     [echo] http://example.org:8080/exist/rest/db//apps/filter/xchmod.xq
```

and


```
     [echo] Remember to make all scripts executable by retrieving:
     [echo] http://example.org:8080/exist/rest/db/mermeid/xchmod.xq
```

You have to do that, because that give MerMEId database execute permissions withing eXist DB


## Final Checks

* http://example.org:8080/exist/rest/db/mermeid/ should (thanks to the configuration of HTTPD above) give the same content as http://example.org/storage/
* The database scripts should work. For instance http://example.org/storage/list_files.xq should return a list of records in the database, just like the one here http://labs.kb.dk/storage/list_files.xq. If it doesn't you forgot to [set execute permissions](#setting-execute-permissions-for-database).
* If you try to delete, copy or create new files you should be forced to authenticate (for example) as first_trusted_user using his or her magic_word
* The same should happen if you load the editor, and try to change a text or something.

