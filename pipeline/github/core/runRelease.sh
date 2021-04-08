#!/bin/bash

DOCKER_SOURCE=${DOT_CICD_LIB}/docker
IMAGE_NAME='dotcms/dotcms-release-process'

cd ${DOCKER_SOURCE}/release

echo
echo '############################################################################################################################################'
echo "Executing: docker build --pull --no-cache -t ${IMAGE_NAME} ."
echo "Executing: docker run --rm \
  -v ${BASE_FOLDER}/.ssh:/root/.ssh \
  -e build_id=\"${BRANCH}\" \
  -e ee_build_id=\"${EE_BRANCH}\" \
  -e repo_username=${REPO_USERNAME} \
  -e repo_password=${REPO_PASSWORD} \
  -e github_user=${GITHUB_USER} \
  -e github_user_token=${GITHUB_USER_TOKEN} \
  -e github_sha=${GITHUB_SHA} \
  -e aws_access_key_id=${AWS_ACCESS_KEY_ID} \
  -e aws_secret_access_key=${AWS_SECRET_ACCESS_KEY} \
  -e docker_username=${DOCKER_USERNAME} \
  -e docker_password=${DOCKER_PASSWORD} \
  -e is_release=${IS_RELEASE} \
  -e debug=${DEBUG} \
  -e ee_rsa=${SSH_RSA_KEY} \
 ${IMAGE_NAME} $2 $3 $4 $5 $6"
echo '############################################################################################################################################'

docker build --pull --no-cache -t ${IMAGE_NAME} .
dResult=$?
if [[ ${dResult} != 0 ]]; then
  exit 1
fi

docker run --rm \
  -v ${BASE_FOLDER}/.ssh:/root/.ssh \
  -e build_id="${BRANCH}" \
  -e ee_build_id="${EE_BRANCH}" \
  -e repo_username=${REPO_USERNAME} \
  -e repo_password=${REPO_PASSWORD} \
  -e github_user=${GITHUB_USER} \
  -e github_user_token=${GITHUB_USER_TOKEN} \
  -e github_sha=${GITHUB_SHA} \
  -e aws_access_key_id=${AWS_ACCESS_KEY_ID} \
  -e aws_secret_access_key=${AWS_SECRET_ACCESS_KEY} \
  -e docker_username=${DOCKER_USERNAME} \
  -e docker_password=${DOCKER_PASSWORD} \
  -e is_release=${IS_RELEASE} \
  -e debug=${DEBUG} \
  -e ee_rsa=${SSH_RSA_KEY} \
  ${IMAGE_NAME} $2 $3 $4 $5 $6
dResult=$?
if [[ ${dResult} == 0 ]]; then
  exit 0
else
  exit 1
fi
