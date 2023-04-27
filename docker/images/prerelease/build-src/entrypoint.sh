#!/bin/bash

#######################
# Script: entrypoint.sh
# Main script for pre-release process which runs a set of steps:
#

. /build/githubCommon.sh
. /build/releaseCommon.sh
. /build/preReleaseCommon.sh

echo
echo '######################################################################'
echo "Build id: ${BUILD_ID}"
echo "Build hash: ${BUILD_HASH}"
echo "Repo username: ${REPO_USERNAME}"
echo "Repo password: ${REPO_PASSWORD}"
echo "Github User: ${GITHUB_USER}"
echo "Github Token: ${GITHUB_USER_TOKEN}"
echo "NPM Token: ${NPM_TOKEN}"
echo "Docker username: ${docker_username}"
echo "Docker password: ${docker_password}"
echo "From Branch: ${FROM_BRANCH}"
echo "Release version: ${RELEASE_VERSION}"
echo "Dry-run: ${DRY_RUN}"
echo "Debug: ${DEBUG}"
echo

setGradle

mkdir -p /build/src
pushd /build/src
runScript setVars
runScript createBranches
runScript preBuildCore
runScript modDotcmsVersion
runScript setGithubLabels
runScript undoBranches
popd
