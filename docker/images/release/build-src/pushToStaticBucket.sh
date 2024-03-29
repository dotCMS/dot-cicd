#!/bin/bash

###############################
# Script: pushToStaticBucket.sh
# Pushes created distro and generated javadoc to S3 bucket
#
# $1: type: type of resource to push to S3 bucket

type=$1
version="${RELEASE_VERSION}"
bucket='s3://static.dotcms.com'
keys_str="--access_key=${AWS_ACCESS_KEY_ID} --secret_key=${AWS_SECRET_ACCESS_KEY}"
distro_base_key='versions'
javadoc_base_key="docs/${version}"

# Pushes to S3 an object identified by the key
#
# $1: key: key to identifies object in bucket
# $2: object: object to sore in bucket
function s3Push {
  local key=$1
  local object=$2

  # Use 's3cmd' tool to push whether is a file or an entire folder
  if [[ -d ${object} ]]; then
    if [[ "${IS_RELEASE}" == 'true' ]]; then
      echo "Executing: s3cmd put ${keys_str} --recursive --quiet ${object} ${bucket}/${key}"
      s3cmd put ${keys_str} --recursive --quiet ${object} ${bucket}/${key}
    else
      echo "Dry running: s3cmd put ${keys_str} --recursive --quiet ${object} ${bucket}/${key}"
    fi
  else
    if [[ "${IS_RELEASE}" == 'true' ]]; then
      echo "Executing: s3cmd put ${keys_str} ${object} ${bucket}/${key}"
      s3cmd put ${keys_str} ${object} ${bucket}/${key}
    else
      echo "Dry running: s3cmd put ${keys_str} ${object} ${bucket}/${key}"
    fi
  fi

  # List contents in bucket for that particular key
  echo "Executing: s3cmd ls ${keys_str} ${bucket}/${key}"
  s3cmd ls ${keys_str} ${bucket}/${key}
}

# Uses s3Push function to push a distro file to S3 bucket
#
# $1: ext: file extension which can be 'zip' or 'tar'gz'
function pushDistro {
  local ext=$1
  local distro_file="dotcms_${version}.${ext}"
  s3Push ${distro_base_key}/${distro_file} ./dist-output/${distro_file}
}

# Uses s3Push function to push a javadoc file to S3 bucket
function pushJavadoc {
  mv dotCMS/build/docs/javadoc dotCMS/build/docs/javadocs
  s3Push ${javadoc_base_key}/ dotCMS/build/docs/javadocs
}

# Type of resources to push: distro, javadoc or both
case "${type}" in
  distro)
    pushDistro 'tar.gz'
    pushDistro 'zip'
    ;;
  javadoc)
    pushJavadoc
    ;;
  all)
    pushDistro 'tar.gz'
    pushDistro 'zip'
    pushJavadoc
    ;;
  *)
    echo "Invalid type, it should be 'distro', 'javadoc' or 'all'"
    exit 1
    ;;
esac
