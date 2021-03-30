#!/bin/bash

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

if [[ -z "${BUILD_ID}" ]]; then
  BUILD_ID=${CURRENT_BRANCH}
fi
if [[ -z "${BUILD_ID}" ]]; then
  BUILD_ID=${BRANCH}
fi

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

caller=$(basename ${0})
if [[ "${caller}" == 'pipeline.sh' || "${caller}" == 'local.sh' ]]; then
  export CONTAINERIZED=false
else
  export CONTAINERIZED=true
fi

[[ "${CONTAINERIZED}" == 'false' || "${DEBUG}" == 'true' ]] && echo "###########
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

function resolveCreds {
  local token=${1}
  local user=${2}
  local creds=

  if [[ -n "${user}" ]]; then
    creds="${user}"
  fi

  if [[ -n "${token}" ]]; then
    local sep=
    if [[ -n "${creds}" ]]; then
      sep=':'
    fi
    creds="${creds}${sep}${token}"
  fi

  echo ${creds}
}

function resolveSite {
  local creds=$(resolveCreds ${1} ${2})
  [[ -n "${creds}" ]] && creds="${creds}@"

  local site="https://${creds}github.com"
  echo ${site}
}

function resolvePath {
  local path=${DOTCMS_GITHUB_ORG}/${1}
  echo ${path}
}

function resolveRepoUrl {
  local path=$(resolvePath ${1})
  local site=$(resolveSite ${2} ${3})
  local url=${site}/${path}.git
  echo ${url}
}

function resolveRepoPath {
  local path=$(resolveRepoUrl $@)
  echo ${path%".git"}
}

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

  [[ "${DEBUG}" == 'true' ]] && git config --list
}

function printGitStatus {
  echo "Git status:"
  git branch
  git status
}

function defaultLocation {
  local repo_url=${1}
  local dest=${2}
  [[ -z "${dest}" ]] && dest=$(basename ${repo_url} .git)
  echo ${dest}
}

function gitClone {
  local repo_url=${1}
  local branch=${2}
  local dest=${3}

  if [[ -z "${repo_url}" ]]; then
    echo "Git repo not provided, aborting"
    exit 1
  fi

  [[ -z "${branch}" ]] && branch='master'
  dest=$(defaultLocation ${repo_url} ${dest})

  echo "Cloning
    repo: ${repo_url}
    branch: ${branch}
    location: ${dest}"
  if [[ "${branch}" == 'master' ]]; then
    git clone --depth 1 ${repo_url} ${dest}
  else
    git clone --depth 1 --single-branch --branch ${branch} ${repo_url} ${dest}
  fi
  local cloneResult=$?

  pushd ${dest}
  git clean -f -d
  popd

  return ${cloneResult}
}

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
  git gc --aggressive
  popd

  return ${sub_result}
}

function gitCloneSubModules {
  gitClone $@
  local clone_result=$?
  [[ ${clone_result} != 0 ]] && return ${clone_result}

  [[ "${DEBUG}" == 'true' ]] && pwd && ls -las .

  local repo_url=${1}
  dest=$(defaultLocation ${repo_url} ${3})

  gitSubModules $(dirname ${repo_url}) ${dest}
  local sub_result=$?

  return ${sub_result}
}

function simpleGitClone {
  local repo=$(resolveRepoUrl ${1})
  local branch=${2}
  local dest=${3}
  gitClone ${repo} ${branch} ${dest}
  return $?
}

function gitRemoteLs {
  local repo_url=${1}
  local build_id=${2}
  return $(git ls-remote --heads ${repo_url} ${build_id} | wc -l | tr -d '[:space:]')
}

function executeCmd {
  local cmd=${1}
  cmd=$(echo ${cmd} | tr '\n' ' \ \n')
  [[ "${DEBUG}" == 'true' ]] && echo "Executing:
==========
${cmd}
"
  eval "${cmd}; export cmdResult=$?"
  if [[ "${DEBUG}" == 'true' ]]; then
    echo -e "cmdResult: ${cmdResult}\n"
  fi
}

function fetchDocker {
  local dest=${1}
  local branch=${2}

  [[ -z "${dest}" ]] && dest=cicd/
  [[ -z "${branch}" ]] && branch=master

  simpleGitClone ${DOCKER_GITHUB_REPO} ${branch} ${dest}
  local cloneResult=$?
  if [[ ${cloneResult} != 0 ]]; then
    echo "Error cloning repo '${repo}'"
    exit 1
  fi
}

# Prepares resources to build a docker image with db access
function setupDockerDb {
  local docker_file_path=${1}
  cp -R ${DOCKER_SOURCE}/setup/db ${docker_file_path}/setup
}

function setupExternal {
  local docker_file_path=${1}
  [[ ! -d ${docker_file_path}/setup/build-src ]] && mkdir -p ${docker_file_path}/setup/build-src
  cp ${DOT_CICD_LIB}/pipeline/github/githubCommon.sh ${docker_file_path}/setup/build-src
}

function setupSrc {
  local docker_file_path=${1}
  local docker_repo_path=${2}
  mkdir -p ${docker_file_path}/setup
  cp -R ${DOCKER_SOURCE}/setup/build-src ${docker_file_path}/setup
  cp -R ${docker_repo_path}/images/dotcms/ROOT ${docker_file_path}
  cp -R ${docker_repo_path}/images/dotcms/build-src/build_dotcms.sh ${docker_file_path}/setup/build-src
}

function addLicenseAndOutput {
  local docker_file_path=${1}
  output_folder=${docker_file_path}/output
  mkdir -p ${output_folder} && chmod 777 ${output_folder}
  license_folder=${docker_file_path}/license
  mkdir -p ${license_folder} && chmod 777 ${license_folder}
}

# Prepares resources to build a docker image with db access and valid license
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
function setupDockerIntegration {
  local folder=${1}
  [[ -z "${folder}" ]] && folder=integration
  mkdir -p ${DOCKER_SOURCE}/tests/${folder}/output
  mkdir -p ${DOCKER_SOURCE}/tests/${folder}/license
  cp -R ${DOCKER_SOURCE}/setup ${DOCKER_SOURCE}/tests/integration
}

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

githack_test_results_url=$(resolveRepoPath ${TEST_RESULTS_GITHUB_REPO} | sed -e 's/github.com/raw.githack.com/')
export BASE_STORAGE_URL="${githack_test_results_url}/$(urlEncode ${BUILD_ID})/projects/${DOT_CICD_TARGET}"
export GITHUB_PERSIST_COMMIT_URL="${BASE_STORAGE_URL}/$(resolveResultsPath ${BUILD_HASH})"
export GITHUB_PERSIST_BRANCH_URL="${BASE_STORAGE_URL}/$(resolveResultsPath current)"
commitPath="$(resolveResultsPath ${BUILD_HASH})"
export STORAGE_JOB_COMMIT_FOLDER="${commitPath}"
export STORAGE_JOB_BRANCH_FOLDER="$(resolveResultsPath current)"

[[ "${CONTAINERIZED}" == 'false' ]] && echo "############
Storage vars
############
BASE_STORAGE_URL: ${BASE_STORAGE_URL}
GITHUB_PERSIST_COMMIT_URL: ${GITHUB_PERSIST_COMMIT_URL}
GITHUB_PERSIST_BRANCH_URL: ${GITHUB_PERSIST_BRANCH_URL}
commitPath: ${commitPath}
STORAGE_JOB_COMMIT_FOLDER: ${STORAGE_JOB_COMMIT_FOLDER}
STORAGE_JOB_BRANCH_FOLDER: ${STORAGE_JOB_BRANCH_FOLDER}
"
