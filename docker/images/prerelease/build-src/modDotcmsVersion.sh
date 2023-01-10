#!/bin/bash

#############################
# Script: modDotcmsVersion.sh
# For core repository replace dependencies versions and release process workflow dot-cicd version and finally commit
# and push changes

printf "\e[32m Modify dotcmsReleaseVersion, coreWebReleaseVersion, webComponentsReleaseVersion and dot-cicd branch version  \e[0m  \n"

pushd ${CORE_GITHUB_REPO}/dotCMS

# Modify release version in gradle.properties in CORE. Release version is passed in parameters
replaceTextInFile ./gradle.properties 'dotcmsReleaseVersion=.*$' "dotcmsReleaseVersion=${RELEASE_VERSION}"
# Modify dot-cicd branch in release-process.yml in CORE
replaceTextInFile ../.github/workflows/release-process.yml 'DOT_CICD_BRANCH:.*$' "DOT_CICD_BRANCH: ${BRANCH}"

# Commit gradle.properties with updated variables versions
executeCmd "git add gradle.properties ../.github/workflows/release-process.yml"
executeCmd "git commit -m 'Modify dotcmsReleaseVersion to ${RELEASE_VERSION}, coreWebReleaseVersion, webComponentsReleaseVersion to rc and dot-cicd branch version to ${BRANCH}'"

popd
