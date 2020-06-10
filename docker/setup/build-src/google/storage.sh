#!/bin/bash

# Examples
# https://storage.googleapis.com/cicd-246518-tests/0253ef83/integration/mysql/reports/html/index.html
# https://storage.googleapis.com/cicd-246518-tests/0253ef83/integration/mysql/logs/dotcms.log
# https://storage.googleapis.com/cicd-246518-tests/0253ef83/unit/reports/html/index.html
# https://storage.googleapis.com/cicd-246518-tests/0253ef83/unit/logs/dotcms.log
# https://storage.googleapis.com/cicd-246518-tests/branch-name/integration/mysql/reports/html/index.html
# https://storage.googleapis.com/cicd-246518-tests/branch-name/integration/mysql/logs/dotcms.log
# https://storage.googleapis.com/cicd-246518-tests/branch-name/unit/reports/html/index.html
# https://storage.googleapis.com/cicd-246518-tests/branch-name/unit/logs/dotcms.log

outputFolder="/custom/output"
credentialsFile="/build/credentials.json"
buckedProtocol="gs://"

# Do we have service account permissions
if [ -z "${GOOGLE_CREDENTIALS_BASE64}" ]
then
  echo ""
  echo "======================================================================================"
  echo " >>>      'GOOGLE_CREDENTIALS_BASE64' environment variable NOT FOUND               <<<"
  echo "======================================================================================"
  exit 0
fi

echo $GOOGLE_CREDENTIALS_BASE64 | base64 -d - > $credentialsFile
 
. /build/printBuildInfo.sh

echo ""
echo "  >>> Pushing reports and logs to [${buckedProtocol}${STORAGE_JOB_COMMIT_FOLDER}] <<<"
echo "  >>> Pushing reports and logs to [${buckedProtocol}${STORAGE_JOB_BRANCH_FOLDER}] <<<"
echo ""

# Now we want to add the logs link at the end of index.html results report file
logURL="https://storage.googleapis.com/${BASE_GOOGLE_URL}${STORAGE_JOB_COMMIT_FOLDER}/logs/dotcms.log"
logsLink="<h2 class=\"summaryGroup infoBox\" style=\"margin: 40px; padding: 15px;\"><a href=\"${logURL}\" target=\"_blank\">dotcms.log</a></h2>"

if [[ "${TEST_TYPE}" == "unit" ]]; then
  echo "
  ${logsLink}
  " >> ${outputFolder}/reports/html/index.html
# elif [[ "${TEST_TYPE}" == "curl" ]]; then
#   echo "
#   ${logsLink}
#   " >> ${outputFolder}/reports/html/index.html
elif [[ "${TEST_TYPE}" == "integration" ]]; then
  echo "
  ${logsLink}
  " >> ${outputFolder}/reports/html/index.html
fi

gcloud auth activate-service-account --key-file="${credentialsFile}"
gsutil -m -q cp -a public-read -r ${outputFolder} ${buckedProtocol}${STORAGE_JOB_COMMIT_FOLDER}

# When the bucket has the branch name we need to clean up the bucket first
gsutil -q rm ${buckedProtocol}${STORAGE_JOB_BRANCH_FOLDER}/**
gsutil -m -q cp -a public-read -r ${outputFolder} ${buckedProtocol}${STORAGE_JOB_BRANCH_FOLDER}

. /build/githubStatus.sh
ignoring_return_value=$?

. /build/printStatus.sh
ignoring_return_value=$?