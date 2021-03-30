#!/bin/bash

function waitFor {
  local label=${1}
  local wait=${2}
  [[ -z "${label}" ]] && label='Unknown'
  [[ -z "${wait}" ]] && wait='1m'
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "            Requested sleep of [${waitFor}]", waiting for the ${label}?
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
