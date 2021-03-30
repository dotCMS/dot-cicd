#!/bin/bash

DOCKER_SOURCE=${DOT_CICD_LIB}/docker
export IMAGE_NAME='dotcms/dotcms-release-process'

pushd ${DOCKER_SOURCE}/images/release

if [[ ${IS_RELEASE} != true ]]; then
  executeCmd "docker build --pull --no-cache -t ${IMAGE_NAME} ."
  if [[ ${cmdResult} != 0 ]]; then
    popd
    exit 1
  fi
fi

set -- ${@:2}
exewcuteCmd "docker run --rm
  -v ${HOME_FOLDER}/.ssh:/root/.ssh
  -e build_id=\"${BRANCH}\"
  -e ee_build_id=\"${EE_BRANCH}\"
  -e repo_username=${REPO_USERNAME}
  -e repo_password=${REPO_PASSWORD}
  -e github_user=${GITHUB_USER}
  -e github_user_token=${GITHUB_USER_TOKEN}
  -e github_sha=${GITHUB_SHA}
  -e aws_access_key_id=${AWS_ACCESS_KEY_ID}
  -e aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
  -e docker_username=${DOCKER_USERNAME}
  -e docker_password=${DOCKER_PASSWORD}
  -e is_release=${IS_RELEASE}
  -e debug=${DEBUG}
 ${IMAGE_NAME} $@"

popd

if [[ ${cmdResult} == 0 ]]; then
  exit 0
else
  exit 1
fi
