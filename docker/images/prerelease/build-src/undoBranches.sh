#!/bin/bash

#########################
# Script: undoBranches.sh
# Runs in dry-run mode and remotely removes all the branches created for provided repos

if [[ "${DRY_RUN}" == 'true' ]]; then
  for repo in "${repos[@]}"
  do
    undoPush ${repo} ${branch}
  done

  [[ "${master_branch}" != 'master' ]] && undoPush ${CORE_WEB_GITHUB_REPO} ${master_branch}
fi
