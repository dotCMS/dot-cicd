#!/bin/bash

###############################
# Script: modEeDotcmsVersion.sh
# For enterprise repository replace dependencies versions and finally commit and push changes

printf "\e[32m Modify and push release version in gradle.properties in ENTERPRISE \e[0m  \n"

# If running in dry-run mode then change the ee dependency to use local
if [[ "${DRY_RUN}" == 'true' ]]; then
  pushd ${CORE_GITHUB_REPO}/dotCMS
  executeCmd "python3 /build/changeEeDependency.py ${RELEASE_VERSION}"
  cat dependencies.gradle | grep enterprise
  executeCmd "git add dependencies.gradle"
  popd
fi

pushd ${CORE_GITHUB_REPO}/${ENTERPRISE_DIR}
replaceTextInFile ./gradle.properties 'dotcmsReleaseVersion=.*' "dotcmsReleaseVersion=${RELEASE_VERSION}"
executeCmd "git add gradle.properties && git commit -m 'update release version'"
enterprise_repo=$(resolveRepoUrl ${ENTERPRISE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
executeCmd "git push ${enterprise_repo} ${branch}"
popd
