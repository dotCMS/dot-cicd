#!/bin/bash

####################
# Script: runCurl.sh
# Fetches the docker repo in order to build from its Dockerfiles.
# Builds a parametrized docker dotcms image for it to be extended later.
# Builds the curl-tests image from the parametrized dotcms image.
# Runs the curl-tests image in docker-compose along with the database and open distro compose files.

export EXPORT_REPORTS=true
export TEST_TYPE=curl
export IMAGE_NAME="dotcms/cicd-dotcms-curl:${GITHUB_RUN_NUMBER}"
export DOCKER_SOURCE=${DOT_CICD_LIB}/docker
export BUILD_ID
docker_repo_path=${DOT_CICD_PATH}/docker
docker_file_path="${DOCKER_SOURCE}/tests/curl"
shared_folder=${DOCKER_SOURCE}/tests/shared

# Cloning core
repo_url=$(resolveRepoUrl ${CORE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
gitClone ${repo_url} ${BUILD_ID}

# Resolve which docker path to use (core or docker repo folder)
resolved_docker_path=${CORE_GITHUB_REPO}/docker/dotcms
# Builds parametrized dotcms image for it to be extended later
buildBase cicd-dotcms ${resolved_docker_path}
# Copies folders with database volume and scripts to be included in the image
setupDocker ${docker_file_path} ${resolved_docker_path}
# Builds curl-tests image from parametrized image
buildBase ${IMAGE_NAME} ${docker_file_path} true
# Adds license file to volume
prepareLicense ${docker_file_path} ${LICENSE_KEY}

# Runs compose files to start dotcms and its curl tests with open distro and database
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
