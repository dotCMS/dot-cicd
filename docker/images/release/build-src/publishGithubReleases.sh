#!/bin/bash

#################################
# Script: publishGithubRelease.sh
# For every main repo (core, enterprise, core-web, plugin-seeds, dot-cicd, docker) triggers a publish workflow by
# committing and pushing.
#
# $1: is_release: release flag
# $2: ee_build_id: enterprise branch/commit
# $3: github_user: github user
# $4: github_user_token: github user token

is_release=${1}
ee_build_id=${2}
github_user=${3}
github_user_token=${4}

# Commits an empty commit and push to provided repo url
#
# $1: repo_url: repo url
function commitAndPush {
  local repo_url=${1}

  git commit --allow-empty -m "Publish Release"

  if [[ "${is_release}" == 'true' ]]; then
    git push ${repo_url}
  else
    echo "Dry run detected, not pushing ${RELEASE_BRANCH_NAME} to ${repo_url}"
  fi
}

# For provided repo, clone it, empty commit and push to trigger github release
#
# $1: repo: repo name
# $2: module_path: when present it represents the path where submodule is targeted
function pushRelease {
  local repo=${1}
  local module_path=${2}
  local repo_url=$(resolveRepoUrl ${repo} ${github_user_token} ${github_user})

  # Verifies for branch to be remote, if it does not exist ignore this repo
  gitRemoteLs ${repo_url} ${RELEASE_BRANCH_NAME}
  local remote_branch=$?
  [[ ${remote_branch} != 1 ]] \
    && echo "Release branch ${RELEASE_BRANCH_NAME} is not found in remote for ${repo}, ignoring release" \
    && return

  echo "#############################
Releasing on ${repo}
#############################"
  # Git clones the repo and depending on module_path it clones the submodules as well
  if [[ -n "${module_path}" ]]; then
    gitCloneSubModules ${repo_url} ${RELEASE_BRANCH_NAME} ${repo}
    pushd ${module_path}
    git checkout -b ${RELEASE_BRANCH_NAME} --track origin/${RELEASE_BRANCH_NAME}
    git pull origin ${RELEASE_BRANCH_NAME}
  else
    gitClone ${repo_url} ${RELEASE_BRANCH_NAME} ${repo}
    pushd ${repo}
  fi

  # Commit and pushes "changes"
  commitAndPush ${repo_url}
  popd
}

RELEASE_BRANCH_NAME=${ee_build_id}
if [[ "${is_release}" == 'true' ]]; then
  RELEASE_PREFIX='release-'
  RELEASE_BRANCH_NAME=${RELEASE_BRANCH_NAME/v/$RELEASE_PREFIX}
fi
echo
echo '######################################################################'
echo "RELEASE_BRANCH_NAME: " ${RELEASE_BRANCH_NAME}

mkdir -p releases && pushd releases
pushRelease ${CORE_GITHUB_REPO} ${CORE_GITHUB_REPO}/dotCMS/src/main/enterprise
pushRelease ${CORE_WEB_GITHUB_REPO}
pushRelease ${PLUGIN_SEEDS_GITHUB_REPO}
pushRelease ${DOT_CICD_GITHUB_REPO}
pushRelease ${DOCKER_GITHUB_REPO}
echo "Releases made" && ls -las
popd
