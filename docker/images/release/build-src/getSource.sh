#!/bin/bash

github_user=${1}
github_user_token=${2}
build_id=${3}

gitCloneSubModules $(resolveRepoUrl ${CORE_GITHUB_REPO} ${github_user_token} ${github_user}) ${build_id}

pushd ${CORE_GITHUB_REPO}
echo 'Git status:'
git branch
git status

pushd dotCMS/src/main/enterprise
git checkout -b ${build_id} --track origin/${build_id}
git pull origin ${build_id}
echo 'Git status:'
git branch
git status
popd

popd
