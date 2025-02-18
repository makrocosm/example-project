#
# Base image for the common rootfs and dev images.
# Install libraries and utilities here.
#

FROM alpine:3.20
ARG TARGETARCH

RUN --mount=type=cache,id=${TARGETARCH}/var/cache/apk,target=/var/cache/apk \
  apk upgrade \
  && apk add libuv
