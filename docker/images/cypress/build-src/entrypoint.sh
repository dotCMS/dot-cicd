#!/bin/bash

. githubCommon.sh
. testResults.sh

output_folder=/srv/output
mkdir -p ${output_folder}
video_output=${output_folder}/videos
screenshot_output=${output_folder}/screenshots
report_output=${output_folder}/reports
export DOT_CICD_TARGET=${CORE_WEB_GITHUB_REPO}
export BASE_STORAGE_URL="${GITHACK_TEST_RESULTS_CORE_WEB_URL}/$(urlEncode ${BUILD_ID})/projects/${DOT_CICD_TARGET}"

# Print result links
function showResultsLinks {
  commit_folder=${BASE_STORAGE_URL}/${BUILD_HASH}/scan/${selected_scan}
  branch_folder=${BASE_STORAGE_URL}/current/scan/${selected_scan}
  reports_commit_url="${commit_folder}/reports/html/index.html"
  reports_branch_url="${branch_folder}/reports/html/index.html"
  echo "
==========================================================
Scan reports location:
Commit location: ${reports_commit_url}
Branch location: ${reports_branch_url}
==========================================================
"
}

# clonar repositorio de core-web
gitClone $(resolveRepoUrl ${CORE_WEB_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER}) ${CORE_WEB_BUILD_ID}
# el repo queda en core-web

# esperar por dotcms
if [[ "${BUNDLED_MODE}" == 'false' ]]; then
  : ${WAIT_DOTCMS_FOR:="80"}
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        Requested sleep of [${WAIT_DOTCMS_FOR}], waiting for DotCMS?
        +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        "
  sleep ${WAIT_DOTCMS_FOR}
fi

# upload bundle
# curl .. http://dotcms-app:8080/xxx
cd ${CORE_WEB_GITHUB_REPO}
curl --location --request POST 'http://dotcms-app:8080/api/bundle?sync=true' \
--header 'Authorization: Basic YWRtaW5AZG90Y21zLmNvbTphZG1pbg==' \
--form 'file=@"./apps/dotcms-ui-e2e/src/fixtures/Cypress-DB-Seed.tar.gz"'

# correr cypress contra http://dotcms-app:8080/xxx
echo '################################## 1 ##################################'
npm i
pwd
ls -la
npm run build:prod
npm install -g nx
BASEURL=http://dotcms-app:8080 npm run e2e:open
# nx e2e dotcms-ui-e2e --base-url http://dotcms-app:8080
# cypress ....

# publicar los tests
cp -R /srv/core-web/dist/cypress/apps/dotcms-ui-e2e/* ${output_folder}
if [[ $? == 0 ]]; then
  persistResults ${TEST_RESULTS_CORE_WEB_GITHUB_REPO}
  showResultsLinks
fi

