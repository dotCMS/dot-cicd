#!/bin/bash

. githubCommon.sh
. testResults.sh

export OUTPUT_FOLDER=/srv/core-web/dist/cypress/apps/cypress
export DOT_CICD_TARGET=${CORE_WEB_GITHUB_REPO}
export BASE_STORAGE_URL="${GITHACK_TEST_RESULTS_CORE_WEB_URL}/$(urlEncode ${BUILD_ID})/projects/${DOT_CICD_TARGET}"
cypress_output=/srv/core-web/dist/cypress/apps/dotcms-ui-e2e

# Print result links
function showResultsLinks {
  commit_folder=${BASE_STORAGE_URL}/${BUILD_HASH}/cypress
  branch_folder=${BASE_STORAGE_URL}/current/cypress
  reports_commit_url="${commit_folder}/reports/index.html"
  reports_branch_url="${branch_folder}/reports/index.html"
  echo "
==========================================================
Cypress reports location:
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
export BASEURL=http://dotcms-app:8080 && npm run e2e
# nx e2e dotcms-ui-e2e --base-url http://dotcms-app:8080
# cypress ....

# publicar los tests
if [[ $? == 0 ]]; then
  mv ${cypress_output} ${OUTPUT_FOLDER}
  persistResults ${TEST_RESULTS_CORE_WEB_GITHUB_REPO}
  showResultsLinks
fi

