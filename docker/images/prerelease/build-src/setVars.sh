#!/bin/bash

####################
# Script: setVars.sh
# Set important env-vars to be used across the release process

: ${FROM_BRANCH:="master"} && export FROM_BRANCH
export ENTERPRISE_DIR=dotCMS/src/main/enterprise

export branch="release-${RELEASE_VERSION}"
master_branch=master
[[ "${DRY_RUN}" == 'true' ]] && master_branch="${master_branch}-cicd"
export master_branch
export GIT_CLONE_STRATEGY=full
