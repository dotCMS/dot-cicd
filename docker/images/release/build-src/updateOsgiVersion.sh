#!/bin/bash

###############################
# Script: updateOsgiVersions.sh
# Updates with new version of DotCMS the dependencies in plugin-seeds repo
#
# $1: github_user: github user
# $2: github_user_token: github user token

github_user=${1}
github_user_token=${2}

cicd_branch="master"
# Gets the current DotCMS version
dotcms_current_version=$(curl https://api.github.com/repos/dotcms/core/releases/latest -s | jq .tag_name -r)
# Removes the 'v' prefix
new_version="${dotcms_current_version//v}"
echo "New version: ${new_version}"

release_branch_name="release-${new_version}"

if [[ -z "${new_version}" ]]; then
  echo "New version not provided"
  exit 1
fi

pushd ../
# Configure github user
gitConfig ${github_user}
plugin_seeds_github_repo_url=$(resolveRepoUrl ${PLUGIN_SEEDS_GITHUB_REPO} ${github_user_token} ${github_user})
# Clones plugin_seeds repo
gitClone ${plugin_seeds_github_repo_url}
pushd ${PLUGIN_SEEDS_GITHUB_REPO}

if [[ "${is_release}" != 'true' ]]; then
  cicd_branch='cicd-test'
  git checkout -b ${cicd_branch}
fi

# Hardcoded list of gradle files to replace its DotCMS version
files=('OSGi/com.dotcms.3rd.party/build.gradle'
'OSGi/com.dotcms.actionlet/build.gradle'
'OSGi/com.dotcms.aop/build.gradle'
'OSGi/com.dotcms.custom.spring/build.gradle'
'OSGi/com.dotcms.dynamic.skeleton/build.gradle'
'OSGi/com.dotcms.fixasset/build.gradle'
'OSGi/com.dotcms.hooks/build.gradle'
'OSGi/com.dotcms.hooks.validations/build.gradle'
'OSGi/com.dotcms.job/build.gradle'
'OSGi/com.dotcms.override/build.gradle'
'OSGi/com.dotcms.portlet/build.gradle'
'OSGi/com.dotcms.pushpublish.listener/build.gradle'
'OSGi/com.dotcms.rest/build.gradle'
'OSGi/com.dotcms.ruleengine.velocityscriptingactionlet/build.gradle'
'OSGi/com.dotcms.ruleengine.visitoripconditionlet/build.gradle'
'OSGi/com.dotcms.simpleService/build.gradle'
'OSGi/com.dotcms.spring/build.gradle'
'OSGi/com.dotcms.staticpublish.listener/build.gradle'
'OSGi/com.dotcms.tuckey/build.gradle'
'OSGi/com.dotcms.viewtool/build.gradle'
'OSGi/com.dotcms.webinterceptor/build.gradle'
'OSGi/com.dotcms.app.example/build.gradle'
'static/com.dotcms.hook/build.gradle'
'static/com.dotcms.macro/build.gradle'
'static/com.dotcms.portlet/build.gradle'
'static/com.dotcms.servlet/build.gradle'
'static/com.dotcms.skeleton/build.gradle'
'static/com.dotcms.viewtool/build.gradle')

# for every file replace dependencies to their new version
for file in "${files[@]}"
do
  echo "Replacing version for ${file}"
  sed -i "s,com.dotcms:dotcms:[0-9][0-9]\.[0-9][0-9]\.[0-9],com.dotcms:dotcms:${new_version},g" ${file}
  ss="name: 'dotcms', version: '[0-9][0-9]\.[0-9][0-9]\.[0-9]'"
  rs="name: 'dotcms', version: '${new_version}'"
  sed -i "s/${ss}/${rs}/g" ${file}
  cat ${file} | grep "${new_version}"
done

# Add changes and commit them
git status
git add .
git commit -m "Updating dotcms version to ${new_version}"
git status

# When is an actual release push the changes, otherwise don't do a thing
if [[ "${is_release}" == 'true' ]]; then
  git push ${plugin_seeds_github_repo_url}
  git status
else
  echo "Dry run detected, not pushing ${release_branch_name} to ${plugin_seeds_github_repo_url}"
fi

echo "Finish updating dotCMS version in OSGI plugins"

popd
popd
