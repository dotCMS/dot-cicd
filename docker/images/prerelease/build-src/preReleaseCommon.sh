#!/bin/bash

#############################
# Script: preReleaseCommon.sh
# Common functions script

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
    ee_resolved_repo=$(resolveRepoUrl ${ENTERPRISE_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
    executeCmd "gitCloneSubModules ${resolved_repo} ${clone_branch}"
    pushd ${repo}
    git status
    [[ "${DEBUG}" == 'true' ]] && cat .gitmodules
    executeCmd "git checkout -- .gitmodules"
    [[ "${DEBUG}" == 'true' ]] && cat .gitmodules
    popd
  else
    executeCmd "gitClone ${resolved_repo} ${clone_branch}"
  fi

  pushd ${repo}
  checkoutBranch ${repo} ${branch}
  local exists=$?
  [[ ${exists} == 0 ]] && executeCmd "git push ${resolved_repo} ${branch}"

  if [[ "${repo}" == "${CORE_GITHUB_REPO}" ]]; then
    pushd ${ENTERPRISE_DIR}
    checkoutBranch ${ENTERPRISE_GITHUB_REPO} ${branch}
    exists=$?
    [[ ${exists} == 0 ]] && executeCmd "git push ${ee_resolved_repo} ${branch}"
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
  if [[ ${remote_branch} == 1 && "${DRY_RUN}" == 'true' ]]; then
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

  printf "\e[32m Removing just created branch ${branch} for ${repo} \e[0m  \n"
  if [[ "${repo}" == "${CORE_GITHUB_REPO}" ]]; then
    resolved_repo=$(resolveRepoUrl ${repo} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
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
  local month=$((arr_in[1] + 1))
  [[ $month -gt 12 ]] && month=1
  echo ${arr_in[0]}.${month}.$((arr_in[2]))
}

# Runs a 'npm publish -tag' command with a provided tag
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

# Calls python script to replace a given text by a provided one
#
# $1: file: file to do replacing
# $2: replace_text: text to replace
# $3: replacing_text: new text
function replaceTextInFile {
  local file=${1}
  local replace_text=${2}
  local replacing_text=${3}

  executeCmd "python3 /build/replaceTextInFile.py ${file} \"${replace_text}\" \"${replacing_text}\""
  [[ "${DEBUG}" == 'true' ]] && cat ${file}
}
