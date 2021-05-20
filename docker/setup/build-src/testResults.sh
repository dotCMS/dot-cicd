#!/bin/bash

#############################
# Script: testsResults.sh
# Collection of functions that support storing results in test-results repo

# Checks for token stored in env-var GITHUB_USER_TOKEN. It not exit the execution with error code 1.
function checkForToken {
  if [[ -z "${GITHUB_USER_TOKEN}" ]]; then
    echo "Error: Test results push token is not defined, aborting..."
    exit 1
  fi

  echo "Test results token found"
}

# Removes specific test type results folder and commit the deletion
function cleanTestFolders {
  if [[ -n "${BUILD_ID}" ]]; then
    local folder=./${BUILD_ID}/${TEST_TYPE}
    [[ -d ${folder} ]] && rm -rf folder && [[ "${DEBUG}" == 'true' ]] && echo "Removing ${folder}"
  fi

  git commit -m "Cleaning ${TEST_TYPE} tests results with hash '${BUILD_HASH}' and branch '${BUILD_ID}'"
}

# Creates required directory structure for the provided results folder and copies them to the new location
#
# $1: results: to copy to results location
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

# Persists results in 'test-results' repo in the provided BUILD_ID branch.
function persistResults {
  # Prepare who is pushing the changes
  gitConfig ${GITHUB_USER}

  # Resolve test results fully
  test_results_repo_url=$(resolveRepoUrl ${TEST_RESULTS_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
  local test_results_path=${DOT_CICD_PATH}/${TEST_RESULTS_GITHUB_REPO}

  # Query for remote branch
  gitRemoteLs ${test_results_repo_url} ${BUILD_ID}
  local remote_branch=$?
  # If it does not exist use master
  if [[ ${remote_branch} == 1 ]]; then
    branch=${BUILD_ID}
  else
    branch=master
  fi

  # Clone test-results repo at resolved branch
  gitClone ${test_results_repo_url} ${branch} ${test_results_path}
  # Create results folder if ir does not exist and switch to it
  local results_folder=${test_results_path}/projects/${DOT_CICD_TARGET}
  if [[ ! -d ${results_folder} ]]; then
    [[ "${DEBUG}" == 'true' ]] && echo "Creating ${results_folder}"
    mkdir -p ${results_folder}
  fi
  cd ${results_folder}

  # If no remote branch detected create one
  if [[ ${remote_branch} != 1 ]]; then
    [[ "${DEBUG}" == 'true' ]] && echo "Git command:
      git checkout -b ${BUILD_ID}
    "
    git checkout -b ${BUILD_ID}
  fi

  # Clean test results folders by removing contents and committing them
  cleanTestFolders

  # Do not add commit results when the branch is master, otherwise add test results to commit
  [[ "${BUILD_ID}" != "master" ]] && addResults ./${BUILD_HASH}
  # Add results to current
  addResults ./current

  # Check for something new to commit
  [[ "${DEBUG}" == 'true' ]] && git branch && git status && echo
  git status | grep "nothing to commit, working tree clean"
  git_result=$?

  # If there are changes then start the fun part
  if [[ ${git_result} != 0 ]]; then
    # Add everything
    [[ "${DEBUG}" == 'true' ]] && echo "Git command:
      git add .
    "
    git add .
    git_result=$?
    if [[ ${git_result} != 0 ]]; then
      echo "Error adding to git for ${BUILD_HASH} at ${BUILD_ID}, error code: ${git_result}"
      exit 1
    fi

    # Commit the changes
    [[ "${DEBUG}" == 'true' ]] && echo "Git command:
      git commit -m \"Adding ${TEST_TYPE} tests results for ${BUILD_HASH} at ${BUILD_ID}\"
    "
    git commit -m "Adding ${TEST_TYPE} tests results for ${BUILD_HASH} at ${BUILD_ID}"
    git_result=$?
    if [[ ${git_result} != 0 ]]; then
      echo "Error committing to git for ${BUILD_HASH} at ${BUILD_ID}, error code: ${git_result}"
      exit 1
    fi

    # Do not pull unless branch is remote
    if [[ ${remote_branch} == 1 ]]; then
      # Perform a pull just in case
      [[ "${DEBUG}" == 'true' ]] && echo "Git command:
        git pull origin ${BUILD_ID}
      "
      git pull origin ${BUILD_ID}
      git_result=$?
      if [[ ${git_result} != 0 ]]; then
        echo "Error pulling from git branch ${BUILD_ID}, error code: ${git_result}"
        exit 1
      fi
    else
      echo "Not pulling ${BUILD_ID} since it is not yet remote"
    fi

    # Finally push the changes
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

# Creates a summary status file for test the specific TEST_TYPE, databaseType in both commit and branch paths.
#
# $1: results status
# $2: folder to store file
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
