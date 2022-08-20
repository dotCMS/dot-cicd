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
  # Bump version of whatever ${FROM_MASTER} holds in package.json
  printf "\e[32m Bumping version of master branch \e[0m  \n"
  export BRANCH=${FROM_BRANCH}
  executeCmd "git checkout ${BRANCH} && git pull origin ${BRANCH}"
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

printf "\e[32m Committing changes to ${BRANCH} branch \e[0m  \n"
executeCmd "git status"
executeCmd "git add package.json libs/dotcms-webcomponents/package.json"

if [[ "${type}" == 'next' ]]; then
  executeCmd "git commit -m 'Update master bumped version for dotcms-ui and dotcms-webcomponents'"
  publishMessg='Publishing Master core-web version'
else
  executeCmd "git commit -m 'Update release version for dotcms-ui and dotcms-webcomponents'"
  publishMessg='Publishing core-web version'
fi

echo "package.json files updated at ${BRANCH} branch"

# Publish CORE-WEB & DotCMS-WebComponents & CORE-WEB Release version
printf "\e[32m ${publishMessg} \e[0m  \n"

[[ "${type}" == 'next' ]] && executeCmd "rm -rf node_modules"

executeCmd 'npm ci'
[[ ${cmdResult} != 0 ]] && echo "Error building ${BRANCH} core-web version" && exit 1

executeCmd 'rm -rf dist'
executeCmd 'npm run build:prod'
[[ ${cmdResult} != 0 ]] && echo "Error building ${BRANCH} core-web version" && exit 1
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

if [[ "${FROM_BRANCH}" != 'master' ]]; then
  echo "::warning::NPM publish was run from a branch (${FROM_BRANCH}) other than master. This might incur in an unexpected versions at npm registry. Luckily you can reestablish the version by running 'npm dist-tag add <package>@<version> <tag>'"
fi

popd

if [[ "${type}" == 'next' ]]; then
  executeCmd "git status"
  executeCmd "git add ."
  executeCmd "git reset dotCMS/src/main/enterprise"
  executeCmd "git commit -m \"Adding next version\""
  executeCmd "git push origin ${BRANCH}"
fi

popd
