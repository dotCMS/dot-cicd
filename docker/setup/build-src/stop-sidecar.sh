#!/bin/bash

[[ -f /srv/TOMCAT_VERSION ]] && TOMCAT_VERSION=$(cat /srv/TOMCAT_VERSION)
TOMCAT_HOME=/srv/dotserver/tomcat-${TOMCAT_VERSION}

export CATALINA_PID="/tmp/dotcms.pid"
if [[ ! -e "${CATALINA_PID}" ]]; then
  echo
  echo "Pid file ${CATALINA_PID} does not exist! Are you sure dotCMS is running?"
  echo
  exit 1
fi

exec -- \
  /usr/local/bin/dockerize \
  ${TOMCAT_HOME}/bin/catalina.sh stop
