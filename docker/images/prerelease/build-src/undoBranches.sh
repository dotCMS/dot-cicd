#!/bin/bash

#########################
# Script: undoBranches.sh
# Runs in dry-run mode and remotely removes all the branches created for provided repos

if [[ "${DRY_RUN}" == 'true' ]]; then
  for repo in "${repos[@]}"
  do
    pushd ${repo}
    undoPush ${repo} ${branch}
    popd
  done

  if [[ "${master_branch}" != 'master' ]]; then
    local resolved_repo=$(resolveRepoUrl ${CORE_WEB_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
    gitRemoteLs ${resolved_repo} ${master_branch}
    remote_branch=$?
    if [[ ${remote_branch} == 1 ]]; then
      pushd ${CORE_WEB_GITHUB_REPO}
      undoPush ${CORE_WEB_GITHUB_REPO} ${master_branch}
      popd
    fi
  fi
fi
