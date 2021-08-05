#! /bin/bash

#####################
# Script: gitClone.sh
# Performs a git clone must likely at Dockerfile build time
#
# $1: repo: repo to clone
# $2: dest: destination folder
# $3: branch: branch to clone

repo=${1}
dest=${2}
branch=${3}

[[ -z "${dest}" ]] && dest=.

if [[ -n "${branch}" && ${branch} =~ master|HEAD ]]; then
  git clone --depth 1 ${repo} ${dest}
else
  git clone --depth 1 --single-branch --branch ${branch} ${repo} ${dest}
fi
