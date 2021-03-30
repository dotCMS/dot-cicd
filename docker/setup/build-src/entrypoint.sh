#!/bin/bash

export TEST_TYPE=${1}

if [[ ! -z "${EXTRA_PARAMS}" ]]; then
  echo "Running tests with extra parameters [${EXTRA_PARAMS}]"
fi

#  One of ["postgres", "mysql", "oracle", "mssql"]
if [[ "${TEST_TYPE}" != "unit" && -z "${databaseType}" ]]; then
  echo ""
  echo "======================================================================================="
  echo " >>> 'databaseType' environment variable NOT FOUND, setting postgres as default DB <<<"
  echo "======================================================================================="
  export databaseType=postgres
fi

. /build/githubCommon.sh

# first we need to do some clean up
rm -rf /custom/output/*
mkdir -p /custom/output/logs
mkdir -p /custom/output/reports/html

if [[ "${TEST_TYPE}" == "integration" || -z "${TEST_TYPE}" ]]; then
  . /build/integrationTests.sh
elif [[ "${TEST_TYPE}" == "unit" || -z "${TEST_TYPE}" ]]; then
  . /build/unitTests.sh
elif [[ "${TEST_TYPE}" == "curl" || -z "${TEST_TYPE}" ]]; then
  . /build/curlTests.sh
else
  echo "Running user CMD..."
  exec -- "$@"
fi
