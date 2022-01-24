#!/bin/bash

##################################
# Script: generateAndUploadJars.sh
# Generates and uploads enterprise jars to repo with credentials
#
# $1: build_id: core branch
# $2: ee_build_id: enterprise branch
# $3: repo_username: artifactory repo username
# $4: repo_password: artifactory repo password
# $4: github_sha: github commit SHA
# $5: is_release: is release flag

build_id=$1
ee_build_id=$2
repo_username=$3
repo_password=$4
github_sha=$5
is_release=$6

echo
echo '##################################'
echo 'Executing generateAndUploadJars.sh'
echo '##################################'

pushd ${DOT_CICD_PATH}/core/dotCMS

if [[ "${is_release}" != 'true' ]]; then
  releaseParam=''
  rev=${github_sha}
else
  releaseParam='-Prelease=true'
  rev=obfuscated
fi

# Build project
## Creating jar
pushd src/main/enterprise
executeCmd "./gradlew clean jar -PuseGradleNode=false"
popd

executeCmd "./gradlew java -PuseGradleNode=false"
[[ ${cmdResult} != 0 ]] && exit 1

echo
echo '################################'
echo 'Uploading Enterprise Edition jar'
echo '################################'
# Upload and deploy enterprise jars
executeCmd "./gradlew -b deploy.gradle uploadEnterprise
  ${releaseParam}
  -Pusername=${repo_username}
  -Ppassword=${repo_password}"
[[ ${cmdResult} != 0 ]] && exit 1

popd
