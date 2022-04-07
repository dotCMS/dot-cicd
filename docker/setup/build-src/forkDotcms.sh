#!/bin/bash

#######################
# Script: forkDotcms.sh
# Main script for docker images which need a DotCMS instance to run against.
# It usually waits for the DB, then starts Tomcat and deploy DotCMS to it, wait for the DotCMS instance to be ready and
# leave it running in the background and finally runs a script to run whatever is needed to be run against DotCMS.
# At the end it shuts down Tomcat.

# Generic wait function. Prints a message and wait for provided amount of time.
#
# $1: label: label to identify what are waiting for.
# $2: wait: time representation to wait
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

# Waits for database the provided amount of time
#
# $1: time representation to wait
function waitDbFor {
  waitFor 'DB' ${1}
}

# Waits for DotCMS instance the provided amount of time
#
# $1: time representation to wait
function waitDotcmsFor {
  waitFor 'DotCMS' ${1}
}

if [[ "${1}" == "dotcms" || -z "${1}" ]]; then
  # Wait for DB to be ready
  : ${WAIT_DB_FOR:="30"}
  waitDbFor ${WAIT_DB_FOR}
  unset WAIT_DB_FOR

  # Executing Tomcat and deploy DotCMS
  echo "Executing: . /srv/entrypoint.sh ${1} &"
  export JVM_ENDPOINT_TEST_PASS=obfuscate_me
  . /srv/entrypoint.sh ${1} &

  if [[ $? != 0 ]]; then
    echo "Error starting dotcms instance"
    exit 1
  fi

  # If custom entry point is defined then try to run it
  if [[ -x /srv/customEntrypoint.sh ]]; then
    # Waits for DotCMS to be ready
    : ${WAIT_DOTCMS_FOR:="3m"}
    waitDotcmsFor ${WAIT_DOTCMS_FOR}

    # While DotCMS is running in the background start running the "payload" against it
    set -- ${@:2}
    echo "Executing: . /srv/customEntrypoint.sh $@"
    . /srv/customEntrypoint.sh $@

    # Stops Tomcat once it finishes
    echo 'Stopping Tomcat...
    Executing: . /srv/stopDotcms.sh'
    . /srv/stopDotcms.sh
  fi
fi
