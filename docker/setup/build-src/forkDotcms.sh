#!/bin/bash

. /build/common.sh

if [[ "${1}" == "dotcms" || -z "${1}" ]]; then
  waitDbFor ${WAIT_DB_FOR}

  echo "Calling: . /srv/entrypoint.sh ${1} &"
  . /srv/entrypoint.sh ${1} &

  if [[ $? != 0 ]]; then
    echo "Error starting dotcms instance"
    exit
  fi

  if [[ -x /srv/customEntrypoint.sh ]]; then
    waitDotcmsFor ${WAIT_DOTCMS_FOR}

    set -- ${@:2}
    echo "Executing: . /srv/customEntrypoint.sh $@"
    . /srv/customEntrypoint.sh $@
    . /srv/stopDotcms.sh
  fi
fi
