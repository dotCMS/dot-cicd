#!/bin/bash

full_scan_report_file='full-scan-testreport.html'
full_scan_report_file='index.html'

echo '
#####################
Running ZAP Full Scan
#####################'
[[ "${DEBUG}" == 'true' ]] \
  && echo "Executing: ./zap-full-scan.py
    -t ${scan_url}
    -r ${full_scan_report_file}"

./zap-full-scan.py \
  -t ${scan_url} \
  -r ${full_scan_report_file}

export full_scan_result=$?
[[ "${DEBUG}" == 'true' && ${full_scan_result} != 0 ]] \
  && echo "Error executing zap-full-scan.py, error code: ${result}"

scan_label='Full Scan Results'
ERROR_CODES="${ERROR_CODES}
${scan_label}: ${full_scan_result}"

copyResults ${full_scan_report_file} "${scan_label}"
