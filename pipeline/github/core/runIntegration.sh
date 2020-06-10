#!/bin/bash

DOCKER_SOURCE=${DOT_CICD_LIB}/docker
export IMAGE_BASE_NAME=docker.pkg.github.com/dotcms/core/tests-base-image:${GITHUB_RUN_NUMBER}
export EXPORT_REPORTS=true
export SERVICE_HOST_PORT_PREFIX=1

setupTestRun integration

docker-compose \
  -f ${DOCKER_SOURCE}/tests/integration/integration-service.yml \
  -f ${DOCKER_SOURCE}/tests/shared/${databaseType}-docker-compose.yml \
  -f ${DOCKER_SOURCE}/tests/shared/open-distro-docker-compose.yml \
  up \
  --abort-on-container-exit

dcResult=$?

cleanUpTest integration

if [[ ${dcResult} == 0 ]]; then
  exit 0
else
  exit 1
fi
