#!/bin/bash

export DOCKER_SOURCE=${DOT_CICD_LIB}/docker
export IMAGE_NAME="dotcms/cicd-test-base:${GITHUB_RUN_NUMBER}"
export EXPORT_REPORTS=true
export SERVICE_HOST_PORT_PREFIX=1
export BUILD_ID
docker_repo_path=${DOT_CICD_PATH}/docker
integration_folder=${DOCKER_SOURCE}/tests/integration
shared_folder=${DOCKER_SOURCE}/tests/shared

setupDockerDb ${integration_folder}
setupDockerIntegration
setupExternal ${integration_folder}
buildBase ${IMAGE_NAME} ${integration_folder}

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
