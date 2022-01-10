#!/bin/bash

build_id=${1}

pushd dotCMS

# resolve dot-ui rc tag
ui_rc_version=$(npm dist-tag ls dotcms-ui | grep "rc: ")
ui_rc_version=${ui_rc_version#"rc: "}
# resolve dot-webcomponents rc tag
webcomponents_rc_version=$(npm dist-tag ls dotcms-webcomponents | grep "rc: ")
webcomponents_rc_version=${webcomponents_rc_version#"rc: "}

# change versions
ui_version=$(grep "coreWebReleaseVersion=rc" gradle.properties)
wc_version=$(grep "webComponentsReleaseVersion=rc" gradle.properties)
[[ -n "${ui_version}" ]] \
  && sed -i -E "s/coreWebReleaseVersion=.*/coreWebReleaseVersion=${ui_rc_version}/g" gradle.properties
[[ -n "${wc_version}" ]] \
  && sed -i -E "s/webComponentsReleaseVersion=.*/webComponentsReleaseVersion=${webcomponents_rc_version}/g" gradle.properties

# show changes
if [[ -n "${ui_version}" || -n "${wc_version}" ]]; then
  grep coreWebReleaseVersion gradle.properties
  grep webComponentsReleaseVersion gradle.properties
  git status

  if [[ "${is_release}" == 'true' ]]; then
    git add gradle.properties
    git commit -m "Updating core-web's dotcms-ui and dotcms-webcomponents versions"
    git push origin ${build_id}
  fi
fi

popd
