FROM cicd-dotcms as build-cms

ARG BUILD_FROM
ENV BUILD_FROM=${BUILD_FROM}
ARG BUILD_ID
ENV BUILD_ID=${BUILD_ID}
ARG LICENSE_KEY

WORKDIR /srv

USER 0

#COPY setup/build-src/build_dotcms.sh /build/build_dotcms.sh
#COPY setup/build-src/common.sh /build/common.sh
#COPY setup/build-src/githubCommon.sh /build/githubCommon.sh
#COPY setup/build-src/prepareLicense.sh /build/prepareLicense.sh

#RUN find /build/ -type f -name "*.sh" -exec chmod a+x {} \;
#RUN ls -las /build/src
#RUN /build/build_dotcms.sh ${BUILD_FROM} ${BUILD_ID}
#RUN /build/prepareLicense.sh ${LICENSE_KEY}

#COPY setup/build-src/forkDotcms.sh /srv/forkDotcms.sh
#COPY setup/build-src/stopDotcms.sh /srv/stopDotcms.sh
#RUN find /srv/ -type f -name "*.sh" -exec chmod a+x {} \;

USER 1000000000
