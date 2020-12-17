#!/bin/bash

echo 'Building Distro files'

cd dotCMS
./gradlew createDist
cd ../
ls -las dist-output

