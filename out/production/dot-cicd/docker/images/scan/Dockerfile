
FROM owasp/zap2docker-stable:latest as build-scan

WORKDIR /zap

USER root

RUN apt-get update -y && apt-get install -y jq

COPY entrypoint.sh /zap/entrypoint.sh
COPY runZapX.sh /zap/runZapX.sh
COPY runBaseline.sh /zap/runBaseline.sh
COPY runFullScan.sh /zap/runFullScan.sh
COPY runApiScan.sh /zap/runApiScan.sh
COPY baseline.conf /zap/baseline.conf
COPY api.conf /zap/api.conf
COPY application.wadl-Swagger20.json /zap/application.wadl-Swagger20.json
COPY setup/build-src/githubCommon.sh /zap/githubCommon.sh

ENTRYPOINT ["/zap/entrypoint.sh"]
