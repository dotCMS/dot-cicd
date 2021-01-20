#!/bin/bash

plugin_seeds_repo="plugin-seeds"
github="github.com"
github_plugin_seeds_path="dotCMS/${plugin_seeds_repo}"
github_plugin_seeds_host_path="${github}/${github_plugin_seeds_path}"
github_plugin_seeds_repo="https://${github_plugin_seeds_host_path}.git"
github_plugin_seeds_token_repo="https://${GITHUB_USER_TOKEN}@${github_plugin_seeds_host_path}.git"

test_run=$1
cicd_branch="master"
dotcms_current_version=$(curl https://api.github.com/repos/dotcms/core/releases/latest -s | jq .tag_name -r)
current_version="${dotcms_current_version//v}"
new_version=${DOTCMS_VERSION}
echo "Current version: ${current_version}"
echo "New version: ${new_version}"

if [[ -z "${current_version}" ]]; then
  echo "Current version not provided"
  exit 1
fi

if [[ -z "${new_version}" ]]; then
  echo "New version not provided"
  exit 1
fi

cd ..
git config --global user.email "${GITHUB_USER}@dotcms.com"
git config --global user.name "${GITHUB_USER}"
git clone ${github_plugin_seeds_repo}
cd plugin-seeds
if [[ ${test_run} == true ]]; then
  cicd_branch='cicd-test'
  git checkout -b ${cicd_branch}
fi

git fetch --all
cp ../core/dotcicd/library/pipeline/github/core/replaceVersions.py .
python ./replaceVersions.py ${current_version} ${new_version}
rm ./replaceVersions.py
git status
git add .
git commit -m "Updating dotcms version from ${current_version} to ${new_version}"
git status

if [[ ${test_run} == true ]]; then
  echo "Removing ${cicd_branch} branch"
  git checkout master
  git branch -D ${cicd_branch}
else
  git push ${github_plugin_seeds_token_repo}
  git status
fi
