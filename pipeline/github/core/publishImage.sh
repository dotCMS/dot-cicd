#!/bin/bash

image=${1}

if [[ -z "${image}" ]]; then
  echo "Image was not provided, aborting..."
  exit 1
fi

docker images
echo ${GITHUB_TOKEN} | docker login https://docker.pkg.github.com -u ${GITHUB_USER} --password-stdin
docker push docker.pkg.github.com/dotcms/${DOT_CICD_TARGET}/${image}:${GITHUB_RUN_NUMBER}
docker images
docker image ls docker.pkg.github.com/dotcms/${DOT_CICD_TARGET}/${image}
docker image ls docker.pkg.github.com/dotcms/${DOT_CICD_TARGET}
