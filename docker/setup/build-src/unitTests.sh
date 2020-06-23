. /build/printStatus.sh

echo ""
echo "================================================================================"
echo "================================================================================"
echo "  >>>   TEST PARAMETERS: ${EXTRA_PARAMS}"
echo "  >>>   BUILD FROM: ${BUILD_FROM}"
echo "  >>>   BUILD ID: ${BUILD_ID}"
echo "  >>>   GIT HASH: ${BUILD_HASH}"
echo "  >>>   STORAGE_JOB_COMMIT_FOLDER: ${STORAGE_JOB_COMMIT_FOLDER}"
echo "  >>>   STORAGE_JOB_BRANCH_FOLDER: ${STORAGE_JOB_BRANCH_FOLDER}"
echo "================================================================================"
echo "================================================================================"
echo ""

cd /build/src/core/dotCMS \
  && ./gradlew test ${EXTRA_PARAMS}

# Required code, without it gradle will exit 1 killing the docker container
gradlewReturnCode=$?
export CURRENT_JOB_BUILD_STATUS=${gradlewReturnCode}

echo ""
if [[ ${gradlewReturnCode} == 0 ]]; then
  echo "  >>> Unit tests executed successfully <<<"
else
  echo "  >>> Unit tests failed <<<" >&2
fi

echo ""
echo "  >>> Copying gradle reports to [/custom/output/reports/]"
echo ""

# Copying gradle report
cp -R /build/src/core/dotCMS/build/test-results/unit-tests/html/ /custom/output/reports/

# Do we want to export the resulting reports to google storage?
if [[ ! -z "${EXPORT_REPORTS}" && $EXPORT_REPORTS ]]; then
  . /build/${DOT_CICD_PERSIST}/storage.sh
  ignoring_return_value=$?
fi

if [[ ${gradlewReturnCode} == 0 ]]; then
  exit 0
else
  exit 1
fi
