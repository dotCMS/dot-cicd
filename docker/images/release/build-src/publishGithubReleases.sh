#!/bin/bash

is_release=${1}
ee_build_id=${2}
github_user=${3}
github_user_token=${4}

function commitAndPush {
  local repo=${1}
  local repo_url=${2}

  git commit --allow-empty -m "Publish Release"

  if [[ "${is_release}" == 'true' ]]; then
    git push ${repo_url}
  else
    echo "Dry run detected, not pushing ${RELEASE_BRANCH_NAME} to ${repo_url}"
  fi
}

function pushRelease {
  local repo=${1}
  local modulePath=${2}
  local repo_url=$(resolveRepoUrl ${repo} ${github_user_token} ${github_user})
  gitRemoteLs ${repo_url} ${RELEASE_BRANCH_NAME}
  local remote_branch=$?

  echo "#############################
Releasing on ${repo}
#############################"
  [[ ${remote_branch} != 1 ]] \
    && echo "Release branch ${RELEASE_BRANCH_NAME} is not found in remote for ${repo}, ignoring release" \
    && return

  if [[ -n "${modulePath}" ]]; then
    gitCloneSubModules ${repo_url} ${RELEASE_BRANCH_NAME} ${repo}
    pushd ${modulePath}
    git checkout -b ${RELEASE_BRANCH_NAME} --track origin/${RELEASE_BRANCH_NAME}
    git pull origin ${RELEASE_BRANCH_NAME}
  else
    gitClone ${repo_url} ${RELEASE_BRANCH_NAME} ${repo}
    pushd ${repo}
  fi

  commitAndPush ${repo} ${repo_url}
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
