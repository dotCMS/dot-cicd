#!/bin/bash

if [[ $# == 0 ]]; then
  echo "Direct call to $0 has been deprecated, it's already taken care in run step"
  exit 0
fi

buildBase $@
