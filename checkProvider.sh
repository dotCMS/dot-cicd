#!/bin/bash

##########################
# Script: checkProvider.sh
# Deprecated

CLOUD_PROVIDERS=(travis github)
currentProvider=${1}

# TODO: Script Deprecation
echo "This script has been deprecated"
exit 0

if [[ -z "${currentProvider}" ]]; then
  echo "Current cloud provider was not specified, aborting..."
  exit 1
fi

echo "Supported providers: [${CLOUD_PROVIDERS[@]}]"
echo "Checking for ${currentProvider}"
found=false
for p in "${CLOUD_PROVIDERS[@]}"; do
  if [[ "${p}" == "${currentProvider}" ]]; then
    found=true
    break
  fi
done

if [[ "${found}" == 'false' ]]; then
  echo "Provider ${currentProvider} is not supported, aborting..."
  exit 1
fi

echo "Using ${currentProvider} as cloud provider"
