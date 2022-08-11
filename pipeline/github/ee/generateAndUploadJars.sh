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

wget -O gradle.zip https://services.gradle.org/distributions/gradle-4.10.2-bin.zip \
unzip gradle.zip

export GRADLE_HOME=$(pwd)/gradle-4.10.2
export PATH=${GRADLE_HOME}/bin:${PATH}
echo "Gradle:
GRADLE_HOME: ${GRADLE_HOME}
"
gradle -v

echo
echo '##################################'
echo 'Executing generateAndUploadJars.sh'
echo '##################################'

pushd ${DOT_CICD_PATH}/core/dotCMS

eval $(cat gradle.properties | grep dotcmsReleaseVersion)
echo "export dotcms_version=\"${dotcmsReleaseVersion}\""
export dotcms_version="${dotcmsReleaseVersion}"

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
ee_jar=${enterprise_lib_dir}/ee_${dotcms_version}.jar
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
  -Pusername=${repo_username}
  -Ppassword=${repo_password}
  -Pfile=./src/main/enterprise/${ee_jar}"
[[ ${cmdResult} != 0 ]] && exit 1

executeCmd "./gradlew java"
[[ ${cmdResult} != 0 ]] && exit 1

popd
