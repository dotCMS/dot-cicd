#!/bin/bash

build_id=$1

# Clone core
pushd ${DOT_CICD_PATH}
git clone https://github.com/dotCMS/core.git core
pushd core
echo 'Getting submodules'
git submodule update --init --recursive
git clean -f -d && git pull

echo "Checking out branch ${build_id}"
git checkout -b ${build_id}
git pull origin ${build_id}

echo
echo 'Git status:'
git status

popd
popd
