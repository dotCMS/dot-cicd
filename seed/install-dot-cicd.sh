#!/bin/bash

: ${DOT_CICD_PATH:="./dotcicd"} && export DOT_CICD_PATH
: ${DOT_CICD_REPO:="https://github.com/dotCMS/dot-cicd.git"} && export DOT_CICD_REPO
: ${DOT_CICD_BRANCH:="master"} && export DOT_CICD_BRANCH
: ${DOT_CICD_LIB:="${DOT_CICD_PATH}/library"} && export DOT_CICD_LIB
: ${PROXY_MODE:="false"} && export PROXY_MODE

echo "#############
dot-cicd vars
#############
DOT_CICD_PATH: ${DOT_CICD_PATH}
DOT_CICD_REPO: ${DOT_CICD_REPO}
DOT_CICD_BRANCH: ${DOT_CICD_BRANCH}
DOT_CICD_LIB: ${DOT_CICD_LIB}
PROXY_MODE: ${PROXY_MODE}
"

# Prepares folders for CI/CD
prepareCICD () {
  if [ ! -d ${DOT_CICD_PATH} ]; then
    mkdir ${DOT_CICD_PATH}
  elif [ -d ${DOT_CICD_LIB} ]; then
    rm -rf ${DOT_CICD_LIB} 
  fi
}

# Clones and checks out a provided repo url with branch (optional)
gitCloneAndCheckout () {
  local dot_cicd_repo=$1
  local dot_cicd_branch=$2

  if [ -z "${dot_cicd_repo}" ]; then
    echo "Repo not provided, cannot continue"
    exit 1
  fi

  if [ "${PROXY_MODE}" = "false" ]; then
    git config --global user.email "dotcmsbuild@dotcms.com"
    git config --global user.name "dotcmsbuild"
    git config --global pull.rebase false
  fi

  if [ -d ${DOT_CICD_LIB} ]; then
    echo "Found a distribution at ${DOT_CICD_LIB}, removing it"
    rm -rf ${DOT_CICD_LIB}
  fi

  echo "Cloning CI/CD repo from ${dot_cicd_repo} to ${DOT_CICD_LIB}"
  git clone ${dot_cicd_repo} ${DOT_CICD_LIB}

  if [ $? -ne 0 ]; then
    echo "Error cloning repo '${dot_cicd_repo}'"
    exit 1
  fi

  if [ -n "${dot_cicd_branch}" ]; then
    cd ${DOT_CICD_LIB}
    git fetch --all
    echo "Checking out branch ${dot_cicd_branch}"
    git checkout -b ${dot_cicd_branch} --track origin/${dot_cicd_branch}
    if [ $? -ne 0 ]; then
      echo "Error checking out branch '${dot_cicd_branch}', continuing with master"
    else
      git pull origin ${dot_cicd_branch}
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

allowSsh () {
  if [ -n "${SSH_RSA_KEY}" ]; then 
    mkdir .ssh
    echo "${SSH_RSA_KEY}" > .ssh/id_rsa
    chmod 600 .ssh/id_rsa
  else
    echo 'SSH key not provided, skipping ssh'
  fi
}

# Fetch CI/CD github repo to include and use its library
fetchCICD () {
  prepareCICD
  allowSsh
  gitCloneAndCheckout ${DOT_CICD_REPO} ${DOT_CICD_BRANCH}
  prepareScripts
}

fetchCICD

if [ $? -ne 0 ]; then
  echo "Aborting pipeline"
  exit 1
fi
