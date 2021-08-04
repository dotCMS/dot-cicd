#!/bin/bash

####################
# Script: setVars.sh
# Set important env-vars to be used across the release process

: ${FROM_BRANCH:="master"} && export FROM_BRANCH
export ENTERPRISE_DIR=${CORE_GITHUB_REPO}/dotCMS/src/main/enterprise

branch="release-${RELEASE_VERSION}"
master_branch=master
if [[ "${DRY_RUN}" == 'true' ]]; then
  master_branch="master-cicd"
fi

export branch
export master_branch
