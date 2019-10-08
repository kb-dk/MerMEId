#########################
# multi stage Dockerfile
# 1. set up the build environment and build the expath-package
# 2. run the eXist-db
#########################
FROM openjdk:8-jdk as builder
LABEL maintainer="Peter Stadler"

ENV BUILD_HOME="/opt/builder"

# installing Apache Ant
RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-transport-https ant

# now building the main App
WORKDIR ${BUILD_HOME}
COPY . .
RUN ant 

#########################
# Now running the eXist-db
# and adding our freshly built xar-package
#########################
FROM stadlerpeter/existdb:4

COPY --chown=wegajetty --from=builder /opt/builder/build/*.xar ${EXIST_HOME}/autodeploy/