#!/bin/bash

####################
# Script: runUnit.sh
# Builds a parametrized and customized integration-tests image that works for both integration and unit tests.
# Runs the unit-tests image in docker-compose

export DOCKER_SOURCE=${DOT_CICD_LIB}/docker
export IMAGE_NAME="dotcms/cicd-test-base:${GITHUB_RUN_NUMBER}"
export BUILD_ID
docker_repo_path=${DOT_CICD_PATH}/docker
integration_folder=${DOCKER_SOURCE}/tests/integration
unit_folder=${DOCKER_SOURCE}/tests/unit

# DB resources setup
setupDockerDb ${integration_folder}
# unit resources setup
setupDockerIntegration unit
# External resources setup
setupExternal ${integration_folder}
# Build customized and parametrized integration image
buildBase ${IMAGE_NAME} ${integration_folder}

# Runs compose files to start unit tests
executeCmd "docker-compose
  -f ${unit_folder}/unit-service.yml
  up
  --abort-on-container-exit
"
if [[ ${cmdResult} == 0 ]]; then
  exit 0
else
  exit 1
fi
