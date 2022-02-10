#!/bin/bash

##################################
# Script: generateAndUploadJars.sh
# Generates core and enterprise jays and upload them to artifactory
#
# $1: build_id: core branch or commit
# $2: ee_build_id: enterprise branch or commit
# $3: repo_username: artifactory repo username
# $4: repo_password: artifactory repo password
# $5: is_release: release flag

build_id=$1
ee_build_id=$2
repo_username=$3
repo_password=$4
is_release=$5

if [[ "${is_release}" == 'true' ]]; then
  pushd dotCMS
  executeCmd "./gradlew clean java -PuseGradleNode=false"

  pushd src/main/enterprise
  executeCmd "./gradlew clean jar -PuseGradleNode=false"
  popd

  echo
  echo '################################'
  echo 'Uploading Enterprise Edition jar'
  echo '################################'
  [[ "${is_release}" == 'true' ]] && releaseParam='-Prelease=true'
  executeCmd "./gradlew -b deploy.gradle uploadEnterprise
    ${releaseParam}
    -Pusername=${repo_username}
    -Ppassword=${repo_password}"
  [[ ${cmdResult} != 0 ]] && exit 1

  echo
  echo '####################'
  echo 'Uploading DotCMS jar'
  echo '####################'
  executeCmd "./gradlew -b deploy.gradle uploadDotcms ${releaseParam} -Pusername=${repo_username} -Ppassword=${repo_password} -PincludeDependencies=true"
  [[ ${cmdResult} != 0 ]] && exit 1

  popd
fi