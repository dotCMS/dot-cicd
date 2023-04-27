#!/bin/bash

####################
# Script: setVars.sh
# Set important env-vars to be used across the release process

BRANCH="release-${RELEASE_VERSION}"
[[ "${DRY_RUN}" == 'true' ]] && BRANCH="${BRANCH}-cicd"
export BRANCH
export GIT_CLONE_STRATEGY=full
