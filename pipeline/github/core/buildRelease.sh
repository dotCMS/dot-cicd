#!/bin/bash

DOCKER_SOURCE=${DOT_CICD_LIB}/docker
export IMAGE_NAME='dotcms/dotcms-release-process'

cd ${DOCKER_SOURCE}/release

docker build --pull --no-cache -t ${IMAGE_NAME} .

dResult=$?

if [[ ${dResult} == 0 ]]; then
  exit 0
else
  exit 1
fi
