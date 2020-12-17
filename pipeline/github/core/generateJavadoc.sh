#!/bin/bash

echo 'Generating Java Doc'

cd dotCMS
./gradlew javadoc
cd ./build/docs/
tar -cf javadoc.tar javadoc
gzip --best javadoc.tar
ls -las .
mv javadoc.tar.gz ../
cd ../../../
