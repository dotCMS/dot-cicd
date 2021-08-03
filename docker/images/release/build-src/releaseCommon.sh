#!/bin/bash

##########################
# Script: releaseCommon.sh
# Collection of functions related to release process

# Runs a release script not without first announce it
#
# $1: script: script file to run
function runScript {
  local script=$1

  echo
  echo '############################################################################################################################################'
  echo "Executing . /build/${script}.sh $2 $3 $4 $5 $6 $7 $8"
  echo '############################################################################################################################################'
  . /build/${script}.sh $2 $3 $4 $5 $6 $7 $8

  if [[ $? != 0 ]]; then
    echo "Error executing: . /build/${script}.sh $2 $3 $4 $5 $6 $7 $8"
    exit 1
  fi
}
