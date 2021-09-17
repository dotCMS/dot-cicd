#!/bin/bash

#########################
# Script: githubCommon.sh
# Collection of common functions used across the pipeline

# Evaluates a provided command to be echoed and then executed setting the result in a variable
#
# $1: cmd command to execute
function executeCmd {
  local cmd=${1}
  cmd=$(echo ${cmd} | tr '\n' ' \ \n')
  echo "Executing:
==========
${cmd}
"
  eval "${cmd}"
  export cmdResult=$?
  [[ "${DEBUG}" == 'true' ]] && echo -e "cmdResult: ${cmdResult}\n"
}

# HTTP-Encodes a provided string
#
# $1: string: url to encode
function urlEncode {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * ) printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"
  ENCODED_URL="${encoded}"
}

# Resolves results path based on the definition TEST_TYPE and databaseType env-vars
#
# $1: path: initial path
function resolveResultsPath {
  local path="${1}"
  if [[ -n "${TEST_TYPE}" ]]; then
    path="${path}/${TEST_TYPE}"
  fi
  if [[ -n "${databaseType}" ]]; then
    path="${path}/${databaseType}"
  fi
  echo "${path}"
}

# TODO: At some point, please change these vars to someone else :P
DEFAULT_GITHUB_USER=victoralfaro-dotcms
DEFAULT_GITHUB_USER_EMAIL='victor.alfaro@dotcms.com'

[[ -z "${BUILD_ID}" ]] && BUILD_ID=${CURRENT_BRANCH}
[[ -z "${BUILD_ID}" ]] && BUILD_ID=${BRANCH}
: ${BUILD_HASH:="${GITHUB_SHA::8}"} && export BUILD_HASH
: ${GITHUB_USER:="${DEFAULT_GITHUB_USER}"} && export GITHUB_USER
: ${GITHUB_USER_EMAIL:="${DEFAULT_GITHUB_USER_EMAIL}"} && export GITHUB_USER_EMAIL
export DOTCMS_GITHUB_ORG=dotCMS
export DOT_CICD_GITHUB_REPO=dot-cicd
export CORE_GITHUB_REPO=core
export ENTERPRISE_GITHUB_REPO=enterprise
export CORE_WEB_GITHUB_REPO=core-web
export DOCKER_GITHUB_REPO=docker
export PLUGIN_SEEDS_GITHUB_REPO=plugin-seeds
export TEST_RESULTS_GITHUB_REPO=test-results
: ${DEBUG:="false"} && export DEBUG

echo "###########
Github vars
###########
BUILD_ID: ${BUILD_ID}
BUILD_HASH: ${BUILD_HASH}
GITHUB_RUN_NUMBER: ${GITHUB_RUN_NUMBER}
PULL_REQUEST: ${PULL_REQUEST}
GITHUB_REF: ${GITHUB_REF}
GITHUB_HEAD_REF: ${GITHUB_HEAD_REF}
GITHUB_USER: ${GITHUB_USER}
GITHUB_USER_TOKEN: ${GITHUB_USER_TOKEN}
DOTCMS_GITHUB_ORG: ${DOTCMS_GITHUB_ORG}
CORE_GITHUB_REPO: ${CORE_GITHUB_REPO}
CORE_WEB_GITHUB_REPO: ${CORE_WEB_GITHUB_REPO}
DOCKER_GITHUB_REPO: ${DOCKER_GITHUB_REPO}
TEST_RESULTS_GITHUB_REPO: ${TEST_RESULTS_GITHUB_REPO}
PLUGIN_SEEDS_GITHUB_REPO: ${PLUGIN_SEEDS_GITHUB_REPO}
DEBUG: ${DEBUG}
"

# Builds credentials part for Github repo url, that is Github user token and username associated with it
#
# $1: token: token to use when building credentials part
# $2: user: github username to use in credentials part
function resolveCreds {
  local token=${1}
  local user=${2}
  local creds=

  if [[ -n "${user}" ]]; then
    creds="${user}"
  fi

  if [[ -n "${token}" ]]; then
    local sep=
    [[ -n "${creds}" ]] && sep=':'
    creds="${creds}${sep}${token}"
  fi

  echo ${creds}
}

# Builds credentials and host parts for Github repo url
#
# $1: token: token to use when building credentials part
# $2: user: Github username to use in credentials part
function resolveSite {
  local creds=$(resolveCreds ${1} ${2})
  [[ -n "${creds}" ]] && creds="${creds}@"

  local site="https://${creds}github.com"
  echo ${site}
}

