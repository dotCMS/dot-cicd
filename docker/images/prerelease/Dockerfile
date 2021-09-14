# OpenJDK distributed under GPLv2+Oracle Classpath Exception license (http://openjdk.java.net/legal/gplv2+ce.html)
# Alpine Linux packages distributed under various licenses including GPL-3.0+ (https://pkgs.alpinelinux.org/packages)
# dotCMS core distributed under GPLv3 license (https://github.com/dotCMS/core/blob/master/license.txt)
FROM openjdk:8u302-slim as dotcms-prerelease-process

LABEL com.dotcms.contact "info@dotcms.com"
LABEL com.dotcms.vendor "dotCMS LLC"
LABEL com.dotcms.description "dotCMS Content Management System"

ARG NODE_VERSION=12

WORKDIR /srv

COPY build-src/ /build/
RUN mv /build/entrypoint.sh /srv
RUN chmod 500 /srv/entrypoint.sh
RUN find /build/ -type f -name "*.sh" -exec chmod a+x {} \;

# Build env dependencies
RUN apt update \
    && apt upgrade -y \
    && apt install -y bash openssh-server openssh-client openssl ca-certificates gnupg grep sed tini curl git python3 \
      musl-dev dirmngr apt-transport-https lsb-release \
    && update-ca-certificates \
    && curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt -y install nodejs

ENTRYPOINT [ "/srv/entrypoint.sh" ]
