#!/bin/bash

if [[ $# == 0 ]]; then
  echo "Direct call to $0 has been deprecated, it's already taken care in run step"
  exit 0
fi

#image_name=${1}
#docker_file_path=${2}
#docker_path=${3}
#skip_pull=${4}

#setupDocker ${docker_file_path} ${docker_path}
buildBase $@
