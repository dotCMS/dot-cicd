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

  [[ "${master_branch}" != 'master' ]] \
    && pushd ${CORE_WEB_GITHUB_REPO} \
    && undoPush ${CORE_WEB_GITHUB_REPO} ${master_branch} \
    && popd
fi
