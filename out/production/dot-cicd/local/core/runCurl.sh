#!/bin/bash

function usage {
  echo "Required environment variables:
    - BUILD_ID: (optional) commit to use to build image, defaults to 'master'
    - DATABASE_TYPE: (optional) database type, defaults to 'postgres'
    - LICENSE_KEY: license key string
    - SKIP_IMAGE_BUILD: (optional) flag to skip image build, defaults to true
    - CURL_TEST: (optional) filename of the postman collection to run, defaults to empty
    - DEBUG: (optional) debug flag to listen at port 8000, defaults to false"
}

if [[ -z "${LICENSE_KEY}" ]]; then
  echo "No license key was provided, aborting"
  usage
  exit 1
fi

: ${BUILD_ID:="master"} && export BUILD_ID
: ${DATABASE_TYPE:="postgres"} && export DATABASE_TYPE
: ${PROVIDER_DB_USERNAME:="postgres"} && export PROVIDER_DB_USERNAME
: ${PROVIDER_DB_PASSWORD:="postgres"} && export PROVIDER_DB_PASSWORD
: ${SKIP_IMAGE_BUILD:="true"} && export SKIP_IMAGE_BUILD
: ${DEBUG:="false"} && export DEBUG
: ${WAIT_DOTCMS_FOR:=80} && export WAIT_DOTCMS_FOR
export IMAGE_NAME="cicd-local-dotcms"
export databaseType=${DATABASE_TYPE}
export TEST_TYPE=curl
export EXPORT_REPORTS=false

mkdir ${DOT_CICD_STAGE_OPERATION}/setup
mkdir ${DOT_CICD_STAGE_OPERATION}/license
cp -R ${DOT_CICD_LIB}/docker/setup/build-src ${DOT_CICD_STAGE_OPERATION}/setup
cp -R ${DOT_CICD_LIB}/docker/setup/db ${DOT_CICD_STAGE_OPERATION}/setup
cp ${DOT_CICD_LIB}/docker/tests/shared/* ${DOT_CICD_STAGE_OPERATION}
cp ${DOT_CICD_LIB}/docker/tests/curl/* ${DOT_CICD_STAGE_OPERATION}
cp -R ${DOT_CICD_DOCKER_PATH}/images/dotcms/ROOT ${DOT_CICD_STAGE_OPERATION}
cp -R ${DOT_CICD_DOCKER_PATH}/images/dotcms/build-src/build_dotcms.sh ${DOT_CICD_STAGE_OPERATION}/setup/build-src

echo "###################"
echo "More vars"
echo "###################"
echo "IMAGE_NAME: ${IMAGE_NAME}"
echo "databaseType: ${databaseType}"
echo "PROVIDER_DB_USERNAME: ${PROVIDER_DB_USERNAME}"
echo "PROVIDER_DB_PASSWORD: ${PROVIDER_DB_PASSWORD}"
echo "TEST_TYPE: ${TEST_TYPE}"
echo "EXPORT_REPORTS: ${EXPORT_REPORTS}"
echo "SKIP_IMAGE_BUILD: ${SKIP_IMAGE_BUILD}"
echo "CURL_TEST: ${CURL_TEST}"
echo "DEBUG: ${DEBUG}"
echo

if [[ ${SKIP_IMAGE_BUILD} == false ]]; then
  buildBase ${IMAGE_NAME} ${DOT_CICD_STAGE_OPERATION}
fi

mkdir -p ${DOT_CICD_STAGE_OPERATION}/output && chmod 777 ${DOT_CICD_STAGE_OPERATION}/output
mkdir -p ${DOT_CICD_STAGE_OPERATION}/custom && chmod 777 ${DOT_CICD_STAGE_OPERATION}/custom

pushd ${DOT_CICD_STAGE_OPERATION}
docker-compose \
  -f sidecar-service-compose.yml \
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
