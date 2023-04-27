#!/bin/bash

# Creates a new branch from a given repo.
# Branch is also provided
#
# $1: repo: repo name
# $2: branch: branch to create
function createAndPush {
  local repo=${1}
  local branch=${2}
  local resolved_repo=$(resolveRepoUrl ${repo} ${GITHUB_USER_TOKEN} ${GITHUB_USER})

  printf "\e[32m Creating and pushing Release Branch on ${repo} \e[0m  \n"
  executeCmd "gitClone ${resolved_repo} ${FROM_BRANCH}"
  [[ ${cmdResult} == 128 ]] && executeCmd "gitClone ${resolved_repo}"

  if [[ "${FROM_BRANCH}" != 'master' ]]; then
    executeCmd "git pull"
    executeCmd "git checkout master"
    executeCmd "git checkout ${FROM_BRANCH}"
  fi

  pushd ${repo}
  executeCmd "git branch && git status"

  checkoutBranch ${repo} ${branch}
  [[ $? == 0 ]] && executeCmd "git push ${resolved_repo} ${branch}"

  popd
  printf "\e[32m Repo ${repo} created and pushed \e[0m  \n"
}

# Depending on if it exists, it checkouts an existing branch or create a new one.
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
    executeCmd "git push ${resolved_repo} :${branch}"
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
function bumpUpVersion {
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
#
# $1: tag: provided tag
function npmPublish {
  executeCmd "npm set //registry.npmjs.org/:_authToken ${NPM_TOKEN}"
  local tag=${1}
  local cmd="CI=true npm publish --tag ${tag}"
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
