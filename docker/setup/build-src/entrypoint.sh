#!/bin/bash

# first we need to do some clean up
rm -rf /custom/output/*
mkdir -p /custom/output/logs
mkdir -p /custom/output/reports/html

. /build/setVars.sh ${1}

if [[ "${TEST_TYPE}" == "integration" || -z "${TEST_TYPE}" ]]; then
  . /build/integrationTests.sh
elif [[ "${TEST_TYPE}" == "unit" || -z "${TEST_TYPE}" ]]; then
  . /build/unitTests.sh
elif [[ "${TEST_TYPE}" == "curl" || -z "${TEST_TYPE}" ]]; then
  . /build/installCurlDeps.sh
  . /build/curlTests.sh
else
    echo "Running user CMD..."
    exec -- "$@"
fi
