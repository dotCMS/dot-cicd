#!/bin/bash

export DOCKER_SOURCE=${DOT_CICD_LIB}/docker
export IMAGE_NAME="dotcms/cicd-test-base:${GITHUB_RUN_NUMBER}"
export BUILD_ID
docker_repo_path=${DOT_CICD_PATH}/docker
integration_folder=${DOCKER_SOURCE}/tests/integration
unit_folder=${DOCKER_SOURCE}/tests/unit

setupDockerDb ${integration_folder}
setupDockerIntegration unit
setupExternal ${integration_folder}
buildBase ${IMAGE_NAME} ${integration_folder}

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
