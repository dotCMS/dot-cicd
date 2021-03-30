#!/bin/bash

setupDockerIntegration integration

echo "Building DotCMS Test image:
build -t ${IMAGE_NAME}
  --build-arg BUILD_FROM=COMMIT
  --build-arg BUILD_ID=${CURRENT_BRANCH}
  --build-arg BUILD_HASH=${GITHUB_SHA::8}
  --build-arg LICENSE_KEY=${LICENSE_KEY}
  ${DOCKER_SOURCE}/tests/integration/
"

docker build -t ${IMAGE_NAME} \
  --build-arg BUILD_FROM=COMMIT \
  --build-arg BUILD_ID=${CURRENT_BRANCH} \
  --build-arg BUILD_HASH=${GITHUB_SHA::8} \
  --build-arg LICENSE_KEY=${LICENSE_KEY} \
  ${DOCKER_SOURCE}/tests/integration/
dcResult=$?

if [[ ${dcResult} != 0 ]]; then
  exit 1
fi
