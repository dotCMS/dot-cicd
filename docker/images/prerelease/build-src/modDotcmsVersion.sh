#!/bin/bash

#############################
# Script: modDotcmsVersion.sh
# For core repository replace dependencies versions and release process workflow dot-cicd version and finally commit
# and push changes

printf "\e[32m Modify dotcmsReleaseVersion, coreWebReleaseVersion, webComponentsReleaseVersion and dot-cicd branch version  \e[0m  \n"

pushd ${CORE_GITHUB_REPO}/dotCMS

# Modify release version in gradle.properties in CORE. Release version is passed in parameters
replaceTextInFile ./gradle.properties 'dotcmsReleaseVersion=.*$' "dotcmsReleaseVersion=${RELEASE_VERSION}"
# Modify  core-web release version in gradle.properties in CORE. Release version is passed in parameters
replaceTextInFile ./gradle.properties 'coreWebReleaseVersion=.*$' 'coreWebReleaseVersion=rc'
# Modify  dotcms-webcomponents release version in gradle.properties in CORE. Release version is passed in parameters
replaceTextInFile ./gradle.properties 'webComponentsReleaseVersion=.*$' 'webComponentsReleaseVersion=rc'
# Modify dot-cicd branch in release-process.yml in CORE
replaceTextInFile ../.github/workflows/release-process.yml 'DOT_CICD_BRANCH:.*$' "DOT_CICD_BRANCH: ${branch}"

# Commit gradle.properties with updated variables versions
executeCmd "git add gradle.properties
  && git add ../.github/workflows/release-process.yml
  && git commit -m 'Modify dotcmsReleaseVersion, coreWebReleaseVersion, webComponentsReleaseVersion and dot-cicd branch version'"
core_repo=$(resolveRepoUrl ${CORE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
executeCmd "git push ${core_repo} ${branch}"

popd