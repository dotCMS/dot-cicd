#!/bin/bash

bucket='s3://static.dotcms.com'
type=$1
version="${dotcms_version}"
keys_str="--access_key=${aws_access_key_id} --secret_key=${aws_secret_access_key}"

test_prefix='cicd-test'
distro_base_key='versions'
javadoc_base_key="docs/${version}/javadocs"
if [[ ${is_release} != true ]]; then
  distro_base_key="${test_prefix}/${distro_base_key}"
  javadoc_base_key="${test_prefix}/${javadoc_base_key}"
fi

function s3Push {
  local key=$1
  local object=$2
  local is_dir=false

  if [[ -d ${object} ]]; then
    echo "Executing: s3cmd put ${keys_str} --recursive --quiet ${object} ${bucket}/${key}"
    s3cmd put ${keys_str} --recursive --quiet ${object} ${bucket}/${key}
  else
    echo "Executing: s3cmd put ${keys_str} ${object} ${bucket}/${key}"
    s3cmd put ${keys_str} ${object} ${bucket}/${key}
  fi

  echo "Executing: s3cmd ls ${keys_str} ${bucket}/${key}"
  s3cmd ls ${keys_str} ${bucket}/${key}
}

function pushDistro {
  local ext=$1
  local distro_file="dotcms_${version}.${ext}"
  s3Push ${distro_base_key}/${distro_file} ./dist-output/${distro_file}
}

function pushJavadoc {
  mv dotCMS/build/docs/javadoc dotCMS/build/docs/javadocs
  s3Push ${javadoc_base_key}/ dotCMS/build/docs/javadocs
}

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
