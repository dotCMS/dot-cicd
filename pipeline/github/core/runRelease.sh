#!/bin/bash

#######################
# Script: runRelease.sh
# Runs a docker image implemented for automating the release process

export DOCKER_SOURCE=${DOT_CICD_LIB}/docker
export IMAGE_NAME='dotcms/dotcms-release-process'

# Copy common collection of functions
cp ${DOT_CICD_LIB}/pipeline/github/githubCommon.sh ${DOCKER_SOURCE}/images/release/build-src

pushd ${DOCKER_SOURCE}/images/release

# When is not a release, build the release-process docker image
executeCmd "docker build --no-cache -t ${IMAGE_NAME} ."
if [[ ${cmdResult} != 0 ]]; then
  exit 1
fi

if [[ -n "${BASE_FOLDER}" ]]; then
  HOME_FOLDER=${BASE_FOLDER}
fi

# Removes first argument
set -- ${@:2}
# Start docker release-process container
executeCmd "docker run --rm
  -e BUILD_ID=\"${BUILD_ID}\"
  -e BUILD_HASH=${BUILD_HASH}
  -e EE_BUILD_ID=\"${EE_BUILD_ID}\"
  -e dotcms_version=\"${DOTCMS_VERSION}\"
  -e repo_username=${REPO_USERNAME}
  -e repo_password=${REPO_PASSWORD}
  -e GITHUB_USER=${GITHUB_USER}
  -e GITHUB_USER_EMAIL:=${GITHUGITHUB_USER_EMAIL:B_USER}
  -e GITHUB_USER_TOKEN=${GITHUB_USER_TOKEN}
  -e aws_access_key_id=${AWS_ACCESS_KEY_ID}
  -e aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
  -e docker_username=${DOCKER_USERNAME}
  -e docker_password=${DOCKER_PASSWORD}
  -e is_release=${IS_RELEASE}
  -e DEBUG=${DEBUG}
  ${IMAGE_NAME} $@"

popd

if [[ ${cmdResult} == 0 ]]; then
  exit 0
else
  exit 1
fi
