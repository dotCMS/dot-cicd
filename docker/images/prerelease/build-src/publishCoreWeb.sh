#!/bin/bash

###########################
# Script: publishCoreWeb.sh
# Modify package.json on release and master branches, push and run npm run publish:dev and edit
# gradle.properties to set the release (RC) & Master versions

printf "\e[32m Publishing core-web version \e[0m  \n"
pushd ${CORE_WEB_GITHUB_REPO}
gitConfig ${GITHUB_USER}

# Set RELEASE_VERSION in package.json and push it
echo 'Updating package.json....'
core_web_release_version="$(getValidNpmVersion ${RELEASE_VERSION})-rc.0"
replaceTextInFile ./package.json '"version": ".*"' "\"version\": \"${core_web_release_version}\""

pushd libs/dotcms-webcomponents
replaceTextInFile ./package.json '"version": ".*"' "\"version\": \"${core_web_release_version}\""
popd

printf "\e[32m Committing changes to branch ${branch} \e[0m  \n"
executeCmd "git add package.json libs/dotcms-webcomponents/package.json
  && git commit -m 'update release version for dotcms-ui & dotcms-webcomponents'"
git status
executeCmd "git push origin ${branch}"
echo "package.json updated and pushed in Release branch"

popd

# Publish CORE-WEB & DotCMS-WebComponents & CORE-WEB Release version
printf "\e[32m Publishing core-web version \e[0m  \n"

pushd ${CORE_WEB_GITHUB_REPO}
executeCmd "npm install
  && npm i -g @angular/cli
  && rm -rf dist
  && npm run build:prod
  && cp package.json ./dist/apps/dotcms-ui/package.json"

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

executeCmd "git checkout master
  && git pull origin master"

[[ "${master_branch}" != 'master' ]] && git checkout -b ${master_branch}

echo "Updating package.json...."
core_web_master_version="$(pumpUpVersion $(getValidNpmVersion $RELEASE_VERSION))-next.0"
replaceTextInFile ./package.json '"version": ".*"' "\"version\": \"${core_web_release_version}\""

pushd libs/dotcms-webcomponents
replaceTextInFile ./package.json '"version": ".*"' "\"version\": \"${core_web_release_version}\""
popd

executeCmd "git add package.json libs/dotcms-webcomponents/package.json
  && git commit -m 'update master bumped version for dotcms-ui & dotcms-webcomponents'
  && git push origin ${master_branch}"
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

pushd dist/apps/dotcms-ui
npmPublish next
popd

printf "\e[32m Publishing Master DotCMS-WebComponents version..... \e[0m  \n"
pushd libs/dotcms-webcomponents
npmPublish next
popd
popd