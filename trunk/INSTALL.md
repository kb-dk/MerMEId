
[MerMEId](../README.md) | [Source code](./README.md) | [Installation overview ](INSTALL.md)

# Installation

Since everything is running inside portable standard server software
products, MerMEId should be portable. However, we have never installed
it on anything but Linux systems and all scripts used to maintain it
depend on having /bin/sh and /usr/bin/perl etc. Sorry if you don't

* [Installing dependencies](#installing-dependencies)
* [Configure MerMEId Form](#configure-mermeid-form)
* Configure Database and Queries
* Building 
* Installing MerMEId

The old manual
[mermeid/INSTALL.html](https://rawgit.com/Det-Kongelige-Bibliotek/MerMEId/master/trunk/mermeid/INSTALL.html)
is about to be deprecated

## Installing dependencies

MerMEId consists of software components residing in an Apache
Tomcat. The components are working intimately together, in an URI
space orchestrated by Apache HTTPD. These are the easy ones (you
should be able to use what comes with your operating system)

### Standard components

* Java 8
* Apache Tomcat 8
* A modern Apache HTTPD (like 2.4 or better)
* Java build tool Apache Ant (something like version 1.10.*)
* PERL scripting language (v5.26.*)

Install these using you yum or apt-get or whatever. If your Linux is
recent, that will do. You shouldn't need to look at my proposed
versions. Configure HTTPD and Tomcat the standard ways, the former
should run on port 80, and the latter on 8080.

### Special components

There are two components that less likely to come with your OS. The
shopping list is as follows:

* A recent stable release of [eXist DB](http://exist-db.org/) xml database, [we are currently using 4.4.0 or better](https://bintray.com/existdb/releases/exist/4.4.0/view)
* [Orbeon FORMS Community Edition (CE)](https://www.orbeon.com/download). We are still using the fairly old version 4.9.

You should be able to get an orbeon.war ready to install in the
tomcat. I install the standard eXist and then build an
[exist.war](https://exist-db.org/exist/apps/doc/exist-building). These
are basically copied to the tomcat webapps directory.



## Configure MerMEId Form



## Configure Database and Queries
## Building 
## Installing MerMEId

