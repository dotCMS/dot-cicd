#!/bin/bash

##########################
# Script: preBuildCore.sh
# Pre-builds core to have immutables compiled before uploading any EE jar

printf "\e[32m Pre-builds core \e[0m  \n"

pushd ${CORE_GITHUB_REPO}/dotCMS
executeCmd "git checkout master"
executeCmd "./gradlew java -PuseGradleNode=false"
executeCmd "git checkout ${branch}"
popd
