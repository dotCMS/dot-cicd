#!/bin/bash

######################
# Script: getSource.sh
# Git clones core repo with submodules (enterprise) with provided branch
#
# $1: GITHUB_USER: github user to run clone on behalf of
# $2: github_user_token: token associated to user
# $3: build_id: branch or commit

export GITHUB_USER=${1}
github_user_token=${2}
build_id=${3}

cd /build/src
# Clone with submodules
gitCloneSubModules $(resolveRepoUrl ${CORE_GITHUB_REPO} ${github_user_token} ${GITHUB_USER}) ${build_id}

pushd ${CORE_GITHUB_REPO}
echo 'Git status:'
git branch
git status
popd
