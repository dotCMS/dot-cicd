# OpenJDK distributed under GPLv2+Oracle Classpath Exception license (http://openjdk.java.net/legal/gplv2+ce.html)
# Alpine Linux packages distributed under various licenses including GPL-3.0+ (https://pkgs.alpinelinux.org/packages)
# dotCMS core distributed under GPLv3 license (https://github.com/dotCMS/core/blob/master/license.txt)
FROM adoptopenjdk/openjdk11:ubuntu as dotcms-release-process

LABEL com.dotcms.contact "info@dotcms.com"
LABEL com.dotcms.vendor "dotCMS LLC"
LABEL com.dotcms.description "dotCMS Content Management System"

ARG NODE_VERSION=16
ARG LOCAL_GRADLE_VERSION=6.9.3

WORKDIR /srv

COPY build-src/ /build/
RUN mv /build/entrypoint.sh /srv
RUN chmod 500 /srv/entrypoint.sh
RUN find /build/ -type f -name "*.sh" -exec chmod a+x {} \;

# Build env dependencies
RUN apt update \
    && apt upgrade -y \
    && apt install -y bash openssh-server openssh-client openssl ca-certificates gnupg grep sed unzip tini git wget python3 python3-pip jq musl-dev \
    && update-ca-certificates \
    && curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt -y install nodejs \
    && pip3 install --upgrade pip \
    && pip3 install s3cmd \
    && wget -q -O gradle.zip https://services.gradle.org/distributions/gradle-${LOCAL_GRADLE_VERSION}-bin.zip \
    && unzip -q gradle.zip

ENTRYPOINT [ "/srv/entrypoint.sh" ]
