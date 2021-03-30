#!/bin/bash

function waitFor {
  local label=${1}
  local wait=${2}
  [[ -z "${label}" ]] && label='Unknown'
  [[ -z "${wait}" ]] && wait='1m'
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "            Requested sleep of [${wait}]", waiting for the ${label}?
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo ""
  sleep ${wait}
}

function waitDbFor {
  waitFor 'DB' ${1}
}

function waitDotcmsFor {
  waitFor 'DotCMS' ${1}
}

if [[ "${1}" == "dotcms" || -z "${1}" ]]; then
  : ${WAIT_DB_FOR:="30"}
  waitDbFor ${WAIT_DB_FOR}
  unset WAIT_DB_FOR

  echo "Executing: . /srv/entrypoint.sh ${1} &"
  . /srv/entrypoint.sh ${1} &

  if [[ $? != 0 ]]; then
    echo "Error starting dotcms instance"
    exit 1
  fi

  if [[ -x /srv/customEntrypoint.sh ]]; then
    : ${WAIT_DOTCMS_FOR:="3m"}
    waitDotcmsFor ${WAIT_DOTCMS_FOR}

    set -- ${@:2}
    echo "Executing: . /srv/customEntrypoint.sh $@"
    . /srv/customEntrypoint.sh $@
    echo 'Stopping Tomcat...
    Executing: . /srv/stopDotcms.sh'
    . /srv/stopDotcms.sh
  fi
fi
