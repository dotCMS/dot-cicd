#!/bin/bash

build_id=$1
ee_build_id=$2
repo_username=$3
repo_password=$4
github_sha=$5
is_release=$6

pushd ${DOT_CICD_PATH}/core/dotCMS
echo
echo '######################################################################'
echo 'Building DotCMS with: ./gradlew java -PuseGradleNode=false'
echo '######################################################################'
./gradlew java -PuseGradleNode=false
if [[ $? != 0 ]]; then
  echo 'Error executing ./gradlew java -PuseGradleNode=false'
  exit 1
fi

if [[ ${is_release} == true ]]; then
  releaseParam='-Prelease=true'
else
  releaseParam=''
fi

echo
echo '####################################################################################################################'
echo 'Uploading Enterprise Edition jar'
echo "./gradlew -b deploy.gradle uploadEnterprise ${releaseParam} -Pusername=${repo_username} -Ppassword=${repo_password}"
echo '####################################################################################################################'
./gradlew -b deploy.gradle uploadEnterprise ${releaseParam} -Pusername=${repo_username} -Ppassword=${repo_password}
if [[ $? != 0 ]]; then
  echo "Error executing ./gradlew -b deploy.gradle uploadEnterprise ${releaseParam} -Pusername=${repo_username} -Ppassword=${repo_password}"
  exit 1
fi

popd
