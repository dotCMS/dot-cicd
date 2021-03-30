#!/bin/bash

export EXPORT_REPORTS=true
export TEST_TYPE=curl
export BUILD_ID=${CURRENT_BRANCH}
export BUILD_HASH=${GITHUB_SHA::8}
export IMAGE_NAME="dotcms/cicd-dotcms:${GITHUB_RUN_NUMBER}"
DOCKER_SOURCE=${DOT_CICD_LIB}/docker
DOCKER_FILE_PATH="${DOCKER_SOURCE}/tests/curl"

setupDocker ${DOCKER_FILE_PATH}
buildBase "dotcms/cicd-dotcms:${GITHUB_RUN_NUMBER}" ${DOCKER_FILE_PATH} ${DOT_CICD_PATH}/docker true

executeCmd "docker-compose \
  -f ${DOCKER_FILE_PATH}/curl-service.yml \
  -f ${DOCKER_SOURCE}/tests/shared/${databaseType}-docker-compose.yml \
  -f ${DOCKER_SOURCE}/tests/shared/open-distro-docker-compose.yml \
  up \
  --abort-on-container-exit
"

if [[ ${cmdResult} == 0 ]]; then
  exit 0
else
  exit 1
fi
