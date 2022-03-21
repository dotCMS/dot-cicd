#!/bin/bash

###########################
# Script: publishCoreWeb.sh
# Modify package.json on release and master branches, push and run npm run publish:dev and edit
# gradle.properties to set the release (RC) & Master versions

npm_release_version=${RELEASE_VERSION}
core_web_release_version="$(getValidNpmVersion ${npm_release_version})"
nextNpmRepoVersionCounter dotcms-ui rc ${core_web_release_version}
ui_npm_artifact_suffix=$?
nextNpmRepoVersionCounter dotcms-webcomponents rc ${core_web_release_version}
wc_npm_artifact_suffix=$?
if [[ "${DRY_RUN}" == 'true' ]]; then
  ui_npm_artifact_suffix="-cicd${ui_npm_artifact_suffix}"
  wc_npm_artifact_suffix="-cicd${wc_npm_artifact_suffix}"
fi

printf "\e[32m Publishing core-web version \e[0m  \n"
pushd ${CORE_WEB_GITHUB_REPO}
gitConfig ${GITHUB_USER}
executeCmd "git branch"

# Set RELEASE_VERSION in package.json and push it
echo 'Updating package.json....'
sed -i -E "s/\"version\": \".*\"/\"version\": \"${core_web_release_version}-rc.${ui_npm_artifact_suffix}\"/g" package.json
cat package.json | grep "version\":"

pushd libs/dotcms-webcomponents
sed -i -E "s/\"version\": \".*\"/\"version\": \"${core_web_release_version}-rc.${wc_npm_artifact_suffix}\"/g" package.json
cat package.json | grep "version\":"
popd

printf "\e[32m Committing changes to branch ${branch} \e[0m  \n"
executeCmd "git status && git add package.json libs/dotcms-webcomponents/package.json"
executeCmd "git commit -m 'update release version for dotcms-ui & dotcms-webcomponents'"
executeCmd "git push origin ${branch}"
echo "package.json files updated and pushed in Release branch"

popd

# Publish CORE-WEB & DotCMS-WebComponents & CORE-WEB Release version
pushd ${CORE_WEB_GITHUB_REPO}
executeCmd "npm install
  && npm i -g @angular/cli
  && rm -rf dist
  && npm run build:prod
  && cp package.json ./dist/apps/dotcms-ui/package.json"
[[ ${cmdResult} != 0 ]] && echo "Error building ${branch} core-web version" && exit 1

printf "\e[32m Publishing Release DotCMS-UI version.... \e[0m  \n"
pushd dist/apps/dotcms-ui
npmPublish rc
popd

printf "\e[32m Publishing Release DotCMS-WebComponents version.... \e[0m  \n"
pushd libs/dotcms-webcomponents
npmPublish rc
popd

popd

# Bump version of master in package.json
printf "\e[32m Bumping version of ${master_branch} branch \e[0m  \n"
pushd ${CORE_WEB_GITHUB_REPO}

executeCmd "git checkout master && git pull origin master"

if [[ "${master_branch}" != 'master' ]]; then
  core_web_resolved_repo=$(resolveRepoUrl ${CORE_WEB_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
  gitRemoteLs ${core_web_resolved_repo} ${master_branch}
  web_core_remote_branch=$?
  [[ ${web_core_remote_branch} == 1 ]] && executeCmd "git push origin :${master_branch}"
  executeCmd "git checkout -b ${master_branch}"
fi

echo "Updating package.json...."
core_web_master_version="$(pumpUpVersion $(getValidNpmVersion ${npm_release_version}))"
sed -i -E "s/\"version\": \".*\"/\"version\": \"${core_web_master_version}-next.1\"/g" package.json
cat package.json | grep "version\":"

pushd libs/dotcms-webcomponents
sed -i -E "s/\"version\": \".*\"/\"version\": \"${core_web_master_version}-next.1\"/g" package.json
cat package.json | grep "version\":"
popd

executeCmd "git status && git add package.json libs/dotcms-webcomponents/package.json"
executeCmd "git commit -m 'update master bumped version for dotcms-ui & dotcms-webcomponents'"
executeCmd "git push origin ${master_branch}"
echo "package.json updated and pushed in Master branch"

popd

# Publish CORE-WEB & DotCMS-WebComponents Master version
printf "\e[32m Publishing Master CORE-WEB version.... \e[0m  \n"

pushd ${CORE_WEB_GITHUB_REPO}
executeCmd "rm -rf node_modules
  && npm install
  && rm -rf dist
  && npm run build:prod
  && cp package.json ./dist/apps/dotcms-ui/package.json"
[[ ${cmdResult} != 0 ]] && echo "Error building master's core-web" && exit 1

printf "\e[32m Publishing Master DotCMS-UI version..... \e[0m  \n"
pushd dist/apps/dotcms-ui
npmPublish next
popd

printf "\e[32m Publishing Master DotCMS-WebComponents version..... \e[0m  \n"
pushd libs/dotcms-webcomponents
npmPublish next
popd
popd
