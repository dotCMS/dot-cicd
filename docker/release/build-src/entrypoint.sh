#!/bin/bash

. /build/releaseCommon.sh

echo
echo '######################################################################'
echo "Single CMD: ${single_cmd}"
echo "Build id: ${build_id}"
echo "EE Build id: ${ee_build_id}"
echo "Repo username: ${repo_username}"
echo "Repo password: ${repo_password}"
echo "Github User: ${github_user}"
echo "Github Token: ${github_user_token}"
echo "Github SHA: ${github_sha}"
echo "AWS Access Key Id: ${aws_access_key_id}"
echo "AWS Secret Access Key: ${aws_secret_access_key}"
echo "Docker username: ${docker_username}"
echo "Docker password: ${docker_password}"
echo "Debug: ${debug}"
echo "EE RSA: ${ee_rsa}"

runScript prepareGit ${ee_rsa}
runScript getSource ${build_id}
runScript setVars
runScript generateAndUploadJars ${build_id} ${ee_build_id} ${repo_username} ${repo_password} ${github_sha} ${is_release}
runScript buildDistro
runScript generateJavadoc
runScript pushToStaticBucket all
runScript updateOsgiVersion ${github_user_token}
runScript publishGithubReleases ${is_release} ${ee_build_id} ${ee_rsa}
