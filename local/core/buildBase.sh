#!/bin/bash

echo "Buidling sidecar image:
  docker build -t ${SIDECAR_IMAGE_BASE_NAME}
  --build-arg BUILD_FROM=COMMIT
  --build-arg BUILD_ID=${BUILD_ID}
  ${DOT_CICD_STAGE_OPERATION}/"
echo

docker build -t ${SIDECAR_IMAGE_BASE_NAME} \
  --build-arg BUILD_FROM=COMMIT \
  --build-arg BUILD_ID=${BUILD_ID} \
  ${DOT_CICD_STAGE_OPERATION}/

dcResult=$?
if [[ ${dcResult} != 0 ]]; then
  exit 1
fi
