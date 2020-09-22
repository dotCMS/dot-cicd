#!/bin/bash

set -e

DOCKER_SOURCE=${DOT_CICD_LIB}/docker
export IMAGE_BASE_NAME="docker.pkg.github.com/dotcms/core/tests-base-image:${GITHUB_RUN_NUMBER}"
export SIDECAR_IMAGE_BASE_NAME="docker.pkg.github.com/dotcms/core/dotcms-image:${GITHUB_RUN_NUMBER}"
export EXPORT_REPORTS=true
export TEST_TYPE=curl
export BUILD_ID=${CURRENT_BRANCH}
export BUILD_HASH=${GITHUB_SHA::8}

setupTestRun sidecar

runFolder=${DOCKER_SOURCE}/tests/sidecar
licenseFolder=${runFolder}/license
mkdir ${licenseFolder}
chmod 777 ${licenseFolder}
licenseFile=${licenseFolder}/license.dat
touch ${licenseFile}
chmod 777 ${licenseFile}
echo "${LICENSE_KEY}" > ${licenseFile}

docker-compose \
  -f ${DOCKER_SOURCE}/tests/sidecar/sidecar-service-compose.yml \
  -f ${DOCKER_SOURCE}/tests/shared/${databaseType}-docker-compose.yml \
  -f ${DOCKER_SOURCE}/tests/shared/open-distro-docker-compose.yml \
  up \
  --abort-on-container-exit

# dcResult=$?

cleanUpTest sidecar

# if [[ ${dcResult} == 0 ]]; then
#   exit 0
# else
#   exit 1
# fi
