#!/bin/bash

echo 'Generating Java Doc'

cd dotCMS
echo
echo '######################################################################'
echo 'Executing ./gradlew javadoc'
echo '######################################################################'

./gradlew javadoc
if [[ $? != 0 ]]; then
  echo 'Error executing ./gradlew javadoc'
  exit 1
fi

cd ./build/docs
tar -cf javadoc.tar javadoc
gzip -9 javadoc.tar
ls -las .
mv javadoc.tar.gz ..
cd ../../..

