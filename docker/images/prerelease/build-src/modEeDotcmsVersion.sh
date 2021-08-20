#!/bin/bash

###############################
# Script: modEeDotcmsVersion.sh
# For enterprise repository replace dependencies versions and finally commit and push changes

printf "\e[32m Modify and push release version in gradle.properties in ENTERPRISE \e[0m  \n"

pushd ${ENTERPRISE_DIR}
replaceTextInFile ./gradle.properties 'dotcmsReleaseVersion=.*' "dotcmsReleaseVersion=${RELEASE_VERSION}"
executeCmd "git add gradle.properties
  && git commit -m 'update release version'"
enterprise_repo=$(resolveRepoUrl ${ENTERPRISE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
executeCmd "git push ${enterprise_repo} ${branch}"
popd
