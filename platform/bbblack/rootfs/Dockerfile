#
# Alpine BeagleBone Black rootfs image
#
FROM mep-common-alpine-rootfs
ARG TARGETARCH

# Kernel and modules from linux context specified in container.cfg's BUILD_CONTEXTS
RUN mkdir /boot
COPY --from=linux boot/Image boot/*.dtb /boot
COPY --from=linux lib /lib

# Platform-specific configuration
COPY etc /etc

# u-boot environment
RUN mkdir /mnt/boot
RUN --mount=type=cache,id=${TARGETARCH}/var/cache/apk,target=/var/cache/apk \
  apk add u-boot-tools

# Prepare the firmware image boot script
COPY boot.cmd /boot/boot.cmd
RUN cd /boot \
  && mkimage -C none -A arm -T script -d boot.cmd boot.scr \
  && rm boot.cmd
