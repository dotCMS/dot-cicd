#!/bin/bash

###########################
# Script: runIntegration.sh
# Builds a parametrized and customized integration-tests image that works for both integration and unit tests.
# Runs the integration-tests image in docker-compose along with the database and open distro compose files.

export DOCKER_SOURCE=${DOT_CICD_LIB}/docker
export IMAGE_NAME="dotcms/cicd-test-base:${GITHUB_RUN_NUMBER}"
export EXPORT_REPORTS=true
export SERVICE_HOST_PORT_PREFIX=1
export BUILD_ID
docker_repo_path=${DOT_CICD_PATH}/docker
integration_folder=${DOCKER_SOURCE}/tests/integration
shared_folder=${DOCKER_SOURCE}/tests/shared

# DB resources setup
setupDockerDb ${integration_folder}
# integration resources setup
setupDockerIntegration
# External resources setup
setupExternal ${integration_folder}
# Build customized and parametrized integration image
buildBase ${IMAGE_NAME} ${integration_folder}

# Runs compose files to start integration tests with open distro and database
executeCmd "docker-compose
  -f ${integration_folder}/integration-service.yml
  -f ${shared_folder}/${databaseType}-docker-compose.yml
  -f ${shared_folder}/open-distro-docker-compose.yml
  up
  --abort-on-container-exit
"
if [[ ${cmdResult} == 0 ]]; then
  exit 0
else
  exit 1
fi
