#!/bin/bash

#######################
# Script: entrypoint.sh
# Main script for release process which runs a set of steps:
# - Get the actual source for core/enterprise
# - Set some required variables
# - Generates and uploads jars
# - Created distribution files
# - Generates javadoc
# - Push distribution and javadoc files to S3 bucket
# - Updates DotCMS versions in plugins repo
# - Publishes Github releases on main repos

. /build/githubCommon.sh
. /build/releaseCommon.sh

echo
echo '######################################################################'
echo "BUILD_ID: ${BUILD_ID}"
echo "BUILD_HASH: ${BUILD_HASH}"
echo "BRANCHING_MODEL: ${BRANCHING_MODEL}"
echo "RELEASE_VERSION: ${RELEASE_VERSION}"
echo "IS_RELEASE: ${IS_RELEASE}"
echo "REPO_USERNAME: ${REPO_USERNAME}"
echo "REPO_PASSWORD: ${REPO_PASSWORD}"
echo "GITHUB_USER: ${GITHUB_USER}"
echo "GITHUB_USER_TOKEN: ${GITHUB_USER_TOKEN}"
echo "AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}"
echo "AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}"
echo

setGradle

mkdir -p /build/src && pushd /build/src
runScript getSource
pushd ${CORE_GITHUB_REPO}
runScript resolveVars
runScript generateAndUploadJars
runScript buildDistro
runScript generateJavadoc
runScript pushToStaticBucket all
runScript updateOsgiVersion
popd
runScript publishGithubReleases true ${BUILD_ID}
