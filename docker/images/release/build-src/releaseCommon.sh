#!/bin/bash

##########################
# Script: releaseCommon.sh
# Collection of functions related to release process

# Runs a release script not without first announce it
#
# $1: script: script file to run
function runScript {
  local script=$1

  set -- ${@:2}
  echo 
  echo '############################################################################################################################################'
  echo "Executing . /build/${script}.sh $@"
  echo '############################################################################################################################################'
  . /build/${script}.sh $@

  if [[ $? != 0 ]]; then
    echo "Error executing: . /build/${script}.sh $@"
    exit 1
  fi
}
