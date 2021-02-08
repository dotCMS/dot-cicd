#!/bin/bash

function usage {
  echo "Usage: <operation>
    Required arguments:
    - operation: operation to run (e.g. 'runCurl', 'runIntegration' OR 'runUnit')"
}

export operation=$0

if [[ -z "${operation}" ]]; then
  echo "Operation argument was not provided, aborting..."
  usage
  exit 1
fi

export CICD_LOCAL_FOLDER="${DOT_CICD_LIB}/local/${DOT_CICD_TARGET}"
localScript=${CICD_LOCAL_FOLDER}/${operation}.sh
if [[ ! -s ${localScript} ]]; then
  echo "Local script associated to operation cannot be found, aborting..."
  exit 1
fi

export DOT_CICD_STAGE_OPERATION=${DOT_CICD_STAGE_FOLDER}/${operation}
mkdir -p ${DOT_CICD_STAGE_OPERATION}

echo "###################"
echo "Local dot-cicd vars"
echo "###################"
echo "DOT_CICD_TARGET: ${DOT_CICD_TARGET}"
echo "DOT_CICD_STAGE_FOLDER: ${DOT_CICD_STAGE_FOLDER}"
echo
echo "##########"
echo "Arguments"
echo "##########"
echo "operation: ${operation}"
echo
echo "Working folder: ${DOT_CICD_STAGE_OPERATION}"
echo

echo "Executing: ${localScript}"
. ${localScript}
