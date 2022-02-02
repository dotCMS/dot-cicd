# OpenJDK distributed under GPLv2+Oracle Classpath Exception license (http://openjdk.java.net/legal/gplv2+ce.html)
# Alpine Linux packages distributed under various licenses including GPL-3.0+ (https://pkgs.alpinelinux.org/packages)
FROM dotcms/dotcms-seed:22.01 as prepare-integration

LABEL com.dotcms.contact = "support@dotcms.com"
LABEL com.dotcms.vendor = "dotCMS LLC"
LABEL com.dotcms.description = "dotCMS Content Management System"

#  One of ["COMMIT", "TAG" ]
ARG BUILD_FROM=COMMIT
ENV BUILD_FROM=${BUILD_FROM}
ARG BUILD_ID=origin/master
ENV BUILD_ID=${BUILD_ID}
ARG BUILD_HASH
ENV BUILD_HASH=${BUILD_HASH}
ARG PG_VERSION=13
ENV PG_VERSION=$PG_VERSION
#  In order to run the integration test a license must be provideduploadEeJar.sh
ARG LICENSE_KEY

WORKDIR /srv

RUN apt-get update -y \
  && apt-get install -y gnupg gnupg1 gnupg2 wget lsb-release curl \
  && sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
  && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && apt-get update -y \
  && apt-get upgrade -y \
  && apt-get install -y postgresql-$PG_VERSION

# Location for assets, indexes and felix
RUN mkdir -p /custom \
    && mkdir -p /custom/assets \
    && mkdir -p /custom/dotsecure \
    && mkdir -p /custom/esdata \
    && mkdir -p /custom/felix \
    && mkdir -p /custom/output

# dotCMS core distributed under GPLv3 license (https://github.com/dotCMS/core/blob/master/license.txt)
COPY setup/build-src/checkout.sh /build/checkout.sh
RUN chmod 500 /build/checkout.sh && /build/checkout.sh ${BUILD_FROM} ${BUILD_ID}

COPY setup/build-src/overrideProperties.sh /build/overrideProperties.sh
RUN chmod 500 /build/overrideProperties.sh && /build/overrideProperties.sh

COPY setup/build-src/prepareTests.sh /build/prepareTests.sh
RUN chmod 500 /build/prepareTests.sh && /build/prepareTests.sh

COPY setup/build-src/prepareLicense.sh /build/prepareLicense.sh
RUN chmod 500 /build/prepareLicense.sh && /build/prepareLicense.sh ${LICENSE_KEY}

COPY setup/build-src/displayDebugData.sh /build/displayDebugData.sh
RUN chmod 500 /build/displayDebugData.sh && /build/displayDebugData.sh ${BUILD_FROM} ${BUILD_ID} ${BUILD_HASH}

# ===========================================
#  Copy our custom data to the source code  #
COPY setup/ROOT/ /build/src/core/dotCMS/src/
# ===========================================

VOLUME /db
VOLUME /custom/output

RUN mkdir /build/google
RUN mkdir /build/github

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

COPY setup/build-src/integrationTests.sh /build/integrationTests.sh
RUN chmod 500 /build/integrationTests.sh

COPY setup/build-src/unitTests.sh /build/unitTests.sh
RUN chmod 500 /build/unitTests.sh

COPY setup/build-src/entrypoint.sh /build/entrypoint.sh
RUN chmod 500 /build/entrypoint.sh

COPY setup/build-src/printBuildInfo.sh /build/printBuildInfo.sh
RUN chmod 500 /build/printBuildInfo.sh

COPY setup/build-src/curlTests.sh /build/curlTests.sh
RUN chmod 500 /build/curlTests.sh

ENTRYPOINT ["/build/entrypoint.sh"]
CMD ["integration"]
