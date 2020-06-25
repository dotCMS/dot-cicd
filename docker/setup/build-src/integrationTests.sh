# Validating we have a license file
if [[ ! -s "/custom/dotsecure/license/license.dat" ]]; then
  echo ""
  echo "================================================================"
  echo " >>> Valid [/custom/dotsecure/license/license.dat] NOT FOUND <<<"
  echo "================================================================"
  exit 1
fi

TEST_SUITE_COMMAND="-Dtest.single=com.dotcms.MainSuite"
GRADLE_PARAMS=${TEST_SUITE_COMMAND}

if [[ ! -z "${EXTRA_PARAMS}" ]]; then
  if [[ ${EXTRA_PARAMS} =~ "--tests" ]]; then
    GRADLE_PARAMS=${EXTRA_PARAMS}
  else
    GRADLE_PARAMS="${EXTRA_PARAMS} ${TEST_SUITE_COMMAND}"
  fi
fi

. /build/printStatus.sh

echo ""
echo "================================================================================"
echo "================================================================================"
echo "  >>>   DB: ${databaseType}"
echo "  >>>   TEST PARAMETERS: ${EXTRA_PARAMS}"
echo "  >>>   BUILD FROM: ${BUILD_FROM}"
echo "  >>>   BUILD ID: ${BUILD_ID}"
echo "  >>>   GIT HASH: ${BUILD_HASH}"
echo "  >>>   STORAGE_JOB_COMMIT_FOLDER: ${STORAGE_JOB_COMMIT_FOLDER}"
echo "  >>>   STORAGE_JOB_BRANCH_FOLDER: ${STORAGE_JOB_BRANCH_FOLDER}"
echo "================================================================================"
echo "================================================================================"
echo ""

if [[ ! -z "${WAIT_DB_FOR}" ]]; then
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "            Requested sleep of [${WAIT_DB_FOR}]", waiting for the db?
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo ""
  sleep ${WAIT_DB_FOR}
fi

echo ""
echo "================================================================================"
echo "Executing... [./gradlew integrationTest ${GRADLE_PARAMS}]"
echo "================================================================================"
echo ""

cd /build/src/core/dotCMS \
  && ./gradlew integrationTest jacocoTestReport ${GRADLE_PARAMS}

# Required code, without it gradle will exit 1 killing the docker container
gradlewReturnCode=$?
export CURRENT_JOB_BUILD_STATUS=${gradlewReturnCode}

echo ""
if [[ ${gradlewReturnCode} == 0 ]]; then
  echo "  >>> Integration tests executed successfully <<<"
else
  echo "  >>> Integration tests failed <<<" >&2
fi

echo ""
echo "  >>> Copying gradle reports to [/custom/output/reports/]"
echo ""

# Copying gradle report
cp -R /build/src/core/dotCMS/build/reports/tests/integrationTest/* /custom/output/reports/html/

# Do we want to export the resulting reports to google storage?
if [[ ! -z "${EXPORT_REPORTS}" ]]; then
  if [[ $EXPORT_REPORTS ]]; then
    . /build/${DOT_CICD_PERSIST}/storage.sh
    ignoring_return_value=$?
  fi
fi

if [[ ${gradlewReturnCode} == 0 ]]; then
  exit 0
else
  exit 1
fi
