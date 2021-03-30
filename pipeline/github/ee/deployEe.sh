#!/bin/bash

EE_FOLDER=${DOT_CICD_LIB}/pipeline/github/ee

echo "###########################################
BUILD_ID: ${BUILD_ID}
EE_BUILD_ID: ${EE_BUILD_ID}
BUILD_HASH: ${BUILD_HASH}
REPO_USERNAME: ${REPO_USERNAME}
REPO_PASSWORD: ${REPO_PASSWORD}
IS_RELEASE: ${IS_RELEASE}
GITHUB_USER_TOKEN: ${GITHUB_USER_TOKEN}
GITHUB_USER: ${GITHUB_USER}
###########################################
"

. ${EE_FOLDER}/getSource.sh ${GITHUB_USER} ${GITHUB_USER_TOKEN} ${BUILD_ID}
. ${EE_FOLDER}/generateAndUploadJars.sh ${BUILD_ID} ${EE_BUILD_ID} ${REPO_USERNAME} ${REPO_PASSWORD} ${BUILD_HASH} ${IS_RELEASE}
