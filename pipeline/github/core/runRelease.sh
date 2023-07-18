#!/bin/bash

#######################
# Script: runRelease.sh
# Runs a docker image implemented for automating the release process

export DOCKER_SOURCE=${DOT_CICD_LIB}/docker
export IMAGE_NAME='dotcms/dotcms-release-process'

# Copy common collection of functions
cp ${DOT_CICD_LIB}/pipeline/github/githubCommon.sh ${DOCKER_SOURCE}/images/release/build-src
pushd ${DOCKER_SOURCE}/images/release

executeCmd "docker build --no-cache -t ${IMAGE_NAME} ."
[[ ${cmdResult} != 0 ]] && exit 1

# Removes first argument
set -- ${@:2}
# Start docker release-process container
executeCmd "docker run --rm
  -e BUILD_ID=\"${BUILD_ID}\"
  -e BUILD_HASH=${BUILD_HASH}
  -e REPO_USERNAME=${REPO_USERNAME}
  -e REPO_PASSWORD=${REPO_PASSWORD}
  -e GITHUB_USER=${GITHUB_USER}
  -e GITHUB_USER_EMAIL=${GITHUB_USER_EMAIL}
  -e GITHUB_USER_TOKEN=${GITHUB_USER_TOKEN}
  -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
  -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
  -e IS_RELEASE=${IS_RELEASE}
  -e IS_LTS=${IS_LTS}
  -e NODE_VERSION=${NODE_VERSION}
  -e BRANCHING_MODEL=${BRANCHING_MODEL}
  ${IMAGE_NAME} $@"

popd

[[ ${cmdResult} != 0 ]] && exit ${cmdResult}
exit 0
