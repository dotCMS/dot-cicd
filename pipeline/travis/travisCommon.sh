#!/bin/bash

source ${DOT_CICD_PATH}/library/pipeline/common.sh

function bell {
  while true; do
    echo -e "\a"
    sleep 60
  done
}

# Git clone by providing repo, destination folder and branch to check out
function gitClone {
  local repo=$1
  local dest=$2
  local branch=$3

  cloneOk=false
  if [[ ! -z "${branch}" ]]; then
    echo "Fetching repo from ${repo} with branch ${branch}"
    git clone ${repo} -b ${branch} ${dest}
    if [[ $? != 0 ]]; then
      echo "Error checking out branch '${branch}', continuing with master"
    else
      cloneOk=true
    fi
  fi

  if [[ $cloneOk == false ]]; then
    echo "Fetching repo from ${repo}"
    git clone ${repo} ${dest}

    if [[ $? != 0 ]]; then
      echo "Error cloning repo '${repo}'"
      exit 1
    fi
  fi
}

# Fetch CI/CD github repo to consume its library
function gitFetchRepo {
  local repo=$1
  local dest=$2
  local branch=$3

  if [[ -z "${repo}" ]]; then
    echo "Repo not provided, cannot continue"
    exit 1
  fi

  if [[ -z "${dest}" ]]; then
    dest=.cicd/
  fi

  gitClone $@
}

# Resolves value of current branch
function resolveCurrentBranch {
  CURRENT_BRANCH=$TRAVIS_PULL_REQUEST_BRANCH
  if [ "$TRAVIS_PULL_REQUEST" = "false" ];
  then
    CURRENT_BRANCH=$TRAVIS_BRANCH
  fi
}