# Builds path: Github organization + repo name
#
# $1: path: Github repo name
function resolvePath {
  local path=${DOTCMS_GITHUB_ORG}/${1}
  echo ${path}
}

# Builds Github repo url
#
# $1: Github repo name
# $2: token to use when building credentials part
# $3: Github username to use in credentials part
function resolveRepoUrl {
  local path=$(resolvePath ${1})
  local site=$(resolveSite ${2} ${3})
  local url=${site}/${path}.git
  echo ${url}
}

# Builds non-cloning Github repo url, that is without the '.git' suffix
#
# $@: same args as resolveRepoUrl
function resolveRepoPath {
  local path=$(resolveRepoUrl $@)
  echo ${path%".git"}
}

# Sets git config globals user.email and user.name
#
# $1: username: Github username
# $2: name: Github user name
function gitConfig {
  local username=${1}
  local name=${2}
  local email

  [[ -z "${name}" ]] && name=${username}

  if [[ -n "${GITHUB_USER_EMAIL}" ]]; then
    email="${GITHUB_USER_EMAIL}"
  else
    email="${username}@dotcms.com"
  fi

  if [[ "${DEBUG}" == 'true' ]]; then
    echo " Git Config:
    git config --global user.email \"${email}\"
    git config --global user.name \"${name}\""
  fi
  git config --global user.email "${email}"
  git config --global user.name "${name}"
  git config --global pager.branch false
  git config pull.rebase false

  [[ "${DEBUG}" == 'true' ]] && git config --list
}

# Defaults to a extracted repo name from repo url
#
# $1: repo_rl: repo url
# $2: dest: destination to
function defaultLocation {
  local repo_url=${1}
  local dest=${2}
  [[ -z "${dest}" ]] && dest=$(basename ${repo_url} .git)
  echo ${dest}
}

# Git clones a given repo url, with a specific branch to a specific location.
#
# $1: repo_url: repo url
# $2: branch: branch to check out
# $3: dest: destination to save the repo
function gitClone {
  local repo_url=${1}
  local branch=${2}
  local dest=${3}

  [[ -z "${branch}" ]] && branch='master'
  dest=$(defaultLocation ${repo_url} ${dest})

  echo "Cloning
    repo: ${repo_url}
    branch: ${branch}
    location: ${dest}"

  local git_clone_mode=
  [[ "${GIT_CLONE_STRATEGY}" != 'full' ]] && git_clone_mode='--depth 1'

  local git_branch_params=
  if [[ "${branch}" != 'master' ]]; then
    git_branch_params="--branch ${branch}"
    if [[ "${GIT_CLONE_STRATEGY}" != 'full' ]]; then
      git_clone_mode="${git_clone_mode} --single-branch"
    fi
  fi

  local git_clone_params="${git_clone_mode} ${git_branch_params}"
  clone_cmd="git clone ${git_clone_params} ${repo_url} ${dest}"
  echo "OJO:>> ${clone_cmd}"
  executeCmd "${clone_cmd}"

echo "OJO:>>1"
  pushd ${dest}
echo "OJO:>>2"
  git clean -f -d
echo "OJO:>>3"
  popd
echo "OJO:>>4"


  return ${cmdResult}
}

# Given a repo url use it to replace the url element in a .gitmodules file in provided location
#
# $1: repo_url: repo url
# $2: dest: destination to save the repo
function gitSubModules {
  local repo_url=${1}
  [[ -z "${repo_url}" ]] && echo "No repo url provided, aborting" && exit 1
  local dest=${2}
  [[ -z "${dest}" ]] && echo "No git folder provided, aborting" && exit 1

  echo 'Getting submodules'
  pushd ${dest}

  [[ "${DEBUG}" == 'true' ]] \
    && cat .gitmodules \
    && echo "Injecting ${repo_url} to submodule"
  sed -i "s,git@github.com:dotCMS,${repo_url},g" .gitmodules
  [[ "${DEBUG}" == 'true' ]] && cat .gitmodules

  git submodule update --init --recursive
  local sub_result=$?
  [[ ${sub_result} != 0 ]] && echo 'Error updating submodule' && exit 1

  # Try to checkout submodule branch and
  local module_path=$(cat .gitmodules| grep "path =" | cut -d'=' -f2 | tr -d '[:space:]')
  local module_branch=$(cat .gitmodules| grep "branch =" | cut -d'=' -f2 | tr -d '[:space:]')
  pushd ${module_path}
  gitConfig ${GITHUB_USER}
  if [[ "${module_branch}" != 'master' ]]; then
    git checkout -b ${module_branch} --track origin/${module_branch}
  else
    git checkout master
  fi

  git pull origin ${module_branch}
  sub_result=$?
  [[ ${sub_result} != 0 ]] && echo 'Error pulling from submodule' && exit 1

  popd
  popd

  return ${sub_result}
}

