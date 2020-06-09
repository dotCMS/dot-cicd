#!/bin/bash

export TEST_TYPE=unit
: ${DOT_CICD_PATH:="./dotcicd"} && export DOT_CICD_PATH
source ${DOT_CICD_PATH}/library/pipeline/travis/travisCommon.sh

DOCKER_SOURCE=${DOT_CICD_LIB}/docker

. ${DOT_CICD_LIB}/pipeline/travis/printStoragePaths.sh
ignoring_return_value=$?

bell &
gcloud builds submit \
  --config=${DOT_CICD_LIB}/pipeline/travis/core/cloudrun-unit.yaml \
  --substitutions=_CUSTOM_RUN_ID=$TRAVIS_COMMIT_SHORT,_PULL_REQUEST=$TRAVIS_PULL_REQUEST,_GOOGLE_CREDENTIALS_BASE64=$GOOGLE_CREDENTIALS_BASE64,_GITHUB_USER=$GITHUB_USER,_GITHUB_USER_TOKEN=$GITHUB_USER_TOKEN,_DOCKER_SOURCE=$DOCKER_SOURCE .
exit $?
