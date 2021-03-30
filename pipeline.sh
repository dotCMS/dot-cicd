#!/bin/bash

set -e

DEFAULT_CLOUD_PROVIDER="github"

function usage {
  echo "Usage: ${0} <target> <operation>
  Target: only one value is accepted: 'github', fallbacks to ${DEFAULT_CLOUD_PROVIDER}
  operation: identified operation to perform (e.g. 'buildBase')"
}

: ${DOT_CICD_PATH:="./dotcicd"} && export DOT_CICD_PATH
: ${DOT_CICD_LIB:="${DOT_CICD_PATH}/library"} && export DOT_CICD_LIB
: ${DOT_CICD_TARGET:="core"} && export DOT_CICD_TARGET
: ${DOT_CICD_CLOUD_PROVIDER:="${DEFAULT_CLOUD_PROVIDER}"} && export DOT_CICD_CLOUD_PROVIDER
export CICD_LOCAL_FOLDER="${DOT_CICD_LIB}/local/${DOT_CICD_TARGET}"

if [[ "${DOT_CICD_CLOUD_PROVIDER}" != "github" ]]; then
  echo "DOT_CICD_CLOUD_PROVIDER is not valid, falling back to ${DEFAULT_CLOUD_PROVIDER}"
  DOT_CICD_CLOUD_PROVIDER="${DEFAULT_CLOUD_PROVIDER}"
fi

if [[ "${DOT_CICD_CLOUD_PROVIDER}" == "github" ]]; then
  export DOT_CICD_PERSIST="github"
fi

export PROVIDER_PATH=${DOT_CICD_LIB}/pipeline/${DOT_CICD_CLOUD_PROVIDER}
export OPERATION_TARGET_PATH=${PROVIDER_PATH}/${DOT_CICD_TARGET}

: ${DOCKER_BRANCH:=""} && export DOCKER_BRANCH
: ${DEBUG:="false"} && export DEBUG

[[ -s ${DOT_CICD_LIB}/banner ]] && cat ${DOT_CICD_LIB}/banner

echo "#############
dot-cicd vars
#############
DOT_CICD_BRANCH: ${DOT_CICD_BRANCH}
DOT_CICD_PATH: ${DOT_CICD_PATH}
DOT_CICD_LIB: ${DOT_CICD_LIB}
DOT_CICD_TARGET: ${DOT_CICD_TARGET}
DOT_CICD_CLOUD_PROVIDER: ${DOT_CICD_CLOUD_PROVIDER}
DOT_CICD_PERSIST: ${DOT_CICD_PERSIST}
PROVIDER_PATH: ${PROVIDER_PATH}
OPERATION_TARGET_PATH: ${OPERATION_TARGET_PATH}
DOCKER_BRANCH: ${DOCKER_BRANCH}
DEBUG: ${DEBUG}
"

if [[ $# == 0 ]]; then
  usage
  exit 1
fi

operation=${1}
if [[ -z "${operation}" ]]; then
  echo "Operation argument was not specified, aborting..."
  usage 
  exit 1
fi

if [[ -z "${DOT_CICD_TARGET}" ]]; then
  echo "No target project (DOT_CICD_TARGET variable) has been defined, aborting..."
  exit 1
fi

. ${PROVIDER_PATH}/${DOT_CICD_CLOUD_PROVIDER}Common.sh

if [[ ${DEBUG} == true ]]; then
  echo "Current dir: ${PWD}"
  ls -las .
fi

pipelineScript=${OPERATION_TARGET_PATH}/${operation}.sh
set -- ${@:2}
echo "Executing ${pipelineScript} $@"

if [[ ! -s ${pipelineScript} ]]; then
  echo "Pipeline script associated to operation cannot be found, aborting..."
  exit 1
fi

. ${pipelineScript} $@
