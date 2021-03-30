#!/bin/bash

export BUILD_ID=${CURRENT_BRANCH}
export BUILD_HASH=${GITHUB_SHA::8}
: ${DOCKER_SOURCE:="${DOT_CICD_LIB}/docker"}
: ${DOCKER_COMPOSE_FILE:="${DOCKER_SOURCE}/images/sidecar/dotcms-sidecar-service.yml"}
: ${DATABASE_TYPE:="postgres"} && export DATABASE_TYPE
: ${PROVIDER_DB_USERNAME:="postgres"} && export PROVIDER_DB_USERNAME
: ${PROVIDER_DB_PASSWORD:="postgres"} && export PROVIDER_DB_PASSWORD
: ${WAIT_DB_FOR:="30"} && export WAIT_DB_FOR
: ${WAIT_DOTCMS_FOR:="3m"} && export WAIT_DOTCMS_FOR
docker_repo_path=${DOT_CICD_PATH}/docker
docker_dotcms_path=${docker_repo_path}/images/dotcms
sidecar_app=${1}
: ${sidecar_app_context:="${DOCKER_SOURCE}/images/${sidecar_app}"} && export sidecar_app_context
sidecar_app_file=${sidecar_app_context}/dotcms-${sidecar_app}-service.yml
args="$@"
set -- ${@:2}

echo "############
Sidecar Vars
############
DOCKER_COMPOSE_FILE: ${DOCKER_COMPOSE_FILE}
DOCKER_SOURCE: ${DOCKER_SOURCE}
BUILD_ID: ${BUILD_ID}
BUILD_HASH: ${BUILD_HASH}
DATABASE_TYPE: ${DATABASE_TYPE}
PROVIDER_DB_USERNAME: ${PROVIDER_DB_USERNAME}
PROVIDER_DB_PASSWORD: ${PROVIDER_DB_PASSWORD}
WAIT_DB_FOR: ${WAIT_DB_FOR}
WAIT_DOTCMS_FOR: ${WAIT_DOTCMS_FOR}
CUSTOM_STARTER_URL: ${CUSTOM_STARTER_URL}
docker_repo_path: ${docker_repo_path}
docker_dotcms_path: ${docker_dotcms_path}
sidecar_app: ${sidecar_app}
sidecar_app_context: ${sidecar_app_context}
sidecar_app_file: ${sidecar_app_file}
Args: ${args}
"

if [[ -z "${sidecar_app}" ]]; then
  echo "Sidecar App was not specified, aborting"
  exit 1
fi

echo ${DOCKER_TOKEN} | docker login --username ${DOCKER_USERNAME} --password-stdin

fetchDocker ${docker_repo_path} ${docker_dotcms_path}
addLicenseAndOutput ${docker_dotcms_path}
buildBase cicd-dotcms ${docker_dotcms_path} ${docker_repo_path}

export SIDECAR_APP_IMAGE_NAME="cicd-dotcms-${sidecar_app}"
setupDocker ${sidecar_app_context}
buildBase ${SIDECAR_APP_IMAGE_NAME} ${sidecar_app_context} ${docker_repo_path} true

prepareLicense ${sidecar_app_context} ${LICENSE_KEY} ${DEBUG}

executeCmd "docker-compose
  -f ${sidecar_app_file}
  -f ${DOCKER_COMPOSE_FILE}
  -f ${DOCKER_SOURCE}/tests/shared/${DATABASE_TYPE}-docker-compose.yml
  -f ${DOCKER_SOURCE}/tests/shared/open-distro-docker-compose.yml
  up
  --abort-on-container-exit
"
result=${cmdResult}

executeCmd "docker-compose
  -f ${sidecar_app_file}
  -f ${DOCKER_COMPOSE_FILE}
  -f ${DOCKER_SOURCE}/tests/shared/${DATABASE_TYPE}-docker-compose.yml
  -f ${DOCKER_SOURCE}/tests/shared/open-distro-docker-compose.yml
  down
"

if [[ ${result} -gt 2 ]]; then
  exit 1
fi
