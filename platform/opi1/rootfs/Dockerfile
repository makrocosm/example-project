#
# Alpine Orange Pi One rootfs image
#
FROM mep-common-alpine-rootfs
ARG TARGETARCH

# Kernel and modules from linux context specified in container.cfg's BUILD_CONTEXTS
COPY --from=linux boot /boot
COPY --from=linux lib /lib

# Platform-specific configuration
COPY etc /etc

# u-boot environment
RUN mkdir /mnt/bootenv
RUN --mount=type=cache,id=${TARGETARCH}/var/cache/apk,target=/var/cache/apk \
  apk add u-boot-tools
