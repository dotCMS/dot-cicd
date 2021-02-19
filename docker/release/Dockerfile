# OpenJDK distributed under GPLv2+Oracle Classpath Exception license (http://openjdk.java.net/legal/gplv2+ce.html)
# Alpine Linux packages distributed under various licenses including GPL-3.0+ (https://pkgs.alpinelinux.org/packages)
# dotCMS core distributed under GPLv3 license (https://github.com/dotCMS/core/blob/master/license.txt)
FROM openjdk:8-jdk-alpine3.9 as dotcms-release

LABEL com.dotcms.contact "info@dotcms.com"
LABEL com.dotcms.vendor "dotCMS LLC"
LABEL com.dotcms.description "dotCMS Content Management System"

WORKDIR /srv

COPY build-src/ /build/
RUN mv /build/entrypoint.sh /srv
RUN chmod 500 /srv/entrypoint.sh
RUN find /build/ -type f -name "*.sh" -exec chmod a+x {} \;

# Build env dependencies
RUN apk update \
    && apk --no-cache upgrade \
    && apk add --no-cache bash openssh openssh-client openssl ca-certificates gnupg grep sed tini nss s6-dns git curl python3 py3-pip jq musl-dev \
    && update-ca-certificates \
    && apk --no-cache upgrade \
    && pip3 install --upgrade pip \
    && pip3 install s3cmd

RUN mkdir -p /build/src
RUN mkdir -p ~/.ssh

ENTRYPOINT [ "/srv/entrypoint.sh" ]