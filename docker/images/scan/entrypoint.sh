#!/bin/bash

. githubCommon.sh

export OUTPUT_FOLDER=/zap/wrk/output/scan
export target_host='http://dotcms-app:8080'
export zap_port=8090
export scan_url="${target_host}/c"
export TEST_TYPE=scan
report_folder=${OUTPUT_FOLDER}/reports/html
scan_results_file=index.html
declare -A scan_results
export ERROR_CODES=''

function createOutput {
  mkdir -p ${report_folder}
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

function mergeResults {
  local results_file=wrk/${scan_results_file}

  cat scanResultsHeader.html > ${results_file}

  for r in "${!scan_results[@]}"
  do
    echo "<tr><td><a href=\"./${r}\">${scan_results[${r}]}</a></td></tr>
" >> ${results_file}
  done
  cat scanResultsFooter.html >> ${results_file}

  _copyResults ${scan_results_file}
}

function reportResults {
  commit_folder=${GITHUB_TEST_RESULTS_BROWSE_URL}/${BUILD_HASH}/scan
  branch_folder=${GITHUB_TEST_RESULTS_BROWSE_URL}/current/scan
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

: ${WAIT_DOTCMS_FOR:="3m"}
echo "Sleeping ${WAIT_DOTCMS_FOR} for DotCMS"
sleep ${WAIT_DOTCMS_FOR}

echo "
####################################################
Starting Vulnerability Scan for ${target_host}
####################################################
OUTPUT_FOLDER: ${OUTPUT_FOLDER}
scan_results_file: ${scan_results_file}
report_folder: ${report_folder}
"

createOutput

# Run xvfb headless
#. runZapX.sh

# Run baseline
. runBaseline.sh

# Run full scan
#. runFullScan.sh

# Run API scan
. runApiScan.sh

echo "
####################################################
Vulnerability Scan Done for ${target_host}
####################################################
Error codes:${ERROR_CODES}
"

mergeResults
persistResults
reportResults

#if [[ ${baseline_scan_result} != 0 || ${full_scan_result} != 0 || ${api_scan_result} != 0 ]]; then
#  exit 1
#fi
