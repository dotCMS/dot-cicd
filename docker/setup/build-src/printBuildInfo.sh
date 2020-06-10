#!/bin/bash

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
if [[ -z "$(ls -A $outputFolder)" ]]; then
  echo ""
  echo "================================================================"
  echo "           >>> EMPTY [${outputFolder}] FOUND <<<"
  echo "================================================================"
  exit 0
fi
