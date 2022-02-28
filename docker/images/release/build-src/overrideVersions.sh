#!/bin/bash

########################
# Script: setVersions.sh
# Changes the values in the files that hold version information (like gradle.properties)
#
# $1: build_id: branch or commit
# $2: is_release: is release flag

build_id=${1}
is_release=${2}

# Override tag to use release branch instead
if [[ "${is_release}" == 'true' ]]; then
  release_build_id="release-${build_id#\"v\"}" \
  runScript getSource ${release_build_id} false

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
  echo "Recreating tag ${build _id}"
  executeCmd "git tag -d ${build_id}"
  executeCmd "git push origin :refs/tags/${build_id}"
  executeCmd "git tag ${build_id}"
  executeCmd "git push origin ${build_id}"
  popd

  echo "Removing ${CORE_GITHUB_REPO}"
  executeCmd "rm -rf ${CORE_GITHUB_REPO}"
fi
