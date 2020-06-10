#!/bin/bash

DOCKER_SOURCE=${DOT_CICD_PATH}/docker
gitFetchRepo "https://github.com/dotCMS/docker.git" ${DOCKER_SOURCE}

resolveCurrentBranch

bell &
gcloud builds submit \
  --config=${DOT_CICD_LIB}/pipeline/travis/core/cloudbuild.yaml \
  --substitutions=_GIT_BRANCH_COMMIT=$CURRENT_BRANCH,COMMIT_SHA=$TRAVIS_COMMIT_SHORT,_LICENSE_KEY=$LICENSE,_CUSTOM_RUN_ID=$TRAVIS_COMMIT_SHORT,_DOCKER_SOURCE=$DOCKER_SOURCE .
exit $?
