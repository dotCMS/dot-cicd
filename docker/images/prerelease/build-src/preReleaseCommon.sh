#!/bin/bash

#############################
# Script: preReleaseCommon.sh
# Common functions script

# Fallbacks into cloning the provided repo when the previous on fails
#
# $1: repo: repo name
# $2: error_code: error code from previous clone
function cloneFallback {
  local repo=${1}
  local error_code=${2}
  local resolved_repo=$(resolveRepoUrl ${repo} ${GITHUB_USER_TOKEN} ${GITHUB_USER})

  [[ ${cmdResult} == 0 ]] && return 0

  if [[ "${DRY_RUN}" == 'true' && ${cmdResult} == 128 ]]; then
    if [[ "${repo}" == "${CORE_GITHUB_REPO}" ]]; then
      executeCmd "gitCloneSubModules ${resolved_repo}"
    else
      executeCmd "gitClone ${resolved_repo}"
    fi
    [[ ${cmdResult} != 0 ]] && exit 1
  else
    exit 1
  fi
}

# Creates a new branch from a given repo.
# Branch is also provided
#
# $1: repo: repo name
# $2: branch: branch to create
function createAndPush {
  local repo=${1}
  local branch=${2}
  local clone_branch=${FROM_BRANCH}
  [[ "${clone_branch}" == 'master' ]] && clone_branch=''

  local resolved_repo=$(resolveRepoUrl ${repo} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
  printf "\e[32m Creating and pushing Release Branch on ${repo} \e[0m  \n"
  if [[ "${repo}" == "${CORE_GITHUB_REPO}" ]]; then
    executeCmd "gitCloneSubModules ${resolved_repo} ${clone_branch}"
    cloneFallback ${repo} ${cmdResult}
    pushd ${repo}
    git status
    [[ "${DEBUG}" == 'true' ]] && cat .gitmodules
    executeCmd "git checkout -- .gitmodules"
    [[ "${DEBUG}" == 'true' ]] && cat .gitmodules
    popd
  else
    executeCmd "gitClone ${resolved_repo} ${clone_branch}"
    cloneFallback ${repo} ${cmdResult}
  fi

  pushd ${repo}
  checkoutBranch ${repo} ${branch}
  [[ $? == 0 ]] && executeCmd "git push ${resolved_repo} ${branch}"

  if [[ "${repo}" == "${CORE_GITHUB_REPO}" ]]; then
    local ee_resolved_repo=$(resolveRepoUrl ${ENTERPRISE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
    pushd ${ENTERPRISE_DIR}
    checkoutBranch ${ENTERPRISE_GITHUB_REPO} ${branch}
    [[ $? == 0 ]] && executeCmd "git push ${ee_resolved_repo} ${branch}"
    popd
  fi
  popd

  printf "\e[32m Repo ${repo} created and pushed \e[0m  \n"
}

# Depending on if it exists, it checkouts an existing branch or create a new one.
# If DRY_RUN mode is 'true' it removes the existent
#
# $1: repo: repo name
# $2: branch: branch to create
function checkoutBranch {
  local repo=${1}
  local branch=${2}
  local resolved_repo=$(resolveRepoUrl ${repo} ${GITHUB_USER_TOKEN} ${GITHUB_USER})

  gitRemoteLs ${resolved_repo} ${branch}
  local remote_branch=$?
  if [[ ${remote_branch} == 1 ]]; then
    undoPush ${repo} ${branch}
    remote_branch=0
  fi

  local checkout_cmd="git checkout -b ${branch}"
  local result=0
  [[ ${remote_branch} == 1 ]] && checkout_cmd="${checkout_cmd} --track origin/${branch}" && result=1
  executeCmd "git branch"
  executeCmd "${checkout_cmd}"
  return ${result}
}

# Remotely removes a given branch at given repo
#
# $1: repo: repo name
# $2: branch: branch to remove
function undoPush {
  local repo=${1}
  local branch=${2}

  printf "\e[32m Removing previously created branch ${branch} for ${repo} \e[0m  \n"
  if [[ "${repo}" == "${CORE_GITHUB_REPO}" ]]; then
    local resolved_repo=$(resolveRepoUrl ${repo} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
    local ee_resolved_repo=$(resolveRepoUrl ${ENTERPRISE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
    executeCmd "git push ${resolved_repo} :${branch}"
    pushd ${ENTERPRISE_DIR}
    executeCmd "git push ${ee_resolved_repo} :${branch}"
    popd
  else
    executeCmd "git push origin :${branch}"
  fi

  [[ ${cmdResult} != 0 ]] && echo "Error pushing ${branch}, ignoring this"
}

# Given a version gets valid npm version from it
#
# $1: version
function getValidNpmVersion {
  local version=${1}
  local major=$(echo ${version} | cut -d. -f1)
  local minor=$(echo ${version} | cut -d. -f2)

  #Removes the '0' from the month if needed
  [[ "${minor::1}" == "0" ]] && minor=${minor:1:1}

  echo "${major}.${minor}.0"
}

# Given a version pump up according to year-month rules
#
# $1: version
function pumpUpVersion {
  local arr_in=(${1//./ })
  local year=$arr_in
  local month=$((arr_in[1] + 1))

  if [ $month -gt 12 ]
    then
      month=1
      year=$((year+1))
    fi

  echo ${year}.${month}.$((arr_in[2]))
}

# Runs a 'npm publish -tag' command npm with a provided tag
# Dry-run mode flag is passed to command
#
# $1: tag: provided tag
function npmPublish {
  executeCmd "npm set //registry.npmjs.org/:_authToken ${NPM_TOKEN}"
  local tag=${1}
  local cmd="npm publish --tag ${tag}"
  [[ "${DRY_RUN}" == 'true' ]] && cmd="${cmd} --dry-run"
  executeCmd "${cmd}"
  [[ ${cmdResult} != 0 ]] && echo "Error running npm publish with tag ${tag}" && exit 1
}

# Given a npm project name, a tag and its release npm valid version, resolves the current version counter.
#
# $1: repo: npm repo
# $2: tag: provided tag
# $3: release_version: release npm valid version
function currentNpmRepoVersionCounter {
  local repo=${1}
  local tag=${2}
  local release_version=${3}
  [[ -z "${repo}" ]] && echo 'Missing repo' && return -1
  [[ -z "${tag}" ]] && echo 'Missing tag' && return -2
  [[ -z "${release_version}" ]] && echo 'Missing release_version' && return -3

  npm dist-tag ls ${repo}
  [[ $? != 0 ]] && echo "Invalid repo: ${repo}" && return -4
  local full_version=$(npm dist-tag ls ${repo} | grep "${tag}: ")
  [[ -z "${full_version}" ]] && return 0

  local prefix="-${tag}."
  local counter=${full_version#*"${prefix}"}
  echo "Found the current npm repo version counter: ${counter}"
  local counter_number=$((counter))
  return ${counter_number}
}

# Given a npm project name, a tag and its release npm valid version, resolves the next version counter.
#
# $1: repo: npm repo
# $2: tag: provided tag
# $3: release_version: release npm valid version
function nextNpmRepoVersionCounter {
  currentNpmRepoVersionCounter $@
  local counter=$?
  counter=$((counter + 1))
  echo "Calculated a next npm repo version counter: ${counter}"
  return ${counter}
}
