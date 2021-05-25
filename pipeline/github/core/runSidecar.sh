#!/bin/bash

#######################
# Script: runSidecar.sh
# Fetches the docker repo in order to build from its Dockerfiles.
# Builds a parametrized docker dotcms image for it to be use it later.
# Builds the sidecar -image from provided location parameter
# Runs the sidecar-image in docker-compose along with the parametrized dotcms image, database and open distro compose files.
# For more information on sidecar execution please refer to https://github.com/dotCMS/dot-cicd/docker/images/dotcms/README.md

# Env-Vars definition
: ${DOCKER_SOURCE:="${DOT_CICD_LIB}/docker"}
: ${DOTCMS_DOCKER_COMPOSE:="${DOCKER_SOURCE}/images/dotcms/dotcms-service.yml"}
: ${DATABASE_TYPE:="postgres"} && export DATABASE_TYPE
: ${PROVIDER_DB_USERNAME:="postgres"} && export PROVIDER_DB_USERNAME
: ${PROVIDER_DB_PASSWORD:="postgres"} && export PROVIDER_DB_PASSWORD
: ${WAIT_DB_FOR:="30"} && export WAIT_DB_FOR
: ${WAIT_DOTCMS_FOR:="3m"} && export WAIT_DOTCMS_FOR
# Flag that tells the script to treat dotcms and sidecar image as one fat imager, not likely to happen
: ${BUNDLED_MODE:="false"} && export BUNDLED_MODE
docker_repo_path=${DOT_CICD_PATH}/docker
docker_dotcms_path=${docker_repo_path}/images/dotcms
# Gets the first argument to be considered the folder where the sidecar Docker files are
sidecar_app=${1}
# Context location in dot-cicd repo where the sidecar docker files can be referenced, it could be specified by defining the same env-var and it won't use its default value
: ${SIDECAR_APP_CONTEXT:="${DOCKER_SOURCE}/images/${sidecar_app}"}
# sidecar docker image name
export SIDECAR_APP_IMAGE_NAME="cicd-dotcms-${sidecar_app}"
# Location of the sidecar docker compose file
SIDECAR_DOCKER_COMPOSE=${SIDECAR_APP_CONTEXT}/dotcms-${sidecar_app}-service.yml
# Store original arguments here
args="$@"
# Remove first argument from original script arguments
set -- ${@:2}
# Define this a new arguments for sidecar app
export SIDECAR_ARGS=${@}
# Reset CUSTOM_STARTER_URL when RESET_STARTER is present and set to true
[[ "${RESET_STARTER}" == 'true' ]] && export CUSTOM_STARTER_URL=

echo "
############
Sidecar Vars
############
DOTCMS_DOCKER_COMPOSE: ${DOTCMS_DOCKER_COMPOSE}
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
SIDECAR_APP_CONTEXT: ${SIDECAR_APP_CONTEXT}
SIDECAR_DOCKER_COMPOSE: ${SIDECAR_DOCKER_COMPOSE}
Args: ${args}
SIDECAR_ARGS: ${SIDECAR_ARGS}
"

# Stop execution when no sidecar app is specified
if [[ -z "${sidecar_app}" ]]; then
  echo "Sidecar App was not specified, aborting"
  exit 1
fi

# Login to docker
echo ${DOCKER_TOKEN} | docker login --username ${DOCKER_USERNAME} --password-stdin

# Resolve which docker path to use (core or docker repo folder)
resolved_docker_path=$(dockerPathWithFallback ${DOT_CICD_TARGET}/dotcms ${docker_repo_path})
# Git clones docker repo with provided branch when docker repo matches docker path
[[ "${resolved_docker_path}" == "${docker_repo_path}" ]] \
  && fetchDocker ${docker_repo_path} ${DOCKER_BRANCH}

# Builds parametrized dotcms image for it to be used later
# buildBase cicd-dotcms ${docker_dotcms_path} TODO
# Copies folders with database volume and scripts to be included in the image
setupDocker ${SIDECAR_APP_CONTEXT} ${docker_repo_path}

# Store license folder before possible change
license_folder=${SIDECAR_APP_CONTEXT}

# if BUNDLED_MODE is activated then the dotcms and sidecar image are merged into one fat Docker file, same thing goes for the compose files
if [[ "${BUNDLED_MODE}" == 'true' ]]; then
  SIDECAR_DOCKER_COMPOSE=${SIDECAR_APP_CONTEXT}/dotcms-${sidecar_app}-service-bundled.yml
  SIDECAR_APP_CONTEXT="${SIDECAR_APP_CONTEXT}/Dockerfile-bundled"
else
  DOTCMS_DOCKER_COMPOSE_FILE_PARAM="-f ${DOTCMS_DOCKER_COMPOSE}"
fi

# Builds curl-tests image from parametrized image
buildBase ${SIDECAR_APP_IMAGE_NAME} ${SIDECAR_APP_CONTEXT} true
# Adds license file to volume
prepareLicense ${license_folder} ${LICENSE_KEY}

# Build docker compose up command
up_cmd="docker-compose
  -f ${SIDECAR_DOCKER_COMPOSE}
  ${DOTCMS_DOCKER_COMPOSE_FILE_PARAM}
  -f ${DOCKER_SOURCE}/tests/shared/${DATABASE_TYPE}-docker-compose.yml
  -f ${DOCKER_SOURCE}/tests/shared/open-distro-docker-compose.yml
  up
  --abort-on-container-exit
"
# Runs compose files to start the sidecar image with the  dotcms, open distro and database
executeCmd "${up_cmd}"
result=${cmdResult}

down_cmd="docker-compose
  -f ${SIDECAR_DOCKER_COMPOSE}
  ${DOTCMS_DOCKER_COMPOSE_FILE_PARAM}
  -f ${DOCKER_SOURCE}/tests/shared/${DATABASE_TYPE}-docker-compose.yml
  -f ${DOCKER_SOURCE}/tests/shared/open-distro-docker-compose.yml
  down
"
executeCmd "${down_cmd}"

if [[ ${result} -gt 2 ]]; then
  exit 1
fi
