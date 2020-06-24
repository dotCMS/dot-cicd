commitFolder=${BASE_STORAGE_URL}/${STORAGE_JOB_COMMIT_FOLDER}
branchFolder=${BASE_STORAGE_URL}/${STORAGE_JOB_BRANCH_FOLDER}
reportsCommitIndexURL="${commitFolder}/reports/html/index.html"
reportsBranchIndexURL="${branchFolder}/reports/html/index.html"
logCommitURL="${commitFolder}/logs/dotcms.log"
logBranchURL="${branchFolder}/logs/dotcms.log"

echo ""
echo -e "\e[36m==========================================================================================================================\e[0m"
echo -e "\e[36m==========================================================================================================================\e[0m"
echo -e "\e[1;36m                                                REPORTING\e[0m"
echo
echo -e "\e[31m   ${reportsBranchIndexURL}\e[0m"
if [[ "${TEST_TYPE}" != "curl" ]]; then
  echo -e "\e[31m   ${logBranchURL}\e[0m"
fi
echo
echo -e "\e[31m   ${reportsCommitIndexURL}\e[0m"
if [[ "${TEST_TYPE}" != "curl" ]]; then
  echo -e "\e[31m   ${logCommitURL}\e[0m"
fi
echo
if [[ "$PULL_REQUEST" != "false" ]]; then
  echo "   GITHUB pull request: [https://github.com/dotCMS/core/pull/${PULL_REQUEST}]"
fi
echo
if [[ -n ${CURRENT_JOB_BUILD_STATUS} ]]; then
  if [[ ${CURRENT_JOB_BUILD_STATUS} == 0 ]]; then
    echo -e "\e[1;32m                                 >>> Tests executed SUCCESSFULLY <<<\e[0m"
  else
    echo -e "\e[1;31m                                       >>> Tests FAILED <<<\e[0m"
  fi
  echo
fi
echo -e "\e[36m==========================================================================================================================\e[0m"
echo -e "\e[36m==========================================================================================================================\e[0m"
echo ""
