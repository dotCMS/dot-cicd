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

echo
echo '######################################################################'
echo 'Building DotCMS with: ./gradlew java -PuseGradleNode=false'
echo '######################################################################'
./gradlew java -PuseGradleNode=false
if [[ $? != 0 ]]; then
  echo 'Error executing ./gradlew java -PuseGradleNode=false'
  exit 1
fi

releaseParam='-Prelease=true'
if [[ "${is_release}" != 'true' ]]; then
  releaseParam=''
  release_version=${github_sha}
  sed -i "s,^dotcmsReleaseVersion=.*$,dotcmsReleaseVersion=${release_version},g" ./gradle.properties
  echo "Overriding dotcmsReleaseVersion to: ${release_version}"
  cat ./gradle.properties | grep dotcmsReleaseVersion
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

if [[ "${is_release}" != 'true' ]]; then
  release_version="${release_version}-SNAPSHOT"
  sed -i "s,^dotcmsReleaseVersion=.*$,dotcmsReleaseVersion=${release_version},g" ./gradle.properties
  echo "Overriding dotcmsReleaseVersion to: ${release_version}"
  cat ./gradle.properties | grep dotcmsReleaseVersion
fi

echo
echo '###########################################################################################################################################'
echo 'Uploading DotCMS jar'
echo "./gradlew -b deploy.gradle uploadDotcms ${releaseParam} -Pusername=${repo_username} -Ppassword=${repo_password} -PincludeDependencies=true"
echo '###########################################################################################################################################'
./gradlew -b deploy.gradle uploadDotcms ${releaseParam} -Pusername=${repo_username} -Ppassword=${repo_password} -PincludeDependencies=true
if [[ $? != 0 ]]; then
  echo "Error executing ./gradlew -b deploy.gradle uploadDotcms ${releaseParam} -Pusername=${repo_username} -Ppassword=${repo_password} -PincludeDependencies=true"
  exit 1
fi

popd