# Git clones with submodules support
#
# $@: same args as gitClone
function gitCloneSubModules {
  gitClone $@
  echo "OJO:>>5"
  local clone_result=$?
  [[ ${clone_result} != 0 ]] && return ${clone_result}

  [[ "${DEBUG}" == 'true' ]] && pwd && ls -las .

  local repo_url=${1}
  [[ "${DEBUG}" == 'true' ]] && echo "defaultLocation args: ${repo_url} ${3}"
  local dest=$(defaultLocation ${repo_url} ${3})
  [[ "${DEBUG}" == 'true' ]] && echo "submodules args: $(dirname ${repo_url}) ${dest}"

  gitSubModules $(dirname ${repo_url}) ${dest}
  echo "OJO:>>6"
  local sub_result=$?

  return ${sub_result}
}

# Git clone not with a repo url but with the repo's name using or not a user token
#
# $1: repository name
# $2: branch: branch to check out
# $3: dest: destination to save repo
function simpleGitClone {
  local repo=$(resolveRepoUrl ${1})
  local branch=${2}
  local dest=${3}
  gitClone ${repo} ${branch} ${dest}
  return $?
}

# Given a repo url and a branch, run a remote list to see if it exists remotely
#
# $1: repo_url: repo url
# $2: build_id: branch to query
function gitRemoteLs {
  local repo_url=${1}
  local build_id=${2}
  return $(git ls-remote --heads ${repo_url} ${build_id} | wc -l | tr -d '[:space:]')
}

# Copies resources to build a docker image with db volume
#
# $1: docker_file_path: path where a Dockerfile is located
function setupDockerDb {
  local docker_file_path=${1}
  [[ "${DEBUG}" == 'true' ]] && echo "Copying from ${DOCKER_SOURCE}/setup/db to ${docker_file_path}/setup"
  cp -R ${DOCKER_SOURCE}/setup/db ${docker_file_path}/setup
}

# Copies dot-cicd external scripts to be included in docker image scripts
#
# $1: docker_file_path: path where a Dockerfile is located
function setupExternal {
  local docker_file_path=${1}
  [[ ! -d ${docker_file_path}/setup/build-src ]] && mkdir -p ${docker_file_path}/setup/build-src
  [[ "${DEBUG}" == 'true' ]] \
    && echo "Copying from ${DOT_CICD_LIB}/pipeline/github/githubCommon.sh to ${docker_file_path}/setup/build-src"
  cp ${DOT_CICD_LIB}/pipeline/github/githubCommon.sh ${docker_file_path}/setup/build-src
}

# Copies scripts to be included in the docker image scripts
#
# $1: docker_file_path: path where a Dockerfile is located
# $2: docker_repo_path: docker repo path
function setupSrc {
  local docker_file_path=${1}
  local docker_repo_path=${2}
  mkdir -p ${docker_file_path}/setup
  [[ "${DEBUG}" == 'true' ]] && echo "Copying from ${DOCKER_SOURCE}/setup/build-src to ${docker_file_path}/setup"
  cp -R ${DOCKER_SOURCE}/setup/build-src ${docker_file_path}/setup
  if [[ "${docker_file_path}" != "${docker_repo_path}" ]]; then
    [[ "${DEBUG}" == 'true' ]] && echo "Copying from ${docker_repo_path}/ROOT to ${docker_file_path}"
    cp -R ${docker_repo_path}/ROOT ${docker_file_path}

    [[ "${DEBUG}" == 'true' ]] \
      && echo "Copying from ${docker_repo_path}/build-src/build_dotcms.sh to ${docker_file_path}/setup/build-src"
    cp -R ${docker_repo_path}/build-src/build_dotcms.sh ${docker_file_path}/setup/build-src
  fi
}

# Creates a directories for output and license
#
# $1: docker_file_path: path where a Dockerfile is located
function addLicenseAndOutput {
  local docker_file_path=${1}
  output_folder=${docker_file_path}/output
  mkdir -p ${output_folder} && chmod 777 ${output_folder}
  license_folder=${docker_file_path}/license
  mkdir -p ${license_folder} && chmod 777 ${license_folder}
}

