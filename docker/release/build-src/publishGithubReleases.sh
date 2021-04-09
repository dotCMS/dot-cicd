#!/bin/bash
is_release=$1
ee_build_id=$2
ee_rsa=$3

if [[ ${is_release} != true ]]; then
  echo "Not releasing on GitHub on different repos"
  exit 1;
fi

RELEASE_PREFIX="release-"
RELEASE_BRANCH_NAME=${ee_rsa/v/$RELEASE_PREFIX}

echo
echo '######################################################################'
echo 'Releasing on enterprise'
echo "RELEASE_BRANCH_NAME: " + ${RELEASE_BRANCH_NAME}
echo '######################################################################'

mkdir -p ~/.ssh
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
echo ${ee_rsa} > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
ls -las ~/.ssh
git config --global user.email "dotcmsbuild@dotcms.com"
git config --global user.name "dotcmsbuild"
git config --global pull.rebase false

git clone git@github.com:dotCMS/enterprise.git
cd enterprise
git checkout ${RELEASE_BRANCH_NAME}
git fetch --all
git commit --allow-empty -m "Publish Release"

cd ../core
