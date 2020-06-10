#!/bin/bash

. ${DOT_CICD_PATH}/library/pipeline/common.sh

function bell {
  while true; do
    echo -e "\a"
    sleep 60
  done
}

# Resolves value of current branch
function resolveCurrentBranch {
  CURRENT_BRANCH=${TRAVIS_PULL_REQUEST_BRANCH}
  if [[ "${TRAVIS_PULL_REQUEST}" == "false" ]]; then
    CURRENT_BRANCH=$TRAVIS_BRANCH
  fi
}