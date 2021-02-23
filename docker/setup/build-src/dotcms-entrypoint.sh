#!/bin/bash

if [[ "${1}" == "dotcms" || -z "${1}" ]]; then
  echo "Calling: . /srv/entrypoint.sh ${1} &"
  . /srv/entrypoint.sh ${1} &

  if [[ $? != 0 ]]; then
    echo "Error starting dotcms instance"
    exit
  fi

  if [[ -n "${2}" ]]; then
    echo "Executing: . /build/entrypoint.sh ${2}"
    . /build/entrypoint.sh ${2}
    . /build/stop-sidecar.sh
  fi
fi
