#!/bin/bash

: ${DOT_CICD_PATH:="./dotcicd"} && export DOT_CICD_PATH
: ${DOT_CICD_REPO:="https://github.com/dotCMS/dot-cicd.git"} && export DOT_CICD_REPO
: ${DOT_CICD_BRANCH:=""} && export DOT_CICD_BRANCH
: ${DOT_CICD_LIB:="${DOT_CICD_PATH}/library"} && export DOT_CICD_LIB
: ${PROXY_MODE:="false"} && export PROXY_MODE

if [ "${DOT_CICD_BRANCH}" = "master" ]; then
  export DOT_CICD_BRANCH=
fi

echo "#############"
echo "dot-cicd vars"
echo "#############"
echo "DOT_CICD_PATH: ${DOT_CICD_PATH}"
echo "DOT_CICD_REPO: ${DOT_CICD_REPO}"
echo "DOT_CICD_BRANCH: ${DOT_CICD_BRANCH}"
echo "DOT_CICD_LIB: ${DOT_CICD_LIB}"
echo

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
  local DOT_CICD_REPO=$1
  local DOT_CICD_BRANCH=$2

  if [ -z "${DOT_CICD_REPO}" ]; then
    echo "Repo not provided, cannot continue"
    exit 1
  fi

  git config --global user.email "dotcmsbuild@dotcms.com"
  git config --global user.name "dotcmsbuild"
  git config --global pull.rebase false

  if [ -d ${DOT_CICD_LIB} ]; then
    echo "Found a distribution at ${DOT_CICD_LIB}, removing it"
    rm -rf ${DOT_CICD_LIB}
  fi

  echo "Cloning CI/CD repo from ${DOT_CICD_REPO} to ${DOT_CICD_LIB}"
  git clone ${DOT_CICD_REPO} ${DOT_CICD_LIB}

  if [ $? -ne 0 ]; then
    echo "Error cloning repo '${DOT_CICD_REPO}'"
    exit 1
  fi

  if [ -n "${DOT_CICD_BRANCH}" ]; then
    cd ${DOT_CICD_LIB}
    git fetch --all
    git pull
    echo "Checking out branch ${DOT_CICD_BRANCH}"
    git checkout -b ${DOT_CICD_BRANCH} --track origin/${DOT_CICD_BRANCH}
    if [ $? -ne 0 ]; then
      echo "Error checking out branch '${DOT_CICD_BRANCH}', continuing with master"
    else
      git pull origin ${DOT_CICD_BRANCH}
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

allowSsh() {
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

  if [ "${PROXY_MODE}" = "false" ]; then
    exit 0
  fi
}

fetchCICD

if [ $? -ne 0 ]; then
  echo "Aborting pipeline"
  exit 1
fi
