#!/bin/bash

##################################
# Script: generateAndUploadJars.sh
# Generates and uploads enterprise jars to repo with credentials
#
# $1: build_id: core branch
# $2: repo_username: artifactory repo username
# $3: repo_password: artifactory repo password
# $4: github_sha: github commit SHA
# $5: is_release: is release flag

build_id=$1
repo_username=$2
repo_password=$3
github_sha=$4
is_release=$5

echo
echo '##################################'
echo 'Executing generateAndUploadJars.sh'
echo '##################################'

pushd ${DOT_CICD_PATH}/core/dotCMS

eval $(cat gradle.properties | grep dotcmsReleaseVersion)
echo "export RELEASE_VERSION=\"${dotcmsReleaseVersion}\""
export RELEASE_VERSION="${dotcmsReleaseVersion}"

if [[ "${is_release}" != 'true' ]]; then
  rev=${github_sha}
else
  releaseParam='-Prelease=true'
  rev=obfuscated
fi

# Build project
## Creating jar
pushd src/main/enterprise
enterprise_lib_dir=build/libs
ee_jar=${enterprise_lib_dir}/ee_${RELEASE_VERSION}.jar
executeCmd "./gradlew clean jar"
executeCmd "ls -las ${enterprise_lib_dir}"
executeCmd "mv ${enterprise_lib_dir}/ee_obfuscated.jar ${ee_jar}"
executeCmd "ls -las ${enterprise_lib_dir}"
popd

echo
echo '################################'
echo 'Uploading Enterprise Edition jar'
echo '################################'
# Upload and deploy enterprise jars
executeCmd "gradle -b deploy.gradle uploadArchives
  ${releaseParam}
  -PgroupId=com.dotcms.enterprise
  -Pusername=${repo_username}
  -Ppassword=${repo_password}
  -Pfile=./src/main/enterprise/${ee_jar}
  -PincludeDependencies=true"
[[ ${cmdResult} != 0 ]] && exit 1

executeCmd "./gradlew java"
[[ ${cmdResult} != 0 ]] && exit 1

popd
