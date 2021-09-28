#!/bin/bash

##################################
# Script: generateAndUploadJars.sh
# Generates core and enterprise jays and upload them to artifactory
#
# $1: build_id: core branch or commit
# $2: ee_build_id: enterprise branch or commit
# $3: repo_username: artifactory repo username
# $4: repo_password: artifactory repo password
# $5: github_sha: commit SHA
# $6: is_release: release flag

build_id=$1
ee_build_id=$2
repo_username=$3
repo_password=$4
github_sha=$5
is_release=$6

pushd dotCMS

executeCmd "./gradlew java -PuseGradleNode=false"
[[ ${cmdResult} != 0 ]] && exit 1

releaseParam='-Prelease=true'
if [[ "${is_release}" != 'true' ]]; then
  releaseParam=''
  release_version=${github_sha}
  changeDotcmsVersion ${release_version}
  executeCmd "python3 /build/changeEeDependency.py ${release_version}"
  cat dependencies.gradle | grep enterprise

  pushd src/main/enterprise
  changeDotcmsVersion ${release_version}
  executeCmd "./gradlew clean jar"
  popd
fi

echo
echo '################################'
echo 'Uploading Enterprise Edition jar'
echo '################################'
executeCmd "./gradlew -b deploy.gradle uploadEnterprise
  ${releaseParam}
  -Pusername=${repo_username}
  -Ppassword=${repo_password}"
[[ ${cmdResult} != 0 ]] && exit 1

[[ "${is_release}" != 'true' ]] \
  && ls -las src/main/enterprise/build/libs \
  && executeCmd "./gradlew clean jar"

echo
echo '####################'
echo 'Uploading DotCMS jar'
echo '####################'
executeCmd "./gradlew -b deploy.gradle uploadDotcms ${releaseParam} -Pusername=${repo_username} -Ppassword=${repo_password} -PincludeDependencies=true"
[[ ${cmdResult} != 0 ]] && exit 1

popd
