#!/bin/bash
is_release=$1
ee_build_id=$2
ee_rsa=$3

if [[ ${is_release} != true ]]; then
  echo "Not releasing on GitHub on different repos"
  exit 1;
fi

RELEASE_PREFIX="release-"
RELEASE_BRANCH_NAME=${ee_build_id/v/$RELEASE_PREFIX}

echo
echo '######################################################################'
echo 'Releasing on enterprise'
echo "RELEASE_BRANCH_NAME: " + ${RELEASE_BRANCH_NAME}
echo '######################################################################'

git clone https://github.com/dotCMS/core.git core
pushd core
echo 'Getting submodules'
git submodule update --init --recursive
git clean -f -d && git pull

cd core/src/main/enterprise
git checkout ${RELEASE_BRANCH_NAME}
git commit --allow-empty -m "Publish Release"
git push origin ${RELEASE_BRANCH_NAME} 

#git checkout ${RELEASE_BRANCH_NAME}
#git fetch --all
#git commit --allow-empty -m "Publish Release"

cd ../core