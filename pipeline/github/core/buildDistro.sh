#!/bin/bash

echo 'Building Distro files'

cd dotCMS
./gradlew createDist
ls -las ../dist-output
cd ../
