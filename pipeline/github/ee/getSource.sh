#!/bin/bash

######################
# Script: getSource.sh
# Git clones core repo with its submodules using github credentials (user and token) and the provided branch
#
# $1: GITHUB_USER: github user to run clone on behalf of
# $2: github_user_token: token associated to user
# $3: build_id: branch or commit

export GITHUB_USER=${1}
github_user_token=${2}
build_id=${3}

pushd ${DOT_CICD_PATH}
gitCloneSubModules $(resolveRepoUrl ${CORE_GITHUB_REPO} ${github_user_token} ${GITHUB_USER}) ${build_id}
