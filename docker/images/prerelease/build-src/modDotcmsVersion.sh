#!/bin/bash

#############################
# Script: modDotcmsVersion.sh
# For core repository replace dependencies versions and release process workflow dot-cicd version and finally commit
# and push changes

printf "\e[32m Modify dotcmsReleaseVersion, coreWebReleaseVersion, webComponentsReleaseVersion and dot-cicd branch version  \e[0m  \n"

pushd ${CORE_GITHUB_REPO}/dotCMS

# Modify release version in gradle.properties in CORE. Release version is passed in parameters
replaceTextInFile ./gradle.properties 'dotcmsReleaseVersion=.*$' "dotcmsReleaseVersion=${RELEASE_VERSION}"
# Modify core-web release version in gradle.properties in CORE. Release version is passed in parameters
replaceTextInFile ./gradle.properties 'coreWebReleaseVersion=.*$' 'coreWebReleaseVersion=rc'
# Modify dotcms-webcomponents release version in gradle.properties in CORE. Release version is passed in parameters
replaceTextInFile ./gradle.properties 'webComponentsReleaseVersion=.*$' 'webComponentsReleaseVersion=rc'
# Modify dot-cicd branch in release-process.yml in CORE
replaceTextInFile ../.github/workflows/release-process.yml 'DOT_CICD_BRANCH:.*$' "DOT_CICD_BRANCH: ${branch}"

# Commit gradle.properties with updated variables versions
executeCmd "git add gradle.properties ../.github/workflows/release-process.yml"
executeCmd "git commit -m 'Modify dotcmsReleaseVersion to ${RELEASE_VERSION}, coreWebReleaseVersion, webComponentsReleaseVersion to rc and dot-cicd branch version to ${branch}'"

# TODO: uncomment when uploadEe jar works once again
#executeCmd "python3 /build/changeEeDependency.py obfuscated"
#cat dependencies.gradle | grep enterprise

popd

# TODO: remove the following when uploadEe jar works once again
pushd ${CORE_GITHUB_REPO}
replaceTextInFile .gitmodules 'branch = .*' "branch = ${branch}"
executeCmd "git add .gitmodules"
executeCmd "git commit -m 'Update branch in git submodule to ${branch}'"
executeCmd "git status"
core_repo=$(resolveRepoUrl ${CORE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
executeCmd "git push ${core_repo} ${branch}"

pushd ${ENTERPRISE_DIR}
executeCmd "git status"
enterprise_repo=$(resolveRepoUrl ${ENTERPRISE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
executeCmd "git push ${enterprise_repo} ${branch}"
popd

popd
