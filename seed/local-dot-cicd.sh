#!/bin/bash

: ${DOT_CICD_PATH:="${HOME}/.dotcicd"} && export DOT_CICD_PATH
: ${DOT_CICD_STAGE_PATH:="${DOT_CICD_PATH}/stage"} && export DOT_CICD_STAGE_PATH
: ${DOT_CICD_DOCKER_PATH:="${DOT_CICD_PATH}/docker"} && export DOT_CICD_DOCKER_PATH
: ${DOCKER_BRANCH:=""} && export DOCKER_BRANCH
: ${DOT_CICD_CLOUD_PROVIDER:="github"} && export DOT_CICD_CLOUD_PROVIDER
export PROXY_MODE='true'

echo "#############
dot-cicd vars
#############
DOT_CICD_PATH: ${DOT_CICD_PATH}
DOT_CICD_STAGE_PATH: ${DOT_CICD_STAGE_PATH}
DOT_CICD_DOCKER_PATH: ${DOT_CICD_DOCKER_PATH}
DOCKER_BRANCH: ${DOCKER_BRANCH}
DOT_CICD_CLOUD_PROVIDER: ${DOT_CICD_CLOUD_PROVIDER}
PROXY_MODE: ${PROXY_MODE}
"

[[ -d ${DOT_CICD_PATH} ]] && rm -rf ${DOT_CICD_PATH}
mkdir ${DOT_CICD_PATH}

curl -fsSL https://raw.githubusercontent.com/dotCMS/dot-cicd/${DOT_CICD_BRANCH}/seed/install-dot-cicd.sh --output ${DOT_CICD_PATH}/install-pipeline.sh
chmod 700 ${DOT_CICD_PATH}/install-pipeline.sh && . ${DOT_CICD_PATH}/install-pipeline.sh

pushd ${DOT_CICD_LIB}
. ./local.sh $@
popd
