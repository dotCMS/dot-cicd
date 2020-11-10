#!/bin/bash

TEST_RESULTS="test-results"
GITHUB="github.com"
GITHACK="raw.githack.com"
GITHUB_TEST_RESULTS_PATH="dotCMS/${TEST_RESULTS}"
export GITHUB_TEST_RESULTS_HOST_PATH="${GITHUB}/${GITHUB_TEST_RESULTS_PATH}"
export GITHUB_TEST_RESULTS_URL="https://${GITHUB_TEST_RESULTS_HOST_PATH}"
export GITHACK_TEST_RESULTS_URL="https://${GITHACK}/${GITHUB_TEST_RESULTS_PATH}"
export GITHUB_TEST_RESULTS_REPO="${GITHUB_TEST_RESULTS_URL}.git"
export GITHUB_TEST_RESULTS_BROWSE_URL="${GITHACK_TEST_RESULTS_URL}/$(urlEncode ${BUILD_ID})/projects/${DOT_CICD_TARGET}"
export GITHUB_TEST_RESULTS_REMOTE="https://${GITHUB_USER_TOKEN}@${GITHUB_TEST_RESULTS_HOST_PATH}"
export GITHUB_TEST_RESULTS_REMOTE_REPO="https://${GITHUB_USER_TOKEN}@${GITHUB_TEST_RESULTS_HOST_PATH}.git"

function checkForToken {
  if [[ -z "${GITHUB_USER_TOKEN}" ]]; then
    echo "Error: Test results push token is not defined, aborting..."
    exit 1
  fi

  echo "Test results token found"
}

function removeIfExists {
  local results=${1}

  if [[ -d $results ]]; then
    echo "Removing test results results: ${results}"
    rm -rf $results
  fi
}

function createAndSwitch {
  local results=${1}
  if [[ ! -d $results ]]; then
    mkdir -p $results
  fi

  cd $results
}

function cleanTestFolders {
  if [[ -n "${BUILD_ID}" ]]; then
    removeIfExists "./${BUILD_ID}/${TEST_TYPE}"
  fi

  git status
  git commit -m "Cleaning ${TEST_TYPE} tests results with hash '${BUILD_HASH}' and branch '${BUILD_ID}'"
}

function gitConfig {
  git config --global user.email "${GITHUB_USER}@dotcms.com"
  git config --global user.name "${GITHUB_USER}"
}

function addResults {
  local results=${1}
  if [[ -z "$results" ]]; then
    echo "Cannot add results since its empty, ignoring"
    exit 1
  fi

  local targetFolder=$(resolveTestPath ${results})
  mkdir -p ${targetFolder}
  echo "Adding test results to: ${targetFolder}"
  cp -R ${outputFolder}/* ${targetFolder}
}

function persistResults {
  TEST_RESULTS_PATH=${DOT_CICD_PATH}/${TEST_RESULTS}
  gitConfig
  
  echo "Cloning ${GITHUB_TEST_RESULTS_REPO} to ${TEST_RESULTS_PATH}"
  git clone ${GITHUB_TEST_RESULTS_REPO} ${TEST_RESULTS_PATH}
  createAndSwitch ${TEST_RESULTS_PATH}/projects/${DOT_CICD_TARGET}

  git fetch --all
  remoteBranch=$(git ls-remote --heads ${GITHUB_TEST_RESULTS_REMOTE_REPO} ${BUILD_ID} | wc -l | tr -d '[:space:]')

  if [[ ${remoteBranch} == 1 ]]; then
    echo "git checkout -b ${BUILD_ID} --track origin/${BUILD_ID}"
    git checkout -b ${BUILD_ID} --track origin/${BUILD_ID}
  else
    echo "git checkout -b ${BUILD_ID}"
    git checkout -b ${BUILD_ID}
  fi
  
  if [[ $? != 0 ]]; then
    echo "Error checking out branch '${BUILD_ID}', continuing with main"
    git pull origin main
  else
    git branch
    if [[ ${remoteBranch} == 1 ]]; then
      echo "git pull origin ${BUILD_ID}"
      git pull origin ${BUILD_ID}
    fi
  fi

  cleanTestFolders
  
  if [[ "${BUILD_ID}" != "main" ]]; then
    addResults ./${BUILD_HASH}
  fi
  addResults ./current

  git add .
  git commit -m "Adding ${TEST_TYPE} tests results for ${BUILD_HASH} at ${BUILD_ID}"
  git push ${GITHUB_TEST_RESULTS_REMOTE}
  git status
}

function trackJob {
  local resultLabel=
  if [[ ${1} == 0 ]]; then
    resultLabel=SUCCESS
  else
    resultLabel=FAIL
  fi

  local resultFile=${2}/job_results.source
  echo "Tracking job results in ${resultFile}"
  > ${resultFile}
  touch ${resultFile}
  echo "TEST_TYPE=${TEST_TYPE^}" >> ${resultFile}
  echo "DATABASE_TYPE=${databaseType}" >> ${resultFile}
  echo "TEST_TYPE_RESULT=${resultLabel}" >> ${resultFile}
  echo "COMMIT_TEST_RESULT_URL=${GITHUB_PERSIST_COMMIT_URL}/reports/html/index.html" >> ${resultFile}
  echo "BRANCH_TEST_RESULT_URL=${GITHUB_PERSIST_BRANCH_URL}/reports/html/index.html" >> ${resultFile}
}

export GITHUB_PERSIST_COMMIT_URL="${GITHUB_TEST_RESULTS_BROWSE_URL}/$(resolveTestPath ${BUILD_HASH})"
export GITHUB_PERSIST_BRANCH_URL="${GITHUB_TEST_RESULTS_BROWSE_URL}/$(resolveTestPath current)"
