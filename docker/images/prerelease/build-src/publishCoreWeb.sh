#!/bin/bash

###########################
# Script: publishCoreWeb.sh
# Modify package.json on release and master branches, push and run npm run publish:dev and edit
# gradle.properties to set the release (RC) & Master versions
# $1: ${type}: Type of operation (rc or next)

type=${1}
[[ "${type}" != 'rc' && "${type}" != 'next' ]] && echo "Invalid type ('${type}') provided" && exit 1

pushd ${CORE_GITHUB_REPO}

if [[ "${type}" == 'next' ]]; then
  # Bump version of master in package.json
  printf "\e[32m Bumping version of master branch \e[0m  \n"
  executeCmd "git checkout master && git pull origin master"
  core_web_version="$(bumpUpVersion $(getValidNpmVersion ${RELEASE_VERSION}))"
else
  core_web_version="$(getValidNpmVersion ${RELEASE_VERSION})"
fi

executeCmd "git branch"

nextNpmRepoVersionCounter dotcms-ui ${type} ${core_web_version}
ui_npm_artifact_suffix=$?
nextNpmRepoVersionCounter dotcms-webcomponents ${type} ${core_web_version}
wc_npm_artifact_suffix=$?

pushd ${CORE_WEB_GITHUB_REPO}

# Set RELEASE_VERSION in package.json and push it
echo 'Updating package.json....'
sed -i -E "s/\"version\": \".*\"/\"version\": \"${core_web_version}-${type}.${ui_npm_artifact_suffix}\"/g" package.json
cat package.json | grep "version\":"

pushd libs/dotcms-webcomponents
sed -i -E "s/\"version\": \".*\"/\"version\": \"${core_web_version}-${type}.${wc_npm_artifact_suffix}\"/g" package.json
cat package.json | grep "version\":"
popd

printf "\e[32m Committing changes to ${branch} branch \e[0m  \n"
executeCmd "git status && git add package.json libs/dotcms-webcomponents/package.json"

if [[ "${type}" == 'next' ]]; then
  executeCmd "git commit -m 'Update master bumped version for dotcms-ui and dotcms-webcomponents'"
  publishMessg='Publishing Master core-web version'
else
  executeCmd "git commit -m 'Update release version for dotcms-ui and dotcms-webcomponents'"
  publishMessg='Publishing core-web version'
fi

echo "package.json files updated at ${branch} branch"

# Publish CORE-WEB & DotCMS-WebComponents & CORE-WEB Release version
printf "\e[32m ${publishMessg} \e[0m  \n"

[[ "${type}" == 'next' ]] && executeCmd "rm -rf node_modules"

executeCmd 'npm ci'
[[ ${cmdResult} != 0 ]] && echo "Error building ${branch} core-web version" && exit 1

#if [[ "${type}" == 'rc' ]]; then
#  executeCmd 'npm i -g @angular/cli'
#  [[ ${cmdResult} != 0 ]] && echo "Error building ${branch} core-web version" && exit 1
#fi

executeCmd 'rm -rf dist'
executeCmd 'npm run build:prod'
[[ ${cmdResult} != 0 ]] && echo "Error building ${branch} core-web version" && exit 1
dist_folder=./dist/apps
executeCmd "cp package.json ${dist_folder}/dotcms-ui/package.json"
dist_coreweb_folder=${dist_folder}/core-web
executeCmd "mkdir -p ${dist_coreweb_folder} && cp prepare.js ${dist_coreweb_folder}"

printf "\e[32m Publishing Release DotCMS-UI version.... \e[0m  \n"
pushd dist/apps/dotcms-ui
npmPublish ${type}
popd

printf "\e[32m Publishing Release DotCMS-WebComponents version.... \e[0m  \n"
pushd libs/dotcms-webcomponents
npmPublish ${type}
popd

popd

[[ "${type}" == 'next' ]] && executeCmd "git push origin master"

popd
