#!/bin/bash

IS_RELEASE=$2
docker_username=$3
docker_password=$4

docker_image_name='dotcms'
docker_tag="${BUILD_ID}"
if [[ "${IS_RELEASE}" == 'true' ]]; then
  docker_tag="${BUILD_ID#*-}"
  docker_tag="${docker_tag//v}"
fi

cd ..
gitConfig ${GITHUB_USER}
fetchDocker docker ${DOCKER_BRANCH}
cd docker
git fetch --all
[[ -n "${DOCKER_BRANCH}" && "${DOCKER_BRANCH}" != 'master' ]] && git checkout -b ${DOCKER_BRANCH} --track origin/${DOCKER_BRANCH}
cd images/dotcms

if [[ "${IS_RELEASE}" != 'true' ]]; then
  docker_image_name="${docker_image_name}-cicd-test"
fi
docker_image_full_name="dotcms/${docker_image_name}"

uname -sm
docker run --rm --privileged linuxkit/binfmt:v0.8
ls -1 /proc/sys/fs/binfmt_misc/qemu-*

docker --version
echo 'Creating multiarch Docker images'
echo 'Executing: docker buildx create --use --name multiarch'
docker buildx create --use --name multiarch
docker buildx inspect --bootstrap

echo "Executing: echo ${docker_password} | docker login --username ${docker_username} --password-stdin"
echo ${docker_password} | docker login --username ${docker_username} --password-stdin

docker_build_cmd="docker buildx build
  --platform linux/amd64,linux/arm64
  --pull
  --push
  --no-cache
  --build-arg BUILD_FROM=COMMIT
  --build-arg BUILD_ID=${BUILD_ID}"
if [[ "${IS_RELEASE}" == 'true' ]]; then
  docker_build_cmd="${docker_build_cmd}
    --build-arg IS_RELEASE=true
    -t ${docker_image_full_name}:latest"
fi
docker_build_cmd="${docker_build_cmd}
  -t ${docker_image_full_name}:${docker_tag}
  ."
time executeCmd "${docker_build_cmd}"

[[ ${cmdResult} != 0 ]] && exit 1

exit 0
