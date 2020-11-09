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

urlEncode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * ) printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"
  ENCODED_URL="${encoded}"
}
