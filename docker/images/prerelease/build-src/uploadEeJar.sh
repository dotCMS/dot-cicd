#!/bin/bash

########################
# Script: uploadEeJar.sh
# Upload enterprise jar to artifactory and updates EE version in main dotcms gradle properties file

printf "\e[32m Uploading enterprise jar \e[0m  \n"

pushd ${CORE_GITHUB_REPO}

# Upload enterprise jar
if [[ "${DRY_RUN}" != 'true' ]]; then
  release_param='-Prelease=true'
else
  release_param=
fi

pushd ${ENTERPRISE_DIR}
executeCmd "./gradlew clean jar -PuseGradleNode=false"
popd

pushd dotCMS
executeCmd "./gradlew -b deploy.gradle uploadEnterprise
  ${release_param}
  -Pusername=${REPO_USERNAME}
  -Ppassword=${REPO_PASSWORD}"
[[ ${cmdResult} != 0 ]] && exit 1
popd

replaceTextInFile .gitmodules 'branch = .*' "branch = ${branch}"
executeCmd "git add .gitmodules"
executeCmd "git commit -m 'update release version'"
core_repo=$(resolveRepoUrl ${CORE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
executeCmd "git push ${core_repo} ${branch}"
popd
