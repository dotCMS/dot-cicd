#!/bin/bash

function resolveTestPath {
  local path="${1}"
  if [[ -n "${TEST_TYPE}" ]]; then
    path="${path}/${TEST_TYPE}"
  fi
  if [[ -n "${databaseType}" ]]; then
    path="${path}/${databaseType}"
  fi
  echo "${path}"
}
