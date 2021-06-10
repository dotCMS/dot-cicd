#!/bin/bash

# Env-Vars definition
DEFAULT_GITHUB_USER_EMAIL='dotcmsbuild@dotcms.com'
DEFAULT_GITHUB_USER=dotcmsbuild
: ${DOT_CICD_PATH:="../dotcicd"} && export DOT_CICD_PATH
: ${DOT_CICD_REPO:="https://github.com/dotCMS/dot-cicd.git"} && export DOT_CICD_REPO
: ${DOT_CICD_BRANCH:="master"} && export DOT_CICD_BRANCH
: ${DOT_CICD_LIB:="${DOT_CICD_PATH}/library"} && export DOT_CICD_LIB
: ${LOCAL_MODE:="false"} && export LOCAL_MODE

echo "#############
dot-cicd vars
#############"
if [ ${LOCAL_MODE} = false ]; then
echo "DOT_CICD_PATH: ${DOT_CICD_PATH}
DOT_CICD_LIB: ${DOT_CICD_LIB}
DOT_CICD_REPO: ${DOT_CICD_REPO}
DOT_CICD_BRANCH: ${DOT_CICD_BRANCH}
LOCAL_MODE: ${LOCAL_MODE}
"
else
  echo "DOT_CICD_LIB: ${DOT_CICD_LIB}
DOT_CICD_REPO: ${DOT_CICD_REPO}
DOT_CICD_BRANCH: ${DOT_CICD_BRANCH}
"
fi

# Prepares folders for CI/CD
prepareCICD () {
  if [ ! -d ${DOT_CICD_PATH} ]; then
    mkdir ${DOT_CICD_PATH}
  elif [ -d ${DOT_CICD_LIB} ]; then
    echo "Found a distribution at ${DOT_CICD_LIB}, removing it"
    rm -rf ${DOT_CICD_LIB} 
  fi
}

# Clones and checks out a provided repo url with branch (optional)
#
# $1: dot_cicd_repo dot-cicd repo url
# $2: dot_cicd_branch dot-cicd branch to check out
gitCloneAndCheckout () {
  local dot_cicd_repo=$1
  local dot_cicd_branch=$2

  if [ -z "${dot_cicd_repo}" ]; then
    echo "Repo not provided, cannot continue"
    exit 1
  fi

  if [ "${LOCAL_MODE}" = "false" ]; then
    git config --global user.email "${DEFAULT_GITHUB_USER_EMAIL}"
    git config --global user.name "${DEFAULT_GITHUB_USER}"
    git config --global pull.rebase false
  fi

  echo "Cloning CI/CD repo from ${dot_cicd_repo} to ${DOT_CICD_LIB}"
  work_dir=$(pwd)
  git clone ${dot_cicd_repo} ${DOT_CICD_LIB}

  if [ $? -ne 0 ]; then
    echo "Error cloning repo '${dot_cicd_repo}'"
    exit 1
  fi

  if [ -n "${dot_cicd_branch}" ]; then
    cd ${DOT_CICD_LIB}
    git fetch --all
    git pull
    echo "Checking out branch ${DOT_CICD_BRANCH}"
    git checkout -b ${DOT_CICD_BRANCH} --track origin/${DOT_CICD_BRANCH}
    if [ $? -ne 0 ]; then
      echo "Error checking out branch '${dot_cicd_branch}', continuing with master"
    else
      git pull origin ${dot_cicd_branch}
    fi

    if [ "${LOCAL_MODE}" = "false" ]; then
      cd ${work_dir}
      echo 'Due to deprecation location of DOT_CICD_PATH, a symlink will be created to guarantee backwards compatibility'
      ln -s ${DOT_CICD_PATH} dotcicd
      ls -las .
    fi
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
  prepareCICD
  gitCloneAndCheckout ${DOT_CICD_REPO} ${DOT_CICD_BRANCH}
  prepareScripts
}

# Actual code to get the dot-cicd repo
fetchCICD

if [ $? -ne 0 ]; then
  echo "Aborting pipeline"
  exit 1
fi
