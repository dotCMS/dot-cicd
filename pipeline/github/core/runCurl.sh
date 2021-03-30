#!/bin/bash

export EXPORT_REPORTS=true
export TEST_TYPE=curl
export IMAGE_NAME="dotcms/cicd-dotcms-curl:${GITHUB_RUN_NUMBER}"
export DOCKER_SOURCE=${DOT_CICD_LIB}/docker
export BUILD_ID
docker_repo_path=${DOT_CICD_PATH}/docker
docker_dotcms_path=${docker_repo_path}/images/dotcms
docker_file_path="${DOCKER_SOURCE}/tests/curl"
shared_folder=${DOCKER_SOURCE}/tests/shared

fetchDocker ${docker_repo_path} ${DOCKER_BRANCH}

buildBase cicd-dotcms ${docker_dotcms_path}

setupDocker ${docker_file_path} ${docker_repo_path}
buildBase ${IMAGE_NAME} ${docker_file_path} true

prepareLicense ${docker_file_path} ${LICENSE_KEY}

executeCmd "docker-compose
  -f ${docker_file_path}/curl-service.yml
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
