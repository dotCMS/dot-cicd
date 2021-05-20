#!/bin/bash

###########################
# Script: printBuildInfo.sh
# Prints build information environment variables: BUILD_HASH, BUILD_ID and $OUTPUT_FOLDER

if [[ -z "${BUILD_HASH}" ]]; then
  echo ""
  echo "======================================================================================"
  echo " >>>                'BUILD_HASH' environment variable NOT FOUND                    <<<"
  echo "======================================================================================"
  exit 0
fi

if [[ -z "${BUILD_ID}" ]]; then
  echo ""
  echo "======================================================================================"
  echo " >>>                'BUILD_ID' environment variable NOT FOUND                    <<<"
  echo "======================================================================================"
  exit 0
fi

# Validating if we have something to copy
if [[ -z "$(ls -A $OUTPUT_FOLDER)" ]]; then
  echo ""
  echo "================================================================"
  echo "           >>> EMPTY [${OUTPUT_FOLDER}] FOUND <<<"
  echo "================================================================"
  exit 0
fi
