#!/bin/bash

##################################
# Script: generateAndUploadJars.sh
# Generates core and enterprise jays and upload them to artifactory

pushd dotCMS
executeCmd "rm -rf build ../dist ../core-web/node_modules"
executeCmd "./gradlew clean"
executeCmd "./gradlew generateDependenciesFromMaven"
executeCmd "./gradlew createDistPrep"
popd

executeCmd "ls -las dist/dotserver/tomcat-9.0.60/webapps/ROOT/WEB-INF/lib/dotcms_*.jar"
dotcms_lib_dir=dotCMS/build/libs
dotcms_jar=dotcms_${RELEASE_VERSION}
dotcms_jar_path=${dotcms_lib_dir}/${dotcms_jar}
github_sha=$(git rev-parse HEAD)
 [[ "${IS_RELEASE}" == 'true' ]] && releaseParam='-Prelease=true'
executeCmd "ls -las ${dotcms_lib_dir}/dotcms_*.jar"
if [[ -f ./${dotcms_lib_dir}/dotcms_null.jar ]]; then
  jar_file=${dotcms_lib_dir}/dotcms_null.jar
else
  jar_file=${dotcms_jar_path}_${github_sha::7}.jar
fi
executeCmd "mv ${jar_file} ${dotcms_jar_path}.jar"
executeCmd "ls -las ${dotcms_lib_dir}/dotcms_*.jar"

if [[ "${IS_RELEASE}" == 'true' ]]; then
  pushd dotCMS/deploy
  echo
  echo '####################'
  echo 'Uploading DotCMS jar'
  echo '####################'
  executeCmd "./gradlew uploadArchives
    ${releaseParam}
    -PgroupId=com.dotcms
    -Pusername=${REPO_USERNAME}
    -Ppassword=${REPO_PASSWORD}
    -PincludeDependencies=true
    -Pfile=../${dotcms_jar_path}.jar"
  [[ ${cmdResult} != 0 ]] && exit 1
  popd
else
  echo "Dry running:
    ./gradlew uploadArchives
      ${releaseParam}
      -PgroupId=com.dotcms
      -Pusername=${REPO_USERNAME}
      -Ppassword=${REPO_PASSWORD}
      -PincludeDependencies=true
      -Pfile=../${dotcms_jar_path}.jar"
fi
