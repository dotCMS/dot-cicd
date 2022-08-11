#!/bin/bash

####################
# Script: setVars.sh
# Set important env-vars to be used across the release process

pushd dotCMS
# Extract the dotcmsReleaseVersion property and store it in an env-var
eval $(cat gradle.properties | grep dotcmsReleaseVersion)
echo "export RELEASE_VERSION=\"${dotcmsReleaseVersion}\""
export RELEASE_VERSION="${dotcmsReleaseVersion}"
popd
