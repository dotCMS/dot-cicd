#!/bin/bash

function prepareStage {
  local operation=$1
  if [[ -d ${DOT_CICD_STAGE} ]]; then
    rm -rf ${DOT_CICD_STAGE}
  fi
  mkdir -p ${DOT_CICD_STAGE}/${operation}
}
