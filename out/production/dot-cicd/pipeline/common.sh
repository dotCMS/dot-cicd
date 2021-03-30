#!/bin/bash

function executeCmd {
  local cmd=${1}
  cmd=$(echo ${cmd} | tr '\n' ' \ \n')
  echo "Executing:
==========
${cmd}
"
  eval "${cmd}; export cmdResult=$?"
}

# Git clone by providing repo, destination folder and branch to check out
function gitClone {
  local repo=$1
  local dest=$2
  local branch=$3

  echo "Cloning repo from ${repo}"
  git clone ${repo} ${dest}

  if [[ $? != 0 ]]; then
    echo "Error cloning repo '${repo}'"
    exit 1
  fi

  if [[ -n "${branch}" ]]; then
    pushd ${dest}
    git fetch --all
    echo "Checking out branch ${branch}"
    git checkout -b ${branch} --track origin/${branch}
    if [[ $? != 0 ]]; then
      echo "Error checking out branch '${branch}', continuing with master"
    fi
    popd
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
    dest=cicd/
  fi

  gitClone $@
}

function fetchDocker {
  local docker_repo_path=${1}
  local docker_file_path=${2}

  if [[ -d "${docker_repo_path}/.git" ]]; then
    echo "Docker ${docker_repo_path} folder already exists, skipping git clone"
  else
    gitFetchRepo 'https://github.com/dotCMS/docker.git' ${docker_repo_path} ${DOCKER_BRANCH}

    if [[ ${docker_file_path} =~ ^${docker_repo_path}.* ]]; then
      echo "docker file path (${docker_file_path}) is within docker_repo_path (${docker_repo_path}), skipping"
    else
      cp -R ${docker_repo_path}/images/dotcms/ROOT ${docker_file_path}
      cp -R ${docker_repo_path}/images/dotcms/build-src/build_dotcms.sh ${docker_file_path}/setup/build-src
    fi
  fi
}

# Prepares resources to build a docker image with db access
function setupDockerDb {
  local docker_file_path=${1}
  mkdir -p ${docker_file_path}/setup
  cp -R ${DOCKER_SOURCE}/setup/db ${docker_file_path}/setup
}

function setupSrc {
  local docker_file_path=${1}
  cp -R ${DOCKER_SOURCE}/setup/build-src ${docker_file_path}/setup
}

function addLicenseAndOutput {
  local docker_file_path=${1}
  outputFolder=${docker_file_path}/output
  mkdir -p ${outputFolder} && chmod 777 ${outputFolder}
  licenseFolder=${docker_file_path}/license
  mkdir -p ${licenseFolder} && chmod 777 ${licenseFolder}
}

# Prepares resources to build a docker image with db access and valid license
function setupDocker {
  local docker_file_path=${1}
  setupDockerDb ${docker_file_path}
  setupSrc ${docker_file_path}
  addLicenseAndOutput ${docker_file_path}
}

function buildBase {
  local image_name=${1}
  local docker_file_path=${2}
  local docker_repo_path=${3}
  local skip_pull=${4}

  build_extra_args=''
  [[ -n "${GITHUB_SHA}" ]] && build_extra_args="--build-arg BUILD_HASH=${GITHUB_SHA::8}"
  [[ -n "${LICENSE_KEY}" ]] && build_extra_args="${build_extra_args} --build-arg LICENSE_KEY=${LICENSE_KEY}"

  pull_param='--pull'
  [[ ${skip_pull} == true ]] && pull_param=''

  executeCmd "docker build ${pull_param} --no-cache -t ${image_name}
    --build-arg BUILD_FROM=COMMIT
    --build-arg BUILD_ID=${BUILD_ID}
    ${build_extra_args}
    ${docker_file_path}/
  "
  dcResult=$?

  if [[ ${dcResult} != 0 ]]; then
    exit 1
  fi
}

# Prepares resources to build integration image
function setupDockerIntegration {
  mkdir -p ${DOCKER_SOURCE}/tests/integration
  mkdir -p ${DOCKER_SOURCE}/tests/integration/output
  mkdir -p ${DOCKER_SOURCE}/tests/integration/license
  cp -R ${DOCKER_SOURCE}/setup ${DOCKER_SOURCE}/tests/integration
}

function prepareLicense {
  local docker_file_path=${1}
  local license=${2}
  local debug=${3}
  local licenseFolder=${docker_file_path}/license
  mkdir -p ${licenseFolder}
  chmod 777 ${licenseFolder}
  licenseFile=${licenseFolder}/license.dat
  touch ${licenseFile}
  chmod 777 ${licenseFile}
  echo ${license} > ${licenseFile}

  if [[ ${debug} == true ]] ; then
    ls -las ${licenseFolder}
    echo "License found:
    ${license}"
  fi
}
