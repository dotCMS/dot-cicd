#!/bin/bash

###############################
# Script: pushToStaticBucket.sh
# Pushes created distro and generated javadoc to S3 bucket
#
# $1: type: type of resource to push to S3 bucket
# $2: is_release: release flag

bucket='s3://static.dotcms.com'
type=$1
is_release=$2
version="${dotcms_version}"
keys_str="--access_key=${aws_access_key_id} --secret_key=${aws_secret_access_key}"
test_prefix='cicd-test'
distro_base_key='versions'
javadoc_base_key="docs/${version}"

# Modify paths when is not a release
if [[ "${is_release}" != 'true' ]]; then
  distro_base_key="${test_prefix}/${distro_base_key}"
  javadoc_base_key="${test_prefix}/${javadoc_base_key}"
fi

# Pushes to S3 an object identified by the key
#
# $1: key: key to identifies object in bucket
# $2: object: object to sore in bucket
function s3Push {
  local key=$1
  local object=$2

  # Use 's3cmd' tool to push whether is a file or an entire folder
  if [[ -d ${object} ]]; then
    echo "Executing: s3cmd put ${keys_str} --recursive --quiet ${object} ${bucket}/${key}"
    s3cmd put ${keys_str} --recursive --quiet ${object} ${bucket}/${key}
  else
    echo "Executing: s3cmd put ${keys_str} ${object} ${bucket}/${key}"
    s3cmd put ${keys_str} ${object} ${bucket}/${key}
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
  ls -las dotCMS/build/docs
  ls -las dotCMS/build/docs/javadocs
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
