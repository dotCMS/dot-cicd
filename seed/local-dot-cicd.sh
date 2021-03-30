#!/bin/bash

: ${DOT_CICD_PATH:="${HOME}/.dotcicd"} && export DOT_CICD_PATH
: ${DOT_CICD_STAGE_FOLDER:="${DOT_CICD_PATH}/stage"} && export DOT_CICD_STAGE_FOLDER
: ${DOT_CICD_STAGE_PATH:="${DOT_CICD_PATH}/stage"} && export DOT_CICD_STAGE_PATH
: ${DOCKER_BRANCH:=""} && export DOCKER_BRANCH
: ${DOT_CICD_CLOUD_PROVIDER:="github"} && export DOT_CICD_CLOUD_PROVIDER
export LOCAL_MODE='true'

echo "###########################
Local-install dot-cicd vars
###########################
DOT_CICD_PATH: ${DOT_CICD_PATH}
DOT_CICD_STAGE_PATH: ${DOT_CICD_STAGE_PATH}
DOT_CICD_CLOUD_PROVIDER: ${DOT_CICD_CLOUD_PROVIDER}
DOCKER_BRANCH: ${DOCKER_BRANCH}
LOCAL_MODE: ${LOCAL_MODE}
"

[[ -d ${DOT_CICD_PATH} ]] && rm -rf ${DOT_CICD_PATH}
mkdir ${DOT_CICD_PATH}

curl -fsSL https://raw.githubusercontent.com/dotCMS/dot-cicd/${DOT_CICD_BRANCH}/seed/install-dot-cicd.sh --output ${DOT_CICD_PATH}/install-pipeline.sh
chmod 700 ${DOT_CICD_PATH}/install-pipeline.sh && . ${DOT_CICD_PATH}/install-pipeline.sh

pushd ${DOT_CICD_LIB}
. ./local.sh $@
popd
