Logging into the same logs directory as exist
=========================================

A few log messages are logged in exist's context. An important message in exist context is the init message banner so one can see if orbeon started and if there were non fatal problems.
All messages in exist context are configured in log4j2.xml in /exist/etc/. To patch the additional configuration into the /exist/etc/log4j2.xml an XSL stylesheet and log4j2.xml in this directory is used. The stylsheet is processed using the saxon XSL processor packaged with exist-db.
Messages in orbeon context are configured using log4j.xml in this directory. log4j 1.2 is not used anymore but the log4j 1.2 API bridge. However log4j2.xml cannot be used as the log4j 1.2 api is a direct dependency of orbeon.