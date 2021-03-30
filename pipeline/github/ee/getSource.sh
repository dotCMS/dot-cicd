#!/bin/bash

github_user=${1}
github_user_token=${2}
build_id=${3}

pushd ${DOT_CICD_PATH}
gitCloneSubModules $(resolveRepoUrl ${CORE_GITHUB_REPO} ${github_user_token} ${github_user}) ${build_id}
pushd ${CORE_GITHUB_REPO}/dotCMS/src/main/enterprise
git checkout -b ${build_id} --track origin/${build_id}
git pull origin ${build_id}
popd
