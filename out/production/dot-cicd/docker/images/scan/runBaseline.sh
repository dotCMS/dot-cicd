#!/bin/bash

baseline_conf_file=baseline.conf
baseline_report_file='baseline-testreport.html'

echo "Executing: zap-baseline.py -t ${scan_url} -r ${baseline_report_file} -c ${baseline_conf_file} -P ${zap_port}"
zap-baseline.py -t ${scan_url} -r ${baseline_report_file} -c ${baseline_conf_file} -P ${zap_port}

result=$?
if [[ ${result} != 0 ]]; then
  echo "Error executing zap-baseline.py, error code: ${result}"
  endScan
  exit ${result}
fi
