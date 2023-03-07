# OpenJDK distributed under GPLv2+Oracle Classpath Exception license (http://openjdk.java.net/legal/gplv2+ce.html)
# Alpine Linux packages distributed under various licenses including GPL-3.0+ (https://pkgs.alpinelinux.org/packages)
FROM cicd-dotcms as build-cms

LABEL com.dotcms.contact "support@dotcms.com"
LABEL com.dotcms.vendor "dotCMS LLC"
LABEL com.dotcms.description "dotCMS Content Management System"

ARG BUILD_FROM=COMMIT
ENV BUILD_FROM=${BUILD_FROM}
ARG BUILD_ID=HEAD
ENV BUILD_ID=${BUILD_ID}
ARG BUILD_HASH
ENV BUILD_HASH=${BUILD_HASH}
ARG LICENSE_KEY

WORKDIR /srv

USER 0

VOLUME /custom/output

# Scripts from docker setup
COPY setup/build-src/displayDebugData.sh /build/displayDebugData.sh
RUN chmod 500 /build/displayDebugData.sh && /build/displayDebugData.sh ${BUILD_FROM} ${BUILD_ID} ${BUILD_HASH}

COPY setup/build-src/storage.sh /build/storage.sh
RUN chmod 500 /build/storage.sh

COPY setup/build-src/githubCommon.sh /build/githubCommon.sh
RUN chmod 500 /build/githubCommon.sh

COPY setup/build-src/testResults.sh /build/testResults.sh
RUN chmod 500 /build/testResults.sh

COPY setup/build-src/githubStatus.sh /build/githubStatus.sh
RUN chmod 500 /build/githubStatus.sh

COPY setup/build-src/printStatus.sh /build/printStatus.sh
RUN chmod 500 /build/printStatus.sh

COPY setup/build-src/printBuildInfo.sh /build/printBuildInfo.sh
RUN chmod 500 /build/printBuildInfo.sh

COPY setup/build-src/curlTests.sh /build/curlTests.sh
RUN chmod 500 /build/curlTests.sh

COPY setup/build-src/gitClone.sh /build/gitClone.sh
RUN chmod 500 /build/gitClone.sh

COPY setup/build-src/newmanTestResultsHeader.html /build/newmanTestResultsHeader.html
RUN chmod 500 /build/newmanTestResultsHeader.html

COPY setup/build-src/newmanTestResultsFooter.html /build/newmanTestResultsFooter.html
RUN chmod 500 /build/newmanTestResultsFooter.html

COPY setup/build-src/forkDotcms.sh /srv/forkDotcms.sh

COPY setup/build-src/stopDotcms.sh /srv/stopDotcms.sh

COPY setup/build-src/entrypoint.sh /srv/customEntrypoint.sh

RUN apt update && apt upgrade -y && apt install -y openssl tini git gcc musl-dev
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -  && apt install -y nodejs
#RUN npm config set unsafe-perm true
RUN npm install -g newman
RUN npm uninstall -g har-validator
RUN npm install -g newman-reporter-htmlextra
RUN npm install -g highlight.js@10 --save-dev

RUN curl -Ls https://repo.dotcms.com/artifactory/ext-release-local/com/dotcms/dockerize/dockerize-linux-`uname -m` | install /dev/stdin /usr/local/bin/dockerize

RUN apt purge --allow-remove-essential -y && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN chmod -R 666 /srv && find /srv/ -type d -exec chmod a+x {} \;
RUN find /srv/ -type f -name "*.sh" -exec chmod a+x {} \;

RUN chmod -R 666 /build && find /build/ -type d -exec chmod a+x {} \;
RUN find /build/ -type f -name "*.sh" -exec chmod a+x {} \;

RUN mkdir -p /build/src \
    && echo "Pulling dotCMS src" \
    && cd /build/src \
    && /build/gitClone.sh https://github.com/dotCMS/core.git core ${BUILD_ID}

ENTRYPOINT ["/srv/forkDotcms.sh"]
CMD ["dotcms"]
