#!/bin/bash

########################
# Script: uploadEeJar.sh
# Upload enterprise jar to artifactory and updates EE version in main dotcms gradle properties file

printf "\e[32m Uploading enterprise jar \e[0m  \n"

pushd ${CORE_GITHUB_REPO}
pushd ${ENTERPRISE_DIR}
executeCmd "./gradlew clean jar -PuseGradleNode=false"
popd

# Upload enterprise jar
pushd dotCMS
release_param='-Prelease=true'
executeCmd "gradle -b deploy.gradle uploadArchives
  ${release_param}
  -Pusername=${REPO_USERNAME}
  -Ppassword=${REPO_PASSWORD}"
[[ ${cmdResult} != 0 ]] && exit 1

executeCmd "git checkout -- dependencies.gradle"
executeCmd "./gradlew clean java -PuseGradleNode=false"
[[ ${cmdResult} != 0 ]] && exit 1
popd

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
