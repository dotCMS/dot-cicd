#!/bin/bash

#########################
# Script: buildDistro.sh
# Execute gradle task for creating DotCMS distribution

pushd dotCMS
echo
echo '######################################################################
Building Distro
######################################################################'

executeCmd "./gradlew createDist"
[[ $? != 0 ]] \
  && echo 'Error executing ./gradlew createDist' \
  && exit 1

popd
ls -las dist-output
