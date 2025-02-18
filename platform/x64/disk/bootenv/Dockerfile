FROM mep-platform-x64-rootfs AS build
RUN grub-editenv /grubenv set default=0
RUN grub-editenv /grubenv set timeout=2

FROM scratch
COPY grub.cfg ./
COPY --from=build grubenv grubenv
