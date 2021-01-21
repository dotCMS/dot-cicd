#!/bin/bash
github_user_token=$1
plugin_seeds_repo="plugin-seeds"
github="github.com"
github_plugin_seeds_path="dotCMS/${plugin_seeds_repo}"
github_plugin_seeds_host_path="${github}/${github_plugin_seeds_path}"
github_plugin_seeds_repo="https://${github_plugin_seeds_host_path}.git"
github_plugin_seeds_token_repo="https://${github_user_token}@${github_plugin_seeds_host_path}.git"

cicd_branch="master"
dotcms_current_version=$(curl https://api.github.com/repos/dotcms/core/releases/latest -s | jq .tag_name -r)
new_version="${dotcms_current_version//v}"
echo "New version: ${new_version}"

if [[ -z "${new_version}" ]]; then
  echo "New version not provided"
  exit 1
fi

cd ..
git config --global user.email "${github_user_token}@dotcms.com"
git config --global user.name "${github_user_token}"
git clone ${github_plugin_seeds_repo}
cd plugin-seeds
git fetch --all

if [[ ${is_release} != true ]]; then
  cicd_branch='cicd-test'
  git checkout -b ${cicd_branch}
fi

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
##'OSGi/com.dotcms.servlet/build.gradle'
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
for file in "${files[@]}"
do
  echo "Replacing version for ${file}"
  sed -i "s,com.dotcms:dotcms:[0-9][0-9]\.[0-9][0-9],com.dotcms:dotcms:${new_version},g" ${file}
  ss="name: 'dotcms', version: '[0-9][0-9]\.[0-9][0-9]'"
  rs="name: 'dotcms', version: '${new_version}'"
  sed -i "s/${ss}/${rs}/g" ${file}
  cat ${file} | grep "${new_version}"
done

git status
git add .
git commit -m "Updating dotcms version to ${new_version}"
git status

if [[ ${is_release} != true ]]; then
  echo "Removing ${cicd_branch} branch"
  git checkout master
  git branch -D ${cicd_branch}
else
  git push ${github_plugin_seeds_token_repo}
  git status
fi

cd ../core
