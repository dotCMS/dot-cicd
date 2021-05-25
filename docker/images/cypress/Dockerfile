
FROM cypress/included:6.6.0 as build-scan

WORKDIR /srv

USER root

RUN apt-get update -y && apt-get install -y sudo jq curl

COPY build-src/entrypoint.sh /srv/entrypoint.sh
COPY setup/build-src/githubCommon.sh /srv/githubCommon.sh
COPY setup/build-src/testResults.sh /srv/testResults.sh

ENTRYPOINT ["/srv/entrypoint.sh"]
