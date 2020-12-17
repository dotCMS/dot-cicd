#!/bin/bash

bucket='static.dotcms.com'
type=$1
test_run=$2
version="${DOTCMS_VERSION}"
aws_access_key_id="${AWS_ACCESS_KEY_ID}"
aws_secret_access_key="${AWS_SECRET_ACCESS_KEY}"

test_prefix='cicd-test'
distro_base_key='versions'
javadoc_base_key="docs/${version}/javadocs"
if [[ ${test_run} == true ]]; then
  distro_base_key="${test_prefix}/${distro_base_key}"
  javadoc_base_key="${test_prefix}/${javadoc_base_key}"
fi

function s3Push {
  local key=$1
  local object=$2
  local is_dir=false

  if [[ $3 == true ]]; then
    is_dir=true
  fi

  if [[ ${is_dir} == true ]]; then
    echo "Executing aws s3 cp ${object} s3://${bucket}/${key} --recursive"
    aws s3 cp ${object} s3://${bucket}/${key} --recursive
    echo "Executing: aws s3 ls ${bucket}/${key}/"
    aws s3 ls ${bucket}/${key}/
  else
    echo "Executing: aws s3api put-object --bucket ${bucket} --key ${key} --body ${object}"
    aws s3api put-object --bucket ${bucket} --key ${key} --body ${object}
    echo "Executing: aws s3 ls ${bucket}/${key}"
    aws s3 ls ${bucket}/${key}
  fi
}

function pushDistro {
  local ext=$1
  local distro_file="dotcms_${version}.${ext}"
  s3Push ${distro_base_key}/${distro_file} ./dist-output/${distro_file}
}

function pushJavadoc {
  s3Push ${javadoc_base_key} dotCMS/build/docs/javadoc true
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
