basic_auth='YWRtaW5AZG90Y21zLmNvbTphZG1pbg=='
user_id='dotcms.org.1'
token_id=123
exp_secs=100000
payload="{\"userId\":\"${user_id}\", \"tokenId\":\"${token_id}\", \"expirationSeconds\":\"${exp_secs}\"}"
access_token=$(curl --insecure -fSLs --request POST ${target_host}/api/v1/apitoken \
  --header 'Content-Type: application/json' \
  --header "Authorization: Basic ${basic_auth}" \
  --data-raw "${payload}" \
  | jq -r '.entity.jwt')
api_scan_file='application.wadl-Swagger20.json'
api_conf_file='api.conf'
#api_scan_report_file='api-scan-testreport.html'
api_scan_report_file='index.html'

mv ${api_scan_file} wrk/
mv ${api_conf_file} wrk/

echo '####################
Running ZAP API Scan
####################'
[[ "${DEBUG}" == 'true' ]] && echo "Executing: ./zap-api-scan.py
  -t ${api_scan_file}
  -r ${api_scan_report_file}
  -f openapi
  -c api.conf
  -z \"-config replacer.full_list\\(0\\).description=auth1
  -config replacer.full_list\\(0\\).enabled=true
  -config replacer.full_list\\(0\\).matchtype=REQ_HEADER
  -config replacer.full_list\\(0\\).matchstr=Cookie
  -config replacer.full_list\\(0\\).regex=false
  -config replacer.full_list\\(0\\).replacement=${access_token}\"
"
./zap-api-scan.py \
  -t ${api_scan_file} \
  -r ${api_scan_report_file} \
  -f openapi \
  -c api.conf \
  -z "-config replacer.full_list\\(0\\).description=auth1
  -config replacer.full_list\\(0\\).enabled=true
  -config replacer.full_list\\(0\\).matchtype=REQ_HEADER
  -config replacer.full_list\\(0\\).matchstr=Cookie
  -config replacer.full_list\\(0\\).regex=false
  -config replacer.full_list\\(0\\).replacement=${access_token}"
export api_scan_result=$?
[[ "${DEBUG}" == 'true' && ${api_scan_result} != 0 ]] \
  && echo "Error executing zap-api-scan.py, error code: ${result}"

scan_label='API Scan Results'
ERROR_CODES="${ERROR_CODES}
${scan_label}: ${api_scan_result}"

copyResults ${api_scan_report_file} "${scan_label}"
