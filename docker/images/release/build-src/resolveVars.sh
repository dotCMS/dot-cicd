#!/bin/bash

########################
# Script: resolveVars.sh
# Set important env-vars to be used across the release process

if [[ "${BRANCHING_MODEL}" != 'trunk-based' ]]; then
  pushd dotCMS
  # Extract the dotcmsReleaseVersion property and store it in an env-var
  eval $(cat gradle.properties | grep dotcmsReleaseVersion)
  echo "export RELEASE_VERSION=\"${dotcmsReleaseVersion}\""
  export RELEASE_VERSION="${dotcmsReleaseVersion}"
  popd
fi
