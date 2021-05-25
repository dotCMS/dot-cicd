#!/bin/bash

. githubCommon.sh
. testResults.sh

export OUTPUT_FOLDER=/srv/output
mkdir -p ${OUTPUT_FOLDER}

export VIDEO_OUTPUT=${OUTPUT_FOLDER}/videos
mkdir -p ${VIDEO_OUTPUT}
export SCREENSHOT_OUTPUT=${OUTPUT_FOLDER}/screenshots
mkdir -p ${SCREENSHOT_OUTPUT}
export REPORT_OUTPUT=${OUTPUT_FOLDER}/reports
mkdir -p ${REPORT_OUTPUT}

# COPIAR DIRECTORIO COMPLETO
function _copyResults {
  local results_file=${1}
  cp wrk/${results_file} ${report_folder}
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
