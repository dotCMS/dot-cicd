#!/bin/bash

######################
# Script: getSource.sh
# Git clones core repo with submodules (enterprise) with provided branch
#
# $1: build_id: branch or commit

build_id=${1}

# Clone with submodules
export GIT_TAG=${build_id}
executeCmd "gitCloneSubModules $(resolveRepoUrl ${CORE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER}) ${build_id}"
export GIT_TAG=
[[ ${cmdResult} != 0 ]] && exit 1

pushd ${CORE_GITHUB_REPO}
echo 'Git status:'
git branch
git status
popd
