#!/bin/bash

########################
# Script: uploadEeJar.sh
# Upload enterprise jar to artifactory and updates EE version in main dotcms gradle properties file

printf "\e[32m Uploading enterprise jar \e[0m  \n"

pushd ${CORE_GITHUB_REPO}/dotCMS

# Upload enterprise jar
[[ "${DRY_RUN}" != 'true' ]] && release_param='-Prelease=true'
executeCmd "./gradlew -b deploy.gradle uploadEnterprise
  ${release_param}
  -Pusername=${REPO_USERNAME}
  -Ppassword=${REPO_PASSWORD}"

replaceTextInFile ../.gitmodules 'branch = .*' "branch = ${branch}"
executeCmd "git add ../.gitmodules"
executeCmd "git commit -m 'update release version'"
core_repo=$(resolveRepoUrl ${CORE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
executeCmd "git push ${core_repo} ${branch}"

popd
