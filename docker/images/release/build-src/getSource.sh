#!/bin/bash

build_id=$1

# Clone core
cd /build/src
git clone https://github.com/dotCMS/core.git core
cd core
echo 'Getting submodules'
git submodule update --init --recursive
git gc --aggressive

if [[ ${is_release} == true ]]; then
  gitBranchTag="TAG"
else
  gitBranchTag="branch"
fi
echo "Checking out ${gitBranchTag} ${build_id}"
if [[ ${is_release} == true ]]; then
  git checkout tags/${build_id} -b ${build_id}
elif [[ "${build_id}" != "master" ]]; then
  git checkout -b ${build_id}
fi

git clean -f -d
git pull origin ${build_id}

echo
echo 'Git status:'
git branch
git status
