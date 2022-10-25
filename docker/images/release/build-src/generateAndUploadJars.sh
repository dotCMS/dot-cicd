#!/bin/bash

##################################
# Script: generateAndUploadJars.sh
# Generates core and enterprise jays and upload them to artifactory
#
# $1: build_id: core branch or commit
# $2: repo_username: artifactory repo username
# $3: repo_password: artifactory repo password
# $4: is_release: release flag

build_id=$1
repo_username=$2
repo_password=$3
is_release=$4

if [[ "${is_release}" == 'true' ]]; then
  pushd dotCMS
  executeCmd "./gradlew clean createDistPrep"
  popd

  pushd ${ENTERPRISE_DIR}
  enterprise_lib_dir=build/libs
  ee_jar=${enterprise_lib_dir}/ee_${RELEASE_VERSION}.jar
  executeCmd "./gradlew clean jar"
  executeCmd "ls -las ${enterprise_lib_dir}"
  executeCmd "mv ${enterprise_lib_dir}/ee_obfuscated.jar ${ee_jar}"
  executeCmd "ls -las ${enterprise_lib_dir}"
  popd

  pushd dotCMS
  echo
  echo '################################'
  echo 'Uploading Enterprise Edition jar'
  echo '################################'
  [[ "${is_release}" == 'true' ]] && releaseParam='-Prelease=true'
  executeCmd "gradle -b deploy.gradle uploadArchives
    ${releaseParam}
    -PgroupId=com.dotcms
    -Pusername=${repo_username}
    -Ppassword=${repo_password}
    -Pfile=./src/main/enterprise/${ee_jar}"
  [[ ${cmdResult} != 0 ]] && exit 1
  popd

  dotcms_lib_dir=dist/dotserver/tomcat-9.0.60/webapps/ROOT/WEB-INF/lib
  dotcms_jar=dotcms_${RELEASE_VERSION}
  dotcms_jar_path=${dotcms_lib_dir}/${dotcms_jar}
  executeCmd "ls -las ${dotcms_lib_dir}"
  executeCmd "mv ${dotcms_jar_path}_999999.jar ${dotcms_jar_path}.jar"
  executeCmd "ls -las ${dotcms_lib_dir}"

  pushd dotCMS
  echo
  echo '####################'
  echo 'Uploading DotCMS jar'
  echo '####################'
  executeCmd "gradle -b deploy.gradle uploadArchives
    ${releaseParam}
    -PgroupId=com.dotcms
    -Pusername=${repo_username}
    -Ppassword=${repo_password}
    -Pfile=../${dotcms_jar_path}.jar"
  [[ ${cmdResult} != 0 ]] && exit 1

  popd
fi
