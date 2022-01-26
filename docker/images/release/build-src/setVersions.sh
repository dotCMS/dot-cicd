#!/bin/bash

########################
# Script: setVersions.sh
# Changes the values in the files that hold version information (like gradle.properties)
#
# $1: build_id: branch or commit
# $2: is release: is release flag

github_sha=${1}
is_release=${2}

echo "Setting versions"
pushd dotCMS

dui_version=$(currentNpmVersion dotcms-ui rc)
dwc_version=$(currentNpmVersion dotcms-webcomponents rc)
changeCoreWebVersions ${dui_version} ${dwc_version}

popd