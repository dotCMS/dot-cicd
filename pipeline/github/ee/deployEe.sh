#!/bin/bash

#####################
# Script: deployEe.sh
# Runs scripts in a sequential way:
#  - Git clones ans its submodules with the specified branch
#  - Generates and uploads the enterprise jars to repo using repo credentials

EE_FOLDER=${DOT_CICD_LIB}/pipeline/github/ee

echo "###########################################
BUILD_ID: ${BUILD_ID}
BUILD_HASH: ${BUILD_HASH}
REPO_USERNAME: ${REPO_USERNAME}
REPO_PASSWORD: ${REPO_PASSWORD}
IS_RELEASE: ${IS_RELEASE}
GITHUB_USER_TOKEN: ${GITHUB_USER_TOKEN}
GITHUB_USER: ${GITHUB_USER}
###########################################
"

source ${DOT_CICD_LIB}/docker/images/release/build-src/releaseCommon.sh

installGradle
setGradle

# Fetch core and its submodules from github
. ${EE_FOLDER}/getSource.sh ${BUILD_ID}
# Generate an upload EE jars
. ${EE_FOLDER}/generateAndUploadJars.sh ${BUILD_ID} ${REPO_USERNAME} ${REPO_PASSWORD} ${BUILD_HASH} ${IS_RELEASE}
