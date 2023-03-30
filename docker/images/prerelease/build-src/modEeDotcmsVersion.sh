#!/bin/bash

###############################
# Script: modEeDotcmsVersion.sh
# For enterprise repository replace dependencies versions and finally commit and push changes

printf "\e[32m Modify and push release version in gradle.properties in ENTERPRISE \e[0m  \n"

pushd ${CORE_GITHUB_REPO}/${ENTERPRISE_DIR}
replaceTextInFile ./gradle.properties 'dotcmsReleaseVersion=.*$' "dotcmsReleaseVersion=${RELEASE_VERSION}"
executeCmd "git add gradle.properties"
executeCmd "git commit -m 'Update release version to ${RELEASE_VERSION}'"
popd
