#!/bin/bash

. githubCommon.sh
. testResults.sh

export OUTPUT_FOLDER=/zap/wrk/output/scan
export target_host='https://local.dotcms.site:8443'
export zap_port=8090
export scan_url="${target_host}/c"
export TEST_TYPE=scan
scan_results_file=index.html
declare -A scan_results
declare -A SCAN_STATUSES && export SCAN_STATUSES
export ERROR_CODES=''
sidecar_args=(${SIDECAR_ARGS})
selected_scan=${sidecar_args[0]}

function createOutput {
  mkdir -p ${report_folder}
}

function hostAlias {
  local dotcms_host=($(host dotcms-app))
  [[ "${DEBUG}" == 'true' ]] && echo "${dotcms_host[@]}"
  local dotcms_app_ip=${dotcms_host[3]}
  echo "Adding local.dotcms.site as '${dotcms_app_ip}' to /etc/hosts"
  echo "${dotcms_app_ip}   local.dotcms.site" >> /etc/hosts
  [[ "${DEBUG}" == 'true' ]] && cat /etc/hosts
}

function _copyResults {
  local results_file=${1}
  cp wrk/${results_file} ${report_folder}
}

function copyResults {
  local results_file=${1}
  local results_name=${2}
  _copyResults ${results_file}
  scan_results[${results_file}]="${results_name}"
}

function runScan {
  case ${selected_scan} in
    api)
      . runApiScan.sh
      ;;
    baseline)
      . runBaseline.sh
      ;;
    full)
      . runFullScan.sh
      ;;
    *)
      echo "Cannot determine scan from ${selected_scan}, ignoring it"
      ;;
  esac
}

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

if [[ "${BUNDLED_MODE}" == 'false' ]]; then
  : ${WAIT_DOTCMS_FOR:="3m"}
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Requested sleep of [${WAIT_DOTCMS_FOR}], waiting for DotCMS?
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
  sleep ${WAIT_DOTCMS_FOR}
fi

[[ -z "${selected_scan}" ]] && echo 'Scan not provided, aborting' && exit 1
report_folder=${OUTPUT_FOLDER}/${selected_scan}/reports/html

echo "
####################################################
Starting Vulnerability Scan for ${target_host}
####################################################
OUTPUT_FOLDER: ${OUTPUT_FOLDER}
scan_results_file: ${scan_results_file}
report_folder: ${report_folder}
selected_scan: ${selected_scan[@]}
"

hostAlias
su - zap
createOutput

showResultsLinks
runScan

echo "
####################################################
Vulnerability Scan Done for ${target_host}
####################################################
"

if [[ ${#scan_results[@]} -gt 0 ]]; then
  echo "Error codes:${ERROR_CODES}"
  persistResults
  showResultsLinks
else
  echo 'No results found'
fi
