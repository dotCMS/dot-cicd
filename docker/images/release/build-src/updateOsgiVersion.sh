#!/bin/bash

###############################
# Script: updateOsgiVersions.sh
# Updates with new version of DotCMS the dependencies in plugin-seeds repo

# Gets the current DotCMS version
dotcms_current_version=${RELEASE_VERSION}
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
plugin_seeds_github_repo_url=$(resolveRepoUrl ${PLUGIN_SEEDS_GITHUB_REPO} ${GITHUB_USER_TOKEN} ${GITHUB_USER})
# Clones plugin_seeds repo
gitClone ${plugin_seeds_github_repo_url} ${release_branch_name}
pushd ${PLUGIN_SEEDS_GITHUB_REPO}

if [[ "${is_release}" != 'true' ]]; then
  git checkout -b cicd-test
fi

# for every file replace dependencies to their new version
for file in $(find . -name build.gradle)
do
  echo "Replacing version for ${file}"
  executeCmd "python3 /build/updateOsgiVersion.py ${file} ${new_version}"
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
else
  echo "Dry run detected, not pushing ${release_branch_name} to ${plugin_seeds_github_repo_url}"
fi

echo "Finish updating dotCMS version in OSGI plugins"

popd
popd
