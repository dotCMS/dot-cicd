#!/bin/bash

set -e

DOCKER_SOURCE=${DOT_CICD_LIB}/docker
export IMAGE_BASE_NAME=docker.pkg.github.com/dotcms/core/tests-base-image:${GITHUB_RUN_NUMBER}

setupTestRun unit

docker-compose \
  -f ${DOCKER_SOURCE}/tests/unit/unit-service.yml \
  up \
  --abort-on-container-exit

# dcResult=$?

cleanUpTest unit

# if [[ ${dcResult} == 0 ]]; then
#   exit 0
# else
#   exit 1
# fi
