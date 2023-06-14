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
 [[ "${is_release}" == 'true' ]] && releaseParam='-Prelease=true'
executeCmd "ls -las ${dotcms_lib_dir}/dotcms_*.jar"
if [[ -f ./${dotcms_lib_dir}/dotcms_null.jar ]]; then
  jar_file=${dotcms_lib_dir}/dotcms_null.jar
else
  jar_file=${dotcms_jar_path}_${github_sha::7}.jar
fi
executeCmd "mv ${jar_file} ${dotcms_jar_path}.jar"
executeCmd "ls -las ${dotcms_lib_dir}/dotcms_*.jar"

if [[ "${is_release}" == 'true' ]]; then
  pushd dotCMS/deploy
  echo
  echo '####################'
  echo 'Uploading DotCMS jar'
  echo '####################'
  executeCmd "./gradlew uploadArchives
    ${releaseParam}
    -PgroupId=com.dotcms
    -Pusername=${repo_username}
    -Ppassword=${repo_password}
    -PincludeDependencies=true
    -Pfile=../${dotcms_jar_path}.jar"
  [[ ${cmdResult} != 0 ]] && exit 1
  popd
else
  echo "Dry running:
    ./gradlew uploadArchives
      ${releaseParam}
      -PgroupId=com.dotcms
      -Pusername=${repo_username}
      -Ppassword=${repo_password}
      -PincludeDependencies=true
      -Pfile=../${dotcms_jar_path}.jar"
fi
