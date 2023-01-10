#!/bin/bash

########################
# Script: uploadEeJar.sh
# Upload enterprise jar to artifactory and updates EE version in main dotcms gradle properties file

printf "\e[32m Uploading enterprise jar \e[0m  \n"

pushd ${CORE_GITHUB_REPO}
pushd ${ENTERPRISE_DIR}
enterprise_lib_dir=build/libs
ee_jar=${enterprise_lib_dir}/ee_${RELEASE_VERSION}.jar
executeCmd "./gradlew clean jar"
executeCmd "ls -las ${enterprise_lib_dir}"
executeCmd "mv ${enterprise_lib_dir}/ee_obfuscated.jar ${ee_jar}"
executeCmd "ls -las ${enterprise_lib_dir}"
popd

# Upload enterprise jar
pushd dotCMS
executeCmd "gradle -b deploy.gradle uploadArchives
  -Prelease=true
  -Pusername=${REPO_USERNAME}
  -Ppassword=${REPO_PASSWORD}
  -Pfile=./src/main/enterprise/${ee_jar}"
[[ ${cmdResult} != 0 ]] && exit 1

executeCmd "./gradlew clean java"
[[ ${cmdResult} != 0 ]] && exit 1
popd

replaceTextInFile .gitmodules 'branch = .*' "branch = ${BRANCH}"
executeCmd "git add .gitmodules"
executeCmd "git commit -m 'Update branch in git submodule to ${BRANCH}'"
executeCmd "git status"
core_repo=$(resolveRepoUrl ${CORE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
executeCmd "git push ${core_repo} ${BRANCH}"

pushd ${ENTERPRISE_DIR}
executeCmd "git status"
enterprise_repo=$(resolveRepoUrl ${ENTERPRISE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
executeCmd "git push ${enterprise_repo} ${BRANCH}"
popd

executeCmd "git status"

popd
