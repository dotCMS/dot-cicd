#!/bin/bash

############################
# Script: generateJavadoc.sh
# Calls gradle task to generate javadoc

echo 'Generating Java Doc'

pushd dotCMS
echo
echo '######################################################################'
echo 'Executing ./gradlew javadoc'
echo '######################################################################'

./gradlew javadoc
if [[ $? != 0 ]]; then
  echo 'Error executing ./gradlew javadoc'
  exit 1
fi

pushd ./build/docs
tar -cf javadoc.tar javadoc
gzip -9 javadoc.tar
ls -las .
mv javadoc.tar.gz ..
popd

popd
