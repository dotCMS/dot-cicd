
#!/bin/bash

zap_api_key='a1b2c3d4e5f6'

echo "Executing: ./zap-x.sh -daemon -host 0.0.0.0 -port ${zap_port} -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true -config api.key=${zap_api_key} &"
./zap-x.sh -daemon -host 0.0.0.0 -port ${zap_port} -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true -config api.key=${zap_api_key} &

wait=3
echo "Sleeping ${wait} secs"
sleep ${wait}
