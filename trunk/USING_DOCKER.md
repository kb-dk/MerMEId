

[MerMEId](../README.md) | [Source code](./README.md) | [Install](INSTALL.md)

# Using MerMEId in Docker 

This is only partly an alternative to the usual [installation](INSTALL.md) procedure.


    Ensure that you have orbeon.war (available directly from the net) and exist.war. We use the very old eXist version 2.2 and you need to build that one according to the recipe). Move them to the

     <MerMEId>/trunk/other-wars
    						

    directory.
    Build the Java components in <MerMEId>/trunk/. Just run

     ant
    						

    or perhaps

     ant -Dwebapp.instance=distro
    						

    There is more information on this in Section 2
    After that you should be able to build just about everything in one go by running a shell script

    <MerMEId>/trunk/build-docker-image.sh
    						

    If your docker behaves like mine, it would be possible to run it using

     docker run <docker image ID>
    						

    and everything will run on a local IP 172.17.0.2. The eXist dashboard should be on

     http://172.17.0.2:8080/exist/apps/dashboard/index.html
    						




