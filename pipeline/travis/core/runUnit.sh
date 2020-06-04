#!/bin/bash

export TEST_TYPE=unit
CICD_FOLDER='dotcicd'
LIB_FOLDER=${CICD_FOLDER}/library
DOCKER_SOURCE=${LIB_FOLDER}/docker

source ${LIB_FOLDER}/pipeline/common.sh
bash ${LIB_FOLDER}/pipeline/travis/printStoragePaths.sh
ignoring_return_value=$?

bell &
gcloud builds submit \
  --config=${LIB_FOLDER}/pipeline/travis/core/cloudrun-unit.yaml \
  --substitutions=_CUSTOM_RUN_ID=$TRAVIS_COMMIT_SHORT,_PULL_REQUEST=$TRAVIS_PULL_REQUEST,_GOOGLE_CREDENTIALS_BASE64=$GOOGLE_CREDENTIALS_BASE64,_GITHUB_USER=$GITHUB_USER,_GITHUB_USER_TOKEN=$GITHUB_USER_TOKEN,_DOCKER_SOURCE=$DOCKER_SOURCE .
exit $?
