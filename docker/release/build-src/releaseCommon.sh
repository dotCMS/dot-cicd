#!/bin/bash

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
