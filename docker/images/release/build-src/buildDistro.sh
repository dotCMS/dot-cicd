#!/bin/bash

#########################
# Script: buildDistro.sh
# Execute gradle task for creating DotCMS distribution

pushd dotCMS
echo
echo '######################################################################'
echo "Executing
  ./gradlew clean
  ./gradlew createDist"
echo '######################################################################'

./gradlew clean
if [[ $? != 0 ]]; then
  echo 'Error executing ./gradlew clean'
  exit 1
fi

./gradlew createDist
if [[ $? != 0 ]]; then
  echo 'Error executing ./gradlew createDist'
  exit 1
fi

popd
ls -las dist-output
