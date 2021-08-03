#!/bin/bash

function usage {
  echo "Required environment variables:
    - DOCKER_BRANCH: (optional) docker repo branch to use when building images, defaults to empty
    - BUILD_ID: (optional) commit to use to build image, defaults to 'master'
    - DATABASE_TYPE: (optional) database type, defaults to 'postgres'
    - LICENSE_KEY: license key string
    - SKIP_IMAGE_BUILD: (optional) flag to skip image build, defaults to true
    - CURL_TEST: (optional) filename of the postman collection to run, defaults to empty
    - DEBUG_MODE: (optional) debug flag to listen at port 8000, defaults to false
  "
}

if [[ -z "${LICENSE_KEY}" ]]; then
  echo "No license key was provided, aborting"
  usage
  exit 1
fi

: ${DOCKER_BRANCH:=""} && export DOCKER_BRANCH
: ${BUILD_ID:="master"} && export BUILD_ID
: ${DATABASE_TYPE:="postgres"} && export DATABASE_TYPE
: ${PROVIDER_DB_USERNAME:="postgres"} && export PROVIDER_DB_USERNAME
: ${PROVIDER_DB_PASSWORD:="postgres"} && export PROVIDER_DB_PASSWORD
: ${SKIP_IMAGE_BUILD:="true"} && export SKIP_IMAGE_BUILD
: ${DEBUG_MODE:="false"} && export DEBUG_MODE
: ${WAIT_DOTCMS_FOR:=80} && export WAIT_DOTCMS_FOR
export IMAGE_NAME="cicd-local-dotcms"
export databaseType=${DATABASE_TYPE}
export TEST_TYPE=curl
export EXPORT_REPORTS=false
export WAIT_DB_FOR=30
export WAIT_DOTCMS_FOR=80
DOCKER_DOTCMS_PATH=${DOT_CICD_DOCKER_PATH}/images/dotcms

echo "
###################
More vars
###################
DOCKER_BRANCH: ${DOCKER_BRANCH}
DOCKER_DOTCMS_PATH: ${DOCKER_DOTCMS_PATH}
IMAGE_NAME: ${IMAGE_NAME}
databaseType: ${databaseType}
PROVIDER_DB_USERNAME: ${PROVIDER_DB_USERNAME}
PROVIDER_DB_PASSWORD: ${PROVIDER_DB_PASSWORD}
TEST_TYPE: ${TEST_TYPE}
EXPORT_REPORTS: ${EXPORT_REPORTS}
SKIP_IMAGE_BUILD: ${SKIP_IMAGE_BUILD}
CURL_TEST: ${CURL_TEST}
WAIT_DB_FOR: ${WAIT_DB_FOR}
WAIT_DOTCMS_FOR: ${WAIT_DOTCMS_FOR}
DEBUG_MODE: ${DEBUG_MODE}
"

# Cloning core
repo_url=$(resolveRepoUrl ${CORE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${github_user})
gitClone ${repo_url} ${BUILD_ID}

# Resolve which docker path to use (core or docker repo folder)
RESOLVED_DOCKER_PATH=${CORE_GITHUB_REPO}/docker/dotcms
# Git clones docker repo with provided branch if
[[ "${RESOLVED_DOCKER_PATH}" == "${DOT_CICD_DOCKER_PATH}" ]] \
  && fetchDocker ${DOT_CICD_DOCKER_PATH} ${DOCKER_BRANCH}

if [[ "${SKIP_IMAGE_BUILD}" == 'false' ]]; then
  buildBase cicd-dotcms ${DOCKER_DOTCMS_PATH}
fi

setupDocker ${DOT_CICD_STAGE_OPERATION} ${RESOLVED_DOCKER_PATH}
cp ${DOCKER_SOURCE}/tests/shared/* ${DOT_CICD_STAGE_OPERATION}
cp ${DOCKER_SOURCE}/tests/curl/* ${DOT_CICD_STAGE_OPERATION}
buildBase ${IMAGE_NAME} ${DOT_CICD_STAGE_OPERATION} true

prepareLicense ${DOT_CICD_STAGE_OPERATION} ${LICENSE_KEY}

pushd ${DOT_CICD_STAGE_OPERATION}
docker-compose \
  -f curl-service.yml \
  -f ${DATABASE_TYPE}-docker-compose.yml \
  -f open-distro-docker-compose.yml \
  up \
  --abort-on-container-exit
dcResult=$?

docker-compose \
  -f curl-service.yml \
  -f ${DATABASE_TYPE}-docker-compose.yml \
  -f open-distro-docker-compose.yml \
  down
popd

echo "Opening: ${DOT_CICD_STAGE_OPERATION}/output/reports/html/index.html"
open ${DOT_CICD_STAGE_OPERATION}/output/reports/html/index.html

if [[ ${dcResult} == 0 ]]; then
  exit 0
else
  exit 1
fi
