# OpenJDK distributed under GPLv2+Oracle Classpath Exception license (http://openjdk.java.net/legal/gplv2+ce.html)
# Alpine Linux packages distributed under various licenses including GPL-3.0+ (https://pkgs.alpinelinux.org/packages)
FROM dotcms/dotcms-seed as build-cms

LABEL com.dotcms.contact "support@dotcms.com"
LABEL com.dotcms.vendor "dotCMS LLC"
LABEL com.dotcms.description "dotCMS Content Management System"

# Location for assets, indexes and felix
RUN mkdir -p /custom \
    && mkdir -p /custom/assets \
    && mkdir -p /custom/dotsecure \
    && mkdir -p /custom/esdata \
    && mkdir -p /custom/felix \
    && mkdir -p /custom/output

ARG BUILD_FROM=COMMIT
ENV BUILD_FROM=${BUILD_FROM}
ARG BUILD_ID=HEAD
ENV BUILD_ID=${BUILD_ID}
ARG BUILD_HASH
ENV BUILD_HASH=${BUILD_HASH}

WORKDIR /srv

# dotCMS core distributed under GPLv3 license (https://github.com/dotCMS/core/blob/master/license.txt)
COPY setup/build-src/build_dotcms.sh /build/build_dotcms.sh
RUN chmod 500 /build/build_dotcms.sh && /build/build_dotcms.sh ${BUILD_FROM} ${BUILD_ID}

# Scripts from docker setup
COPY setup/build-src/displayDebugData.sh /build/displayDebugData.sh
RUN chmod 500 /build/displayDebugData.sh && /build/displayDebugData.sh ${BUILD_FROM} ${BUILD_ID} ${BUILD_HASH}

VOLUME /custom/output

RUN mkdir /build/google
RUN mkdir /build/github

COPY setup/build-src/google/storage.sh /build/google/storage.sh
RUN chmod 500 /build/google/storage.sh

COPY setup/build-src/github/storage.sh /build/github/storage.sh
RUN chmod 500 /build/github/storage.sh

COPY setup/build-src/github/githubCommon.sh /build/github/githubCommon.sh
RUN chmod 500 /build/github/githubCommon.sh

COPY setup/build-src/common.sh /build/common.sh
RUN chmod 500 /build/common.sh

COPY setup/build-src/githubStatus.sh /build/githubStatus.sh
RUN chmod 500 /build/githubStatus.sh

COPY setup/build-src/printStatus.sh /build/printStatus.sh
RUN chmod 500 /build/printStatus.sh

COPY setup/build-src/entrypoint.sh /build/entrypoint.sh
RUN chmod 500 /build/entrypoint.sh

COPY setup/build-src/setVars.sh /build/setVars.sh
RUN chmod 500 /build/setVars.sh

COPY setup/build-src/printBuildInfo.sh /build/printBuildInfo.sh
RUN chmod 500 /build/printBuildInfo.sh

# COPY setup/build-src/installCurlDeps.sh /build/installCurlDeps.sh
# RUN chmod 500 /build/installCurlDeps.sh

COPY setup/build-src/curlTests.sh /build/curlTests.sh
RUN chmod 500 /build/curlTests.sh

COPY setup/build-src/newmanTestResultsHeader.html /build/newmanTestResultsHeader.html
RUN chmod 500 /build/newmanTestResultsHeader.html

COPY setup/build-src/newmanTestResultsFooter.html /build/newmanTestResultsFooter.html
RUN chmod 500 /build/newmanTestResultsFooter.html

COPY setup/build-src/dotcms-entrypoint.sh /build/dotcms-entrypoint.sh
RUN chmod 500 /build/dotcms-entrypoint.sh

COPY setup/build-src/stop-sidecar.sh /build/stop-sidecar.sh
RUN chmod 500 /build/stop-sidecar.sh

RUN mkdir -p /srv/utils /srv/templates /srv/config /srv/home
RUN chmod -R 666 /srv && find /srv/ -type d -exec chmod a+x {} \;

# OpenJDK distributed under GPLv2+Oracle Classpath Exception license (http://openjdk.java.net/legal/gplv2+ce.html)
# Alpine Linux packages distributed under various licenses including GPL-3.0+ (https://pkgs.alpinelinux.org/packages)
FROM openjdk:8-jdk-alpine

WORKDIR /srv

RUN apk --no-cache upgrade \
    && apk add --no-cache bash openssl ca-certificates gnupg grep sed tini nss git s6-dns \
    && update-ca-certificates 

RUN apk --no-cache add libc6-compat tomcat-native curl && apk add libsass --no-cache \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/

RUN apk --no-cache add nodejs=10.19.0-r0 npm=10.19.0-r0
RUN npm config set unsafe-perm true
RUN npm install -g newman
#RUN npm uninstall -g har-validator
RUN npm install -g newman-reporter-htmlextra@1.19.2
#RUN npm install -g highlight.js@10 --save-dev

# This is a nasty hack for libjsass, Alpine 3.9 no longer has a deprecated symlink in /lib
RUN [ ! -e /lib/ld-linux-x86-64.so.2 ] &&  ln -s $(readlink /lib64/ld-linux-x86-64.so.2) /lib/ld-linux-x86-64.so.2 || :

# Dockerize distributed under MIT license (https://github.com/jwilder/dockerize)
ENV DOCKERIZE_VERSION v0.6.0
RUN wget --quiet https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -xzf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz -C /usr/local/bin \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY --from=build-cms /srv/ /srv/
COPY --from=build-cms /build/ /build/
COPY ROOT/ /

# Make scripts runable
RUN find /srv/ -type f -name "*.sh" -exec chmod a+x {} \;

# Make plugin merging directories writable
RUN find /srv/templates -type d -exec chmod 770 {} \;

RUN mkdir -p /data/shared/assets && mkdir -p /data/local/dotsecure/license && chmod -R 660 /data && find /data/ -type d -exec chmod 770 {} \;

ENV SERVICE_DELAY_DEFAULT_MIN 1
ENV SERVICE_DELAY_DEFAULT_STEP 3
ENV SERVICE_DELAY_DEFAULT_MAX 30

#VOLUME /data/local

## Ports
# Direct connect
EXPOSE 8080
# Connect from proxy, HTTP/80, non-secure
EXPOSE 8081
# Connect from proxy, HTTPS/443, secure
EXPOSE 8082
# Java Debugging - must be configured via CMS_JAVA_OPTS
EXPOSE 8000
# Glowroot profiler - must be configured via CMS_JAVA_OPTS
EXPOSE 4000

ENTRYPOINT ["/build/dotcms-entrypoint.sh"]
CMD ["dotcms"]
