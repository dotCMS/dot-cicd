: ${DOT_CICD_REPO:="https://github.com/dotCMS/dot-cicd.git"} && export DOT_CICD_REPO
: ${DOT_CICD_LIB:="${DOT_CICD_PATH}/library"} && export DOT_CICD_LIB
: ${DOT_CICD_VERSION:="1.0"} && export DOT_CICD_VERSION
: ${DOT_CICD_TOOL:="travis"} && export DOT_CICD_TOOL
: ${DOT_CICD_PERSIST:="google"} && export DOT_CICD_PERSIST
# Remove me
: ${DOT_CICD_TARGET:="core"} && export DOT_CICD_TARGET

echo "dot-cicd vars"
echo "#############"
echo "DOT_CICD_REPO: ${DOT_CICD_REPO}"
echo "DOT_CICD_BRANCH: ${DOT_CICD_BRANCH}"
echo "DOT_CICD_PATH: ${DOT_CICD_PATH}"
echo "DOT_CICD_LIB: ${DOT_CICD_LIB}"
echo "DOT_CICD_VERSION: ${DOT_CICD_VERSION}"
echo "DOT_CICD_TOOL: ${DOT_CICD_TOOL}"
echo "DOT_CICD_PERSIST: ${DOT_CICD_PERSIST}"
echo "DOT_CICD_TARGET: ${DOT_CICD_TARGET}"