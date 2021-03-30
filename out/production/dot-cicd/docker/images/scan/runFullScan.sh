#!/bin/bash

full_scan_report_file='full-scan-testreport.html'

echo "Executing: zap-full-scan.py -t ${scan_url} -r ${full_scan_report_file}"
zap-full-scan.py -t ${scan_url} -r ${full_scan_report_file}

result=$?
if [[ ${result} != 0 ]]; then
  echo "Error executing zap-full-scan.py, error code: ${result}"
  endScan
  exit 1
fi
