#!/bin/bash

TEST_RESULTS="test-results"
GITHUB="github.com"
GITHACK="raw.githack.com"
GITHUB_TEST_RESULTS_PATH="dotCMS/${TEST_RESULTS}"
export GITHUB_TEST_RESULTS_HOST_PATH="${GITHUB}/${GITHUB_TEST_RESULTS_PATH}"
export GITHUB_TEST_RESULTS_URL="https://${GITHUB_TEST_RESULTS_HOST_PATH}"
export GITHACK_TEST_RESULTS_URL="https://${GITHACK}/${GITHUB_TEST_RESULTS_PATH}"
export GITHUB_TEST_RESULTS_REPO="${GITHUB_TEST_RESULTS_URL}.git"
export GITHUB_TEST_RESULTS_BROWSE_URL="${GITHACK_TEST_RESULTS_URL}/master/projects/${DOT_CICD_TARGET}"

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
  echo "Cloning ${GITHUB_TEST_RESULTS_REPO} to ${TEST_RESULTS_PATH}"
  git clone ${GITHUB_TEST_RESULTS_REPO} ${TEST_RESULTS_PATH}
  
  gitConfig
  createAndSwitch ${TEST_RESULTS_PATH}/projects/${DOT_CICD_TARGET}
  cleanTestFolders
  
  addResults ./${BUILD_HASH}
  addResults ./${BUILD_ID}

  git add .
  git commit -m "Adding ${TEST_TYPE} tests results for ${BUILD_HASH} at ${BUILD_ID}"
  git push https://${GITHUB_USER_TOKEN}@${GITHUB_TEST_RESULTS_HOST_PATH}
  git status
}

export GITHUB_PERSIST_COMMIT_URL="${GITHUB_TEST_RESULTS_BROWSE_URL}/$(resolveTestPath ${BUILD_HASH})"
export GITHUB_PERSIST_BRANCH_URL="${GITHUB_TEST_RESULTS_BROWSE_URL}/$(resolveTestPath ${BUILD_ID})"
