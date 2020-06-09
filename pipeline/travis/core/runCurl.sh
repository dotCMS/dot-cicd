#!/bin/bash

export TEST_TYPE=curl
: ${DOT_CICD_PATH:="./dotcicd"} && export DOT_CICD_PATH
source ${DOT_CICD_PATH}/library/pipeline/travis/travisCommon.sh

DOCKER_SOURCE=${DOT_CICD_LIB}/docker

. ${DOT_CICD_LIB}/pipeline/travis/printStoragePaths.sh
ignoring_return_value=$?

cp -R ${DOCKER_SOURCE}/setup/db ${DOCKER_SOURCE}/tests/curl/setup

runFolder=${DOCKER_SOURCE}/tests/curl
licenseFolder=${runFolder}/license
mkdir ${licenseFolder}
chmod 777 ${licenseFolder}
licenseFile=${licenseFolder}/license.dat
touch ${licenseFile}
chmod 777 ${licenseFile}
echo "${LICENSE}" > ${licenseFile}

bell &
gcloud builds submit \
  --config=${DOT_CICD_LIB}/pipeline/travis/core/cloudrun-curl.yaml \
  --substitutions=_DB_TYPE=$DB_TYPE,_CUSTOM_RUN_ID=$TRAVIS_COMMIT_SHORT,_PULL_REQUEST=$TRAVIS_PULL_REQUEST,_GOOGLE_CREDENTIALS_BASE64=$GOOGLE_CREDENTIALS_BASE64,_GITHUB_USER=$GITHUB_USER,_GITHUB_USER_TOKEN=$GITHUB_USER_TOKEN,_PROVIDER_DB_USERNAME=$PROVIDER_DB_USERNAME,_PROVIDER_DB_PASSWORD=$PROVIDER_DB_PASSWORD,_DOCKER_SOURCE=$DOCKER_SOURCE .
exit $?
