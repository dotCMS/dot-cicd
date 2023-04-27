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

  pushd dotCMS
  executeCmd "./gradlew clean createDistPrep"
  popd

  executeCmd "ls -las dist/dotserver/tomcat-9.0.60/webapps/ROOT/WEB-INF/lib/dotcms_*.jar"
  dotcms_lib_dir=dotCMS/build/libs
  dotcms_jar=dotcms_${RELEASE_VERSION}
  dotcms_jar_path=${dotcms_lib_dir}/${dotcms_jar}
  github_sha=$(git rev-parse HEAD)
  executeCmd "ls -las ${dotcms_lib_dir}/dotcms_*.jar"
  executeCmd "mv ${dotcms_jar_path}_${github_sha::7}.jar ${dotcms_jar_path}.jar"
  executeCmd "ls -las ${dotcms_lib_dir}/dotcms_*.jar"

if [[ "${is_release}" == 'true' ]]; then
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
else
  echo "Dry running:
    ./gradlew -b deploy.gradle uploadArchives
      -PgroupId=com.dotcms
      -Pusername=${repo_username}
      -Ppassword=${repo_password}
      -Pfile=../${dotcms_jar_path}.jar"
fi
