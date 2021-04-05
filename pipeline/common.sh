#!/bin/bash

# Git clone by providing repo, destination folder and branch to check out
function gitClone {
  local repo=$1
  local dest=$2
  local branch=$3

  echo "Cloning repo from ${repo}"
  echo "Params1: ${repo} ${dest} ${branch}"
  git clone ${repo} ${dest}

  if [[ $? != 0 ]]; then
    echo "Error cloning repo '${repo}'"
    exit 1
  fi

  echo "Params2: ${repo} ${dest} ${branch}"
  if [[ -n "${branch}" ]]; then
    echo "Params3: ${repo} ${dest} ${branch}"
    pushd ${dest}
    git fetch --all
    git pull
    echo "Params4: ${repo} ${dest} ${branch}"
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

  gitClone ${repo} ${dest} ${branch}
}

# Cleans up setup for Docker test resources
function cleanUpTest {
  local testType=${1}

  if [[ ! -d ${DOCKER_SOURCE}/tests/${testType}/setup ]]; then
    echo "Test type location ${DOCKER_SOURCE}/tests/${testType}/setup does not exist, aborting clean up"
    exit 1
  fi

  rm -rf ${DOCKER_SOURCE}/tests/${testType}/setup
}

# Prepares resources to build integration image
function setupBuildBase {
  mkdir -p ${DOCKER_SOURCE}/tests/sidecar/setup
  mkdir -p ${DOCKER_SOURCE}/tests/sidecar/license
  cp -R ${DOCKER_SOURCE}/setup/build-src ${DOCKER_SOURCE}/tests/sidecar/setup
  cp -R ${DOCKER_SOURCE}/setup/db ${DOCKER_SOURCE}/tests/sidecar/setup

  local dotcmsDockerImage=${1}
  gitFetchRepo 'https://github.com/dotCMS/docker.git' ${dotcmsDockerImage} "19756-docker-java-11"
  cp -R ${dotcmsDockerImage}/images/dotcms/ROOT ${DOCKER_SOURCE}/tests/sidecar
  cp -R ${dotcmsDockerImage}/images/dotcms/build-src/build_dotcms.sh ${DOCKER_SOURCE}/tests/sidecar/setup/build-src
}

# Prepares resources to build integration image
function setupBuildBaseTests {
  mkdir -p ${DOCKER_SOURCE}/tests/integration
  cp -R ${DOCKER_SOURCE}/setup ${DOCKER_SOURCE}/tests/integration
}

# Prepares resources to run unit tests
function setupTestRun {
  local testType=${1}

  if [[ -d ${DOCKER_SOURCE}/tests/${testType}/setup ]]; then
    rm -rf ${DOCKER_SOURCE}/tests/${testType}/setup
  fi

  mkdir -p ${DOCKER_SOURCE}/tests/${testType}/setup
  cp -R ${DOCKER_SOURCE}/setup/db ${DOCKER_SOURCE}/tests/${testType}/setup
}
