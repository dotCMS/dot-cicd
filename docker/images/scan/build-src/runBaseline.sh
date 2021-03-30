#!/bin/bash

baseline_conf_file=baseline.conf
baseline_report_file='baseline-testreport.html'

mv ${baseline_conf_file} wrk/

[[ ${DEBUG} == true ]] && \
  echo "Executing: zap-baseline.py -t ${scan_url} -r ${baseline_report_file} -c ${baseline_conf_file} -P ${zap_port}"

zap-baseline.py -t ${scan_url} \
  -r ${baseline_report_file} \
  -c ${baseline_conf_file} \
  -P ${zap_port}

export baseline_scan_result=$?
if [[ ${baseline_scan_result} != 0 ]]; then
  echo "Error executing zap-baseline.py, error code: ${result}"
fi

scan_label='Baseline Scan Results'
ERROR_CODES="${ERROR_CODES}
${scan_label}: ${baseline_scan_result}"

copyResults ${baseline_report_file} "${scan_label}"
