#!/bin/bash

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
  local folder=${1}
  if [[ ! -d ${folder} ]]; then
    [[ "${DEBUG}" == 'true' ]] && echo "Creating ${folder}"
    mkdir -p ${folder}
  fi

  cd ${folder}
}

function cleanTestFolders {
  if [[ -n "${BUILD_ID}" ]]; then
    [[ "${DEBUG}" == 'true' ]] && echo "Removing ./${BUILD_ID}/${TEST_TYPE}"
    removeIfExists ./${BUILD_ID}/${TEST_TYPE}
  fi

  git commit -m "Cleaning ${TEST_TYPE} tests results with hash '${BUILD_HASH}' and branch '${BUILD_ID}'"
}

function addResults {
  local results=${1}
  if [[ -z "${results}" ]]; then
    echo "Cannot add results since its empty, ignoring"
    exit 1
  fi

  local target_folder=$(resolveResultsPath ${results})
  mkdir -p ${target_folder}
  echo "Adding test results ${results} to: ${target_folder}"

  cp -R ${OUTPUT_FOLDER}/* ${target_folder}
}

function persistResults {
  gitConfig ${GITHUB_USER}

  test_results_repo_url=$(resolveRepoUrl ${TEST_RESULTS_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
  local test_results_path=${DOT_CICD_PATH}/${TEST_RESULTS_GITHUB_REPO}

  gitRemoteLs ${test_results_repo_url} ${BUILD_ID}
  local remote_branch=$?
  if [[ ${remote_branch} == 1 ]]; then
    branch=${BUILD_ID}
  else
    branch=master
  fi

  gitClone ${test_results_repo_url} ${branch} ${test_results_path}
  createAndSwitch ${test_results_path}/projects/${DOT_CICD_TARGET}

  if [[ ${remote_branch} != 1 ]]; then
    [[ "${DEBUG}" == 'true' ]] && echo "Git command:
      git checkout -b ${BUILD_ID}
    "
    git checkout -b ${BUILD_ID}
  fi

  cleanTestFolders

  [[ "${BUILD_ID}" != "master" ]] && addResults ./${BUILD_HASH}
  addResults ./current

  [[ "${DEBUG}" == 'true' ]] && git branch && git status && echo
  git status | grep "nothing to commit, working tree clean"
  git_result=$?

  if [[ ${git_result} != 0 ]]; then
    [[ "${DEBUG}" == 'true' ]] && echo "Git command:
      git add .
    "
    git add .
    git_result=$?
    if [[ ${git_result} != 0 ]]; then
      echo "Error adding to git for ${BUILD_HASH} at ${BUILD_ID}, error code: ${git_result}"
      exit 1
    fi

    [[ "${DEBUG}" == 'true' ]] && echo "Git command:
      git commit -m \"Adding ${TEST_TYPE} tests results for ${BUILD_HASH} at ${BUILD_ID}\"
    "
    git commit -m "Adding ${TEST_TYPE} tests results for ${BUILD_HASH} at ${BUILD_ID}"
    git_result=$?
    if [[ ${git_result} != 0 ]]; then
      echo "Error committing to git for ${BUILD_HASH} at ${BUILD_ID}, error code: ${git_result}"
      exit 1
    fi

    [[ "${DEBUG}" == 'true' ]] && echo "Git command:
      git pull origin ${BUILD_ID}
    "
    git pull origin ${BUILD_ID}
    git_result=$?
    if [[ ${git_result} != 0 ]]; then
      echo "Error pulling from git branch ${BUILD_ID}, error code: ${git_result}"
      exit 1
    fi

    [[ "${DEBUG}" == 'true' ]] && echo "Git command:
      git push ${test_results_repo_url}
    "
    git push ${test_results_repo_url}
    git_result=$?
    if [[ ${git_result} != 0 ]]; then
      echo "Error pushing to git for ${BUILD_HASH} at ${BUILD_ID}, error code: ${git_result}"
      exit 1
    fi

    [[ "${DEBUG}" == 'true' ]] && echo "Git command:
      git status
    "
    git status
  else
    echo "No changes detected, not committing nor pushing"
  fi
}

function trackCoreTests {
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
