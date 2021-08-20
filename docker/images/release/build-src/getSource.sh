#!/bin/bash

######################
# Script: getSource.sh
# Git clones core repo with submodules (enterprise) with provided branch
#
# $1: build_id: branch or commit

build_id=${1}

# Clone with submodules
gitCloneSubModules $(resolveRepoUrl ${CORE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER}) ${build_id}

pushd ${CORE_GITHUB_REPO}
echo 'Git status:'
git branch
git status
popd
