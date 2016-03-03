################################################################################
# Author:   Fernando Zavala
# Company:  Pivotal Software Inc.
# Date:     2/24/2016
# Purpose:  Dockerizing Pivotal Gemfire
#           Can dockerize the in the following OS
#           RHEL 5,6,7 and Debian Wheezy, Jessie,
#           Ubuntu is also possible, but not supported, using the debian bits
################################################################################

FROM centos:6.7
MAINTAINER Fernando Zavala <fzavala@pivotal.io>
LABEL DESCRIPTION="Dockerizing Pivotal GemFire always latest version 8.2" VENDOR="Pivotal Software Inc." VERSION="1.0"

ENV JAVA_VERSION 8u74 # these are the latest bits from Oracle
ENV BUILD_VERSION b02
ENV JAVA_HOME /usr/java/latest # this needs to be updated
ENV GEMFIRE=/tmp/Pivotal_GemFire_820)b17919
ENV PATH=$PATH:$GEMFIRE/bin

COPY * /tmp/
RUN echo root:pivotal | chpasswd \
        && yum -y update
        && yum -y upgrade
        && yum -y install unzip which tar more util-linux-ng passwd openssh-clients openssh-server ed m4 wget; yum clean all \
        && wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-$BUILD_VERSION/jdk-$JAVA_VERSION-linux-x64.rpm" -O /tmp/jdk-8-linux-x64.rpm
        && yum -y install /tmp/jdk-8-linux-x64.rpm
        && alternatives --install /usr/bin/java jar /usr/java/latest/bin/java 200000
        && alternatives --install /usr/bin/javaws javaws /usr/java/latest/bin/javaws 200000
        && alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 200000
        && tar -xzvf tmp/Pivotal_GemFire_820)b17919_Linux.tar.gz -C /tmp/ \
        && rm tmp/Pivotal_GemFire_820)b17919_Linux.tar.gz \


EXPOSE 8080 10344 4040 1099 7070
VOLUME ["/data/"]
CMD ["gfsh"]