# Copies all the resources (scripts, files, directories) to a location they could be used creating dotcms docker image
#
# $1: docker_file_path: path where a Dockerfile is located
# $2: docker_repo_path: docker repo path
function setupDocker {
  local docker_file_path=${1}
  local docker_repo_path=${2}
  echo "Setting up docker resources:
  docker_file_path: ${docker_file_path}
  docker_repo_path: ${docker_repo_path}
  "
  setupSrc ${docker_file_path} ${docker_repo_path}
  setupDockerDb ${docker_file_path}
  setupExternal ${docker_file_path}
  addLicenseAndOutput ${docker_file_path}
}

# Prepares resources to build integration image
#
# $1: folder: folder to create and copy integration resources to
function setupDockerIntegration {
  local folder=${1}
  [[ -z "${folder}" ]] && folder=integration
  mkdir -p ${DOCKER_SOURCE}/tests/${folder}/output
  mkdir -p ${DOCKER_SOURCE}/tests/${folder}/license
  cp -R ${DOCKER_SOURCE}/setup ${DOCKER_SOURCE}/tests/integration
}

# Calls 'docker build' command with provided build args to create a docker image.
# Most of the times this is used after running a setupXXX function for it to work properly.
#
# $1: image_name: name to use when building image
# $2: docker_file_path: path where a Dockerfile is located
# $3: skip_pull: when true
function buildBase {
  local image_name=${1}
  local docker_file_path=${2}
  local skip_pull=${3}

  build_extra_args=''
  [[ -n "${BUILD_HASH}" ]] && build_extra_args="--build-arg BUILD_HASH=${BUILD_HASH}"
  [[ -n "${LICENSE_KEY}" ]] && build_extra_args="${build_extra_args} --build-arg LICENSE_KEY=${LICENSE_KEY}"

  pull_param='--pull'
  [[ "${skip_pull}" == 'true' ]] && pull_param=''

  if [[ -f ${docker_file_path} ]]; then
    docker_file=${docker_file_path}
    docker_file_folder=$(dirname ${docker_file_path})
    docker_file_path="-f ${docker_file}
    ${docker_file_folder}
    "
  fi

  executeCmd "docker build ${pull_param} --no-cache -t ${image_name}
    --build-arg BUILD_FROM=COMMIT
    --build-arg BUILD_ID=${BUILD_ID}
    ${build_extra_args}
    ${docker_file_path}
  "
  dcResult=$?

  if [[ ${dcResult} != 0 ]]; then
    exit 1
  fi
}

# Creates a directory and file with provided license
#
# $1: docker_file_path: path where a Dockerfile is located
# $2: license: DotCMS license
function prepareLicense {
  local docker_file_path=${1}
  local license=${2}
  local license_folder=${docker_file_path}/license
  [[ "${DEBUG}" == 'true' ]] && echo "License Args: $@"

  mkdir -p ${license_folder}
  chmod 777 ${license_folder}
  license_file=${license_folder}/license.dat
  touch ${license_file}
  chmod 777 ${license_file}
  echo ${license} > ${license_file}

  if [[ "${DEBUG}" == 'true' ]] ; then
    ls -las ${license_folder}
    echo "License found:
    ${license}"
  fi
}

# More Env-Vars definition, specifically to results storage
githack_test_results_url=$(resolveRepoPath ${TEST_RESULTS_GITHUB_REPO} | sed -e 's/github.com/raw.githack.com/')
export BASE_STORAGE_URL="${githack_test_results_url}/$(urlEncode ${BUILD_ID})/projects/${DOT_CICD_TARGET}"
export GITHUB_PERSIST_COMMIT_URL="${BASE_STORAGE_URL}/$(resolveResultsPath ${BUILD_HASH})"
export GITHUB_PERSIST_BRANCH_URL="${BASE_STORAGE_URL}/$(resolveResultsPath current)"
commitPath="$(resolveResultsPath ${BUILD_HASH})"
export STORAGE_JOB_COMMIT_FOLDER="${commitPath}"
export STORAGE_JOB_BRANCH_FOLDER="$(resolveResultsPath current)"

echo "############
Storage vars
############
BASE_STORAGE_URL: ${BASE_STORAGE_URL}
GITHUB_PERSIST_COMMIT_URL: ${GITHUB_PERSIST_COMMIT_URL}
GITHUB_PERSIST_BRANCH_URL: ${GITHUB_PERSIST_BRANCH_URL}
commitPath: ${commitPath}
STORAGE_JOB_COMMIT_FOLDER: ${STORAGE_JOB_COMMIT_FOLDER}
STORAGE_JOB_BRANCH_FOLDER: ${STORAGE_JOB_BRANCH_FOLDER}
"
