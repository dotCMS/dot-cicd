#!/bin/bash

###############################
# Script: publishDockerImage.sh
# Builds and publishes, with 'docker buildx' commands, the multi-arch docker DotCMS images
#
# $1: docker_username: artifactory repo username
# $2: docker_password: artifactory repo password

docker_username=$1
docker_password=$2

docker_image_name='dotcms'
docker_tag="${BUILD_ID}"
# Evaluates dry run
if [[ "${IS_RELEASE}" == 'true' ]]; then
  docker_tag="${BUILD_ID#*-}"
  docker_tag="${docker_tag//v}"
fi

cd ..
# Configs git with default user
gitConfig ${GITHUB_USER}
# Git clones docker repo with provided branch
core_docker_path=/build/src/core/docker
# Resolve which docker path to use (core or docker repo folder)
resolved_docker_path=${core_docker_path}
# Git clones docker repo with provided branch if
if [[ "${resolved_docker_path}" == 'docker' ]]; then
  fetchDocker docker ${DOCKER_BRANCH}
  pushd docker/images/dotcms
else
  pushd ${core_docker_path}
fi

if [[ "${IS_RELEASE}" != 'true' ]]; then
  docker_image_name="${docker_image_name}-cicd-test"
fi
docker_image_full_name="dotcms/${docker_image_name}"

# Prepare docker multi-arch build
docker --version

# Docker login
echo "Executing: echo ${docker_password} | docker login --username ${docker_username} --password-stdin"
echo ${docker_password} | docker login --username ${docker_username} --password-stdin

uname -sm
docker run --rm --privileged linuxkit/binfmt:v0.8
ls -1 /proc/sys/fs/binfmt_misc/qemu-*

echo 'Creating multi-arch Docker images'
echo 'Executing: docker buildx create --use --name multiarch'
docker buildx create --use --name multiarch
docker buildx inspect --bootstrap

docker_build_cmd="docker buildx build
  --platform linux/amd64,linux/arm64
  --pull
  --push
  --no-cache
  --build-arg BUILD_FROM=COMMIT
  --build-arg BUILD_ID=${BUILD_ID}"
if [[ "${IS_RELEASE}" == 'true' ]]; then
  docker_build_cmd="${docker_build_cmd}
    --build-arg is_release=true
    -t ${docker_image_full_name}:latest"
fi
docker_build_cmd="${docker_build_cmd}
  -t ${docker_image_full_name}:${docker_tag}
  ."
# Actual multi-arch build
time executeCmd "${docker_build_cmd}"

[[ ${cmdResult} != 0 ]] && exit 1

exit 0
