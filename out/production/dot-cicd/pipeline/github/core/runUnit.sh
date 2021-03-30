#!/bin/bash

DOCKER_SOURCE=${DOT_CICD_LIB}/docker
export IMAGE_NAME="dotcms/cicd-test-base:${GITHUB_RUN_NUMBER}"

setupDockerDb ${DOCKER_SOURCE}/tests/unit

. ${OPERATION_TARGET_PATH}/buildTestBase.sh

docker-compose \
  -f ${DOCKER_SOURCE}/tests/unit/unit-service.yml \
  up \
  --abort-on-container-exit
dcResult=$?

if [[ ${dcResult} == 0 ]]; then
  exit 0
else
  exit 1
fi
