#!/bin/bash

###############################
# Script: publishDockerImage.sh
# Builds and publishes, with 'docker buildx' commands, the multi-arch docker DotCMS images

is_release=$2
docker_username=$3
docker_password=$4

docker_image_name='dotcms'
docker_tag="${BUILD_ID}"
# Evaluates dry run
if [[ "${is_release}" == 'true' ]]; then
  docker_tag="${BUILD_ID#*-}"
  docker_tag="${docker_tag//v}"
fi

cd ..
# Configs git with default user
gitConfig ${GITHUB_USER}

core_docker_path=/build/src/core/docker
# Resolve which docker path to use (core or docker repo folder)
resolved_docker_path=$(dockerPathWithFallback ${core_docker_path} docker)
# Git clones docker repo with provided branch if
if [[ "${resolved_docker_path}" == 'docker' ]]; then
  fetchDocker docker ${DOCKER_BRANCH}
  pushd docker/images/dotcms
else
  pushd ${core_docker_path}
fi

if [[ "${is_release}" != 'true' ]]; then
  docker_image_name="${docker_image_name}-cicd-test"
fi
docker_image_full_name="dotcms/${docker_image_name}"

uname -sm
docker run --rm --privileged linuxkit/binfmt:v0.8
ls -1 /proc/sys/fs/binfmt_misc/qemu-*

# Prepare docker multi-arch build
docker --version
echo 'Creating multi-arch Docker images'
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
if [[ "${is_release}" == 'true' ]]; then
  docker_build_cmd="${docker_build_cmd}
    --build-arg is_release=true
    -t ${docker_image_full_name}:latest"
fi
docker_build_cmd="${docker_build_cmd}
  -t ${docker_image_full_name}:${docker_tag}
  ."
# Actual multi-arch build
time executeCmd "${docker_build_cmd}"

popd

[[ ${cmdResult} != 0 ]] && exit 1

exit 0
