#!/bin/bash

CICD_FOLDER='dotcicd'
LIB_FOLDER=${CICD_FOLDER}/library
DOCKER_SOURCE=${CICD_FOLDER}/docker

source ${LIB_FOLDER}/pipeline/common.sh

DOCKER_IMAGES_GITHUB_REPO='https://github.com/dotCMS/docker.git'
gitFetchRepo ${DOCKER_IMAGES_GITHUB_REPO} ${DOCKER_SOURCE}

resolveCurrentBranch

bell &
gcloud builds submit \
  --config=${LIB_FOLDER}/pipeline/travis/core/cloudbuild.yaml \
  --substitutions=_GIT_BRANCH_COMMIT=$CURRENT_BRANCH,COMMIT_SHA=$TRAVIS_COMMIT_SHORT,_LICENSE_KEY=$LICENSE,_CUSTOM_RUN_ID=$TRAVIS_COMMIT_SHORT,_DOCKER_SOURCE=$DOCKER_SOURCE .
exit $?
