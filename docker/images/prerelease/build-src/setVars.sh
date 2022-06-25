#!/bin/bash

####################
# Script: setVars.sh
# Set important env-vars to be used across the release process

export ENTERPRISE_DIR=dotCMS/src/main/enterprise
export branch="release-${RELEASE_VERSION}"
export GIT_CLONE_STRATEGY=full
