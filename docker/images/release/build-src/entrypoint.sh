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
echo "Build id: ${BUILD_ID}"
echo "Build hash: ${BUILD_HASH}"
echo "Is Release: ${IS_RELEASE}"
echo "Repo username: ${REPO_USERNAME}"
echo "Repo password: ${REPO_PASSWORD}"
echo "Github User: ${GITHUB_USER}"
echo "Github Token: ${GITHUB_USER_TOKEN}"
echo "AWS Access Key Id: ${AWS_ACCESS_KEY_ID}"
echo "AWS Secret Access Key: ${AWS_SECRET_ACCESS_KEY}"
echo "Docker username: ${DOCKER_USERNAME}"
echo "Docker password: ${docker_password}"
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
