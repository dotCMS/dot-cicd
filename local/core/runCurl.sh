#!/bin/bash

function usage {
  echo "Required environment variables:
    - BUILD_ID: (optional) commit to use to build image, default to 'master'
    - DATABASE_TYPE: (optional) database type, defaults to 'postgres'
    - LICENSE_KEY: license key string"
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
: ${SKIP_IMAGE_BUILD:="false"} && export SKIP_IMAGE_BUILD
export IMAGE_BASE_NAME="cicd-tests-base-image"
export SIDECAR_IMAGE_BASE_NAME="cicd-dotcms-image"
export databaseType=${DATABASE_TYPE}
export TEST_TYPE=curl
export EXPORT_RESULTS=false
# export BUILD_HASH=${GITHUB_SHA::8}

mkdir ${DOT_CICD_STAGE_OPERATION}/setup
mkdir ${DOT_CICD_STAGE_OPERATION}/license
cp -R ${DOT_CICD_LIB}/docker/setup/build-src ${DOT_CICD_STAGE_OPERATION}/setup
cp -R ${DOT_CICD_LIB}/docker/setup/db ${DOT_CICD_STAGE_OPERATION}/setup
cp ${DOT_CICD_LIB}/docker/tests/shared/* ${DOT_CICD_STAGE_OPERATION}
cp ${DOT_CICD_LIB}/docker/tests/sidecar/* ${DOT_CICD_STAGE_OPERATION}
cp -R ${DOT_CICD_DOCKER}/images/dotcms/ROOT ${DOT_CICD_STAGE_OPERATION}
cp -R ${DOT_CICD_DOCKER}/images/dotcms/build-src/build_dotcms.sh ${DOT_CICD_STAGE_OPERATION}/setup/build-src

echo "###################"
echo "More vars"
echo "###################"
echo "IMAGE_BASE_NAME: ${IMAGE_BASE_NAME}"
echo "SIDECAR_IMAGE_BASE_NAME: ${SIDECAR_IMAGE_BASE_NAME}"
echo "databaseType: ${databaseType}"
echo "PROVIDER_DB_USERNAME: ${PROVIDER_DB_USERNAME}"
echo "PROVIDER_DB_PASSWORD: ${PROVIDER_DB_PASSWORD}"
echo "TEST_TYPE: ${TEST_TYPE}"
echo "EXPORT_RESULTS: ${EXPORT_RESULTS}"
echo "SKIP_IMAGE_BUILD: ${SKIP_IMAGE_BUILD}"
echo "CURL_TEST: ${CURL_TEST}"
echo

if [[ "${SKIP_IMAGE_BUILD}" == 'false' ]]; then
  . ${CICD_LOCAL_FOLDER}/buildBase.sh
fi

licenseFolder=${DOT_CICD_STAGE_OPERATION}/license
mkdir -p ${licenseFolder}
chmod 777 ${licenseFolder}
licenseFile=${licenseFolder}/license.dat
touch ${licenseFile}
chmod 777 ${licenseFile}
echo "${LICENSE_KEY}" > ${licenseFile}
mkdir -p ${DOT_CICD_STAGE_OPERATION}/output

pushd ${DOT_CICD_STAGE_OPERATION}
docker-compose \
  -f sidecar-service-compose.yml \
  -f ${DATABASE_TYPE}-docker-compose.yml \
  -f open-distro-docker-compose.yml \
  up \
  --abort-on-container-exit
dcResult=$?

docker-compose \
  -f sidecar-service-compose.yml \
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
