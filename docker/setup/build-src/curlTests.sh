#!/bin/bash

######################
# Script: curlTests.sh
# Runs curl tests (postman tests) found in /build/src/core/dotCMS/build/reports/tests/curlTest

function resolveLabel {
  local result=$1
  if [[ $result == 0 ]]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

. /build/printStatus.sh
. /build/testResults.sh

echo ""
echo "================================================================================"
echo "================================================================================"
echo "  >>>   DB: ${databaseType}"
echo "  >>>   TEST PARAMETERS: ${EXTRA_PARAMS}"
echo "  >>>   BUILD FROM: ${BUILD_FROM}"
echo "  >>>   BUILD ID: ${BUILD_ID}"
echo "  >>>   GIT HASH: ${BUILD_HASH}"
echo "  >>>   STORAGE_JOB_COMMIT_FOLDER: ${STORAGE_JOB_COMMIT_FOLDER}"
echo "  >>>   STORAGE_JOB_BRANCH_FOLDER: ${STORAGE_JOB_BRANCH_FOLDER}"
echo "  >>>   CURL_TEST: ${CURL_TEST}"
echo "================================================================================"
echo "================================================================================"
echo ""

echo ""
echo "========================================================================================================"
echo "Executing... [newman run <collection> -reporters cli,htmlextra --reporter-htmlextra-export] <report file>"
echo "========================================================================================================"
echo ""


# Prepare to run newman for every found postman collection
postmanEnvFile="postman_environment.json"
reportFolder="/build/src/core/dotCMS/build/reports/tests/curlTest"
mkdir -p $reportFolder

srcFolder=/build/src/core/dotCMS/src
mkdir -p ${srcFolder}
mv /srv/curl-test ${srcFolder}
cd ${srcFolder}/curl-test

sed -i 's/localhost:8080/dotcms-app:8080/g' ./${postmanEnvFile}
# Create a map to store collection -> newman result
declare -A curlResults
> /build/resultLinks.html

IFS=$'\n'
for f in $(ls *.json);
do
  if [[ "$f" == "$postmanEnvFile" ]]; then
    continue
  fi

  if [[ -n "${CURL_TEST}" && "${CURL_TEST}" != "${f}" ]]; then
    echo "File ${f} is not ${CURL_TEST}, ignoring it"
    continue
  fi

  echo "Running newman for collection: \"${f}\""
  collectionId=$(echo "${f}"| tr ' ' '_' | cut -f 1 -d '.')
  page="${collectionId}.html"
  resultFile="${reportFolder}/${page}"

  # actual running of postman tests for current collection
  newman run "$f" -e ${postmanEnvFile} --reporters cli,htmlextra --reporter-htmlextra-export $resultFile

  # handle collection results
  curlResults[$collectionId]=$?
  resultLabel=$(resolveLabel ${curlResults[$collectionId]})
  echo "<tr><td><a href=\"./$page\">$f</a></td>
    <td>${resultLabel}</td></tr>" >> /build/resultLinks.html
  echo
done

cat /build/newmanTestResultsHeader.html /build/resultLinks.html /build/newmanTestResultsFooter.html \
  > "${reportFolder}/index.html" &&
  rm /build/resultLinks.html

curlReturnCode=0
for r in "${!curlResults[@]}"
do
  if [[ ${curlResults[$r]} != 0 ]]; then
    curlReturnCode=1
    break
  fi
done

export CURRENT_JOB_BUILD_STATUS=${curlReturnCode}

echo ""
if [[ ${CURRENT_JOB_BUILD_STATUS} == 0 ]]; then
  echo "  >>> Curl tests executed successfully <<<"
else
  echo "  >>> Curl tests failed <<<" >&2
fi

echo ""
echo "  >>> Copying gradle reports to [/custom/output/reports/]"
echo ""

# Copying gradle report
cp -R ${reportFolder}/* /custom/output/reports/html/

# Do we want to export the resulting reports to google storage?
if [[ "${EXPORT_REPORTS}" == "true" ]]; then
  # Track job results
  trackCoreTests ${CURRENT_JOB_BUILD_STATUS} /custom/output
  
  . /build/storage.sh
  ignoring_return_value=$?
fi

if [[ ${CURRENT_JOB_BUILD_STATUS} == 0 ]]; then
  exit 0
else
  exit 1
fi
