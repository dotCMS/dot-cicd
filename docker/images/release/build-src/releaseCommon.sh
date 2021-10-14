#!/bin/bash

##########################
# Script: releaseCommon.sh
# Collection of functions related to release process

# Runs a release script not without first announce it
#
# $1: script: script file to run
function runScript {
  local script=$1

  echo
  echo '############################################################################################################################################'
  echo "Executing . /build/${script}.sh $2 $3 $4 $5 $6 $7 $8"
  echo '############################################################################################################################################'
  . /build/${script}.sh $2 $3 $4 $5 $6 $7 $8
}

# Changes dotcms version property at gradle.properties file
#
# $1: version to use as replacement
function changeDotcmsVersion {
  local version=${1}
  sed -i "s,^dotcmsReleaseVersion=.*$,dotcmsReleaseVersion=${version},g" ./gradle.properties
  echo "Overriding dotcmsReleaseVersion to: ${version}"
  cat ./gradle.properties | grep dotcmsReleaseVersion
}
