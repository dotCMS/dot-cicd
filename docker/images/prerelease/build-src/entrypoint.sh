#!/bin/bash

#######################
# Script: entrypoint.sh
# Main script for pre-release process which runs a set of steps:
#

. /build/githubCommon.sh
. /build/releaseCommon.sh
. /build/preReleaseCommon.sh

: ${DRY_RUN:="true"} && export DRY_RUN

echo
echo '######################################################################'
echo "Single CMD: ${single_cmd}"
echo "Build id: ${BUILD_ID}"
echo "Build hash: ${BUILD_HASH}"
echo "Repo username: ${REPO_USERNAME}"
echo "Repo password: ${REPO_PASSWORD}"
echo "Github User: ${GITHUB_USER}"
echo "Github Token: ${GITHUB_USER_TOKEN}"
echo "NPM Token: ${NPM_TOKEN}"
echo "Docker username: ${docker_username}"
echo "Docker password: ${docker_password}"
echo "Release version: ${RELEASE_VERSION}"
echo "Dry run: ${DRY_RUN}"
echo "Debug: ${DEBUG}"
echo

mkdir -p /build/src
pushd /build/src
runScript setVars
runScript createBranches
#runScript publishCoreWeb
runScript preBuildCore
runScript modEeDotcmsVersion
runScript modDotcmsVersion
runScript uploadEeJar
runScript undoBranches
runScript setGithubLabels
popd
