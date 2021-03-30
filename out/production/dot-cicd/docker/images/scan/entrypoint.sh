#!/bin/bash

. githubCommon.sh

function endScan {
  echo "####################################################
Vulnerability Scan Done for ${target_host}
####################################################
"
}

function createOutput {
  baseOutput=output/scan
  mkdir -p ${baseOutput}
  mkdir -p ${baseOutput}/${BUILD_HASH}
  mkdir -p ${baseOutput}/current
}

function prepareResults {
  local resultsFile=${1}
  cp ${resultsFile} output/${BUILD_HASH}
  cp ${resultsFile} output/current
}

export target_host='dotcms-app:8080'
export zap_port=8090
export scan_url="${target_host}/c"

: ${WAIT_DOTCMS_FOR:="3m"}
echo "Sleeping ${WAIT_DOTCMS_FOR} for DotCMS"
sleep ${WAIT_DOTCMS_FOR}

echo "####################################################
Starting Vulnerability Scan for ${target_host}
####################################################
"
createOutput

# Run xvfb headless
#. runZapX.sh

# Run baseline
#. runBaseline.sh

# Run full scan
#. runFullScan.sh

# Run API scan
. runApiScan.sh

export TEST_TYPE=scan
persistResults

endScan