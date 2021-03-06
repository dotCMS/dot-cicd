#!/bin/bash

########################
# Script: runBaseline.sh
# Baseline Scan script

baseline_conf_file=baseline.conf
baseline_report_file='index.html'

mv ${baseline_conf_file} wrk/

# Runs baseline scan using configuration file stored in baseline_conf_file
echo '
#########################
Running ZAP Baseline Scan
#########################'
[[ "${DEBUG}" == 'true' ]] \
  && echo "Executing: ./zap-baseline.py
    -t ${scan_url}
    -r ${baseline_report_file}
    -c ${baseline_conf_file}
    -P ${zap_port}"
./zap-baseline.py \
  -t ${scan_url} \
  -r ${baseline_report_file} \
  -c ${baseline_conf_file} \
  -P ${zap_port}
export baseline_scan_result=$?
[[ "${DEBUG}" == 'true' && ${baseline_scan_result} != 0 ]] \
  && echo "Error executing zap-baseline.py, error code: ${result}"

scan_label='Baseline Scan Results'
ERROR_CODES="${ERROR_CODES}
${scan_label}: ${baseline_scan_result}"

# Copy results to report folder and register results in map
copyResults ${baseline_report_file} "${scan_label}"
