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

#echo
#echo '######################################################################'
#echo "RELEASE_BRANCH_NAME: " ${RELEASE_BRANCH_NAME}
#
#echo 'Releasing on enterprise'
#
#git clone https://github.com/dotCMS/core.git core
#pushd core
#echo 'Getting submodules'
#git submodule update --init --recursive
#git clean -f -d && git pull
#
#cd dotCMS/src/main/enterprise
#git checkout ${RELEASE_BRANCH_NAME}
#git commit --allow-empty -m "Publish Release"
#git push origin ${RELEASE_BRANCH_NAME}
#cd ../core
#
#echo 'Releasing on core-web'
#git clone git@github.com:dotCMS/core-web.git core-web
#pushd core-web
#git clean -f -d && git pull
#git checkout ${RELEASE_BRANCH_NAME}
#git commit --allow-empty -m "Publish Release"
#git push origin ${RELEASE_BRANCH_NAME}
#cd ../core-web
#
#echo 'Releasing on plugin-seeds'
#git clone git@github.com:dotCMS/plugin-seeds.git plugin-seeds
#pushd plugin-seeds
#git clean -f -d && git pull
#git checkout ${RELEASE_BRANCH_NAME}
#git commit --allow-empty -m "Publish Release"
#git push origin ${RELEASE_BRANCH_NAME}
#cd ../plugin-seeds
#
#echo 'Releasing on dot-cicd'
#git clone git@github.com:dotCMS/dot-cicd.git dot-cicd
#pushd dot-cicd
#git clean -f -d && git pull
#git checkout ${RELEASE_BRANCH_NAME}
#git commit --allow-empty -m "Publish Release"
#git push origin ${RELEASE_BRANCH_NAME}
#cd ../dot-cicd
#
#echo 'Releasing on docker'
#git clone git@github.com:dotCMS/docker.git docker-repo
#pushd docker-repo
#git clean -f -d && git pull
#git checkout ${RELEASE_BRANCH_NAME}
#git commit --allow-empty -m "Publish Release"
#git push origin ${RELEASE_BRANCH_NAME}
#cd ../docker-repo
