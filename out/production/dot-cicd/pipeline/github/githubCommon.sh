#!/bin/bash

. ${DOT_CICD_LIB}/pipeline/common.sh

echo "###################"
echo "Github Actions vars"
echo "###################"
echo "GITHUB_RUN_NUMBER: ${GITHUB_RUN_NUMBER}"
echo "PULL_REQUEST: ${PULL_REQUEST}"
echo "GITHUB_REF: ${GITHUB_REF}"
echo "GITHUB_HEAD_REF: ${GITHUB_HEAD_REF}"
echo "CURRENT_BRANCH: ${CURRENT_BRANCH}"
echo "GITHUB_SHA: ${GITHUB_SHA::8}"
echo
