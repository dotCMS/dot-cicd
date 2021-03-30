#!/bin/bash

function usage {
  echo "Usage: <operation>
Required arguments:
- operation: operation to run (e.g. 'runCurl', 'runIntegration' OR 'runUnit')
"
}

: ${DOT_CICD_TARGET:="core"} && export DOT_CICD_TARGET
export CICD_LOCAL_FOLDER="${DOT_CICD_LIB}/local/${DOT_CICD_TARGET}"

export operation=$0

if [[ -z "${operation}" ]]; then
  echo 'Operation argument was not provided, aborting...'
  usage
  exit 1
fi

localScript=${CICD_LOCAL_FOLDER}/${operation}.sh
if [[ ! -s ${localScript} ]]; then
  echo 'Local script associated to operation cannot be found, aborting...'
  exit 1
fi

export DOT_CICD_STAGE_OPERATION=${DOT_CICD_STAGE_FOLDER}/${operation}
mkdir -p ${DOT_CICD_STAGE_OPERATION}

: ${DOT_CICD_DOCKER_PATH:="${DOT_CICD_PATH}/docker"} && export DOT_CICD_DOCKER_PATH
: ${DOCKER_SOURCE:="${DOT_CICD_LIB}/docker"} && export DOCKER_SOURCE

: ${DEBUG_MODE:="false"} && export DEBUG_MODE

. ${DOT_CICD_LIB}/pipeline/github/githubCommon.sh

echo "
###################
Local dot-cicd vars
###################
DOT_CICD_TARGET: ${DOT_CICD_TARGET}
DOT_CICD_STAGE_FOLDER: ${DOT_CICD_STAGE_FOLDER}
DOT_CICD_STAGE_OPERATION: ${DOT_CICD_STAGE_OPERATION}
DOT_CICD_DOCKER_PATH: ${DOT_CICD_DOCKER_PATH}
DOCKER_SOURCE: ${DOCKER_SOURCE}
DEBUG_MODE: ${DEBUG_MODE}
"

echo "############
Java version
############"
java -version
echo

echo "#################
Script Arguments
#################
operation: ${operation}
Working folder: ${DOT_CICD_STAGE_OPERATION}
"

echo "Executing: ${localScript}"
. ${localScript}
