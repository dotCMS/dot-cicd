#!/bin/bash

image=${1}

if [[ -z "${image}" ]]; then
  echo "Image was not provided, aborting..."
  exit 1
fi

echo ${GITHUB_TOKEN} | docker login https://docker.pkg.github.com -u ${GITHUB_USER} --password-stdin
docker images
docker image ls docker.pkg.github.com/dotcms/${DOT_CICD_TARGET}/${image}
echo "Executing: docker pull docker.pkg.github.com/dotcms/${DOT_CICD_TARGET}/${image}:${GITHUB_RUN_NUMBER}"
docker pull docker.pkg.github.com/dotcms/${DOT_CICD_TARGET}/${image}:${GITHUB_RUN_NUMBER}
docker images
