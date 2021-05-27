#!/bin/bash

github_user=$1
github_user_token=$2
build_id=$3
is_release=$4
docker_username=$5
docker_password=$6
docker_repo="docker"
github="github.com"
github_docker_path="dotCMS/${docker_repo}"
github_docker_host_path="${github}/${github_docker_path}"
github_docker_remote_repo="https://${github_docker_host_path}"
github_docker_repo="${github_docker_remote_repo}.git"
github_docker_token_repo="https://${github_user_token}@${github_docker_host_path}.git"

docker_image_name='dotcms'
docker_tag="${build_id}"
if [[ ${is_release} == true ]]; then
  docker_tag="${build_id#*-}"
  docker_tag="${docker_tag//v}"
fi

cd ..
git config --global user.email "${github_user}@dotcms.com"
git config --global user.name "${github_user}"
git clone ${github_docker_repo}
cd docker
git fetch --all
[[ -n "${DOCKER_BRANCH}" && "${DOCKER_BRANCH}" != 'master' ]] && git checkout -b ${DOCKER_BRANCH} --track origin/${DOCKER_BRANCH}
cd images/dotcms

if [[ ${is_release} != true ]]; then
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
  --build-arg BUILD_ID=${build_id}"
if [[ ${is_release} == true ]]; then
  docker_build_cmd="${docker_build_cmd}
    --build-arg IS_RELEASE=true
    -t ${docker_image_full_name}:latest"
fi
docker_build_cmd="${docker_build_cmd}
  -t ${docker_image_full_name}:${docker_tag}
  ."
echo "Executing: ${docker_build_cmd}"
time $(echo ${docker_build_cmd})
