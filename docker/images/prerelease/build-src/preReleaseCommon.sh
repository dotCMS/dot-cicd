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

  resolved_repo=$(resolveRepoUrl ${repo} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
  printf "\e[32m Creating and pushing Release Branch on ${repo} \e[0m  \n"
  if [[ "${repo}" == "${CORE_GITHUB_REPO}" ]]; then
    executeCmd "gitCloneSubModules ${resolved_repo}"
    pushd ${repo}
    git status
    [[ "${DEBUG}" == 'true' ]] && cat .gitmodules
    executeCmd "git checkout -- .gitmodules"
    [[ "${DEBUG}" == 'true' ]] && cat .gitmodules
    popd
  else
    executeCmd "gitClone ${resolved_repo}"
  fi

  pushd ${repo}
  executeCmd "git pull origin master"
  [[ "${FROM_BRANCH}" != 'master' ]] && executeCmd "git checkout -b ${FROM_BRANCH} --track origin/${FROM_BRANCH}"

  local checkoutCmd="git checkout -b ${branch}"
  gitRemoteLs ${resolved_repo} ${branch}
  local remote_branch=$?
  if [[ ${remote_branch} == 1 ]]; then
    if [[ "${DRY_RUN}" != 'true' ]]; then
      checkoutCmd="${checkoutCmd} --track origin/${branch}"
    else
      undoPush ${repo} ${branch}
    fi
  fi

  executeCmd "${checkoutCmd}"
  executeCmd "git push ${resolved_repo} ${branch}"
  popd

  printf "\e[32m Repo ${repo} created and pushed \e[0m  \n"
}

# Remotely removes a given branch at given repo
#
# $1: repo: repo name
# $2: branch: branch to remove
function undoPush {
  local repo=${1}
  local branch=${2}

  pushd ${repo}
  printf "\e[32m Removing just created branch ${branch} for ${repo} \e[0m  \n"
  if [[ "${repo}" == "${CORE_GITHUB_REPO}" ]]; then
    resolved_repo=$(resolveRepoUrl ${repo} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
    executeCmd "git push ${resolved_repo} :${branch}"
  else
    executeCmd "git push origin :${branch}"
  fi

  [[ ${cmdResult} != 0 ]] && echo "Error pushing ${branch}" && exit 1
  popd
}

# Given a version gets valid npm version from it
#
# $1: version
function getValidNpmVersion {
  local major=$(echo $1 | cut -d. -f1)
  local minor=$(echo $1 | cut -d. -f2)

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
  local tag=${1}
  local cmd="npm publish --tag ${tag}"
  [[ "${DRY_RUN}" == 'true' ]] && cmd="${cmd} --dry-run"
  execute "${cmd}"
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
  [[ "${DEBUG}" == 'true' ]] && cat ${file} | grep "${replacing_text}"
}
