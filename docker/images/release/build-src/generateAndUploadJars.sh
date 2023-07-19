#!/bin/bash

##################################
# Script: generateAndUploadJars.sh
# Generates core and enterprise jays and upload them to artifactory

pushd dotCMS
executeCmd "rm -rf build ../dist ../core-web/node_modules"
executeCmd "./gradlew generateDependenciesFromMaven"
executeCmd "./gradlew createDistPrep"
dotcms_jar=dotcms_${RELEASE_VERSION}
eval $(cat gradle.properties | grep dotcmsReleaseVersion)
echo "release_version=${dotcmsReleaseVersion}"
release_version="${dotcmsReleaseVersion}"
if [[ "${BRANCHING_MODEL}" == 'trunk-based' && "${RELEASE_VERSION}" != "${release_version}" ]]; then
  dotcms_jar=dotcms_${release_version}
fi
popd

executeCmd "ls -las dist/dotserver/tomcat-9.0.60/webapps/ROOT/WEB-INF/lib/dotcms_*.jar"
dotcms_lib_dir=dotCMS/build/libs
dotcms_jar_path=${dotcms_lib_dir}/${dotcms_jar}
jar_file=${dotcms_jar_path}_${BUILD_HASH::7}.jar
executeCmd "ls -las ${dotcms_lib_dir}/dotcms_*.jar"
executeCmd "mv ${jar_file} ${dotcms_jar_path}.jar"
executeCmd "ls -las ${dotcms_lib_dir}/dotcms_*.jar"

if [[ "${IS_RELEASE}" == 'true' ]]; then
  releaseParam='-Prelease=true'
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
