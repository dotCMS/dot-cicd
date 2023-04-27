#!/bin/bash

###########################
# Script: undoBranches.sh
# Given an array of repo names iterate it and for each remove the recently created branch

export repos=(${CORE_GITHUB_REPO} ${DOT_CICD_GITHUB_REPO} ${PLUGIN_SEEDS_GITHUB_REPO})

printf "\e[32m Creating branches \e[0m  \n"

for repo in "${repos[@]}"
do
  undoPush ${repo} ${BRANCH}
done
