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
docker_repo_path=${DOT_CICD_PATH}/docker
# Gets the first argument to be considered the folder where the sidecar Docker files are
sidecar_app=${1}
# Context location in dot-cicd repo where the sidecar docker files can be referenced, it could be specified by defining the same env-var and it won't use its default value
: ${SIDECAR_APP_CONTEXT:="${DOCKER_SOURCE}/images/${sidecar_app}"}
# sidecar docker image name
SIDECAR_APP_IMAGE_NAME="cicd-dotcms"
# Resolve which docker path to use (core or docker repo folder)
resolved_docker_path=${CORE_GITHUB_REPO}/docker/dotcms
# Location of the sidecar docker compose file
if [[ -n "${sidecar_app}" ]]; then
  SIDECAR_APP_IMAGE_NAME="${SIDECAR_APP_IMAGE_NAME}-${sidecar_app}"
  SIDECAR_DOCKER_COMPOSE=${SIDECAR_APP_CONTEXT}/dotcms-${sidecar_app}-service.yml
  SIDECAR_APP_IMAGE_FILE_PARAM="-f ${SIDECAR_DOCKER_COMPOSE}"
else
  SIDECAR_APP_CONTEXT=$(dirname ${DOTCMS_DOCKER_COMPOSE})
  echo "Sidecar App was not specified, just starting dotcms instance"
fi
export SIDECAR_APP_IMAGE_NAME
# Store license folder before possible change

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
CUSTOM_STARTER_URL: ${CUSTOM_STARTER_URL}
docker_repo_path: ${docker_repo_path}
sidecar_app: ${sidecar_app}
SIDECAR_APP_CONTEXT: ${SIDECAR_APP_CONTEXT}
SIDECAR_DOCKER_COMPOSE: ${SIDECAR_DOCKER_COMPOSE}
Args: ${args}
SIDECAR_ARGS: ${SIDECAR_ARGS}
"

# Cloning core
repo_url=$(resolveRepoUrl ${CORE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${github_user})
gitClone ${repo_url} ${BUILD_ID}

# Login to docker
echo ${DOCKER_TOKEN} | docker login --username ${DOCKER_USERNAME} --password-stdin
# Copies folders with database volume and scripts to be included in the image
setupDocker ${SIDECAR_APP_CONTEXT} ${resolved_docker_path}

# Builds parametrized dotcms image for it to be used later
buildBase cicd-dotcms ${resolved_docker_path}

# Builds sidecar image from parametrized image
[[ -n "${sidecar_app}" ]] && buildBase ${SIDECAR_APP_IMAGE_NAME} ${SIDECAR_APP_CONTEXT} true

# Adds license file to volume
prepareLicense ${SIDECAR_APP_CONTEXT} ${LICENSE_KEY}

# Build docker compose up command
up_cmd="docker-compose 
  ${SIDECAR_APP_IMAGE_FILE_PARAM}
  -f ${DOTCMS_DOCKER_COMPOSE}
  -f ${DOCKER_SOURCE}/tests/shared/${DATABASE_TYPE}-docker-compose.yml
  -f ${DOCKER_SOURCE}/tests/shared/open-distro-docker-compose.yml
  up -d
"
# Runs compose files to start the sidecar image with the  dotcms, open distro and database
executeCmd "${up_cmd}"
result=${cmdResult}

if [[ -n "${sidecar_app}" ]]; then
  down_cmd="docker-compose
    ${SIDECAR_APP_IMAGE_FILE_PARAM}
    -f ${DOTCMS_DOCKER_COMPOSE}
    -f ${DOCKER_SOURCE}/tests/shared/${DATABASE_TYPE}-docker-compose.yml
    -f ${DOCKER_SOURCE}/tests/shared/open-distro-docker-compose.yml
    down
  "
  executeCmd "${down_cmd}"
fi

[[ ${result} != 0 ]] && exit 0
