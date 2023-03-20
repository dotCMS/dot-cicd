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
echo "Is Release: ${is_release}"
echo "Repo username: ${repo_username}"
echo "Repo password: ${repo_password}"
echo "Github User: ${GITHUB_USER}"
echo "Github Token: ${GITHUB_USER_TOKEN}"
echo "AWS Access Key Id: ${aws_access_key_id}"
echo "AWS Secret Access Key: ${aws_secret_access_key}"
echo "Docker username: ${docker_username}"
echo "Docker password: ${docker_password}"
echo "Debug: ${DEBUG}"
echo

setGradle

runScript setVars
mkdir -p /build/src && pushd /build/src
runScript getSource ${BUILD_ID} ${is_release}
pushd ${CORE_GITHUB_REPO}
runScript resolveVars
runScript generateAndUploadJars ${BUILD_ID} ${repo_username} ${repo_password} ${is_release}
runScript buildDistro
runScript generateJavadoc
runScript pushToStaticBucket all true
runScript updateOsgiVersion
popd
runScript publishGithubReleases true ${BUILD_ID}
