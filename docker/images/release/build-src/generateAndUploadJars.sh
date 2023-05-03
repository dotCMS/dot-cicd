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


  executeCmd "ls -las dist/dotserver/tomcat-9.0.60/webapps/ROOT/WEB-INF/lib/dotcms_*.jar"
  #dotcms_lib_dir=dist/dotserver/tomcat-9.0.60/webapps/ROOT/WEB-INF/lib
  dotcms_lib_dir=dotCMS/build/libs
  dotcms_jar=dotcms_${RELEASE_VERSION}
  dotcms_jar_path=${dotcms_lib_dir}/${dotcms_jar}
  github_sha=$(git rev-parse HEAD)
  [[ "${is_release}" == 'true' ]] && releaseParam='-Prelease=true'
  executeCmd "ls -las ${dotcms_lib_dir}/dotcms_*.jar"
  executeCmd "mv ${dotcms_jar_path}_${github_sha::7}.jar ${dotcms_jar_path}.jar"
  executeCmd "ls -las ${dotcms_lib_dir}/dotcms_*.jar"

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

  pushd ${ENTERPRISE_DIR}
  enterprise_lib_dir=build/libs
  ee_jar=${enterprise_lib_dir}/ee_${RELEASE_VERSION}.jar
  executeCmd "./gradlew clean jar"
  executeCmd "ls -las ${enterprise_lib_dir}/ee_*.jar"
  executeCmd "mv ${enterprise_lib_dir}/ee_obfuscated.jar ${ee_jar}"
  executeCmd "ls -las ${enterprise_lib_dir}/ee_*.jar"
  popd

  pushd dotCMS
  echo
  echo '################################'
  echo 'Uploading Enterprise Edition jar'
  echo '################################'
  executeCmd "gradle -b deploy.gradle uploadArchives
    ${releaseParam}
    -PgroupId=com.dotcms.enterprise
    -Pusername=${repo_username}
    -Ppassword=${repo_password}
    -Pfile=./src/main/enterprise/${ee_jar}"
  [[ ${cmdResult} != 0 ]] && exit 1
  popd
fi
