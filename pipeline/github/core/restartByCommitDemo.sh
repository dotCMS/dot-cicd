#!/bin/bash

################################
# Script: restartByCommitDemo.sh
# Pushes a commit to demo.dotcms.com in order to restart it.
# In progress.

build_id=$1
is_release=$2

demo_repo="demo.dotcms.com"
github="github.com"
github_path="dotCMS/${demo_repo}"
github_host_path="${github}/${github_path}"
github_remote_repo="https://${github_host_path}"
github_repo="${github_remote_repo}.git"
github_token_repo="https://${github_user_token}@${github_host_path}.git"

cd ..
git config --global user.email "${github_user}@dotcms.com"
git config --global user.name "${github_user}"
git clone ${github_repo}
cd ${demo_repo}
git pull

git commit --allow-empty -m "Trigger demo restart as per release of ${build_id}"
git status
echo "Executing: git push"
if [[ "${is_release}" == 'true' ]]; then
  git push
fi
