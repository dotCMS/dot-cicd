#!/bin/bash

#######################
# Script: stopDotcms.sh
# Stops Tomcat execution

[[ -f /srv/TOMCAT_VERSION ]] && TOMCAT_VERSION=$(cat /srv/TOMCAT_VERSION)
TOMCAT_HOME=/srv/dotserver/tomcat-${TOMCAT_VERSION}

exec -- \
  /usr/local/bin/dockerize \
  ${TOMCAT_HOME}/bin/catalina.sh stop
