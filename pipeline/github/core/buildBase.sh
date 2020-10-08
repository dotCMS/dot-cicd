#!/bin/bash

DOCKER_SOURCE=${DOT_CICD_LIB}/docker
setupBuildBase ${DOT_CICD_PATH}/docker

docker build -t docker.pkg.github.com/dotcms/core/dotcms-image:${GITHUB_RUN_NUMBER} \
  --build-arg BUILD_FROM=COMMIT \
  --build-arg BUILD_ID=${CURRENT_BRANCH} \
  --build-arg BUILD_HASH=${GITHUB_SHA::8} \
  ${DOCKER_SOURCE}/tests/sidecar/

dcResult=$?

cleanUpTest sidecar

if [[ ${dcResult} == 0 ]]; then
  exit 0
else
  exit 1
fi
