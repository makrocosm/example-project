#
# Alpine x64 rootfs image
#
FROM alpine-common-rootfs
ARG TARGETARCH

# Kernel and modules from linux context specified in container.cfg's BUILD_CONTEXTS
COPY --from=linux boot /boot
COPY --from=linux lib /lib

# Platform-specific configuration
COPY etc /etc
COPY usr /usr

# Grub environment
RUN mkdir /boot/grub
RUN mkdir /efi
RUN --mount=type=cache,id=${TARGETARCH}/var/cache/apk,target=/var/cache/apk \
  apk add grub grub-bios grub-efi parted
