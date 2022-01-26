#!/bin/bash

######################
# Script: getSource.sh
# Git clones core repo with submodules (enterprise) with provided branch
#
# $1: build_id: branch or commit
# $2: is_release: is release flag

build_id=${1}
is_release=${2}

# Clone with submodules
[[ "${is_release}" == 'true' ]] && export GIT_TAG=${build_id}
executeCmd "gitCloneSubModules $(resolveRepoUrl ${CORE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER}) ${build_id}"
[[ "${is_release}" == 'true' ]] && export GIT_TAG=
[[ ${cmdResult} != 0 ]] && exit 1
[[ "${is_release}" == 'true' ]] && export GIT_TAG=

pushd ${CORE_GITHUB_REPO}
echo 'Git status:'
git branch
git status
popd
