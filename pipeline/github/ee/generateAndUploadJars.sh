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

pushd ${DOT_CICD_PATH}/core/dotCMS
echo
echo '######################################################################'
echo 'Building DotCMS with: ./gradlew java -PuseGradleNode=false'
echo '######################################################################'
# Build project
./gradlew java -PuseGradleNode=false
if [[ $? != 0 ]]; then
  echo 'Error executing ./gradlew java -PuseGradleNode=false'
  exit 1
fi

# Mark this as release or dry-run
if [[ "${is_release}" == 'true' ]]; then
  releaseParam='-Prelease=true'
else
  releaseParam=''
  #  This is for testing purposes, we should never seen a branch no other than master or a release one
  if [[ "${build_id}" != 'master' ]]; then
    cp ./gradle.properties ./gradle.properties.bak
    sed -i "s,^dotcmsReleaseVersion=.*$,dotcmsReleaseVersion=${github_sha},g" ./gradle.properties
    echo "Overriding dotcmsReleaseVersion to: ${github_sha}"
    cat ./gradle.properties | grep dotcmsReleaseVersion
  fi
fi

echo
echo '####################################################################################################################'
echo 'Uploading Enterprise Edition jar'
echo "./gradlew -b deploy.gradle uploadEnterprise ${releaseParam} -Pusername=${repo_username} -Ppassword=${repo_password}"
echo '####################################################################################################################'
# Upload and deploy enterprise jars
./gradlew -b deploy.gradle uploadEnterprise ${releaseParam} -Pusername=${repo_username} -Ppassword=${repo_password}
if [[ $? != 0 ]]; then
  echo "Error executing ./gradlew -b deploy.gradle uploadEnterprise ${releaseParam} -Pusername=${repo_username} -Ppassword=${repo_password}"
  exit 1
fi

popd
