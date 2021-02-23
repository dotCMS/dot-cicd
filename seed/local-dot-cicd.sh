#!/bin/bash

: ${DOT_CICD_PATH:="${HOME}/.dotcicd"} && export DOT_CICD_PATH
: ${DOT_CICD_STAGE_FOLDER:="${DOT_CICD_PATH}/stage"} && export DOT_CICD_STAGE_FOLDER
: ${DOT_CICD_BRANCH:="master"} && export DOT_CICD_BRANCH
: ${DOT_CICD_TARGET:="core"} && export DOT_CICD_TARGET
: ${DOT_CICD_DOCKER:="${DOT_CICD_PATH}/docker"} && export DOT_CICD_DOCKER
: ${DOT_CICD_DOCKER_BRANCH:=""} && export DOT_CICD_DOCKER_BRANCH
: ${DOT_CICD_CLOUD_PROVIDER:="github"} && export DOT_CICD_CLOUD_PROVIDER
export PROXY_MODE='true'

[[ -d ${DOT_CICD_PATH} ]] && rm -rf ${DOT_CICD_PATH}
mkdir ${DOT_CICD_PATH}

curl -fsSL https://raw.githubusercontent.com/dotCMS/dot-cicd/${DOT_CICD_BRANCH}/seed/install-dot-cicd.sh --output ${DOT_CICD_PATH}/pipeline.sh
chmod 700 ${DOT_CICD_PATH}/pipeline.sh

. ${DOT_CICD_PATH}/pipeline.sh

DOCKER_REPO='https://github.com/dotCMS/docker.git'
git clone ${DOCKER_REPO} ${DOT_CICD_DOCKER}
pushd ${DOT_CICD_DOCKER}
git fetch --all
if [[ -n "${DOT_CICD_DOCKER_BRANCH}" ]]; then
  git checkout -b ${DOT_CICD_DOCKER_BRANCH}
fi
popd

pushd ${DOT_CICD_LIB}
. ./local.sh $1 $2 $3 $4 $5
popd
