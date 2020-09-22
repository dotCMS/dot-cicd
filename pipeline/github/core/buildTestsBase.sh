#!/bin/bash

set -e

DOCKER_SOURCE=${DOT_CICD_LIB}/docker

setupBuildBaseTests integration

docker build -t docker.pkg.github.com/dotcms/core/tests-base-image:${GITHUB_RUN_NUMBER} \
  --build-arg BUILD_FROM=COMMIT \
  --build-arg BUILD_ID=${CURRENT_BRANCH} \
  --build-arg BUILD_HASH=${GITHUB_SHA::8} \
  --build-arg LICENSE_KEY=${LICENSE_KEY} \
  ${DOCKER_SOURCE}/tests/integration/

# dcResult=$?

cleanUpTest integration

# if [[ ${dcResult} == 0 ]]; then
#   exit 0
# else
#   exit 1
# fi
