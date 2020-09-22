#!/bin/bash

export TEST_TYPE=curl
DOCKER_SOURCE=${DOT_CICD_LIB}/docker

setupTestRun curl

runFolder=${DOCKER_SOURCE}/tests/curl
licenseFolder=${runFolder}/license
mkdir -p ${licenseFolder}
chmod 777 ${licenseFolder}
licenseFile=${licenseFolder}/license.dat
touch ${licenseFile}
chmod 777 ${licenseFile}
echo "${LICENSE}" > ${licenseFile}

bell &
gcloud builds submit \
  --config=${DOT_CICD_LIB}/pipeline/travis/core/cloudrun-curl.yaml \
  --substitutions=_DB_TYPE=$DB_TYPE,_CUSTOM_RUN_ID=$TRAVIS_COMMIT_SHORT,_PULL_REQUEST=$TRAVIS_PULL_REQUEST,_GOOGLE_CREDENTIALS_BASE64=$GOOGLE_CREDENTIALS_BASE64,_GITHUB_USER=$GITHUB_USER,_GITHUB_USER_TOKEN=$GITHUB_USER_TOKEN,_PROVIDER_DB_USERNAME=$PROVIDER_DB_USERNAME,_PROVIDER_DB_PASSWORD=$PROVIDER_DB_PASSWORD,_DOCKER_SOURCE=$DOCKER_SOURCE,_DOT_CICD_PATH=$DOT_CICD_PATH,_DOT_CICD_CLOUD_PROVIDER=$DOT_CICD_CLOUD_PROVIDER,_DOT_CICD_PERSIST=$DOT_CICD_PERSIST,_DOT_CICD_TARGET=$DOT_CICD_TARGET .

dcResult=$?

cleanUpTest curl

if [[ ${dcResult} == 0 ]]; then
  exit 0
else
  exit 1
fi
