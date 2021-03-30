#!/bin/bash

. /build/githubCommon.sh

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

commitPath="$(resolveResultsPath ${BUILD_HASH})"
export STORAGE_JOB_COMMIT_FOLDER="${commitPath}"
export STORAGE_JOB_BRANCH_FOLDER="$(resolveResultsPath current)"
export BASE_STORAGE_URL=${GITHUB_TEST_RESULTS_BROWSE_URL}
