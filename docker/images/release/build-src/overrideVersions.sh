#!/bin/bash

########################
# Script: setVersions.sh
# Changes the values in the files that hold version information (like gradle.properties)
#
# $1: $local_build_id: branch or commit
# $2: $is_release: is release flag
# $3: $local_is_lts: is LTS release flag

local_build_id=${1}
is_release=${2}
local_is_lts=${3}

# Override tag to use release branch instead
if [[ "${is_release}" == 'true' && "${local_is_lts}" != 'true' ]]; then
  justNumbers=
  release_build_id="release-${local_build_id#"v"}"
  . /build/getSource.sh ${release_build_id} false
  is_release=true

  pushd ${CORE_GITHUB_REPO}
  pushd dotCMS
  echo "Setting versions"

  dui_version=$(currentNpmVersion dotcms-ui rc)
  dwc_version=$(currentNpmVersion dotcms-webcomponents rc)
  changeCoreWebVersions ${dui_version} ${dwc_version}

  echo "Saving new versions to ${dui_version} and ${dwc_version}"
  executeCmd "git add gradle.properties"
  executeCmd "git commit -m 'Updating core-web versions'"
  executeCmd "git push origin ${release_build_id}"
  popd

  # Recreate the git tag
  echo "Recreating tag ${local_build_id}"
  executeCmd "git tag -d ${local_build_id}"
  executeCmd "git push origin :refs/tags/${local_build_id}"
  executeCmd "git tag ${local_build_id}"
  executeCmd "git push origin ${local_build_id}"
  popd

  echo "Removing ${CORE_GITHUB_REPO}"
  executeCmd "rm -rf ${CORE_GITHUB_REPO}"
fi
