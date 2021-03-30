#!/bin/bash

BUILD_ID=${BRANCH}
EE_BUILD_ID=${EE_BRANCH}
EE_FOLDER=${DOT_CICD_LIB}/pipeline/ee

echo
echo '######################################################################'
echo "Build id: ${BUILD_ID}"
echo "EE Build id: ${EE_BUILD_ID}"
echo "Repo username: ${REPO_USERNAME}"
echo "Repo password: ${REPO_PASSWORD}"
echo "Is Release: ${IS_RELEASE}"
echo "Debug: ${DEBUG}"

java -version

. ${EE_FOLDER}/prepareGit.sh
. ${EE_FOLDER}/getSource.sh ${BUILD_ID}
. ${EE_FOLDER}/generateAndUploadJars.sh ${BUILD_ID} ${EE_BUILD_ID} ${REPO_USERNAME} ${REPO_PASSWORD} ${GITHUB_SHA} ${IS_RELEASE}
