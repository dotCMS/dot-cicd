#!/bin/bash

#################################
# Script: publishGithubRelease.sh
# For every main repo (core, enterprise, core-web, plugin-seeds, dot-cicd, docker) triggers a publish workflow by
# committing and pushing.
#
# $1: is_release: release flag
# $2: build_id: enterprise branch/commit

is_release=${1}
build_id=${2}

# Commits an empty commit and push to provided repo url
#
# $1: repo_url: repo url
function commitAndPush {
  local repo_url=${1}

  executeCmd "git commit --allow-empty -m \"Publish Release\""

  if [[ "${is_release}" == 'true' ]]; then
    executeCmd "git push ${repo_url}"
  else
    echo "Dry run detected, not pushing ${RELEASE_BRANCH_NAME} to ${repo_url}"
  fi
}

# For provided repo, clone it, empty commit and push to trigger github release
#
# $1: repo: repo name
function pushRelease {
  local repo=${1}
  local repo_url=$(resolveRepoUrl ${repo} ${GITHUB_USER_TOKEN} ${GITHUB_USER})

  # Verifies for branch to be remote, if it does not exist ignore this repo
  gitRemoteLs ${repo_url} ${RELEASE_BRANCH_NAME}
  local remote_branch=$?
  [[ ${remote_branch} != 1 ]] \
    && echo "Release branch ${RELEASE_BRANCH_NAME} is not found in remote for ${repo}, ignoring release" \
    && return

  echo "#############################
Releasing on ${repo}
#############################"
  gitClone ${repo_url} ${RELEASE_BRANCH_NAME} ${repo}
  [[ ! -d ./${repo} ]] && echo "Repo ${repo} could not be cloned, ignoring it"

  pushd ${repo}
  # Commit and pushes "changes"
  commitAndPush ${repo_url}
  popd
}

RELEASE_BRANCH_NAME=${build_id}
if [[ "${is_release}" == 'true' ]]; then
  RELEASE_PREFIX='release-'
  RELEASE_BRANCH_NAME=${RELEASE_BRANCH_NAME/v/$RELEASE_PREFIX}

  echo
  echo '######################################################################'
  echo "RELEASE_BRANCH_NAME: " ${RELEASE_BRANCH_NAME}

  mkdir -p releases
  pushd releases
  release_repos=(${CORE_GITHUB_REPO} ${PLUGIN_SEEDS_GITHUB_REPO} ${DOT_CICD_GITHUB_REPO} ${DOCKER_GITHUB_REPO})
  for repo in "${release_repos[@]}"
  do
    pushRelease ${repo}
  done
  echo "Releases made:" && ls -las
  popd
fi
