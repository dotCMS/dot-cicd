#!/bin/bash

: ${DOCKER_SOURCE:="${DOT_CICD_LIB}/docker"}
: ${sidecar_docker_compose:="${DOCKER_SOURCE}/images/sidecar/dotcms-sidecar-service.yml"}
: ${DATABASE_TYPE:="postgres"} && export DATABASE_TYPE
: ${PROVIDER_DB_USERNAME:="postgres"} && export PROVIDER_DB_USERNAME
: ${PROVIDER_DB_PASSWORD:="postgres"} && export PROVIDER_DB_PASSWORD
: ${WAIT_DB_FOR:="30"} && export WAIT_DB_FOR
: ${WAIT_DOTCMS_FOR:="3m"} && export WAIT_DOTCMS_FOR
: ${BUNDLED_MODE:="false"} && export BUNDLED_MODE
docker_repo_path=${DOT_CICD_PATH}/docker
docker_dotcms_path=${docker_repo_path}/images/dotcms
sidecar_app=${1}
: ${sidecar_app_context:="${DOCKER_SOURCE}/images/${sidecar_app}"} && export sidecar_app_context
export SIDECAR_APP_IMAGE_NAME="cicd-dotcms-${sidecar_app}"
sidecar_app_file=${sidecar_app_context}/dotcms-${sidecar_app}-service.yml
args="$@"
set -- ${@:2}
export SIDECAR_ARGS=${@}
[[ "${RESET_STARTER}" == 'true' ]] && export CUSTOM_STARTER_URL=

echo "
############
Sidecar Vars
############
sidecar_docker_compose: ${sidecar_docker_compose}
DOCKER_SOURCE: ${DOCKER_SOURCE}
DATABASE_TYPE: ${DATABASE_TYPE}
PROVIDER_DB_USERNAME: ${PROVIDER_DB_USERNAME}
PROVIDER_DB_PASSWORD: ${PROVIDER_DB_PASSWORD}
WAIT_DB_FOR: ${WAIT_DB_FOR}
WAIT_DOTCMS_FOR: ${WAIT_DOTCMS_FOR}
BUNDLED_MODE: ${BUNDLED_MODE}
CUSTOM_STARTER_URL: ${CUSTOM_STARTER_URL}
docker_repo_path: ${docker_repo_path}
docker_dotcms_path: ${docker_dotcms_path}
sidecar_app: ${sidecar_app}
sidecar_app_context: ${sidecar_app_context}
sidecar_app_file: ${sidecar_app_file}
Args: ${args}
SIDECAR_ARGS: ${SIDECAR_ARGS}
"

if [[ -z "${sidecar_app}" ]]; then
  echo "Sidecar App was not specified, aborting"
  exit 1
fi

echo ${DOCKER_TOKEN} | docker login --username ${DOCKER_USERNAME} --password-stdin

fetchDocker ${docker_repo_path} ${DOCKER_BRANCH}

buildBase cicd-dotcms ${docker_dotcms_path}

setupDocker ${sidecar_app_context} ${docker_repo_path}
license_folder=${sidecar_app_context}
if [[ "${BUNDLED_MODE}" == 'true' ]]; then
  sidecar_app_file=${sidecar_app_context}/dotcms-${sidecar_app}-service-bundled.yml
  sidecar_app_context="${sidecar_app_context}/Dockerfile-bundled"
else
  sidecar_docker_compose_file_param="-f ${sidecar_docker_compose}"
fi
buildBase ${SIDECAR_APP_IMAGE_NAME} ${sidecar_app_context} true

prepareLicense ${license_folder} ${LICENSE_KEY}

up_cmd="docker-compose
  -f ${sidecar_app_file}
  ${sidecar_docker_compose_file_param}
  -f ${DOCKER_SOURCE}/tests/shared/${DATABASE_TYPE}-docker-compose.yml
  -f ${DOCKER_SOURCE}/tests/shared/open-distro-docker-compose.yml
  up
  --abort-on-container-exit
"
executeCmd "${up_cmd}"
result=${cmdResult}

down_cmd="docker-compose
  -f ${sidecar_app_file}
  ${sidecar_docker_compose_file_param}
  -f ${DOCKER_SOURCE}/tests/shared/${DATABASE_TYPE}-docker-compose.yml
  -f ${DOCKER_SOURCE}/tests/shared/open-distro-docker-compose.yml
  down
"
executeCmd "${down_cmd}"

if [[ ${result} -gt 2 ]]; then
  exit 1
fi
