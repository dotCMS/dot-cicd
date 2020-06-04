#!/bin/bash

CICD_FOLDER='dotcicd'
LIB_FOLDER=${CICD_FOLDER}/library
DOCKER_SOURCE=${LIB_FOLDER}/docker

source ${LIB_FOLDER}/pipeline/common.sh

resolveCurrentBranch

bell &
gcloud builds submit \
  --config=${LIB_FOLDER}/pipeline/travis/core/cloudbuild-curl.yaml \
  --substitutions=_LICENSE_KEY=$LICENSE,_CUSTOM_RUN_ID=$TRAVIS_COMMIT_SHORT,_DOCKER_SOURCE=$DOCKER_SOURCE .
exit $?
