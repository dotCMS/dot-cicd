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

# Calls python script to replace a given text by a provided one
#
# $1: file: file to do replacing
# $2: replace_text: text to replace
# $3: replacing_text: new text
function replaceTextInFile {
  local file=${1}
  local replace_text=${2}
  local replacing_text=${3}

  executeCmd "python3 /build/replaceTextInFile.py ${file} \"${replace_text}\" \"${replacing_text}\""
  [[ "${DEBUG}" == 'true' ]] && cat ${file} | grep "${replacing_text}"
}

# Changes dotcms version property at gradle.properties file
#
# $1: version to use as replacement
function changeDotcmsVersion {
  local version=${1}
  echo "Overriding dotcmsReleaseVersion to: ${version}"
  replaceTextInFile ./gradle.properties 'dotcmsReleaseVersion=.*$' "dotcmsReleaseVersion=${version}"
}

# Changes core-web version property at gradle.properties file
#
# $1: ui_version: dotcms-ui version
# $2: wc_version: dotcms-webcomponents version
function changeCoreWebVersions {
  local ui_version=${1}
  local wc_version=${2}
  echo "Overriding coreWebReleaseVersion with ${ui_version} and webComponentsReleaseVersion with ${wc_version}"
  replaceTextInFile ./gradle.properties 'coreWebReleaseVersion=.*$' "coreWebReleaseVersion=${ui_version}"
  replaceTextInFile ./gradle.properties 'webComponentsReleaseVersion=.*$' "webComponentsReleaseVersion=${wc_version}"
}

# Given a npm project name and a tag, resolves the current npm version.
#
# $1: repo: npm repo
# $2: tag: provided tag
function currentNpmVersion {
  local repo=${1}
  local tag=${2}
  [[ -z "${repo}" ]] && return 1
  [[ -z "${tag}" ]] && return 2

  local version=$(npm dist-tag ls ${repo} | grep "${tag}: ")
  [[ -z "${version}" ]] && return 4

  echo ${version#*"${tag}: "}
}

function installGradle {
  wget -O ${TOOLS_HOME}/gradle.zip https://services.gradle.org/distributions/gradle-${LOCAL_GRADLE_VERSION}-bin.zip \
    && unzip gradle.zip
}

function setGradle {
  export GRADLE_HOME=${TOOLS_HOME}/gradle-${LOCAL_GRADLE_VERSION}
  export PATH=${GRADLE_HOME}/bin:${PATH}
  echo "Gradle:
  GRADLE_HOME: ${GRADLE_HOME}
  "
  gradle -v
}

: ${TOOLS_HOME:="${PWD}"} && export TOOLS_HOME
: ${LOCAL_GRADLE_VERSION:="6.9.3"} && export LOCAL_GRADLE_VERSION
