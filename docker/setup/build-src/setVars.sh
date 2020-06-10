#!/bin/bash

export TEST_TYPE=${1}

if [[ ! -z "${EXTRA_PARAMS}" ]]; then
  echo "Running curl tests with extra parameters [${EXTRA_PARAMS}]"
fi

#  One of ["postgres", "mysql", "oracle", "mssql"]
if [[ "${TEST_TYPE}" != "unit" && -z "${databaseType}" ]]; then
  echo ""
  echo "======================================================================================="
  echo " >>> 'databaseType' environment variable NOT FOUND, setting postgres as default DB <<<"
  echo "======================================================================================="
  export databaseType=postgres
fi

. /build/common.sh

commitPath="$(resolveTestPath ${BUILD_HASH})"
branchPath="$(resolveTestPath ${BUILD_ID})"

if [[ "${DOT_CICD_PERSIST}" == "google" ]]; then
  export STORAGE_JOB_COMMIT_FOLDER="cicd-246518-tests/${commitPath}"
  export STORAGE_JOB_BRANCH_FOLDER="cicd-246518-tests/${branchPath}"
  export BASE_STORAGE_URL="https://storage.googleapis.com"
elif [[ "${DOT_CICD_PERSIST}" == "github" ]]; then
  . /build/github/githubCommon.sh 
  export STORAGE_JOB_COMMIT_FOLDER="${commitPath}"
  export STORAGE_JOB_BRANCH_FOLDER="${branchPath}"
  export BASE_STORAGE_URL=${GITHUB_TEST_RESULTS_BROWSE_URL}
fi
