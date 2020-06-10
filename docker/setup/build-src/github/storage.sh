#!/bin/bash

export outputFolder="/custom/output"

. /build/printBuildInfo.sh

echo ""
echo "  >>> Pushing reports and logs to [${GITHUB_PERSIST_COMMIT_URL}] <<<"
echo "  >>> Pushing reports and logs to [${GITHUB_PERSIST_BRANCH_URL}] <<<"
echo ""

# Now we want to add the logs link at the end of index.html results report file
logURL="${GITHUB_PERSIST_COMMIT_URL}/logs/dotcms.log"
logsLink="<h2 class=\"summaryGroup infoBox\" style=\"margin: 40px; padding: 15px;\"><a href=\"${logURL}\" target=\"_blank\">dotcms.log</a></h2>"

if [[ "${TEST_TYPE}" == "unit" ]]; then
  echo "
  ${logsLink}
  " >> ${outputFolder}/reports/html/index.html
# elif [[ "${TEST_TYPE}" == "curl" ]]; then
#   echo "
#   ${logsLink}
#   " >> ${outputFolder}/reports/html/index.html
else
  echo "
  ${logsLink}
  " >> ${outputFolder}/reports/html/integrationTest/index.html
fi

checkForToken

cd /build/src
persistResults

cd /build/src/core/dotCMS/src/curl-test

. /build/githubStatus.sh
ignoring_return_value=$?

. /build/printStatus.sh
ignoring_return_value=$?
