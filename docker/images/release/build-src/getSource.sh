#!/bin/bash

######################
# Script: getSource.sh
# Git clones core repo with submodules (enterprise) with provided branch
#

echo "Fetching ${BUILD_ID} branch/tag"
# Clone with submodules
[[ "${IS_RELEASE}" == 'true' ]] && export GIT_TAG=${BUILD_ID}
export GIT_CLONE_STRATEGY=full
executeCmd "gitClone $(resolveRepoUrl ${CORE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER}) ${BUILD_ID}"
export GIT_CLONE_STRATEGY=
[[ "${IS_RELEASE}" == 'true' ]] && export GIT_TAG=
pushd ${CORE_GITHUB_REPO}
#[[ "${BRANCHING_MODEL}" == 'trunk-based' ]] && executeCmd "git reset --hard ${BUILD_HASH}"
[[ ${cmdResult} != 0 ]] && exit 1

executeCmd "gitConfig ${GITHUB_USER}"
echo 'Git status:'
executeCmd "git branch"
executeCmd "git status"

popd
