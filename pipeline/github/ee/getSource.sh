#!/bin/bash

######################
# Script: getSource.sh
# Git clones core repo with its submodules using github credentials (user and token) and the provided branch
#
# $1: build_id: branch or commit

build_id=${1}

echo
echo '######################'
echo 'Executing getSource.sh'
echo '######################'

pushd ${DOT_CICD_PATH}
executeCmd "gitCloneSubModules $(resolveRepoUrl ${CORE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER}) ${build_id}"
[[ ${cmdResult} != 0 ]] && exit 1
echo "Source downloaded"
