#!/bin/bash

######################
# Script: getSource.sh
# Git clones core repo with submodules (enterprise) with provided branch
#
# $1: github_user: github user to run clone on behalf of
# $2: github_user_token: token associated to user
# $3: build_id: branch or commit

github_user=${1}
github_user_token=${2}
build_id=${3}

cd /build/src
# Clone with submodules
gitCloneSubModules $(resolveRepoUrl ${CORE_GITHUB_REPO} ${github_user_token} ${github_user}) ${build_id}

pushd ${CORE_GITHUB_REPO}
echo 'Git status:'
git branch
git status

# Switch to enterprise and make sure the branch id exist and pull from it
pushd dotCMS/src/main/enterprise
git checkout -b ${build_id} --track origin/${build_id}
git pull origin ${build_id}
echo 'Git status:'
git branch
git status
popd

popd
