
FROM owasp/zap2docker-stable:latest as build-scan

WORKDIR /zap

USER root

RUN apt-get update -y && apt-get install -y jq

COPY entrypoint.sh /zap/entrypoint.sh
COPY build-src/runZapX.sh /zap/runZapX.sh
COPY build-src/runBaseline.sh /zap/runBaseline.sh
COPY build-src/runFullScan.sh /zap/runFullScan.sh
COPY build-src/runApiScan.sh /zap/runApiScan.sh
COPY build-src/baseline.conf /zap/baseline.conf
COPY build-src/api.conf /zap/api.conf
COPY build-src/application.wadl-Swagger20.json /zap/application.wadl-Swagger20.json
COPY build-src/scanResultsHeader.html /zap/scanResultsHeader.html
COPY build-src/scanResultsFooter.html /zap/scanResultsFooter.html
COPY setup/build-src/githubCommon.sh /zap/githubCommon.sh

ENTRYPOINT ["/zap/entrypoint.sh"]
