#!/bin/bash

##########################
# Script: preBuildCore.sh
# Pre-builds core to have immutables compiled before uploading any EE jar

printf "\e[32m Pre-build core \e[0m  \n"

pushd ${CORE_GITHUB_REPO}/dotCMS
executeCmd "rm -rf build ../dist ../core-web/node_modules"
executeCmd "./gradlew clean"
executeCmd "./gradlew generateDependenciesFromMaven"
executeCmd "./gradlew createDistPrep"
popd
