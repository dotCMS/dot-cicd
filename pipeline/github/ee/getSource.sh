#!/bin/bash

######################
# Script: getSource.sh
# Git clones core repo with its submodules using github credentials (user and token) and the provided branch
#
# $1: build_id: branch or commit

build_id=${1}

pushd ${DOT_CICD_PATH}
gitCloneSubModules $(resolveRepoUrl ${CORE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER}) ${build_id}
