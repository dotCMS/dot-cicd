basic_auth='YWRtaW5AZG90Y21zLmNvbTphZG1pbg=='
user_id='dotcms.org.1'
token_id=123
exp_secs=100000
payload="{\"userId\":\"${user_id}\", \"tokenId\":\"${token_id}\", \"expirationSeconds\":\"${exp_secs}\"}"
access_token=$(curl -fSLs --request POST ${target_host}/api/v1/apitoken \
  --header 'Content-Type: application/json' \
  --header "Authorization: Basic ${basic_auth}" \
  --data-raw "${payload}" \
  | jq -r '.entity.jwt')
api_scan_file="application.wadl-Swagger20.json"
api_scan_report_file='api-scan-testreport.html'

echo "Executing: zap-api-scan.py -t ${api_scan_file}
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
zap-api-scan.py -t ${api_scan_file} \
  -r ${api_scan_report_file} \
  -f openapi \
  -c api.conf \
  -z "-config replacer.full_list\\(0\\).description=auth1
  -config replacer.full_list\\(0\\).enabled=true
  -config replacer.full_list\\(0\\).matchtype=REQ_HEADER
  -config replacer.full_list\\(0\\).matchstr=Cookie
  -config replacer.full_list\\(0\\).regex=false
  -config replacer.full_list\\(0\\).replacement=${access_token}"
result=$?

if [[ ${result} != 0 ]]; then
  echo "Error executing zap-api-scan.py, error code: ${result}"
  endScan
  exit 1
fi

prepareResults ${api_scan_report_file}
