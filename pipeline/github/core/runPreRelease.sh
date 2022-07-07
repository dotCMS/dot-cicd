#!/bin/bash

#######################
# Script: runPreRelease.sh
# Runs a docker image implemented for automating the pre-release process

export DOCKER_SOURCE=${DOT_CICD_LIB}/docker
export IMAGE_NAME='dotcms/dotcms-pre-release-process'

# Copy common collection of functions
cp ${DOT_CICD_LIB}/pipeline/github/githubCommon.sh ${DOCKER_SOURCE}/images/prerelease/build-src
cp ${DOCKER_SOURCE}/images/release/build-src/releaseCommon.sh ${DOCKER_SOURCE}/images/prerelease/build-src
cp ${DOCKER_SOURCE}/images/release/build-src/changeEeDependency.py ${DOCKER_SOURCE}/images/prerelease/build-src
cp ${DOCKER_SOURCE}/images/release/build-src/replaceTextInFile.py ${DOCKER_SOURCE}/images/prerelease/build-src
pushd ${DOCKER_SOURCE}/images/prerelease

executeCmd "docker build --no-cache
  --build-arg NODE_VERSION=${NODE_VERSION}
  -t ${IMAGE_NAME} ."
[[ ${cmdResult} != 0 ]] && exit 1

# Removes first argument
set -- ${@:2}
# Start docker pre-release-process container
executeCmd "docker run --rm
  -e BUILD_ID=\"${BUILD_ID}\"
  -e BUILD_HASH=${BUILD_HASH}
  -e REPO_USERNAME=${REPO_USERNAME}
  -e REPO_PASSWORD=${REPO_PASSWORD}
  -e GITHUB_USER=${GITHUB_USER}
  -e GITHUB_USER_EMAIL=${GITHUB_USER_EMAIL}
  -e GITHUB_USER_TOKEN=${GITHUB_USER_TOKEN}
  -e NPM_TOKEN=${NPM_TOKEN}
  -e RELEASE_VERSION=${RELEASE_VERSION}
  -e FROM_BRANCH=${FROM_BRANCH}
  -e NODE_VERSION=${NODE_VERSION}
  -e DEBUG=${DEBUG}
  ${IMAGE_NAME} $@"

popd

[[ ${cmdResult} != 0 ]] && exit 1
exit 0
