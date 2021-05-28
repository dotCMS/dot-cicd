#!/bin/bash

########################
# Script: runFullScan.sh
# Full Scan script

full_scan_report_file='index.html'

# Runs full scan
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

# Copy results to report folder and register results in map
copyResults ${full_scan_report_file} "${scan_label}"
