#! /bin/sh

GITHUB_STATUS="failure"
GITHUB_DESCRIPTION="Tests FAILED"
if [[ ${CURRENT_JOB_BUILD_STATUS} == 0 ]]; then
  GITHUB_STATUS="success"
  GITHUB_DESCRIPTION="Tests executed SUCCESSFULLY"
fi

# Examples
# https://storage.googleapis.com/cicd-246518-tests/branch-name/integration/mysql/reports/html/index.html
# https://storage.googleapis.com/cicd-246518-tests/branch-name/integration/mysql/logs/dotcms.log
# https://storage.googleapis.com/cicd-246518-tests/branch-name/unit/reports/html/index.html
# https://storage.googleapis.com/cicd-246518-tests/branch-name/unit/logs/dotcms.log
if [[ -n "${PULL_REQUEST}" && "${PULL_REQUEST}" != "false" ]]; then
  statusesLabel="Unknown"
  if [[ "${DOT_CICD_CLOUD_PROVIDER}" == "travis" ]]; then
    statusesLabel="Travis CI"
  elif [[ "${DOT_CICD_CLOUD_PROVIDER}" == "github" ]]; then
    statusesLabel="Github Actions"
  fi

  if [[ "${TEST_TYPE}" == "unit" ]]; then
    statusesContext="${statusesLabel} - [Unit tests results]"
  elif [[ "${TEST_TYPE}" == "curl" ]]; then
    statusesContext="${statusesLabel} - [Curl tests results] - [${databaseType}]"
  elif [[ "${TEST_TYPE}" == "integration" ]]; then
    statusesContext="${statusesLabel} - [Integration tests results] - [${databaseType}]"
  fi

#  logURL="${BASE_STORAGE_URL}/${STORAGE_JOB_BRANCH_FOLDER}/logs/dotcms.log"

#  echo ""
#  echo "=================================================================================="
#  echo "=================================================================================="
#  echo "  >>>   Storage folder for job: [${STORAGE_JOB_BRANCH_FOLDER}]"
#  echo "  >>>   Reports URL for job: [${reportsIndexURL}]"
#  echo "  >>>   Log URL for job: [${logURL}]"
#  echo "  >>>   GITHUB pull request: [https://github.com/dotCMS/core/pull/${PULL_REQUEST}]"
#  echo "  >>>   Job build status: ${CURRENT_JOB_BUILD_STATUS}"
#  echo "  >>>   GITHUB user: ${GITHUB_USER}/${GITHUB_USER_TOKEN}"
#  echo "=================================================================================="
#  echo "=================================================================================="
#  echo ""

  jsonBaseValue="https://api.github.com/repos/dotCMS/core/statuses/"
  jsonAttribute="\"href\": \"${jsonBaseValue}"

  # https://developer.github.com/v3/auth/#via-oauth-tokens

  # Reading the pull request information in order to get the statuses URL (has a github PR identifier)

  # https://developer.github.com/v3/pulls/#get-a-single-pull-request
  jsonResponse=$(curl -u ${GITHUB_USER}:${GITHUB_USER_TOKEN} \
  --request GET https://api.github.com/repos/dotCMS/core/pulls/${PULL_REQUEST} -s)

  # Parse the response json to get the statuses URL
  jsonStatusesAttribute=`echo "$jsonResponse" | grep "${jsonAttribute}\w*\""`
  statusesURL=`echo "$jsonStatusesAttribute" | grep -o "${jsonBaseValue}\w*"`

  # https://developer.github.com/v3/repos/statuses/#create-a-status
  # The state of the status. Can be one of error, failure, pending, or success.
  curl -u ${GITHUB_USER}:${GITHUB_USER_TOKEN} \
  --request POST \
  --data "{
    \"state\": \"${GITHUB_STATUS}\",
    \"description\": \"${GITHUB_DESCRIPTION}\",
    \"target_url\": \"${reportsIndexURL}\",
    \"context\": \"${statusesContext}\"
  }" \
  $statusesURL -s
fi