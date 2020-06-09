#!/bin/bash

: ${DOT_CICD_PATH:="./dotcicd"} && export DOT_CICD_PATH
source ${DOT_CICD_PATH}/library/pipeline/travis/travisCommon.sh

DOCKER_SOURCE=${DOT_CICD_LIB}/docker

resolveCurrentBranch

bell &
gcloud builds submit \
  --config=${DOT_CICD_LIB}/pipeline/travis/core/cloudbuild-curl.yaml \
  --substitutions=_CUSTOM_RUN_ID=$TRAVIS_COMMIT_SHORT,_DOCKER_SOURCE=$DOCKER_SOURCE .
exit $?
