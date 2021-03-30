#!/bin/bash

DOCKER_SOURCE=${DOT_CICD_LIB}/docker
export IMAGE_NAME="dotcms/cicd-test-base:${GITHUB_RUN_NUMBER}"
export EXPORT_REPORTS=true
export SERVICE_HOST_PORT_PREFIX=1

setupDockerDb ${DOCKER_SOURCE}/tests/integration

. ${OPERATION_TARGET_PATH}/buildTestBase.sh

docker-compose \
  -f ${DOCKER_SOURCE}/tests/integration/integration-service.yml \
  -f ${DOCKER_SOURCE}/tests/shared/${databaseType}-docker-compose.yml \
  -f ${DOCKER_SOURCE}/tests/shared/open-distro-docker-compose.yml \
  up \
  --abort-on-container-exit
dcResult=$?

if [[ ${dcResult} == 0 ]]; then
  exit 0
else
  exit 1
fi
