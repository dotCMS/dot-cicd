#!/bin/bash

: ${DOT_CICD_REPO:="https://github.com/dotCMS/dot-cicd.git"} && export DOT_CICD_REPO
: ${DOT_CICD_PATH:="./dotcicd"} && export DOT_CICD_PATH
: ${DOT_CICD_LIB:="${DOT_CICD_PATH}/library"} && export DOT_CICD_LIB
: ${DOT_CICD_VERSION:="1.0"} && export DOT_CICD_VERSION
: ${DOT_CICD_TOOL:="travis"} && export DOT_CICD_TOOL
: ${DOT_CICD_PERSIST:="google"} && export DOT_CICD_PERSIST
# Remove me
: ${DOT_CICD_TARGET:="core"} && export DOT_CICD_TARGET

# Prepares folders for CI/CD
prepareCICD () {
  if [ ! -d ${DOT_CICD_PATH} ]; then
    mkdir ${DOT_CICD_PATH}
  fi
}

# Clones and checkout a provided repo url with branch (optional)
gitCloneAndCheckout () {
  local DOT_CICD_REPO=$1
  local DOT_CICD_BRANCH=$2

  if [ -z "${DOT_CICD_REPO}" ]; then
    echo "Repo not provided, cannot continue"
    exit 1
  fi

  echo "Cloning CI/CD repo from ${DOT_CICD_REPO} to ${DOT_CICD_LIB}"
  git clone ${DOT_CICD_REPO} ${DOT_CICD_LIB}

  if [ $? -ne 0 ]; then
    echo "Error cloning repo '${DOT_CICD_REPO}'"
    exit 1
  fi

  if [ ! -z "${DOT_CICD_BRANCH}" ]; then
    cd ${DOT_CICD_LIB}
    echo "Checking out branch ${DOT_CICD_BRANCH}"
    git checkout -b ${DOT_CICD_BRANCH}
    if [ $? -ne 0 ]; then
      echo "Error checking out branch '${DOT_CICD_BRANCH}', continuing with master"
    else
      git branch
    fi

    cd ../../
  fi
}

# Make bash scripts to be executable
prepareScripts () {
  for script in $(find ${DOT_CICD_LIB} -type f -name "*.sh"); do
    echo "Making ${script} executable"
    chmod +x ${script}
  done
}

# Fetch CI/CD github repo to include and use its library
fetchCICD () {
  if [ -z "${DOT_CICD_TARGET}" ]; then
    echo "No CI/CD target project (DOT_CICD_TARGET variable) has been defined, aborting pipeline"
    exit 1
  fi

  prepareCICD
  gitCloneAndCheckout ${DOT_CICD_REPO} ${DOT_CICD_BRANCH}
  prepareScripts

  exit 0
}

fetchCICD

if [[ $? != 0 ]]; then
  echo "Aborting pipeline"
  exit 1
fi
